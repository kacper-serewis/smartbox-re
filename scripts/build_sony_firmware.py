#!/usr/bin/env python3
"""Build and re-extract the experimental Sony-only HW501 v131 audio image offline."""
import argparse
from datetime import datetime, timezone
import hashlib
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import tempfile

from build_display_firmware import inventory, sha
from disassemble_evidence import annotate
from sony_audio_patch import patch, PROFILE, HOOK, CONTINUE, STUB
from update_device import load_release

ROOT = Path(__file__).resolve().parents[1]
STOCK_ARCHIVE_SHA = 'bbf89a7aaa399297609d1543fd0c977c6848c6284ecaa53e0fb4482af6a86466'
STOCK_APP_SHA = '60c9120d289cfe9053667628b639367e27393fd805ddef4e7d68ecb079738c49'
PARTITION_LIMIT = 0x500000


def build(source, output, report):
    for tool in ('mksquashfs', 'unsquashfs'):
        if not shutil.which(tool):
            raise ValueError(f'Missing tool: {tool}')
    archive_data = (source / 'hw501_131.tar').read_bytes()
    if sha(archive_data) != STOCK_ARCHIVE_SHA:
        raise ValueError('Expected the exact archived stock HW501 v131 update')
    with tarfile.open(fileobj=io.BytesIO(archive_data), mode='r:') as archive:
        if sorted(m.name for m in archive.getmembers()) != ['app.img', 'appmd5sum.txt']:
            raise ValueError('Unexpected stock archive contents')
        entries = {name: archive.getmember(name) for name in ('app.img', 'appmd5sum.txt')}
        if not all(entry.isfile() for entry in entries.values()):
            raise ValueError('Update members must be regular files')
        stock_app = archive.extractfile('app.img').read()
        md5 = archive.extractfile('appmd5sum.txt').read().decode().strip()
    if sha(stock_app) != STOCK_APP_SHA or hashlib.md5(stock_app).hexdigest() != md5:
        raise ValueError('Stock app image verification failed')

    with tempfile.TemporaryDirectory(prefix='smartbox-sony-') as directory:
        temp = Path(directory)
        source_image = temp / 'stock.img'
        source_image.write_bytes(stock_app)
        baseline, tree, verified = (temp / name for name in ('baseline', 'tree', 'verified'))
        listing = subprocess.check_output(['unsquashfs', '-lln', str(source_image)], text=True)
        owners = {line.split()[1] for line in listing.splitlines() if re.match(r'^[dl-][rwxstST-]{9} ', line)}
        if len(owners) != 1:
            raise ValueError('Stock filesystem ownership is not uniform')
        uid, gid = next(iter(owners)).split('/')
        subprocess.run(['unsquashfs', '-no-progress', '-d', str(baseline), str(source_image)],
                       check=True, capture_output=True, umask=0)
        shutil.copytree(baseline, tree, symlinks=True)
        executable = tree / 'bin/CPAAProxyEx'
        modified, details = patch(executable.read_bytes())
        times = executable.stat()
        executable.write_bytes(modified)
        os.utime(executable, ns=(times.st_atime_ns, times.st_mtime_ns))
        old, new = inventory(baseline), inventory(tree)
        if old.keys() != new.keys() or [name for name in old if old[name] != new[name]] != ['bin/CPAAProxyEx']:
            raise ValueError('Unexpected change to stock filesystem')
        app = temp / 'app.img'
        result = subprocess.run([
            'mksquashfs', str(tree), str(app), '-comp', 'xz', '-b', '262144',
            '-noappend', '-no-progress', '-no-xattrs', '-force-uid', uid, '-force-gid', gid,
            '-mkfs-time', str(entries['app.img'].mtime),
        ], check=True, capture_output=True, text=True)
        build_log = result.stdout + result.stderr
        if app.stat().st_size > PARTITION_LIMIT:
            raise ValueError('App exceeds the observed 5 MiB application partition')
        result = subprocess.run(['unsquashfs', '-no-progress', '-d', str(verified), str(app)],
                                check=True, capture_output=True, text=True, umask=0)
        verify_log = result.stdout + result.stderr
        if inventory(verified) != new:
            raise ValueError('Re-extracted filesystem does not match build inputs')
        if subprocess.check_output(['unsquashfs', '-lln', str(app)], text=True) != listing:
            raise ValueError('Filesystem ownership, permissions, sizes, or timestamps changed')
        app_data = app.read_bytes()
        checksum = (hashlib.md5(app_data).hexdigest() + '\n').encode()
        output_tar = temp / 'hw501_131.tar'
        with tarfile.open(output_tar, 'w', format=tarfile.GNU_FORMAT) as archive:
            for name, data in [('app.img', app_data), ('appmd5sum.txt', checksum)]:
                entry = entries[name]
                entry.size = len(data)
                archive.addfile(entry, io.BytesIO(data))
        raw = output_tar.read_bytes()
        chunk = 32768
        manifest = {
            'version': 131, 'hardware': 501, 'label': f'EXPERIMENTAL {PROFILE}',
            'built_at': datetime.now(timezone.utc).isoformat(),
            'source': 'Local patch of archived stock HW501 v131',
            'size': len(raw), 'sha256': sha(raw), 'parent_archive_sha256': STOCK_ARCHIVE_SHA,
            'app_size': len(app_data), 'app_partition_limit': PARTITION_LIMIT,
            'app_sha256': sha(app_data), 'app_md5': checksum.decode().strip(),
            'chunk_metadata': {'result': 1, 'version': 131, 'pos': 0, 'itemsize': chunk,
                               'count': (len(raw) + chunk - 1) // chunk,
                               'filesize': len(raw), 'datasize': chunk},
            'changed_files': ['bin/CPAAProxyEx'], 'patch': details,
            'verification': 'Re-extracted image matches inputs; filesystem metadata retained; '
                            'only CPAAProxyEx content changed. Hardware validation pending.',
            'runtime_tested': False,
        }
        (temp / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        # Exercise the actual updater's local archive loader, without a device.
        checked, checked_raw = load_release(temp)
        if checked_raw != raw or checked != manifest:
            raise ValueError('Updater loader did not return the verified release')
        output.mkdir(parents=True, exist_ok=True)
        (output / 'archive').mkdir(exist_ok=True)
        report.mkdir(parents=True, exist_ok=True)
        shutil.copy2(output_tar, output / output_tar.name)
        shutil.copy2(temp / 'manifest.json', output / 'manifest.json')
        shutil.copy2(app, output / 'archive/app.img')
        (output / 'archive/appmd5sum.txt').write_bytes(checksum)
        (output / 'CPAAProxyEx.patched').write_bytes(modified)
        (output / 'build.log').write_text(build_log)
        (output / 'verification.log').write_text(verify_log)
        (report / 'build.json').write_text(json.dumps(manifest, indent=2) + '\n')
        objdump = shutil.which('gobjdump') or '/opt/homebrew/opt/binutils/bin/gobjdump'
        if Path(objdump).is_file():
            evidence = report / 'evidence'
            evidence.mkdir(exist_ok=True)
            for name, start, stop in [
                ('stock-car-format-parser', 0x2ac94, 0x2adc4),
                ('stock-format-getter', 0x28420, 0x2842c),
                ('stock-pcm-rate-mapping', 0x2375c, 0x23858),
                ('stock-media-pcm-offer', 0x4d41a, 0x4d47c),
                ('stock-media-aac-offer', 0x4d5f6, 0x4d680),
                ('patched-car-format-hook', HOOK, CONTINUE),
                ('patched-media-pcm-offer', 0x4d41a, 0x4d47c),
                ('patched-media-aac-offer', 0x4d5f6, 0x4d680),
                ('patched-stub', STUB, STUB + details['instruction_bytes']),
            ]:
                path = executable if name.startswith('patched') else baseline / 'bin/CPAAProxyEx'
                # Hook lives in expanded PT_LOAD padding, outside .text.
                command = [objdump, '-D' if name == 'patched-stub' else '-d', '-C',
                           f'--start-address={start}', f'--stop-address={stop}', str(path)]
                if name == 'patched-stub':
                    hook_file = temp / 'hook.bin'
                    hook_file.write_bytes(modified[STUB - 0x10000:STUB - 0x10000 + details['instruction_bytes']])
                    command = [objdump, '-D', '-b', 'binary', '-m', 'riscv:rv32',
                               f'--adjust-vma={STUB}', str(hook_file)]
                text = subprocess.check_output(command, text=True)
                (evidence / f'{name}.asm').write_text(annotate(path, text))
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT / 'firmwares/hw501/131')
    parser.add_argument('--output', type=Path, default=ROOT / 'firmwares/experiments/hw501_131_sony_ax1005db_audio_v1')
    args = parser.parse_args()
    manifest = build(args.source, args.output, ROOT / 'reports/audio/sony-build')
    print(f'Built: {args.output / "hw501_131.tar"}')
    print(f'App image: {manifest["app_size"]:,} / {PARTITION_LIMIT:,} bytes')
    print(f'SHA256: {manifest["sha256"]}')
    print('Verified offline; Sony playback and boot have not been tested. No device was flashed.')


if __name__ == '__main__':
    main()
