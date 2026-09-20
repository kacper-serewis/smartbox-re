"""Offline checks of authentication and adversarial/persistent RTSP framing."""
import datetime
import hashlib
import socket
import struct
import threading
import time
import unittest
import tempfile
import json
import base64
from pathlib import Path
from types import SimpleNamespace

from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding, rsa, x25519
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from mac_carplay_auth import BenchAuth
from mac_carplay_observer import read_request
from mac_carplay_video import avcc_config, normalize_nals, capture


class Tests(unittest.TestCase):
    def test_exchange_and_replay(self):
        key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
        name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, 'Local bench identity only')])
        now = datetime.datetime.now(datetime.timezone.utc)
        cert = (x509.CertificateBuilder().subject_name(name).issuer_name(name).public_key(key.public_key())
                .serial_number(1).not_valid_before(now).not_valid_after(now + datetime.timedelta(days=1))
                .sign(key, hashes.SHA256()).public_bytes(serialization.Encoding.DER))
        server = BenchAuth(cert, key.private_bytes(serialization.Encoding.DER,
                           serialization.PrivateFormat.PKCS8, serialization.NoEncryption()))
        client = x25519.X25519PrivateKey.generate()
        public = client.public_key().public_bytes_raw()
        for invalid in (b'', b'\x02' + public, b'\x01' + bytes(32)):
            with self.assertRaises(ValueError):
                server.exchange(invalid)
        response = server.exchange(b'\x01' + public)
        n = struct.unpack('>I', response[32:36])[0]
        self.assertEqual(response[36:36+n], cert)
        self.assertEqual(struct.unpack('>I', response[36+n:40+n])[0], 256)
        shared = client.exchange(x25519.X25519PublicKey.from_public_bytes(response[:32]))
        decryptor = Cipher(algorithms.AES(hashlib.sha1(b'AES-KEY' + shared).digest()[:16]),
                           modes.CTR(hashlib.sha1(b'AES-IV' + shared).digest()[:16])).decryptor()
        sig = decryptor.update(response[40+n:])
        key.public_key().verify(sig, response[:32] + public, padding.PKCS1v15(), hashes.SHA1())
        with self.assertRaises(ValueError):
            server.exchange(b'\x01' + public)

    def test_video_bounds(self):
        config = bytes.fromhex('0164001fffe100046764001f01000268aa')
        self.assertEqual(avcc_config(config), (4, bytes.fromhex('6764001f'), bytes.fromhex('68aa')))
        for n in range(len(config)):
            with self.assertRaises(ValueError):
                avcc_config(config[:n])
        self.assertEqual(normalize_nals(b'\x00\x02\x65\xaa', 2), b'\0\0\0\2\x65\xaa')
        for invalid in (b'\0', b'\0\0', b'\0\3\x65\xaa'):
            with self.assertRaises(ValueError):
                normalize_nals(invalid, 2)

    def test_encrypted_capture(self):
        session_key, stream_id = bytes(range(16)), 1234567
        def derive(prefix):
            return hashlib.sha512(prefix + b'1234567' + session_key).digest()[:16]
        encryptor = Cipher(algorithms.AES(derive(b'AirPlayStreamKey')),
                           modes.CTR(derive(b'AirPlayStreamIV'))).encryptor()
        def frame(op, body):
            return struct.pack('<IB', len(body), op) + bytes(123) + body
        codec = bytes.fromhex('0164001fffe100046764001f01000268aa')
        nal = bytes.fromhex('0000000265aa')
        stream = frame(1, codec) + frame(0, encryptor.update(nal)) + frame(0, encryptor.update(nal))
        a, b = socket.socketpair()
        with tempfile.TemporaryDirectory() as directory:
            media = SimpleNamespace(key=session_key, output=Path(directory), active=lambda: True, records=[])
            try:
                b.sendall(stream)
                b.shutdown(socket.SHUT_WR)
                capture(a, media, stream_id)
                packets = [json.loads(line) for line in (Path(directory)/'screen-packets.jsonl').read_text().splitlines()]
                self.assertEqual(len(packets), 2)
                self.assertEqual(base64.b64decode(packets[1]['avcc']), nal)
                self.assertEqual(media.records[-1]['video_frames'], 2)
            finally:
                a.close(); b.close()

    def test_socket_fragments(self):
        a, b = socket.socketpair()
        message = b'POST /test RTSP/1.0\r\nCSeq: 2\r\nContent-Length: 3\r\n\r\nxyz'
        def sender():
            with b:
                for byte in message:
                    b.sendall(bytes([byte]))
        thread = threading.Thread(target=sender)
        thread.start()
        try:
            a.settimeout(0.1)
            frame, pending = read_request(a, b'', time.monotonic()+2, threading.Event())
            self.assertEqual(frame[3], b'xyz')
            self.assertEqual(pending, b'')
        finally:
            a.close()
            thread.join(timeout=2)

    def parse(self, data):
        a, b = socket.socketpair()
        try:
            a.settimeout(0.1)
            b.shutdown(socket.SHUT_WR)
            return read_request(a, data, time.monotonic()+1, threading.Event())
        finally:
            a.close(); b.close()

    def test_framing(self):
        first = b'POST /auth-setup RTSP/1.0\r\nCSeq: 0\r\nContent-Length: 3\r\n\r\nabc'
        second = b'GET /info RTSP/1.0\r\nCSeq: 1\r\n\r\n'
        frame, pending = self.parse(first + second)
        self.assertEqual(frame[3], b'abc')
        self.assertEqual(pending, second)
        for request in (
            first[:-1], b'x'*8193,
            first.replace(b'Content-Length: 3', b'Content-Length: 99999'),
            first.replace(b'CSeq: 0', b'CSeq: 0\r\nCSeq: 1'),
            first.replace(b'CSeq: 0', b'Transfer-Encoding: chunked\r\nCSeq: 0'),
        ):
            with self.assertRaises(ValueError):
                self.parse(request)


if __name__ == '__main__':
    unittest.main()
