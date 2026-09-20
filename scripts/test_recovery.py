#!/usr/bin/env python3
"""Linux/RV32 recovery fault tests; no adapter, flash device or external network."""
import argparse
import hashlib
import http.client
import json
import os
from pathlib import Path
import shutil
import signal
import socket
import subprocess
import sys
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASE = Path('/tmp/smartbox-recovery-test')
RAM = BASE / 'tmp/smartbox-rescue'
APP = BASE / 'mnt/app'
STATE = BASE / 'mnt/UDISK/smartbox-recovery'
TC = '/deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1'
# Static programs need the real /proc. The toolchain sysroot contains an empty
# /proc directory, which QEMU would otherwise substitute for process scans.
QEMU = ['/andes/qemu-riscv32', '-cpu', 'andes-a25', '-L', '/']
BUILD = ROOT / 'firmwares/research/recovery-build'
FLAVOR = 'native'


def script(path, body):
    path.write_text('#!/bin/sh\n' + body + '\n')
    path.chmod(0o700)


def birth(pid):
    return Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()[19]


class Recovery(unittest.TestCase):
    def setUp(self):
        shutil.rmtree(BASE, ignore_errors=True)
        Path('/tmp/recovery-known-hosts').unlink(missing_ok=True)
        for p in (RAM, STATE, APP / 'stock', APP / 'launch', APP / 'bin', APP / 'recovery', BASE / 'sbin', BASE / 'mnt/UDISK/smartbox-mode'):
            p.mkdir(parents=True, exist_ok=True)
            p.chmod(0o700)
        self.children = []
        self.log = (BASE / 'test.log').open('w')
        self.app = self.spawn(['sleep', '300'])
        shutil.copytree(BUILD / 'bundle', RAM, dirs_exist_ok=True)
        # Execs from QEMU require binfmt on a real kernel. Test-only wrappers
        # explicitly invoke the emulator; device artifacts remain real ELF files.
        script(RAM / 'dropbearmulti', 'exec ' + ' '.join(QEMU) + ' /work/firmwares/research/recovery-build/bundle/dropbearmulti "$@"')
        script(RAM / 'UpdateServer', 'exec python3 /tmp/mock-updater.py "$@"')
        script(BASE / 'sbin/reboot', f'touch {BASE}/reboot-requested')
        (RAM / 'keys/authorized_keys').write_text('no-agent-forwarding,no-X11-forwarding,permitopen="127.0.0.1:8083",permitopen="127.0.0.1:8082" ' + Path('/tmp/recovery-owner.pub').read_text())
        (RAM / 'keys/authorized_keys').chmod(0o600)
        self.server = None

    def tearDown(self):
        for proc in reversed(self.children):
            if proc.poll() is None:
                proc.terminate()
                try: proc.wait(timeout=3)
                except subprocess.TimeoutExpired: proc.kill(); proc.wait()
        # Services intentionally outlive their parent. Stop only processes
        # referring to this disposable test root or our emulator Dropbear path.
        for entry in Path('/proc').iterdir():
            if not entry.name.isdigit() or int(entry.name) == os.getpid(): continue
            try:
                cmd = (entry / 'cmdline').read_bytes()
                if (str(BASE).encode() in cmd or b'/tmp/mock-updater.py' in cmd or
                    b'/tmp/recovery-native' in cmd or b'/tmp/recovery-rv32' in cmd or
                    b'/work/firmwares/research/recovery-build/bundle/dropbearmulti' in cmd):
                    os.kill(int(entry.name), signal.SIGKILL)
            except (OSError, ProcessLookupError): pass
        self.log.close()
        time.sleep(.1)

    def spawn(self, args, **kwargs):
        p = subprocess.Popen(args, stdout=self.log, stderr=subprocess.STDOUT, **kwargs)
        self.children.append(p)
        return p

    def until(self, condition, seconds=8):
        end = time.monotonic() + seconds
        while time.monotonic() < end:
            try:
                if condition(): return
            except (OSError, ValueError, http.client.HTTPException): pass
            time.sleep(.05)
        self.fail((BASE / 'test.log').read_text() + '\n' + ((RAM / 'recovery.log').read_text() if (RAM / 'recovery.log').exists() else '') + '\nTimed out')

    def command(self):
        return ['/tmp/recovery-native'] if FLAVOR == 'native' else QEMU + (['-strace'] if os.environ.get('RECOVERY_STRACE') else []) + ['/tmp/recovery-rv32']

    def start(self):
        self.server = self.spawn(self.command() + ['--serve', str(self.app.pid), birth(self.app.pid)], start_new_session=True)
        self.until(lambda: self.http('/status')[0] == 200)

    def http(self, path, method='GET', headers=None, port=8083):
        conn = http.client.HTTPConnection('127.0.0.1', port, timeout=8)
        conn.request(method, path, headers=headers or {})
        reply = conn.getresponse()
        result = reply.status, reply.read().decode()
        conn.close()
        return result

    def post(self, path):
        return self.http(path, 'POST', {'X-SmartBox-Recovery': '1'})

    def ssh(self, key='/tmp/recovery-owner', *extra):
        return ['ssh', '-F', '/dev/null', '-o', 'StrictHostKeyChecking=no', '-o', 'UserKnownHostsFile=/tmp/recovery-known-hosts',
                '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=2', '-o', 'IdentitiesOnly=yes', '-i', key, '-p', '2222', *extra, 'root@127.0.0.1']

    def ssh_ready(self):
        result = subprocess.run(self.ssh() + ['printf recovery-ok'], capture_output=True, timeout=4)
        return result.returncode == 0 and result.stdout == b'recovery-ok'

    def test_key_login_wrong_key_and_tunnel(self):
        self.start()
        self.until(self.ssh_ready, 15)
        bad = subprocess.run(self.ssh('/tmp/recovery-wrong') + ['true'], capture_output=True, timeout=4)
        self.assertNotEqual(bad.returncode, 0)
        self.assertIn(b'publickey', bad.stderr)
        self.spawn(self.ssh('/tmp/recovery-owner', '-N', '-o', 'ExitOnForwardFailure=yes', '-L', '127.0.0.1:18083:127.0.0.1:8083'))
        self.until(lambda: self.http('/status', port=18083)[0] == 200)
        self.assertIn('SmartBox recovery', self.http('/', port=18083)[1])
        # Non-recovery forwarding destinations must be rejected by authorized_keys.
        result = subprocess.run(self.ssh('/tmp/recovery-owner', '-W', '127.0.0.1:80'), capture_output=True, timeout=4)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b'administratively prohibited', result.stderr)

    def test_host_key_persists_and_web_rejects_cross_origin(self):
        self.start()
        fingerprint = hashlib.sha256((STATE / 'hostkey').read_bytes()).hexdigest()
        self.assertEqual(self.post('/disable')[0], 200)
        self.assertEqual(self.http('/disable', 'POST')[0], 403)
        self.assertEqual(self.http('/disable', 'POST', {'X-SmartBox-Recovery':'1', 'Origin':'http://evil.example'})[0], 403)
        self.assertEqual(self.http('/status', headers={'Host':'evil.example'})[0], 403)
        self.assertEqual(self.http('/prepare')[0], 404)
        self.assertEqual(self.http('/../../etc/passwd')[0], 404)
        self.server.terminate(); self.server.wait(timeout=3)
        self.start()
        self.assertEqual(fingerprint, hashlib.sha256((STATE / 'hostkey').read_bytes()).hexdigest())

    def test_app_death_does_not_kill_recovery(self):
        self.start()
        self.app.kill(); self.app.wait()
        self.assertEqual(self.http('/status')[0], 200)
        self.assertFalse(json.loads(self.http('/status')[1])['application_running'])
        self.assertEqual(self.post('/reboot')[0], 409)
        self.until(self.ssh_ready, 15)

    def test_prepare_stops_app_and_updater_survives_service_shutdown(self):
        self.start()
        response = self.post('/prepare')
        self.assertEqual(response[0], 200, response[1] + (BASE / 'test.log').read_text())
        self.app.wait(timeout=3)
        self.assertTrue((RAM / 'maintenance').exists())
        self.assertTrue((BASE / 'mnt/UDISK/smartbox-mode/recovery-disabled').exists())
        info = json.loads((BASE / 'updater.json').read_text())
        self.assertEqual(info['pid'], info['sid'])
        self.assertEqual(info['cwd'], str(RAM))
        self.assertEqual(info['ports'], '8082')
        self.assertEqual(self.post('/reboot')[0], 409)
        self.server.terminate(); self.server.wait(timeout=3)
        self.assertEqual(self.http('/getupdatestatus', port=8082)[0], 200)

    def test_prepare_refuses_an_open_app_file(self):
        with (APP / 'held').open('w') as held:
            self.start()
            self.assertEqual(self.post('/prepare')[0], 409, (BASE / 'test.log').read_text()[-24000:])
            self.assertFalse((BASE / 'updater.json').exists())
        self.assertEqual(self.post('/prepare')[0], 200)

    def test_reboot_sets_stock_latch(self):
        self.start()
        self.assertEqual(self.post('/reboot')[0], 200)
        self.until(lambda: (BASE / 'reboot-requested').exists())
        self.assertTrue((BASE / 'mnt/UDISK/smartbox-mode/recovery-disabled').exists())

    def test_malformed_http_does_not_crash_service(self):
        self.start()
        for request in [b'GET / HTTP/1.1\r\n\r\n', b'GET / HTTP/1.1\r\nHost: localhost:18083\r\nHost: evil\r\n\r\n', b'X'*8192]:
            with socket.create_connection(('127.0.0.1',8083), timeout=3) as s:
                s.sendall(request)
                self.assertIn(s.recv(1024).split()[1], [b'400',b'403'])
        self.assertEqual(self.http('/status')[0], 200)

    def test_real_vendor_updater_allows_only_loopback_without_flashing(self):
        libs = TC + '/riscv32-buildroot-linux-gnu/sysroot'
        script(RAM / 'UpdateServer', 'exec ' + ' '.join(QEMU) + f' -L {libs} -E LD_LIBRARY_PATH={libs}/lib:{libs}/usr/lib /work/firmwares/hw501/131/rootfs/bin/UpdateServer "$@"')
        (RAM / 'web').mkdir()
        self.start()
        response = self.post('/prepare')
        self.assertEqual(response[0], 200, response[1] + (BASE / 'test.log').read_text())
        self.assertEqual(self.http('/getupdatestatus', port=8082), (200, '{}'))
        # A different loopback source is sufficient to exercise the exact /32
        # ACL without giving the test container an external network interface.
        with socket.create_connection(('127.0.0.1',8082), timeout=2, source_address=('127.0.0.2',0)) as denied:
            try:
                denied.sendall(b'GET /getupdatestatus HTTP/1.0\r\n\r\n')
                self.assertEqual(denied.recv(1024), b'')
            except ConnectionResetError:
                pass

    def test_stale_pid_cannot_kill_another_process(self):
        self.server = self.spawn(self.command() + ['--serve', str(self.app.pid), str(int(birth(self.app.pid))+1)], start_new_session=True)
        self.until(lambda: self.http('/status')[0] == 200)
        self.assertEqual(self.post('/prepare')[0], 200)
        self.assertIsNone(self.app.poll())

    def test_bootstrap_copies_to_ram_before_app_and_survives_parent(self):
        # Test bootstrap executable native/RV32, with explicit test re-exec wrapper.
        shutil.copytree(RAM, APP / 'recovery', dirs_exist_ok=True)
        script(APP / 'recovery/recoveryd', 'exec ' + ' '.join(self.command()) + ' "$@"')
        for name in ['stock', 'launch']:
            script(APP / name / 'CPAAProxyEx', f'touch {BASE}/{name}-started\nexec sleep 300')
        self.server = self.spawn(self.command(), start_new_session=True)
        self.until(lambda: (BASE / 'launch-started').exists(), 15)
        self.assertEqual(self.http('/status')[0], 200)
        self.server.kill(); self.server.wait()
        self.until(self.ssh_ready, 15)
        self.assertEqual(self.post('/prepare')[0], 200)
        restarted = self.spawn(self.command(), start_new_session=True)
        time.sleep(.5)
        self.assertIsNone(restarted.poll())
        self.assertIn(b'--hold', Path(f'/proc/{restarted.pid}/cmdline').read_bytes())

    def test_missing_recovery_bundle_falls_back_to_stock(self):
        (APP / 'recovery').rmdir()
        script(APP / 'stock/CPAAProxyEx', f'touch {BASE}/stock-started\nexec sleep 300')
        script(APP / 'launch/CPAAProxyEx', f'touch {BASE}/experimental-started\nexec sleep 300')
        self.spawn(self.command(), start_new_session=True)
        self.until(lambda: (BASE / 'stock-started').exists())
        self.assertFalse((BASE / 'experimental-started').exists())


def guest(test=None):
    global FLAVOR
    source = str(ROOT / 'experiments/recovery/recovery.c')
    flags = ['-std=c11', '-O2', '-Wall', '-Wextra', '-Werror', f'-DSMARTBOX_ROOT="{BASE}"', '-DSSH_BIND="127.0.0.1:2222"']
    subprocess.run(['cc', *flags, source, '-o', '/tmp/recovery-native'], check=True)
    subprocess.run([TC + '/bin/riscv32-buildroot-linux-gnu-gcc', *flags, '-static', source, '-o', '/tmp/recovery-rv32'], check=True)
    for name in ['owner', 'wrong']:
        subprocess.run(['ssh-keygen', '-q', '-t', 'ed25519', '-N', '', '-f', f'/tmp/recovery-{name}'], check=True)
    Path('/tmp/mock-updater.py').write_text('''import http.server, json, os, sys
from pathlib import Path
Path('/tmp/smartbox-recovery-test/updater.json').write_text(json.dumps(dict(pid=os.getpid(),sid=os.getsid(0),cwd=os.getcwd(),ports=sys.argv[sys.argv.index('-ports')+1])))
class Handler(http.server.BaseHTTPRequestHandler):
 def do_GET(self):
  self.send_response(200);self.end_headers();self.wfile.write(b'{}')
http.server.HTTPServer(('127.0.0.1',8082),Handler).serve_forever()
''')
    for FLAVOR in ['native', 'rv32']:
        print('Recovery tests:', FLAVOR, flush=True)
        suite = unittest.defaultTestLoader.loadTestsFromName(test, Recovery) if test else unittest.defaultTestLoader.loadTestsFromTestCase(Recovery)
        result = unittest.TextTestRunner(verbosity=2).run(suite)
        if not result.wasSuccessful(): raise SystemExit(1)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--guest', action='store_true')
    parser.add_argument('--test')
    parser.add_argument('--deps', type=Path, default=ROOT / 'firmwares/research/mirror-deps')
    parser.add_argument('--qemu', type=Path, default=ROOT / 'firmwares/research/qemu-andes-build')
    args = parser.parse_args()
    if args.guest:
        guest(args.test); return
    command = ['docker', 'run', '--rm', '--platform', 'linux/amd64', '--network', 'none', '--read-only',
               '--tmpfs', '/tmp:rw,exec,nosuid,size=128m', '-v', f'{ROOT}:/work:ro',
               '-v', f'{args.deps.resolve()}:/deps:ro', '-v', f'{args.qemu.resolve()}:/andes:ro',
               'smartbox-recovery-tests:local', 'python3', '/work/scripts/test_recovery.py', '--guest']
    if args.test: command += ['--test', args.test]
    if os.environ.get('RECOVERY_STRACE'): command[2:2] = ['-e', 'RECOVERY_STRACE=1']
    hashes = {'source_sha256': hashlib.sha256((ROOT / 'experiments/recovery/recovery.c').read_bytes()).hexdigest(),
              'test_source_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'bundle_manifest_sha256': hashlib.sha256((BUILD / 'bundle/manifest.json').read_bytes()).hexdigest()}
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    after = {'source_sha256': hashlib.sha256((ROOT / 'experiments/recovery/recovery.c').read_bytes()).hexdigest(),
             'test_source_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
             'bundle_manifest_sha256': hashlib.sha256((BUILD / 'bundle/manifest.json').read_bytes()).hexdigest()}
    (BUILD / 'tests.log').write_text(result.stdout)
    (BUILD / 'tests.json').write_text(json.dumps({'passed': result.returncode == 0 and hashes == after,
        'full_suite': not args.test, 'hardware_tested': False, **hashes}, indent=2)+'\n')
    print(result.stdout)
    result.check_returncode()
    if hashes != after: raise RuntimeError('Recovery inputs changed during tests; rerun with stable inputs')


if __name__ == '__main__': main()
