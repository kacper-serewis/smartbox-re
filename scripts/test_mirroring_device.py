#!/usr/bin/env python3
"""Run RV32 bridge checks and preload the integration into the real stock app."""
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def guest():
    import socket
    import time
    sysroot = '/work/firmwares/research/mirror-deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1/riscv32-buildroot-linux-gnu/sysroot'
    qemu = ['/work/firmwares/research/qemu-andes-build/qemu-riscv32', '-cpu', 'andes-a25', '-L', sysroot,
            '-E', f'LD_LIBRARY_PATH=/mnt/app/lib:{sysroot}/lib:{sysroot}/usr/lib']
    build = '/work/firmwares/research/mirroring-riscv/'
    report = {'physical_hardware_tested': False, 'checks': {}}
    for binary in ('test-timeouts', 'test-capture', 'test-device-bridge'):
        output = subprocess.check_output(['timeout', '--signal=KILL', '15'] + qemu + [build + binary], text=True, stderr=subprocess.STDOUT)
        Path('/evidence/' + binary + '.log').write_text(output)
        report['checks'][binary] = 'passed'
    log = open('/evidence/preload.log', 'w')
    proc = subprocess.Popen(['timeout', '--signal=KILL', '10'] + qemu + ['-strace', '-E', f'LD_PRELOAD={build}libsmartbox-mirror.so', '/mnt/app/bin/CPAAProxyEx'], stdout=log, stderr=subprocess.STDOUT)
    try:
        until = time.monotonic() + 5
        while not Path('/tmp/smartbox-mirror.sock').exists() and time.monotonic() < until:
            time.sleep(0.05)
        for operation in ('probe', 'start'):
            mode = 'mirroring' if operation == 'probe' else 'carplay'
            result = subprocess.run(['timeout', '--signal=KILL', '5'] + qemu + ['-0', 'smartbox-mode-driver', build + 'smartbox-launch', operation, mode], capture_output=True, text=True)
            if result.returncode: raise RuntimeError(f'Device driver {operation} failed: {result.stderr}')
            report['checks']['stock-preload-driver-' + operation] = 'passed'
        state = json.loads(Path('/tmp/smartbox-mirror.json').read_text())
        if state['state'] != 'carplay': raise RuntimeError(state)
        report['runtime_status'] = state
        proc.wait(timeout=12)
    finally:
        if proc.poll() is None: proc.kill(); proc.wait()
        log.close()
    text = Path('/evidence/preload.log').read_text(errors='replace')
    report['stock_app_exit'] = proc.returncode
    report['stock_app_sigill'] = '--- SIGILL' in text
    report['stock_app_sigsegv'] = '--- SIGSEGV' in text
    # Exercise the packaged receiver against the real stock Bonjour daemon.
    # This is isolated registration over loopback, not an iPhone discovery test.
    Path('/tmp/smartbox-mirror.sock').unlink(missing_ok=True)
    state_dir = Path('/mnt/UDISK/smartbox-mode'); state_dir.mkdir(mode=0o700, exist_ok=True)
    (state_dir / 'connection-mode').write_text('mirroring\n')
    with open('/evidence/mdns.log', 'w') as dns_log, open('/evidence/mirror-startup.log', 'w') as mirror_log:
        dns = subprocess.Popen(['timeout', '--signal=KILL', '15'] + qemu + ['/mnt/app/bin/mdnsd', '-foreground'], stdout=dns_log, stderr=subprocess.STDOUT)
        time.sleep(1)
        app = subprocess.Popen(['timeout', '--signal=KILL', '8'] + qemu + ['-E', f'LD_PRELOAD={build}libsmartbox-mirror.so', '/mnt/app/bin/CPAAProxyEx'], stdout=mirror_log, stderr=subprocess.STDOUT)
        try:
            until = time.monotonic() + 4
            while not Path('/tmp/smartbox-mirror.sock').exists() and time.monotonic() < until: time.sleep(0.05)
            result = subprocess.run(['timeout', '--signal=KILL', '5'] + qemu + ['-0', 'smartbox-mode-driver', build + 'smartbox-launch', 'start', 'mirroring'], capture_output=True, text=True)
            if result.returncode: raise RuntimeError('Mirroring startup failed: ' + result.stderr)
            status = json.loads(Path('/tmp/smartbox-mirror.json').read_text())
            if status['state'] != 'waiting' or len(status['pin']) != 4 or not status['pin'].isdigit(): raise RuntimeError(status)
            if not (state_dir / 'receiver.key').is_file(): raise RuntimeError('Pairing identity missing')
            report['checks']['stock-mdns-receiver-startup'] = 'passed'
            report['checks']['pairing-pin-available-before-connection'] = 'passed'
            result = subprocess.run(['timeout', '--signal=KILL', '5'] + qemu + ['-0', 'smartbox-mode-driver', build + 'smartbox-launch', 'stop', 'mirroring'], capture_output=True, text=True)
            if result.returncode: raise RuntimeError('Mirroring cleanup failed: ' + result.stderr)
            report['checks']['receiver-cleanup'] = 'passed'
        finally:
            app.wait(timeout=10); dns.wait(timeout=17)
    report['note'] = 'Tests verify loader compatibility, driver IPC, and bridge logic. The stock app still lacks vendor hardware in QEMU; this is not a full firmware boot or car display test.'
    Path('/evidence/report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))


def main():
    output = ROOT / 'firmwares/research/emulation' / ('mirror-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
    output.mkdir(parents=True)
    subprocess.run(['docker', 'run', '--rm', '--platform', 'linux/amd64', '--network', 'none', '--read-only',
                    '--cap-drop', 'ALL', '--security-opt', 'no-new-privileges', '--memory', '512m', '--pids-limit', '128',
                    '--tmpfs', '/tmp:rw,exec,nosuid,size=64m', '--tmpfs', '/mnt/UDISK:rw,nosuid,size=16m', '--tmpfs', '/run:rw,nosuid,size=4m',
                    '-v', f'{ROOT}:/work:ro', '-v', f'{ROOT / "firmwares/hw501/131/rootfs"}:/mnt/app:ro',
                    '-v', f'{output}:/evidence', '-w', '/tmp', 'smartbox-emulation:local',
                    'python3', '/work/scripts/test_mirroring_device.py', '--guest'], check=True)
    print(f'Evidence: {output}')


if __name__ == '__main__':
    guest() if '--guest' in sys.argv else main()
