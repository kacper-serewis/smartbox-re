#!/usr/bin/env python3
"""Build and verify the experimental HW501/v131 mirroring update archive."""
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
from build_recovery_firmware import BUNDLE, install_recovery, verify_bundle, verify_tests


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--density', type=float, choices=(125, 137.5, 150), default=137.5)
    parser.add_argument('--recovery-bundle', type=Path, default=BUNDLE)
    args = parser.parse_args()
    verify_bundle(args.recovery_bundle)
    verify_tests(args.recovery_bundle)
    build = ROOT / 'firmwares/research/mirroring-riscv'
    mode = ROOT / 'firmwares/experiments/connection-mode'
    manifest = json.loads((build / 'manifest.json').read_text())
    for name, digest in manifest['integration_sources'].items():
        if sha((ROOT / name).read_bytes()) != digest:
            raise ValueError(f'Receiver source changed; rebuild before packaging: {name}')
    for name in ('libsmartbox-mirror.so', 'smartbox-launch'):
        if sha((build / name).read_bytes()) != manifest['files'][name]['sha256']:
            raise ValueError(f'Build manifest mismatch: {name}')
    output = ROOT / f'firmwares/experiments/hw501_131_mirroring_density{args.density:g}'
    output.mkdir(parents=True, exist_ok=True)
    # Never leave validation for an older archive alongside a newly built image.
    (output / 'validation.json').unlink(missing_ok=True)
    source_manifest = json.loads((SOURCE / 'manifest.json').read_text())
    original = (SOURCE / 'rootfs/bin/CPAAProxyEx').read_bytes()
    modified, density = patch(original, density=args.density)
    with tempfile.TemporaryDirectory(prefix='smartbox-mirror-image-') as temporary:
        temp = Path(temporary); tree = temp / 'tree'; baseline = temp / 'baseline'
        listing = subprocess.check_output(['unsquashfs', '-lln', str(SOURCE / 'archive/app.img')], text=True)
        owners = {line.split()[1] for line in listing.splitlines() if re.match(r'^[dl-][rwxstST-]{9} ', line)}
        if len(owners) != 1: raise ValueError('Unexpected stock ownership')
        uid, gid = next(iter(owners)).split('/')
        subprocess.run(['unsquashfs', '-no-progress', '-d', str(baseline), str(SOURCE / 'archive/app.img')], check=True, capture_output=True, umask=0)
        shutil.copytree(baseline, tree, symlinks=True)
        timestamp = next(m['mtime'] for m in source_manifest['members'] if m['name'] == 'app.img')
        def install(relative, data, mode_bits=0o644):
            target = tree / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data); target.chmod(mode_bits); os.utime(target, (timestamp, timestamp))
        install('stock/CPAAProxyEx', modified, 0o775)
        recovery = install_recovery(tree, baseline, args.recovery_bundle, install, (build / 'smartbox-launch').read_bytes())
        install('lib/libsmartbox-mirror.so', (build / 'libsmartbox-mirror.so').read_bytes(), 0o755)
        install('bin/smartbox-mode', (mode / 'bin/smartbox-mode').read_bytes(), 0o755)
        # The recovery bootstrap now occupies bin/CPAAProxyEx; driver requests
        # must still reach the actual mirroring launcher.
        (tree / 'bin/smartbox-mode-driver').symlink_to('../launch/CPAAProxyEx')
        for name in ('index.html', 'mode.js'):
            install('mode-web/' + name, (mode / 'web' / name).read_bytes())
        for name in ('index_cptowlcp.html', 'index_cptowlcp_en.html'):
            install('web/' + name, (mode / 'stock-web' / name).read_bytes(), (baseline / 'web' / name).stat().st_mode & 0o7777)
        licenses = [('UxPlay', ROOT / 'firmwares/research/UxPlay/LICENSE'),
                    ('playfair', ROOT / 'firmwares/research/UxPlay/lib/playfair/LICENSE.md'),
                    ('llhttp', ROOT / 'firmwares/research/UxPlay/lib/llhttp/LICENSE-MIT'),
                    ('libplist', ROOT / 'firmwares/research/mirror-deps/libplist-2.7.0/COPYING'),
                    ('libplist-LGPL', ROOT / 'firmwares/research/mirror-deps/libplist-2.7.0/COPYING.LESSER')]
        for name, path in licenses:
            if not path.is_file(): raise ValueError(f'Missing license: {path}')
            install('mirror-licenses/' + name + '.txt', path.read_bytes())
        install('mirror-licenses/sources.json', json.dumps(manifest, indent=2).encode())
        old, new = inventory(baseline), inventory(tree)
        changed = sorted(k for k in old if new.get(k) != old[k])
        expected = ['bin/CPAAProxyEx', 'web/index_cptowlcp.html', 'web/index_cptowlcp_en.html']
        if changed != expected: raise ValueError(f'Unexpected stock changes: {changed}')
        for path in tree.rglob('*'):
            if str(path.relative_to(tree)) not in old and not path.is_symlink():
                os.utime(path, (timestamp, timestamp))
                if path.is_dir(): path.chmod(0o755)
        new = inventory(tree)
        image = temp / 'app.img'
        result = subprocess.run(['mksquashfs', str(tree), str(image), '-comp', 'xz', '-b', '262144', '-noappend', '-no-progress', '-no-xattrs', '-force-uid', uid, '-force-gid', gid, '-mkfs-time', str(timestamp)], capture_output=True, text=True)
        (output / 'build.log').write_text(result.stdout + result.stderr); result.check_returncode()
        if image.stat().st_size > 0x500000: raise ValueError('Image exceeds observed 5 MiB app partition')
        extracted = temp / 'verified'
        result = subprocess.run(['unsquashfs', '-no-progress', '-d', str(extracted), str(image)], capture_output=True, text=True, umask=0)
        result.check_returncode(); (output / 'verification.log').write_text(result.stdout + result.stderr)
        if inventory(extracted) != new: raise ValueError('Re-extracted filesystem differs from inputs')
        image_data = image.read_bytes(); md5 = (hashlib.md5(image_data).hexdigest() + '\n').encode()
        archive = output / 'hw501_131.tar'
        with tarfile.open(SOURCE / 'hw501_131.tar', 'r:') as source, tarfile.open(archive, 'w', format=tarfile.GNU_FORMAT) as target:
            for name, data in [('app.img', image_data), ('appmd5sum.txt', md5)]:
                member = source.getmember(name); member.size = len(data); target.addfile(member, io.BytesIO(data))
        (output / 'archive').mkdir(exist_ok=True)
        shutil.copy2(image, output / 'archive/app.img'); (output / 'archive/appmd5sum.txt').write_bytes(md5)
        raw = archive.read_bytes(); step = 32768
        release = {'version': 131, 'hardware': 501, 'label': f'EXPERIMENTAL mirroring v131 density{args.density:g}',
                   'flashable': True, 'hardware_validated': False, 'built_at': datetime.now(timezone.utc).isoformat(),
                   'size': len(raw), 'sha256': sha(raw), 'parent_archive_sha256': source_manifest['sha256'],
                   'app_size': len(image_data), 'app_partition_limit': 0x500000, 'app_md5': md5.decode().strip(),
                   'chunk_metadata': {'result': 1, 'version': 131, 'pos': 0, 'itemsize': step, 'count': (len(raw) + step - 1) // step, 'filesize': len(raw), 'datasize': step},
                   'changed_stock_files': changed, 'added_files': sorted(set(new) - set(old)), 'density_patch': density,
                   'receiver_build': manifest,
                   'recovery_build': recovery,
                   'limitations': ['No physical dongle/Corsa mirroring test yet', 'No full iOS pairing test yet',
                                   'Video passthrough only; no audio, touch, scaling, or rotation adaptation',
                                   'Head unit acceptance of phone-selected H.264 geometry is unverified'],
                   'recovery': 'Independent RAM service, key-only SSH, tunneled recovery page and updater; persistent experiment latch; not hardware validated',
                   'verification': 'Image fits partition; re-extraction matches inputs; stock files unchanged except launcher and two configuration pages; relocated stock app has density metadata patch.'}
        (output / 'manifest.json').write_text(json.dumps(release, indent=2) + '\n')
        load_release(output)
        (output / 'SHA256SUMS').write_text(f'{release["sha256"]}  hw501_131.tar\n')
        print(f'Built experimental update: {archive}\nImage: {len(image_data):,} / 5,242,880 bytes\nSHA256: {release["sha256"]}\nPhysical mirroring validation remains outstanding.')


if __name__ == '__main__':
    main()
