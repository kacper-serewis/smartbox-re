#!/usr/bin/env python3
"""Verify the exact USB probe build; --install copies it but never loads it."""
import argparse
import hashlib
import os
from pathlib import Path
import platform
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'firmwares/research/mac-usb-probe/SmartBoxUSBProbe.kext'
DESTINATION = Path('/Library/Extensions/SmartBoxUSBProbe.kext')
# Pin the reviewed artifact, not a mutable manifest supplied by the caller.
EXPECTED = {
    'Contents/MacOS/SmartBoxUSBProbe': '982131f02c6ffaa0aca02ca339ecba5f7a829fc0f8d84a4893a0a5655a984c4b',
    'Contents/Info.plist': 'e04cb5102ecc8fd3b508b8f5efb94fb7cc0ce08c18a08599288c4ef372a5ca0d',
}


def verify(bundle):
    if bundle.is_symlink() or not bundle.is_dir():
        raise ValueError(f'Expected a real bundle directory: {bundle}')
    files = set()
    for path in bundle.rglob('*'):
        if path.is_symlink():
            raise ValueError(f'Symlink rejected: {path}')
        if path.is_file():
            name = path.relative_to(bundle).as_posix()
            if name not in EXPECTED or hashlib.sha256(path.read_bytes()).hexdigest() != EXPECTED[name]:
                raise ValueError(f'Unexpected or modified artifact: {path}')
            files.add(name)
        elif not path.is_dir():
            raise ValueError(f'Special file rejected: {path}')
    if files != set(EXPECTED):
        raise ValueError('Bundle is incomplete')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--install', action='store_true')
    args = parser.parse_args()
    if platform.system() != 'Darwin':
        parser.error('This bundle targets macOS')
    model = subprocess.check_output(['sysctl', '-n', 'hw.model'], text=True).strip()
    if model != 'Mac17,9':
        raise ValueError(f'This controller-specific experiment was prepared for Mac17,9, not {model}')
    verify(SOURCE)
    print('Verified the two pinned, unsigned bundle files.')
    if DESTINATION.exists() or DESTINATION.is_symlink():
        verify(DESTINATION)
        print('An identical bundle is already installed; no files changed.')
        return
    if not args.install:
        print('No installed bundle. Verification only; nothing copied or loaded.')
        return
    if os.geteuid() != 0:
        raise PermissionError('Run --install with sudo after the approved Recovery changes')
    sip = subprocess.check_output(['csrutil', 'status'], text=True)
    if 'System Integrity Protection status: disabled.' not in sip:
        raise ValueError('SIP is not reported disabled; this unsigned test bundle has not been staged')
    with tempfile.TemporaryDirectory(prefix='.smartbox-probe-', dir=DESTINATION.parent) as tmp:
        staged = Path(tmp) / DESTINATION.name
        shutil.copytree(SOURCE, staged)
        verify(staged)
        for path in [staged, *staged.rglob('*')]:
            os.chown(path, 0, 0)
            os.chmod(path, 0o755 if path.is_dir() or path.name == 'SmartBoxUSBProbe' else 0o644)
        if DESTINATION.exists() or DESTINATION.is_symlink():
            raise FileExistsError('Destination appeared during staging; refusing to overwrite it')
        staged.rename(DESTINATION)
    verify(DESTINATION)
    print(f'Installed exact bundle: {DESTINATION}')
    print('Not loaded. Next: sudo kmutil load -p /Library/Extensions/SmartBoxUSBProbe.kext')


if __name__ == '__main__':
    main()
