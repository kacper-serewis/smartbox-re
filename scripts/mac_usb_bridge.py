#!/usr/bin/env python3
"""Build/run the USB bridge client; default is read-only status. Never loads a kext."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    actions = parser.add_mutually_exclusive_group()
    for name in ('status', 'check', 'republish', 'restore', 'force-off-bus', 'release-off-bus'):
        actions.add_argument('--' + name, action='store_true')
    for name in ('publish', 'validate', 'make-profile'):
        actions.add_argument('--' + name, type=Path, metavar='JSON')
    args = parser.parse_args()
    if platform.system() != 'Darwin':
        parser.error('This client requires macOS')
    output = ROOT / 'device-snapshots' / ('mac-usb-bridge-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(parents=True, mode=0o700)
    source = ROOT / 'experiments/macos-usb'
    binary = output / 'mac-usb-bridge'
    build = subprocess.run(['xcrun', 'clang++', '-std=c++14', '-O2', '-Wall', '-Wextra', '-Werror', '-fobjc-arc',
                            '-framework', 'Foundation', '-framework', 'IOKit', str(source / 'bridge.mm'), '-o', str(binary)],
                           capture_output=True, text=True, timeout=60)
    (output / 'build.log').write_text(build.stdout + build.stderr)
    if build.returncode:
        print(build.stderr)
        return build.returncode
    manifest = {name: hashlib.sha256((source / name).read_bytes()).hexdigest()
                for name in ('bridge.mm', 'FoundationNodes.h', 'DescriptorValidation.h')}
    (output / 'sources.json').write_text(json.dumps(manifest, indent=2) + '\n')
    flags = ['--status']
    for name, value in vars(args).items():
        if value:
            flags = ['--' + name.replace('_', '-')]
            if isinstance(value, Path):
                flags.append(str(value.resolve()))
            break
    run = subprocess.run([str(binary), *flags], capture_output=True, text=True, timeout=20)
    (output / 'result.json').write_text(run.stdout)
    (output / 'result.stderr').write_text(run.stderr)
    print('Evidence:', output)
    print(run.stdout or run.stderr)
    return run.returncode


if __name__ == '__main__':
    raise SystemExit(main())
