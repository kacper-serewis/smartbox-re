#!/usr/bin/env python3
"""Inspect/test the prepared SmartBoxIAP2 USB interface; never publishes it or switches roles."""
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
    action = parser.add_mutually_exclusive_group()
    action.add_argument('--open', action='store_true', help='Open and close only our custom interface')
    action.add_argument('--configure', action='store_true', help='Set iAP2 interface class, allocate two bulk endpoints, commit, then close')
    args = parser.parse_args()
    if platform.system() != 'Darwin':
        parser.error('This client requires macOS')
    output = ROOT / 'device-snapshots' / ('mac-usb-interface-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(parents=True, mode=0o700)
    source = ROOT / 'experiments/macos-usb/interface_probe.mm'
    binary = output / 'mac-usb-interface'
    build = subprocess.run(['xcrun', 'clang++', '-std=c++14', '-O2', '-Wall', '-Wextra', '-Werror', '-fobjc-arc',
                            '-framework', 'Foundation', '-framework', 'IOKit', str(source), '-o', str(binary)],
                           capture_output=True, text=True, timeout=60)
    (output / 'build.log').write_text(build.stdout + build.stderr)
    if build.returncode:
        print(build.stderr)
        return build.returncode
    (output / 'source.json').write_text(json.dumps({'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest()}, indent=2) + '\n')
    flags = ['--configure'] if args.configure else ['--open'] if args.open else []
    run = subprocess.run([str(binary), *flags], capture_output=True, text=True, timeout=20)
    (output / 'result.json').write_text(run.stdout)
    (output / 'result.stderr').write_text(run.stderr)
    print('Evidence:', output)
    print(run.stdout or run.stderr)
    return run.returncode


if __name__ == '__main__':
    raise SystemExit(main())
