#!/usr/bin/env python3
"""Verify upgrade ordering and refusal paths without touching a device."""
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch

import update_mirroring as u


class Upgrade(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.r = Mock(output=Path(self.temp.name))
        self.r.read_json.return_value = {}
        self.events = []
        self.r.diagnostic.side_effect = self.diagnostic
        self.supervisor = dict(pid=42, name='CPAAProxyEx', ppid=1, pgid=42, sid=1, start_time=100, state='S')
        self.app = dict(pid=43, name='CPAAProxyEx', ppid=42, pgid=43, sid=1, start_time=105, state='S')
        self.metadata = dict(sha256=u.RELEASE_SHA, version=131, app_size=1024, app_md5='image-md5', chunk_metadata={'count': 2})
        self.device = Mock()
        self.device.request.side_effect = self.status
        self.progress = dict(shutdown_requested=False, flash_requested=False)

    def diagnostic(self, command):
        if command.startswith('test ! -e'): return 'CLEAN\n'
        if command == 'md5sum /proc/42/exe': return u.SUPERVISOR_MD5 + '  /proc/42/exe\n'
        if command == 'md5sum /proc/43/exe': return u.APP_MD5 + '  /proc/43/exe\n'
        if 'kill -TERM 42' in command: return 'STOP_REQUESTED\n'
        if command.startswith('dd '):
            self.events.append('readback')
            return 'image-md5  -\n'
        self.fail('Unexpected diagnostic: ' + command)

    def status(self, *args):
        self.events.append('confirm-staged')
        return dict(version=131, pos=1, count=2)

    def run_upgrade(self):
        with patch.object(u, 'stage', side_effect=lambda *a: self.events.append('upload')), \
             patch.object(u, 'stop_supervisor', side_effect=lambda *a: self.events.append('stop')), \
             patch.object(u, 'apply', side_effect=lambda *a: self.events.append('flash')):
            u.upgrade(self.r, self.device, self.metadata, b'image', self.supervisor, self.progress)

    def test_healthy_preflight_never_stops_or_flashes(self):
        with patch.object(u, 'processes', return_value={42:self.supervisor, 43:self.app}):
            self.assertEqual(u.preflight(self.r), self.supervisor)
        self.assertFalse(any('kill' in c.args[0] for c in self.r.diagnostic.call_args_list))

    def test_active_update_refused(self):
        self.r.read_json.return_value = {'percent': 3}
        with self.assertRaises(ValueError): u.preflight(self.r)
        self.r.diagnostic.assert_not_called()

    def test_recovery_is_never_cleared(self):
        self.r.diagnostic.side_effect = None
        self.r.diagnostic.return_value = ''
        with self.assertRaises(ValueError): u.preflight(self.r)
        self.assertFalse(any('rm ' in c.args[0] for c in self.r.diagnostic.call_args_list))

    def test_wrong_supervisor_refused(self):
        self.r.diagnostic.side_effect = lambda command: 'CLEAN' if command.startswith('test !') else 'wrong-hash'
        with patch.object(u, 'processes', return_value={42:self.supervisor, 43:self.app}), self.assertRaises(ValueError):
            u.preflight(self.r)

    def test_stop_signals_only_verified_pid_and_waits(self):
        running = dict(self.supervisor, state='R')
        with patch.object(u, 'processes', side_effect=[{42:running,43:self.app},{}]):
            u.stop_supervisor(self.r, self.supervisor)
        signals = [c.args[0] for c in self.r.diagnostic.call_args_list if 'kill' in c.args[0]]
        self.assertEqual(len(signals), 1)
        self.assertIn('kill -TERM 42 &&', signals[0])
        self.assertNotIn('kill -TERM -', signals[0])

    def test_reused_pid_refused(self):
        with patch.object(u, 'processes', return_value={42:dict(self.supervisor,start_time=999)}), self.assertRaises(ValueError):
            u.stop_supervisor(self.r, self.supervisor)
        self.assertFalse(any('kill' in c.args[0] for c in self.r.diagnostic.call_args_list))

    def test_upload_stop_confirm_flash_readback_order(self):
        self.run_upgrade()
        self.assertEqual(self.events, ['upload','stop','confirm-staged','flash','readback'])
        self.assertTrue((self.r.output/'result.json').exists())

    def test_failed_upload_does_not_stop_application(self):
        with patch.object(u,'stage',side_effect=ValueError('upload failed')), patch.object(u,'stop_supervisor') as stop, self.assertRaises(ValueError):
            u.upgrade(self.r,self.device,self.metadata,b'image',self.supervisor,self.progress)
        stop.assert_not_called()
        self.assertFalse(self.progress['shutdown_requested'])

    def test_lost_staged_state_never_flashes(self):
        self.device.request.side_effect = lambda *a: {}
        with self.assertRaises(ValueError): self.run_upgrade()
        self.assertNotIn('flash',self.events)
        self.assertFalse(self.progress['flash_requested'])

    def test_bad_readback_never_reports_success(self):
        original = self.diagnostic
        self.r.diagnostic.side_effect = lambda command: 'wrong-md5' if command.startswith('dd ') else original(command)
        with self.assertRaises(ValueError): self.run_upgrade()
        self.assertTrue(self.progress['flash_requested'])
        self.assertFalse((self.r.output/'result.json').exists())


if __name__ == '__main__':
    unittest.main()
