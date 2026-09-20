#!/usr/bin/env python3
"""Build the receiver against HW501's stock crypto/DNS libraries and glibc 2.34."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
DEPS = ROOT / 'firmwares/research/mirror-deps'
BUILD = ROOT / 'firmwares/research/mirroring-riscv'
TC = 'riscv32-ilp32d--glibc--bleeding-edge-2021.11-1'
SOURCES = {
    f'{TC}.tar.bz2': (f'https://toolchains.bootlin.com/downloads/releases/toolchains/riscv32-ilp32d/tarballs/{TC}.tar.bz2', '63defd144fdb1d40712316e2c3acd37275d6407b52d70efcd36e7f7129b4a0d0'),
    'libplist-2.7.0.tar.bz2': ('https://github.com/libimobiledevice/libplist/releases/download/2.7.0/libplist-2.7.0.tar.bz2', '7ac42301e896b1ebe3c654634780c82baa7cb70df8554e683ff89f7c2643eb8b'),
    'openssl-1.1.1w.tar.gz': ('https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz', 'cf3098950cb4d853ad95c0841f1f9c6d3dc102dccfcacd521d93925208b76ac8'),
    'dns_sd.h': ('https://raw.githubusercontent.com/apple-oss-distributions/mDNSResponder/mDNSResponder-2200.140.11/mDNSShared/dns_sd.h', '85e84206de72f95570ed3d4abb912af5ba522bb41752ab35636e63f672f1beb5'),
}


def run(args):
    subprocess.run(args, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--setup', action='store_true')
    args = parser.parse_args()
    DEPS.mkdir(parents=True, exist_ok=True)
    BUILD.mkdir(parents=True, exist_ok=True)
    for name, (url, digest) in SOURCES.items():
        path = DEPS / name
        if not path.exists() and args.setup:
            temporary = path.with_suffix('.download')
            urllib.request.urlretrieve(url, temporary)
            if hashlib.sha256(temporary.read_bytes()).hexdigest() != digest:
                raise RuntimeError(f'Checksum mismatch: {name}')
            temporary.rename(path)
        if not path.exists() or hashlib.sha256(path.read_bytes()).hexdigest() != digest:
            raise RuntimeError(f'Missing/invalid source {name}; use --setup')
        if name.endswith(('.bz2', '.gz')):
            directory = name.removesuffix('.tar.bz2').removesuffix('.tar.gz')
            if not (DEPS / directory).exists():
                with tarfile.open(path) as archive:
                    archive.extractall(DEPS, filter='data')
    upstream = ROOT / 'firmwares/research/UxPlay'
    rev = subprocess.check_output(['git', '-C', str(upstream), 'rev-parse', 'HEAD'], text=True).strip()
    if rev != '57ea83411d5f7e0b38c5841987439340543f025c' or subprocess.check_output(['git', '-C', str(upstream), 'status', '--porcelain']):
        raise RuntimeError('Expected the pinned, unmodified UxPlay checkout')
    if args.setup:
        run(['docker', 'build', '--platform', 'linux/amd64', '-f', str(ROOT / 'experiments/mirroring/Dockerfile'), '-t', 'smartbox-mirror-builder:local', str(ROOT / 'experiments/mirroring')])
    command = ['docker', 'run', '--rm', '--platform', 'linux/amd64', '--network', 'none',
               '-v', f'{ROOT}:/work:ro', '-v', f'{DEPS}:/deps', '-v', f'{BUILD}:/build',
               '-w', '/build', 'smartbox-mirror-builder:local', 'sh', '/work/experiments/mirroring/build-riscv.sh']
    with (BUILD / 'build.log').open('w') as log:
        result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
    if result.returncode:
        print((BUILD / 'build.log').read_text()[-6000:])
        result.check_returncode()
    manifest = {'toolchain': TC, 'glibc': '2.34', 'uxplay_commit': rev,
                'sources': {n: {'url': u, 'sha256': h} for n, (u, h) in SOURCES.items()},
                'stock_libraries': ['libcrypto.so.1.1', 'libdns_sd.so'], 'files': {}}
    manifest['integration_sources'] = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                                       for p in sorted((ROOT / 'experiments/mirroring').iterdir())
                                       if p.suffix in ('.c', '.h', '.sh', '.map')}
    for name in ('mirror-capture', 'test-capture', 'test-transport', 'libsmartbox-mirror.so', 'smartbox-launch', 'test-native-video', 'test-device-bridge', 'replay-bridge', 'replay-native'):
        path = BUILD / name
        manifest['files'][name] = {'size': path.stat().st_size, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
    (BUILD / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(manifest['files'], indent=2))


if __name__ == '__main__':
    main()
