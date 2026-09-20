#!/usr/bin/env python3
"""Inspect the Mac's USB device controller associated with smartBox-9302.

--check-access submits its existing configuration unchanged, only while device
mode is disconnected. Does not switch roles, load drivers, or change security.
"""
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
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--check-access', action='store_true')
    mode.add_argument('--kernel-check-access', action='store_true',
                      help='Request one test from an already loaded SmartBoxUSBProbe driver; never installs it')
    args = parser.parse_args()
    if platform.system() != 'Darwin':
        parser.error('This probe requires macOS')
    output = ROOT / 'device-snapshots' / ('mac-usb-gadget-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(parents=True, mode=0o700)
    source = ROOT / 'experiments/macos-usb/probe.m'
    binary = output / 'probe-mac-usb'
    build = subprocess.run(['xcrun', 'clang', '-O2', '-Wall', '-Wextra', '-Werror', '-fobjc-arc',
                            '-framework', 'Foundation', '-framework', 'IOKit', str(source), '-o', str(binary)],
                           capture_output=True, text=True, timeout=60)
    (output / 'build.log').write_text(build.stdout + build.stderr)
    build.check_returncode()
    environment = {}
    for name, command in [('macos', ['sw_vers']), ('model', ['sysctl', '-n', 'hw.model']), ('sip', ['csrutil', 'status'])]:
        r = subprocess.run(command, capture_output=True, text=True, timeout=10)
        environment[name] = dict(returncode=r.returncode, stdout=r.stdout, stderr=r.stderr)
    environment['source_sha256'] = hashlib.sha256(source.read_bytes()).hexdigest()
    (output / 'environment.json').write_text(json.dumps(environment, indent=2) + '\n')
    flags = ['--kernel-check-access'] if args.kernel_check_access else (['--check-access'] if args.check_access else [])
    run = subprocess.run([str(binary)] + flags,
                         capture_output=True, text=True, timeout=15)
    (output / 'probe.json').write_text(run.stdout)
    (output / 'probe.stderr').write_text(run.stderr)
    print('Evidence:', output)
    if run.stdout:
        report = json.loads(run.stdout)
        print('Device controllers:', len(report['controllers']))
        print('Controllers matching the dongle port:', report['matching_controllers'])
        print(json.dumps({k: v for k, v in report.items() if k in (
            'refused', 'set_existing_configuration', 'description_unchanged', 'state_after',
            'kernel_probe_error', 'kernel_request', 'kernel_configuration_result')}, indent=2))
    if run.stderr:
        print(run.stderr)
    return run.returncode


if __name__ == '__main__':
    raise SystemExit(main())
