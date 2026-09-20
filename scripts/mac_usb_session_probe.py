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
    parser.add_argument('--stage', choices=('detect', 'syn', 'control', 'auth', 'identify', 'network'), default='control')
    parser.add_argument('--collect-network', action='store_true', help='Read the owned dongle network/log state over its Wi-Fi during identification')
    args = parser.parse_args()
    if args.collect_network and (not args.run or args.stage not in ('identify', 'network')):
        parser.error('--collect-network requires --run --stage identify or network')
    if platform.system() != 'Darwin':
        parser.error('Requires the prepared macOS machine and loaded protocol-3 bridge')
    out = ROOT / 'device-snapshots' / ('mac-usb-session-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    out.mkdir(mode=0o700, parents=True)
    print('Evidence:', out, flush=True)
    src = ROOT / 'experiments/macos-usb'
    common = ['xcrun', 'clang++', '-std=c++14', '-O2', '-Wall', '-Wextra', '-Werror', '-fobjc-arc',
              '-framework', 'Foundation', '-framework', 'IOKit', '-framework', 'Security']
    manifest = {}
    for name, source in [('bridge', 'bridge.mm'), ('interface', 'interface_probe.mm'), ('role', 'role_switch.mm')]:
        extra = shlex.split(subprocess.check_output(['pkg-config', '--cflags', '--libs', 'libusb-1.0'], text=True)) if name == 'role' else []
        subprocess.run(common + [str(src / source), *extra, '-o', str(out / name)], check=True, timeout=60)
        manifest[source] = hashlib.sha256((src / source).read_bytes()).hexdigest()
    for name in ('IAP2Probe.h', 'IAP2AuthProbe.h', 'DescriptorValidation.h', 'FoundationNodes.h'):
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
    credentials = []
    if args.stage in ('auth', 'identify', 'network'):
        # Ephemeral self-signed bench identity, unrelated to any Apple/car keys.
        cert, key, pem = out / 'test-cert.der', out / 'test-key.der', out / 'test-key.pem'
        with (out / 'test-identity.log').open('w') as log:
            subprocess.run(['/usr/bin/openssl', 'req', '-x509', '-newkey', 'rsa:2048', '-nodes', '-days', '1',
                            '-subj', '/CN=SmartBox Local Bench Test/O=Local Development Only',
                            '-keyout', str(pem), '-outform', 'DER', '-out', str(cert)], stdout=log, stderr=log, check=True, timeout=30)
            pem.chmod(0o600)
            subprocess.run(['/usr/bin/openssl', 'rsa', '-in', str(pem), '-outform', 'DER', '-out', str(key)],
                           stdout=log, stderr=log, check=True, timeout=10)
            key.chmod(0o600)
        credentials = [str(cert), str(key)]
    profile = out / 'profile.json'
    invoke('make-profile', ['--make-profile', str(profile)])
    listener = role = observer = None
    try:
        invoke('publish', ['--publish', str(profile)], admin=True)
        flag = {'detect': '--listen', 'syn': '--syn-probe', 'control': '--control-probe', 'auth': '--auth-probe', 'identify': '--identify-probe', 'network': '--network-probe'}[args.stage]
        if args.stage == 'network':
            credentials.append(str(out / 'network-ready.json'))
        with (out / 'listen.json').open('w') as output, (out / 'listen.stderr').open('w') as errors:
            listener = subprocess.Popen([str(out / 'interface'), flag, '30', *credentials], stdout=output, stderr=errors)
            deadline = time.monotonic() + 5
            while time.monotonic() < deadline and listener.poll() is None:
                if 'READY:' in (out / 'listen.stderr').read_text():
                    break
                time.sleep(0.03)
            if 'READY:' not in (out / 'listen.stderr').read_text():
                raise RuntimeError('Interface was not ready; role switch not sent')
            with (out / 'role.json').open('w') as output, (out / 'role.stderr').open('w') as errors:
                role = subprocess.Popen([str(out / 'role'), '--switch-with-mac-role'], stdout=output, stderr=errors)
                if args.stage in ('identify', 'network'):
                    if args.stage == 'network':
                        from mac_carplay_observer import USBObserver
                        observer = USBObserver(out)
                        print(f'USB-only observer: [{observer.host}%{observer.name}]:{observer.port}', flush=True)
                    else:
                        time.sleep(3)
                    network = subprocess.run(['/sbin/ifconfig', '-a'], capture_output=True, text=True, timeout=5)
                    (out / 'mac-network.txt').write_text(network.stdout + network.stderr)
                    if args.collect_network:
                        from recover_updater import Recovery
                        diagnostics = out / 'dongle-network'
                        diagnostics.mkdir(mode=0o700)
                        recovery = Recovery('http://192.168.5.1', diagnostics, 'smartBox-9302')
                        recovery.check_identity()
                        recovery.diagnostic('ifconfig; cat /proc/net/route; cat /proc/net/if_inet6; cat /tmp/logs/app.log')
                role.wait(timeout=25)
            listener.wait(timeout=35)
    finally:
        if observer:
            observer.close()
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
    keys = ('result', 'received_hex', 'detect_echo_received', 'valid_control_syn_ack', 'control_transfer_captured',
            'control_messages', 'authentication_succeeded', 'identification_requested', 'identification_accepted',
            'session_start_sent', 'read_error', 'error')
    print(json.dumps({k: result[k] for k in keys if k in result}, indent=2))
    if not role_result.get('mac_host_mode_restore', {}).get('success') or role_result.get('mode_after') != 2:
        raise RuntimeError('Mac host-role restoration was not verified; inspect role.json')
    print('Mac host role and original USB configuration restored. No firmware changes.')
    milestone = {'detect': 'detect_echo_received', 'syn': 'valid_control_syn_ack', 'control': 'control_transfer_captured', 'auth': 'identification_requested', 'identify': 'identification_accepted', 'network': 'session_start_sent'}[args.stage]
    network_ok = observer is None or any(record.get('request') and record.get('response_status') == 501 for record in observer.records)
    if observer:
        print('Observed requests:', [record.get('request', record.get('error')) for record in observer.records])
    transport_ok = result.get('result', {}).get('success')
    if args.stage == 'network' and network_ok and not result.get('error') and result.get('result', {}).get('hex') == '0xe00002eb':
        print('Request observation completed; the final USB read was aborted. The observer returned 501, not a video session.')
        transport_ok = True
    return 0 if transport_ok and result.get(milestone) and role.returncode == 0 and network_ok else 3


if __name__ == '__main__':
    raise SystemExit(main())
