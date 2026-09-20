#!/usr/bin/env python3
"""Build a scoped Mac USB probe; --run briefly changes USB roles, then restores them."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import shlex
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', action='store_true', help='Publish, probe the owned dongle, and restore using native administrator dialogs')
    parser.add_argument('--stage', choices=('detect', 'syn', 'control'), default='control')
    args = parser.parse_args()
    if platform.system() != 'Darwin':
        parser.error('Requires the prepared macOS machine and loaded protocol-3 bridge')
    out = ROOT / 'device-snapshots' / ('mac-usb-session-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    out.mkdir(mode=0o700, parents=True)
    print('Evidence:', out, flush=True)
    src = ROOT / 'experiments/macos-usb'
    common = ['xcrun', 'clang++', '-std=c++14', '-O2', '-Wall', '-Wextra', '-Werror', '-fobjc-arc',
              '-framework', 'Foundation', '-framework', 'IOKit']
    manifest = {}
    for name, source in [('bridge', 'bridge.mm'), ('interface', 'interface_probe.mm'), ('role', 'role_switch.mm')]:
        extra = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'libusb-1.0'], text=True)) if name == 'role' else []
        subprocess.run(common + [str(src / source), *extra, '-o', str(out / name)], check=True, timeout=60)
        manifest[source] = hashlib.sha256((src / source).read_bytes()).hexdigest()
    for name in ('IAP2Probe.h', 'DescriptorValidation.h', 'FoundationNodes.h'):
        manifest[name] = hashlib.sha256((src / name).read_bytes()).hexdigest()
    (out / 'sources.json').write_text(json.dumps(manifest, indent=2) + '\n')

    def invoke(name, flags=(), admin=False):
        command = [str(out / 'bridge'), *flags]
        if admin:
            command = ['/usr/bin/osascript', '-e', 'do shell script ' + json.dumps(shlex.join(command)) + ' with administrator privileges']
        p = subprocess.run(command, capture_output=True, text=True, timeout=120 if admin else 20)
        (out / (name + '.stdout')).write_text(p.stdout)
        (out / (name + '.stderr')).write_text(p.stderr)
        # osascript may put the helper's JSON in stderr on a nonzero exit.
        text = p.stdout or p.stderr
        data = json.JSONDecoder().raw_decode(text[text.index('{'):])[0]
        (out / (name + '.json')).write_text(json.dumps(data, indent=2) + '\n')
        if p.returncode or (admin and not data.get('operation_result', {}).get('success')):
            raise RuntimeError(f'{name} failed; inspect {out}')
        return data

    status = invoke('status')
    if not args.run:
        print(json.dumps(status, indent=2))
        print('Read-only check complete. Use --run to perform the temporary probe.')
        return 0
    if status.get('bridge', {}).get('ProbeVersion') != '3':
        raise RuntimeError('Expected the already-installed protocol-3 bridge; no changes made')
    profile = out / 'profile.json'
    invoke('make-profile', ['--make-profile', str(profile)])
    listener = role = None
    try:
        invoke('publish', ['--publish', str(profile)], admin=True)
        flag = {'detect': '--listen', 'syn': '--syn-probe', 'control': '--control-probe'}[args.stage]
        with (out / 'listen.json').open('w') as output, (out / 'listen.stderr').open('w') as errors:
            listener = subprocess.Popen([str(out / 'interface'), flag, '30'], stdout=output, stderr=errors)
            deadline = time.monotonic() + 5
            while time.monotonic() < deadline and listener.poll() is None:
                if 'READY:' in (out / 'listen.stderr').read_text():
                    break
                time.sleep(0.03)
            if 'READY:' not in (out / 'listen.stderr').read_text():
                raise RuntimeError('Interface was not ready; role switch not sent')
            with (out / 'role.json').open('w') as output, (out / 'role.stderr').open('w') as errors:
                role = subprocess.Popen([str(out / 'role'), '--switch-with-mac-role'], stdout=output, stderr=errors)
                role.wait(timeout=25)
            listener.wait(timeout=35)
    finally:
        # SIGTERM asks the role helper to restore mode 2. Never SIGKILL it.
        for process in (role, listener):
            if process and process.poll() is None:
                process.terminate()
                process.wait(timeout=10)
        invoke('cleanup-force-off', ['--force-off-bus'], admin=True)
        deadline = time.monotonic() + 3
        while True:
            state = invoke('cleanup-state')['state_after']
            if state.get('DeviceState') == 'Disconnected' and state.get('OnBus') is False:
                break
            if time.monotonic() >= deadline:
                raise RuntimeError('Controller did not disconnect; inspect evidence before another test')
            time.sleep(0.1)
        restored = invoke('cleanup-restore', ['--restore'], admin=True)
        invoke('cleanup-release', ['--release-off-bus'], admin=True)
        if not restored.get('original_configuration_restored'):
            raise RuntimeError('Original configuration comparison failed')
    role_result = json.loads((out / 'role.json').read_text())
    result = json.loads((out / 'listen.json').read_text())
    keys = ('result', 'received_hex', 'detect_echo_received', 'valid_control_syn_ack', 'control_transfer_captured', 'error')
    print(json.dumps({k: result[k] for k in keys if k in result}, indent=2))
    if not role_result.get('mac_host_mode_restore', {}).get('success') or role_result.get('mode_after') != 2:
        raise RuntimeError('Mac host-role restoration was not verified; inspect role.json')
    print('Mac host role and original USB configuration restored. No firmware changes.')
    milestone = {'detect': 'detect_echo_received', 'syn': 'valid_control_syn_ack', 'control': 'control_transfer_captured'}[args.stage]
    return 0 if result.get('result', {}).get('success') and result.get(milestone) and role.returncode == 0 else 3


if __name__ == '__main__':
    raise SystemExit(main())
