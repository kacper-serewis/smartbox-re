#!/usr/bin/env python3
"""Build a pinned static RV32 SSH/recovery bundle; never contacts the adapter."""
import argparse
import base64
import hashlib
import json
from pathlib import Path
import shutil
import struct
import subprocess
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'firmwares/research/recovery-build'
VERSION = '2026.94'
URL = f'https://dropbear.nl/mirror/releases/dropbear-{VERSION}.tar.bz2'
SHA = 'e098034a843699200c8c977a991fff73159735bf795d5f72ef672c41a6b1ae81'
TC = 'riscv32-ilp32d--glibc--bleeding-edge-2021.11-1'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def public_key(path):
    fields = path.read_text().strip().split()
    if len(fields) < 2 or fields[0] != 'ssh-ed25519' or '\n' in path.read_text().strip():
        raise ValueError('Expected one Ed25519 public key, without authorized_keys options')
    raw = base64.b64decode(fields[1], validate=True)
    if len(raw) != 51 or raw[:19] != struct.pack('>I', 11) + b'ssh-ed25519' + struct.pack('>I', 32):
        raise ValueError('Invalid Ed25519 public key encoding')
    # Keep shell access; restrict forwarded connections to the two rescue HTTP ports.
    return ('no-agent-forwarding,no-X11-forwarding,permitopen="127.0.0.1:8083",'
            'permitopen="127.0.0.1:8082" ssh-ed25519 ' + fields[1] + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--authorized-key', type=Path, required=True)
    parser.add_argument('--deps', type=Path, default=ROOT / 'firmwares/research/mirror-deps')
    parser.add_argument('--setup', action='store_true', help='download pinned Dropbear source')
    args = parser.parse_args()
    key = public_key(args.authorized_key)
    BUILD.mkdir(parents=True, exist_ok=True)
    archive = BUILD / f'dropbear-{VERSION}.tar.bz2'
    if not archive.exists() and args.setup:
        temp = archive.with_suffix('.download')
        urllib.request.urlretrieve(URL, temp)
        if digest(temp) != SHA:
            raise ValueError('Dropbear source checksum mismatch')
        temp.rename(archive)
    if not archive.exists() or digest(archive) != SHA:
        raise ValueError('Missing verified Dropbear source; use --setup')
    source = BUILD / f'dropbear-{VERSION}'
    # Always unpack fresh so local upstream changes cannot enter a release.
    shutil.rmtree(source, ignore_errors=True)
    with tarfile.open(archive) as tf:
        tf.extractall(BUILD, filter='data')
    shutil.copy2(ROOT / 'experiments/recovery/dropbear-options.h', source / 'localoptions.h')
    output = BUILD / 'bundle'
    shutil.rmtree(output, ignore_errors=True)
    (output / 'keys').mkdir(parents=True)
    (output / 'keys/authorized_keys').write_text(key)
    (output / 'keys/authorized_keys').chmod(0o600)
    shutil.copy2(ROOT / 'experiments/recovery/index.html', output / 'index.html')
    shutil.copy2(source / 'LICENSE', output / 'Dropbear-LICENSE')
    command = ['docker', 'run', '--rm', '--platform', 'linux/amd64', '--network', 'none',
               '--read-only', '--tmpfs', '/tmp:rw,exec,nosuid,size=128m',
               '-v', f'{args.deps.resolve()}:/deps:ro', '-v', f'{ROOT}:/work:ro',
               '-v', f'{BUILD}:/build', 'smartbox-mirror-builder:local',
               'sh', '/work/experiments/recovery/build.sh']
    with (BUILD / 'build.log').open('w') as log:
        result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
    if result.returncode:
        print((BUILD / 'build.log').read_text()[-5000:])
        result.check_returncode()
    manifest = {'kind': 'recovery_bundle', 'flashable': False, 'hardware_validated': False,
                'dropbear': {'version': VERSION, 'url': URL, 'sha256': SHA}, 'toolchain': TC,
                'source_hashes': {str(p.relative_to(ROOT)): digest(p) for p in sorted((ROOT / 'experiments/recovery').iterdir()) if p.is_file()},
                'files': {str(p.relative_to(output)): digest(p) for p in sorted(output.rglob('*')) if p.is_file()}}
    (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'Built static RV32 recovery bundle: {output}')


if __name__ == '__main__':
    main()
