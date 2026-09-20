"""Real local TCP tests for selective teardown, new keys and retained captures."""
import base64
import hashlib
import json
from pathlib import Path
import plistlib
import socket
import struct
import tempfile
import threading
import time
import unittest
from types import SimpleNamespace
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from mac_carplay_media import BenchMedia
from mac_carplay_observer import USBObserver


class Streams(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.media = BenchMedia('::1', 0, '::1', Path(self.directory.name),
                                threading.Event(), time.monotonic() + 20)
        self.media.key = bytes(range(16))

    def tearDown(self):
        self.media.close()
        self.directory.cleanup()

    def screen(self, stream_id):
        return self.media.setup_streams(dict(streams=[dict(type=110, streamConnectionID=stream_id)]))['streams'][0]['dataPort']

    def send_video(self, port, stream_id):
        def derive(prefix):
            return hashlib.sha512(prefix + str(stream_id).encode() + self.media.key).digest()[:16]
        cipher = Cipher(algorithms.AES(derive(b'AirPlayStreamKey')),
                        modes.CTR(derive(b'AirPlayStreamIV'))).encryptor()
        codec = bytes.fromhex('0164001fffe100046764001f01000268aa')
        nal = bytes.fromhex('0000000265aa')
        def frame(kind, data):
            return struct.pack('<IB', len(data), kind) + bytes(123) + data
        connection = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
        connection.connect(('::1', port))
        connection.sendall(frame(1, codec) + frame(0, cipher.update(nal)))
        group = self.media.streams[110]
        end = time.monotonic() + 2
        while time.monotonic() < end:
            p = group.output / 'screen-packets.jsonl'
            if p.exists() and p.stat().st_size:
                return connection
            time.sleep(.01)
        connection.close()
        self.fail('No decrypted packet')

    def test_recreate_live_video_without_stopping_audio(self):
        timing = self.media.bind(socket.SOCK_DGRAM)
        self.media.setup_streams(dict(streams=[dict(type=100, audioFormat=2048)]))
        audio = self.media.streams[100]
        captures = []
        for stream_id in (123, 456):
            connection = self.send_video(self.screen(stream_id), stream_id)
            group = self.media.streams[110]
            captures.append(group.output)
            self.media.teardown(dict(streams=[dict(type=110)]))
            connection.close()
            self.assertFalse(any(t.is_alive() for t in group.threads))
            self.assertTrue(all(s.fileno() == -1 for s in group.sockets))
            self.assertFalse(audio.closed.is_set())
            self.assertGreaterEqual(timing.fileno(), 0)
            self.assertEqual(self.media.key, bytes(range(16)))
        self.assertNotEqual(*captures)
        for directory in captures:
            packets = [json.loads(x) for x in (directory / 'screen-packets.jsonl').read_text().splitlines()]
            self.assertEqual(len(packets), 1)
            self.assertEqual(base64.b64decode(packets[0]['avcc']), bytes.fromhex('0000000265aa'))
        self.assertEqual(self.media.video_budget['frames'], 1798)
        self.media.teardown(dict(streams=[dict(type=100)]))
        self.media.setup_streams(dict(streams=[dict(type=100, audioFormat=2048)]))

    def test_bad_teardown_is_atomic_and_duplicate_is_safe(self):
        self.screen(10)
        group = self.media.streams[110]
        for data in ([], {'streams': 'bad'}, {'streams': [dict(type=110), dict(type=7)]},
                     {'streams': [dict(type=110, streamConnectionID=11)]}):
            with self.assertRaises(ValueError):
                self.media.teardown(data)
            self.assertFalse(group.closed.is_set())
        with self.assertRaises(ValueError):
            self.screen(11)
        self.media.teardown({'streams': [dict(type=110)]})
        self.media.teardown({'streams': [dict(type=110)]})
        self.screen(11)
        self.media.teardown({})
        self.assertTrue(self.media.closed.is_set())
        self.assertEqual(self.media.streams, {})

    def test_rtsp_dispatch_teardown_then_setup(self):
        self.screen(1)
        observer = USBObserver.__new__(USBObserver)
        observer.auth = SimpleNamespace(cipher=object())
        observer.deadline = time.monotonic() + 3
        observer.stop = threading.Event()
        observer.name, observer.scope, observer.host = 'loopback', 0, '::1'
        observer.records, observer.output = [], Path(self.directory.name)
        observer.media, observer.media_lock = self.media, threading.RLock()
        observer.save_lock = threading.Lock()
        requests = []
        for index, (verb, data) in enumerate([
            ('TEARDOWN', dict(streams=[dict(type=110)])),
            ('SETUP', dict(streams=[dict(type=110, streamConnectionID=2)])),
            ('TEARDOWN', dict(streams=[dict(type=110)]))]):
            body = plistlib.dumps(data, fmt=plistlib.FMT_BINARY)
            requests.append(f'{verb} / RTSP/1.0\r\nCSeq: {index}\r\nContent-Length: {len(body)}\r\n\r\n'.encode() + body)
        a, b = socket.socketpair()
        thread = threading.Thread(target=observer.handle, args=(a, ('::1', 0, 0, 0)))
        thread.start()
        with b:
            b.sendall(b''.join(requests)); b.shutdown(socket.SHUT_WR)
            response = b''
            while data := b.recv(8192):
                response += data
        thread.join(timeout=4)
        self.assertFalse(thread.is_alive())
        self.assertEqual(response.count(b'RTSP/1.0 200 OK'), 3)
        self.assertFalse(self.media.closed.is_set())


if __name__ == '__main__':
    unittest.main()
