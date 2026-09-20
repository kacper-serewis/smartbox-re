#!/usr/bin/env python3
"""Exercise native or QEMU mode service with explicit fake driver hooks."""
import http.client
import json
import os
from pathlib import Path
import selectors
import subprocess
import tempfile
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]
COMMAND = json.loads(os.environ.get("SMARTBOX_MODE_COMMAND", json.dumps([str(ROOT / "firmwares/research/mode-build/smartbox-mode")])))


class ModeService(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.folder = Path(self.temp.name)
        self.state = self.folder / "state"
        self.state.mkdir()
        self.driver = self.folder / "driver"
        self.driver.write_text('''#!/bin/sh
set -eu
printf '%s %s\\n' "$1" "$2" >> "$SMARTBOX_TEST_DIR/journal"
test ! -f "$SMARTBOX_TEST_DIR/fail-$1-$2"
''')
        self.driver.chmod(0o700)
        self.reboot = self.folder / "fake-reboot"
        self.reboot.write_text('''#!/bin/sh
set -eu
cat "$SMARTBOX_TEST_DIR/state/connection-mode" >> "$SMARTBOX_TEST_DIR/reboots"
test ! -f "$SMARTBOX_TEST_DIR/fail-reboot"
''')
        self.reboot.chmod(0o700)
        self.proc = None

    def tearDown(self):
        self.stop()
        self.temp.cleanup()

    def start(self, with_driver=True, runtime_status=None, reboot=False):
        args = COMMAND + ["--state-dir", str(self.state), "--web-dir", str(ROOT / "experiments/mode/web"), "--port", "0", "--lab"]
        if with_driver:
            args += ["--driver", str(self.driver)]
        if runtime_status:
            args += ["--runtime-status", str(runtime_status)]
        if reboot:
            args += ["--reboot-command", str(self.reboot)]
        env = dict(os.environ, SMARTBOX_TEST_DIR=str(self.folder))
        self.proc = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env, bufsize=0)
        deadline = time.monotonic() + 15
        with selectors.DefaultSelector() as sel:
            sel.register(self.proc.stdout, selectors.EVENT_READ)
            while time.monotonic() < deadline:
                if not sel.select(0.1):
                    continue
                line = self.proc.stdout.readline().decode()
                if line.startswith("READY "):
                    self.port = int(line.split(":")[2].split()[0])
                    return
                if not line:
                    break
        self.fail("Service did not become ready: " + self.proc.stderr.read().decode())

    def stop(self):
        if self.proc:
            self.proc.terminate()
            try:
                self.proc.communicate(timeout=8)
            except subprocess.TimeoutExpired:
                self.proc.kill()
                self.proc.communicate()
                self.fail("Service did not stop")
            self.assertEqual(self.proc.returncode, 0)
            self.proc = None

    def request(self, method="GET", path="/api/mode", body=None, headers=None):
        conn = http.client.HTTPConnection("127.0.0.1", self.port, timeout=5)
        try:
            conn.request(method, path, body=body, headers=headers or {})
            response = conn.getresponse()
            data = response.read()
            return response.status, json.loads(data) if path == "/api/mode" else data
        finally:
            conn.close()

    def select(self, mode):
        return self.request("POST", body=f"mode={mode}", headers={"X-SmartBox-Mode": "1"})

    def until(self, predicate, seconds=5):
        deadline = time.monotonic() + seconds
        while time.monotonic() < deadline:
            if predicate():
                return
            time.sleep(0.05)
        self.fail("Condition timed out")

    def test_save_acknowledged_before_single_delayed_reboot(self):
        self.start(reboot=True)
        self.assertTrue(self.request()[1]['restart_on_save'])
        status, state = self.select('mirroring')
        self.assertEqual(status, 200)
        self.assertTrue(state['restarting'])
        self.assertEqual(state['active'], 'carplay')
        self.assertFalse((self.folder / 'reboots').exists())
        self.assertEqual(self.select('carplay')[0], 409)
        self.until(lambda: (self.folder / 'reboots').exists())
        self.assertEqual((self.folder / 'reboots').read_text(), 'mirroring\n')
        self.assertEqual(self.select('carplay')[0], 409)
        self.stop()
        self.start(reboot=True)
        state = self.request()[1]
        self.assertEqual(state['active'], 'mirroring')
        self.assertFalse(state['restarting'])
        self.assertEqual(self.select('carplay')[0], 200)
        self.until(lambda: (self.folder / 'reboots').read_text() == 'mirroring\ncarplay\n')

    def test_reboot_failure_preserves_selection_and_allows_retry(self):
        (self.folder / 'fail-reboot').touch()
        self.start(reboot=True)
        self.assertEqual(self.select('mirroring')[0], 200)
        self.until(lambda: self.request()[1]['error'] == 'restart_failed')
        state = self.request()[1]
        self.assertFalse(state['restarting'])
        self.assertEqual(state['selected'], 'mirroring')
        (self.folder / 'fail-reboot').unlink()
        self.assertTrue(self.select('mirroring')[1]['restarting'])
        self.until(lambda: (self.folder / 'reboots').read_text() == 'mirroring\nmirroring\n')

    def test_failed_and_rejected_saves_never_reboot(self):
        self.start(reboot=True)
        self.assertEqual(self.select('invalid')[0], 400)
        self.assertEqual(self.request('POST', body='mode=mirroring')[0], 403)
        self.assertEqual(self.request('POST', body='mode=mirroring', headers={
            'X-SmartBox-Mode': '1', 'Origin': 'http://unrelated.invalid'})[0], 403)
        (self.state / 'connection-mode').mkdir()
        self.assertEqual(self.select('mirroring')[0], 500)
        time.sleep(2.3)
        self.assertFalse((self.folder / 'reboots').exists())
        self.assertFalse(self.request()[1]['restarting'])

    def test_incomplete_startup_and_missing_reboot_command_block_save(self):
        self.start(reboot=True)
        (self.state / 'boot-pending').touch()
        self.assertEqual(self.select('mirroring')[0], 409)
        (self.state / 'boot-pending').unlink()
        self.reboot.unlink()
        self.assertEqual(self.select('mirroring')[0], 503)
        self.assertFalse((self.state / 'connection-mode').exists())
        self.assertFalse(self.request()[1]['restarting'])

    def test_accepted_reboot_that_does_not_happen_reports_failure(self):
        self.start(reboot=True)
        self.assertEqual(self.select('mirroring')[0], 200)
        self.until(lambda: self.request()[1]['error'] == 'restart_failed', seconds=20)
        self.assertEqual((self.folder / 'reboots').read_text(), 'mirroring\n')
        self.assertFalse(self.request()[1]['restarting'])

    def test_runtime_pin_and_status_are_bounded(self):
        status = self.folder / 'runtime.json'
        self.start(runtime_status=status)
        self.assertEqual(self.request(path='/api/mirror')[0], 503)
        status.write_text('{"state":"pairing","pin":"1234"}\n')
        code, body = self.request(path='/api/mirror')
        self.assertEqual(code, 200)
        self.assertEqual(json.loads(body)['pin'], '1234')
        status.write_text('x' * 1024)
        self.assertEqual(self.request(path='/api/mirror')[0], 503)

    def test_selection_persists_and_only_applies_after_restart(self):
        self.start()
        self.assertEqual(self.request()[1]["active"], "carplay")
        status, state = self.select("mirroring")
        self.assertEqual(status, 200)
        self.assertEqual((state["selected"], state["active"], state["pending"]), ("mirroring", "carplay", True))
        self.assertEqual((self.state / "connection-mode").read_text(), "mirroring\n")
        self.assertNotIn("start mirroring", (self.folder / "journal").read_text())
        self.stop()
        self.start()
        state = self.request()[1]
        self.assertEqual((state["selected"], state["active"], state["pending"]), ("mirroring", "mirroring", False))
        self.assertEqual(self.select("carplay")[0], 200)
        self.stop()
        self.start()
        self.assertEqual(self.request()[1]["active"], "carplay")

    def test_failed_mirroring_falls_back_without_forgetting_selection(self):
        (self.state / "connection-mode").write_text("mirroring\n")
        (self.folder / "fail-start-mirroring").touch()
        self.start()
        state = self.request()[1]
        self.assertEqual((state["selected"], state["active"], state["error"]), ("mirroring", "carplay", "start_failed"))
        self.assertIn("start mirroring\nstop mirroring\nstart carplay", (self.folder / "journal").read_text())

    def test_missing_integration_never_claims_mirroring_works(self):
        self.start(with_driver=False)
        state = self.request()[1]
        self.assertEqual(state["active"], "unknown")
        self.assertFalse(state["available"]["mirroring"])
        self.assertEqual(self.select("mirroring")[0], 409)
        self.assertFalse((self.state / "connection-mode").exists())

    def test_invalid_saved_mode_uses_carplay(self):
        (self.state / "connection-mode").write_text("anything-else\n")
        self.start()
        self.assertEqual(self.request()[1]["selected"], "carplay")
        self.assertEqual(self.request()[1]["error"], "invalid_settings")
        self.assertEqual(self.select("carplay")[1]["error"], "none")

    def test_failed_cleanup_does_not_start_conflicting_mode(self):
        (self.state / "connection-mode").write_text("mirroring\n")
        (self.folder / "fail-start-mirroring").touch()
        (self.folder / "fail-stop-mirroring").touch()
        self.start()
        state = self.request()[1]
        self.assertEqual((state["active"], state["error"]), ("unknown", "cleanup_failed"))
        self.assertNotIn("start carplay", (self.folder / "journal").read_text())

    def test_invalid_requests_do_not_change_state(self):
        self.start()
        for value in ("android", "mirroring&mode=carplay", "../mirroring", "mirroring\x00"):
            self.assertEqual(self.select(value)[0], 400)
        self.assertEqual(self.request("POST", body="mode=mirroring")[0], 403)
        self.assertEqual(self.request("POST", body="mode=mirroring", headers={"X-SmartBox-Mode": "1", "Origin": "http://unrelated.invalid"})[0], 403)
        self.assertEqual(self.request()[1]["selected"], "carplay")

    def test_unwritable_target_does_not_report_success(self):
        self.start()
        (self.state / "connection-mode").mkdir()
        self.assertEqual(self.select("mirroring")[0], 500)
        self.assertEqual(self.request()[1]["selected"], "carplay")
        self.assertEqual(list(self.state.glob(".mode.*")), [])

    def test_rejected_post_with_delayed_body_receives_complete_response(self):
        self.start()
        conn = http.client.HTTPConnection("127.0.0.1", self.port, timeout=5)
        try:
            body = b"mode=mirroring"
            conn.putrequest("POST", "/api/mode")
            conn.putheader("Content-Length", str(len(body)))
            conn.endheaders()
            time.sleep(0.03)  # ensure headers/body arrive in different reads
            conn.send(body)
            response = conn.getresponse()
            self.assertEqual(response.status, 403)
            self.assertIn("Same-origin", json.loads(response.read())["message"])
        finally:
            conn.close()
        self.assertEqual(self.request()[1]["selected"], "carplay")

    def test_serves_ui_and_prevents_path_traversal(self):
        self.start()
        self.assertIn(b"Screen Mirroring", self.request(path="/")[1])
        self.assertIn(b"/api/mode", self.request(path="/mode.js")[1])
        self.assertEqual(self.request(path="/../connection-mode")[0], 404)


if __name__ == "__main__":
    unittest.main()
