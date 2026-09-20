#!/usr/bin/env python3
"""Package recovery with HW501 v131 density137.5; never uploads or flashes."""
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

from build_display_firmware import ROOT, SOURCE, inventory, sha
from display_patch import patch
from update_device import load_release

BUNDLE = ROOT / 'firmwares/research/recovery-build/bundle'


def verify_bundle(bundle):
    manifest = json.loads((bundle / 'manifest.json').read_text())
    if manifest.get('kind') != 'recovery_bundle':
        raise ValueError('Expected a recovery bundle')
    for name, expected in manifest['source_hashes'].items():
        if sha((ROOT / name).read_bytes()) != expected:
            raise ValueError(f'Recovery source changed; rebuild: {name}')
    for name, expected in manifest['files'].items():
        if sha((bundle / name).read_bytes()) != expected:
            raise ValueError(f'Recovery bundle hash mismatch: {name}')
    for name in ('recoveryd', 'dropbearmulti'):
        data = (bundle / name).read_bytes()
        if data[:6] != b'\x7fELF\x01\x01' or int.from_bytes(data[18:20], 'little') != 243:
            raise ValueError(f'Expected little-endian RV32 ELF: {name}')
        # All rescue components must be static: no interpreter or shared libs.
        phoff = int.from_bytes(data[28:32], 'little')
        phsize = int.from_bytes(data[42:44], 'little')
        count = int.from_bytes(data[44:46], 'little')
        if not phsize or any(int.from_bytes(data[phoff+i*phsize:phoff+i*phsize+4], 'little') in (2, 3) for i in range(count)):
            raise ValueError(f'Recovery executable is not static: {name}')
    # Key files must be restricted to the intended tunnel destinations.
    key = (bundle / 'keys/authorized_keys').read_text()
    if 'permitopen="127.0.0.1:8083"' not in key or 'permitopen="127.0.0.1:8082"' not in key:
        raise ValueError('Missing recovery SSH forwarding restrictions')
    return manifest


def verify_tests(bundle):
    report = json.loads((bundle.parent / 'tests.json').read_text())
    if not report.get('passed') or not report.get('full_suite'):
        raise ValueError('Run the complete recovery test suite before packaging')
    for key, path in [('source_sha256', ROOT / 'experiments/recovery/recovery.c'),
                      ('test_source_sha256', ROOT / 'scripts/test_recovery.py'),
                      ('bundle_manifest_sha256', bundle / 'manifest.json')]:
        if report.get(key) != sha(path.read_bytes()):
            raise ValueError('Recovery tests are stale; rebuild and test before packaging')


def install_recovery(tree, baseline, bundle, install, launch_app):
    manifest = verify_bundle(bundle)
    install('launch/CPAAProxyEx', launch_app, 0o755)
    install('bin/CPAAProxyEx', (bundle / 'recoveryd').read_bytes(), 0o755)
    for name in manifest['files']:
        install('recovery/' + name, (bundle / name).read_bytes(), 0o755 if name in ('recoveryd', 'dropbearmulti') else 0o600)
    install('recovery/manifest.json', json.dumps(manifest, indent=2).encode())
    install('recovery/UpdateServer', (baseline / 'bin/UpdateServer').read_bytes(), 0o755)
    for path in (baseline / 'web').rglob('*'):
        if path.is_symlink():
            raise ValueError('Unexpected symlink in stock updater web files')
        if path.is_file():
            install('recovery/web/' + str(path.relative_to(baseline / 'web')), path.read_bytes())
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--recovery-bundle', type=Path, default=BUNDLE)
    args = parser.parse_args()
    verify_bundle(args.recovery_bundle)
    verify_tests(args.recovery_bundle)
    output = ROOT / 'firmwares/experiments/hw501_131_recovery_density137.5'
    output.mkdir(parents=True, exist_ok=True)
    (output / 'manifest.json').unlink(missing_ok=True)
    original_manifest = json.loads((SOURCE / 'manifest.json').read_text())
    modified, density = patch((SOURCE / 'rootfs/bin/CPAAProxyEx').read_bytes(), density=137.5)
    with tempfile.TemporaryDirectory(prefix='smartbox-recovery-image-') as temporary:
        temp = Path(temporary)
        baseline, tree = temp / 'baseline', temp / 'tree'
        listing = subprocess.check_output(['unsquashfs', '-lln', str(SOURCE / 'archive/app.img')], text=True)
        owners = {line.split()[1] for line in listing.splitlines() if re.match(r'^[dl-][rwxstST-]{9} ', line)}
        if len(owners) != 1:
            raise ValueError('Unexpected stock ownership')
        uid, gid = next(iter(owners)).split('/')
        subprocess.run(['unsquashfs', '-no-progress', '-d', str(baseline), str(SOURCE / 'archive/app.img')], check=True, capture_output=True, umask=0)
        shutil.copytree(baseline, tree, symlinks=True)
        stamp = next(m['mtime'] for m in original_manifest['members'] if m['name'] == 'app.img')

        def install(name, data, mode=0o644):
            p = tree / name
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_bytes(data)
            p.chmod(mode)
            os.utime(p, (stamp, stamp))

        install('stock/CPAAProxyEx', modified, 0o755)
        recovery = install_recovery(tree, baseline, args.recovery_bundle, install, modified)
        old, new = inventory(baseline), inventory(tree)
        changed = sorted(p for p in old if old[p] != new.get(p))
        if changed != ['bin/CPAAProxyEx']:
            raise ValueError(f'Unexpected stock changes: {changed}')
        for path in tree.rglob('*'):
            if path.is_dir() and str(path.relative_to(tree)) not in old:
                path.chmod(0o755)
            os.utime(path, (stamp, stamp))
        new = inventory(tree)
        image = temp / 'app.img'
        result = subprocess.run(['mksquashfs', str(tree), str(image), '-comp', 'xz', '-b', '262144', '-noappend', '-no-progress', '-no-xattrs', '-force-uid', uid, '-force-gid', gid, '-mkfs-time', str(stamp)], capture_output=True, text=True)
        (output / 'build.log').write_text(result.stdout + result.stderr)
        result.check_returncode()
        if image.stat().st_size > 0x500000:
            raise ValueError('Recovery image exceeds the observed 5 MiB application partition')
        verified = temp / 'verified'
        subprocess.run(['unsquashfs', '-no-progress', '-d', str(verified), str(image)], check=True, capture_output=True, umask=0)
        if inventory(verified) != new:
            raise ValueError('Re-extracted image does not match inputs')
        data = image.read_bytes()
        md5 = (hashlib.md5(data).hexdigest() + '\n').encode()
        archive = output / 'hw501_131.tar'
        with tarfile.open(SOURCE / 'hw501_131.tar') as source, tarfile.open(archive, 'w', format=tarfile.GNU_FORMAT) as target:
            for name, content in [('app.img', data), ('appmd5sum.txt', md5)]:
                entry = source.getmember(name)
                entry.size = len(content)
                target.addfile(entry, io.BytesIO(content))
        raw = archive.read_bytes()
        release = {'version': 131, 'hardware': 501, 'label': 'EXPERIMENTAL recovery + density137.5',
                   'flashable': True, 'hardware_validated': False, 'built_at': datetime.now(timezone.utc).isoformat(),
                   'sha256': sha(raw), 'size': len(raw), 'app_size': len(data), 'app_partition_limit': 0x500000,
                   'parent_archive_sha256': original_manifest['sha256'], 'app_md5': md5.decode().strip(),
                   'chunk_metadata': {'result': 1, 'version': 131, 'pos': 0, 'itemsize': 32768, 'count': (len(raw)+32767)//32768, 'filesize': len(raw), 'datasize': 32768},
                   'density_patch': density, 'recovery_build': recovery, 'changed_stock_files': changed,
                   'added_files': sorted(set(new)-set(old)),
                   'limitations': ['Application-partition recovery only; no independent boot recovery',
                                   'Wi-Fi independence, login with the device account database, RAM budget and physical restore require hardware validation',
                                   'Stock restore removes SSH/recovery; owner public key included, host private key generated on device']}
        (output / 'manifest.json').write_text(json.dumps(release, indent=2) + '\n')
        (output / 'SHA256SUMS').write_text(f'{sha(raw)}  hw501_131.tar\n')
        load_release(output)
        print(f'Built and re-extracted: {archive}\nImage: {len(data):,} / 5,242,880 bytes\nNo device contacted; hardware validation remains outstanding.')


if __name__ == '__main__':
    main()
