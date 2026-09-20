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
    'Contents/MacOS/SmartBoxUSBProbe': '576b16135bd966ecf2b4cc2713098e9502e3ca53242c7a0615795c44b96192a5',
    'Contents/Info.plist': '23a79e016305605f4602f4a311790c63629273bc27af5fb2d426b430b71254b7',
}
PREVIOUS = {
    'Contents/MacOS/SmartBoxUSBProbe': '27ce29c18f05284bad96e96f92cb86b30c76914bcbbc5f734992eca880887fd8',
    'Contents/Info.plist': 'a78245c81eaf51923c89a8aaf8f454ae8a42c15331e1b0dfcdb6ae6991641a6b',
}


def verify(bundle, expected=None):
    expected = EXPECTED if expected is None else expected
    if bundle.is_symlink() or not bundle.is_dir():
        raise ValueError(f'Expected a real bundle directory: {bundle}')
    files = set()
    for path in bundle.rglob('*'):
        if path.is_symlink():
            raise ValueError(f'Symlink rejected: {path}')
        if path.is_file():
            name = path.relative_to(bundle).as_posix()
            if name not in expected or hashlib.sha256(path.read_bytes()).hexdigest() != expected[name]:
                raise ValueError(f'Unexpected or modified artifact: {path}')
            files.add(name)
        elif not path.is_dir():
            raise ValueError(f'Special file rejected: {path}')
    if files != set(expected):
        raise ValueError('Bundle is incomplete')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group()
    action.add_argument('--install', action='store_true')
    action.add_argument('--upgrade', action='store_true', help='Replace only the pinned 0.1.1 build, preserving a backup')
    args = parser.parse_args()
    if platform.system() != 'Darwin':
        parser.error('This bundle targets macOS')
    model = subprocess.check_output(['sysctl', '-n', 'hw.model'], text=True).strip()
    if model != 'Mac17,9':
        raise ValueError(f'This controller-specific experiment was prepared for Mac17,9, not {model}')
    verify(SOURCE)
    print('Verified the two pinned, unsigned bundle files.')
    previous = False
    if DESTINATION.exists() or DESTINATION.is_symlink():
        try:
            verify(DESTINATION)
        except ValueError:
            verify(DESTINATION, PREVIOUS)
            previous = True
            print('Installed bundle is the recognized previous version, 0.1.1.')
        else:
            print('An identical bundle is already installed; no files changed.')
            return
    if not args.install and not args.upgrade:
        if previous:
            print('Verification only. Use --upgrade to stage the prepared 0.2.0 update.')
            return
        print('No installed bundle. Verification only; nothing copied or loaded.')
        return
    if previous and not args.upgrade:
        raise ValueError('Use --upgrade for the recognized previous version; --install never replaces it')
    if args.upgrade and not previous:
        raise ValueError('No recognized installed version to upgrade')
    if os.geteuid() != 0:
        raise PermissionError('Run the install/upgrade with sudo after the approved Recovery changes')
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
        backup = Path('/Library/Application Support/SmartBoxUSBProbe/0.1.1.kext')
        if previous:
            verify(DESTINATION, PREVIOUS)
            backup.parent.mkdir(parents=True, exist_ok=True)
            if backup.exists() or backup.is_symlink():
                raise FileExistsError('Previous-version backup exists; inspect it before retrying')
            DESTINATION.rename(backup)
        elif DESTINATION.exists() or DESTINATION.is_symlink():
            raise FileExistsError('Destination appeared during staging; refusing to overwrite it')
        try:
            staged.rename(DESTINATION)
        except Exception:
            if previous:
                backup.rename(DESTINATION)
            raise
    verify(DESTINATION)
    print(f'Installed exact bundle: {DESTINATION}')
    print('Not loaded. Next: sudo kmutil load -p /Library/Extensions/SmartBoxUSBProbe.kext')


if __name__ == '__main__':
    main()
