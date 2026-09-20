"""Recovery preconditions, offline; no adapter requests or writes."""
import errno
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch, Mock

from recover_updater import Recovery, alternate_url, process_table


class RecoveryGuards(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.recovery = Recovery('http://192.168.5.1', Path(self.folder.name), 'smartBox-9302')

    def test_process_stat_name_with_parentheses(self):
        line = '1745 (Update (Server)) S 1 1745 1745 ' + ' '.join(['0']*15+['4321'])
        proc = process_table('heading\n'+line)[1745]
        self.assertEqual((proc['name'],proc['pgid'],proc['sid'],proc['start_time']), ('Update (Server)',1745,1745,4321))

    def test_wrong_adapter_does_not_run_diagnostic(self):
        self.recovery.read_json = Mock(return_value=dict(hwtype=501, appversioncode=131, appversionstr='2026081801',devicename='smartBox-76F9'))
        self.recovery.diagnostic = Mock()
        with self.assertRaisesRegex(ValueError,'Unexpected adapter'):
            self.recovery.probe()
        self.recovery.diagnostic.assert_not_called()

    def test_active_update_does_not_run_diagnostic(self):
        self.recovery.check_identity = Mock(return_value={})
        self.recovery.read_json = Mock(return_value={'percent':3})
        self.recovery.diagnostic = Mock()
        with self.assertRaisesRegex(ValueError,'still be active'):
            self.recovery.probe()
        self.recovery.diagnostic.assert_not_called()

    def test_wrong_helper_bytes_never_transferred(self):
        self.recovery.diagnostic = Mock()
        with patch('socket.create_connection',side_effect=ConnectionRefusedError(errno.ECONNREFUSED,'refused')), \
             patch.object(Path,'read_bytes',return_value=b'wrong executable'):
            with self.assertRaisesRegex(ValueError,'Unexpected detachment helper'):
                self.recovery.prepare({})
        self.recovery.diagnostic.assert_not_called()

    def test_unknown_existing_listener_not_reused(self):
        self.recovery.diagnostic = Mock()
        with patch('socket.create_connection',return_value=Mock()):
            with self.assertRaisesRegex(ValueError,'already in use'):
                self.recovery.prepare({})
        self.recovery.diagnostic.assert_not_called()

    def test_oversized_filename_rejected_before_request(self):
        self.recovery.http.fetch = Mock()
        with self.assertRaisesRegex(ValueError,'buffer budget'):
            self.recovery.diagnostic('x'*900)
        self.recovery.http.fetch.assert_not_called()

    def test_invalid_origins_rejected(self):
        for url in ('file:///tmp', 'http://user:pass@192.168.5.1', 'http://192.168.5.1/path', 'http://192.168.5.1?host=other'):
            with self.assertRaises(ValueError): alternate_url(url)
        self.assertEqual(alternate_url('http://192.168.5.1'), 'http://192.168.5.1:8082')


if __name__ == '__main__': unittest.main()
