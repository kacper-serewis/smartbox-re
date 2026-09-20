#!/usr/bin/env python3
"""Fault injection against the actual supervisor, using disposable Linux processes."""
import json
import hashlib
import os
import re
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import time
import unittest
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
BASE = Path('/tmp/smartbox-supervisor-test')
STATE = BASE / 'mnt/UDISK/smartbox-mode'
APP = BASE / 'mnt/app/stock/CPAAProxyEx'
BIN = BASE / 'mnt/app/bin'
RUNTIME = BASE / 'tmp'
COMMAND = []


class Recovery(unittest.TestCase):
    def setUp(self):
        shutil.rmtree(BASE, ignore_errors=True)
        for p in (STATE, APP.parent, BIN, RUNTIME): p.mkdir(parents=True, exist_ok=True)
        self.proc = None
        self.log = (BASE / 'supervisor.log').open('w')
        page = BIN / 'smartbox-mode'
        page.write_text('#!/bin/sh\necho page >> ' + str(BASE / 'pages') + '\nexec sleep 60\n')
        page.chmod(0o755)

    def tearDown(self):
        if self.proc and self.proc.poll() is None:
            self.proc.terminate(); self.proc.wait(timeout=5)
        self.log.close()

    def payload(self, behavior):
        # Native shell children still exercise real RV32 fork/exec/waitpid/signal
        # handling in QEMU. This is not a simulated vendor app or a full boot.
        APP.write_text('''#!/bin/sh
if [ -n "$LD_PRELOAD" ]; then
  unset LD_PRELOAD
  echo experimental >> ROOT/events
  BEHAVIOR
else
  echo original >> ROOT/events
fi
exec sleep 60
'''.replace('ROOT', str(BASE)).replace('BEHAVIOR', behavior))
        APP.chmod(0o755)

    def start(self):
        self.proc = subprocess.Popen(COMMAND, stdout=self.log, stderr=subprocess.STDOUT)

    def until(self, check, seconds=8):
        end = time.monotonic() + seconds
        while time.monotonic() < end:
            if check(): return
            time.sleep(0.05)
        self.log.flush()
        self.fail((BASE / 'supervisor.log').read_text() + '\nCondition timed out')

    def events(self):
        p = BASE / 'events'
        return p.read_text().splitlines() if p.exists() else []

    def test_sigsegv_recovers_and_next_boot_skips_library(self):
        self.payload('kill -SEGV $$')
        self.start(); self.until(lambda: self.events() == ['experimental', 'original'])
        self.assertTrue((STATE / 'recovery-disabled').exists())
        self.until(lambda: (BASE / 'pages').exists())
        self.assertIsNone(self.proc.poll())
        self.proc.terminate(); self.proc.wait(timeout=5)
        self.start(); self.until(lambda: self.events() == ['experimental', 'original', 'original'])

    def test_nonzero_exit_recovers(self):
        self.payload('exit 127')
        self.start(); self.until(lambda: self.events() == ['experimental', 'original'])

    def test_sigkill_recovers(self):
        self.payload('kill -KILL $$')
        self.start(); self.until(lambda: self.events() == ['experimental', 'original'])

    def test_supervisor_death_leaves_boot_guard(self):
        self.payload(':')
        self.start(); self.until(lambda: self.events() == ['experimental'])
        self.proc.kill(); self.proc.wait(timeout=5)
        self.assertTrue((STATE / 'boot-pending').exists())
        self.start(); self.until(lambda: self.events() == ['experimental', 'original'])

    def test_late_crash_after_startup_grace_is_still_latched(self):
        self.payload('touch ' + str(RUNTIME / 'smartbox-mirror.sock') + '; sleep 3; kill -ABRT $$')
        self.start(); self.until(lambda: self.events() == ['experimental'])
        self.until(lambda: not (STATE / 'boot-pending').exists())
        self.until(lambda: self.events() == ['experimental', 'original'])
        self.assertTrue((STATE / 'recovery-disabled').exists())

    def test_missing_integration_times_out(self):
        self.payload(':')
        self.start(); self.until(lambda: self.events() == ['experimental', 'original'])
        self.assertEqual((STATE / 'recovery-disabled').read_text(), 'startup_timeout')

    def test_incomplete_boot_goes_directly_to_original(self):
        (STATE / 'boot-pending').write_text('interrupted startup')
        self.payload('exit 88')
        self.start(); self.until(lambda: self.events() == ['original'])

    def test_original_failures_are_bounded_and_page_survives(self):
        APP.write_text('#!/bin/sh\necho failed >> ' + str(BASE / 'events') + '\nexit 1\n')
        APP.chmod(0o755)
        self.start()
        def exhausted():
            try: return json.loads((RUNTIME / 'smartbox-mirror.json').read_text())['reason'] == 'original_app_failed'
            except (OSError, ValueError, KeyError): return False
        self.until(exhausted, 10)
        self.assertEqual(len(self.events()), 4)  # one experimental + three original
        time.sleep(0.3); self.assertEqual(len(self.events()), 4)
        self.assertIsNone(self.proc.poll())
        self.assertTrue((BASE / 'pages').exists())

    def test_missing_executable_preserves_mode_page(self):
        self.start(); self.until(lambda: (STATE / 'recovery-disabled').exists())
        self.until(lambda: (BASE / 'pages').exists())
        self.assertIsNone(self.proc.poll())

    def test_real_settings_page_serves_after_crash(self):
        shutil.copy2('/tmp/mode-native', BIN / 'smartbox-mode')
        (BASE / 'mnt/app/mode-web').symlink_to('/work/experiments/mode/web')
        self.payload('kill -SEGV $$')
        self.start()
        def recovered_page():
            try:
                with urllib.request.urlopen('http://127.0.0.1:8081/api/mirror', timeout=0.2) as r:
                    return json.load(r)['state'] == 'recovery'
            except (OSError, ValueError, KeyError): return False
        self.until(recovered_page)
        with urllib.request.urlopen('http://127.0.0.1:8081/api/mode') as r: status = json.load(r)
        self.assertEqual(status['active'], 'unknown')
        self.assertFalse(status['available']['mirroring'])
        with urllib.request.urlopen('http://127.0.0.1:8081/') as r:
            self.assertIn(b'Connection mode', r.read())

    def test_clean_shutdown_does_not_latch_recovery(self):
        self.payload('touch ' + str(RUNTIME / 'smartbox-mirror.sock'))
        self.start(); self.until(lambda: (BASE / 'pages').exists())
        self.proc.terminate(); self.assertEqual(self.proc.wait(timeout=5), 0)
        self.assertFalse((STATE / 'recovery-disabled').exists())
        self.assertFalse((STATE / 'boot-pending').exists())

    def updater_helper(self, signal_app):
        helper = BASE / 'mock-updater'
        helper.write_text('#!/bin/sh\n'
            + 'echo started > ' + str(BASE / 'updater-started') + '\n'
            + ('kill -TERM "$1"\n' if signal_app else '')
            + 'sleep 0.5\n'
            + 'echo survived > ' + str(BASE / 'updater-survived') + '\n')
        helper.chmod(0o755)
        # The updater must remain in the application's process group, just like
        # the real UpdateServer started by the vendor's system("... &") call.
        self.payload(str(helper) + ' "$$" &\n touch ' + str(RUNTIME / 'smartbox-mirror.sock'))

    def test_updater_survives_vendor_app_exit(self):
        self.updater_helper(signal_app=True)
        self.start()
        self.until(lambda: (STATE / 'recovery-disabled').exists())
        self.until(lambda: (BASE / 'updater-survived').exists())

    def test_updater_survives_supervisor_shutdown(self):
        self.updater_helper(signal_app=False)
        self.start(); self.until(lambda: (BASE / 'updater-started').exists())
        self.proc.terminate(); self.proc.wait(timeout=5)
        self.until(lambda: (BASE / 'updater-survived').exists())


def main():
    global COMMAND
    if '--guest' in sys.argv:
        tc = '/work/firmwares/research/mirror-deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1'
        source = '/work/experiments/mirroring/device_launch.c'
        flags = ['-O2', '-Wall', '-Wextra', '-Werror', '-DSMARTBOX_ROOT="/tmp/smartbox-supervisor-test"', '-DSTARTUP_SECONDS=1', '-DSTABLE_SECONDS=2']
        subprocess.run([tc + '/bin/riscv32-buildroot-linux-gnu-gcc', *flags, source, '-o', '/tmp/supervisor-rv32'], check=True)
        subprocess.run(['cc', *flags, source, '-o', '/tmp/supervisor-native'], check=True)
        subprocess.run(['cc', '-O2', '/work/experiments/mode/mode_service.c', '-o', '/tmp/mode-native'], check=True)
        for name in ('native', 'rv32'):
            COMMAND = ['/tmp/supervisor-native'] if name == 'native' else [
                '/work/firmwares/research/qemu-andes-build/qemu-riscv32', '-cpu', 'andes-a25',
                '-L', tc + '/riscv32-buildroot-linux-gnu/sysroot', '/tmp/supervisor-rv32']
            print('Supervisor fault injection:', name, flush=True)
            result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(Recovery))
            if not result.wasSuccessful(): raise SystemExit(1)
    else:
        result = subprocess.run(['docker', 'run', '--rm', '--platform', 'linux/amd64', '--network', 'none', '--read-only',
                        '--tmpfs', '/tmp:rw,exec,nosuid,size=64m', '-v', f'{ROOT}:/work:ro',
                        'smartbox-mirror-builder:local', 'python3', '/work/scripts/test_mirroring_supervisor.py', '--guest'],
                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        output = ROOT / 'firmwares/research/supervisor-tests'
        output.mkdir(parents=True, exist_ok=True)
        (output / 'tests.log').write_text(result.stdout)
        (output / 'report.json').write_text(json.dumps({'passed': result.returncode == 0,
            'test_counts_native_rv32': [int(n) for n in re.findall(r'Ran (\d+) tests', result.stdout)],
            'source_sha256': hashlib.sha256((ROOT / 'experiments/mirroring/device_launch.c').read_bytes()).hexdigest(),
            'children': 'disposable native Linux executables/scripts, supervised by native and RV32 builds',
            'hardware_tested': False}, indent=2) + '\n')
        print(result.stdout)
        result.check_returncode()


if __name__ == '__main__': main()
