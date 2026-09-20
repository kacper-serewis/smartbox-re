"""AirPlay auth-setup bench identity; not an Apple-certified receiver identity.

Wire reference: catplay-labs/catplay core/catplay_hap/src/backend/auth_setup.rs.
The locally generated RSA certificate is accepted only if the test peer permits it.
"""
import hashlib
import struct

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding, rsa, x25519
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes


class BenchAuth:
    def __init__(self, certificate, private_key):
        self.certificate = certificate
        self.key = serialization.load_der_private_key(private_key, password=None)
        if not isinstance(self.key, rsa.RSAPrivateKey) or self.key.key_size != 2048:
            raise ValueError('Expected the generated RSA-2048 bench key')
        if not 640 < len(certificate) <= 2048:
            raise ValueError('Unexpected bench certificate size')
        self.cipher = None

    def exchange(self, request):
        if self.cipher is not None:
            raise ValueError('Authentication already performed on this connection')
        if len(request) != 33 or request[0] != 1:
            raise ValueError('Expected version-1 auth-setup with 32-byte public key')
        secret = x25519.X25519PrivateKey.generate()
        public = secret.public_key().public_bytes_raw()
        shared = secret.exchange(x25519.X25519PublicKey.from_public_bytes(request[1:]))
        key = hashlib.sha1(b'AES-KEY' + shared).digest()[:16]
        iv = hashlib.sha1(b'AES-IV' + shared).digest()[:16]
        cipher = Cipher(algorithms.AES(key), modes.CTR(iv)).encryptor()
        signature = self.key.sign(public + request[1:], padding.PKCS1v15(), hashes.SHA1())
        encrypted = cipher.update(signature)
        self.cipher = cipher
        return (public + struct.pack('>I', len(self.certificate)) + self.certificate
                + struct.pack('>I', len(encrypted)) + encrypted)
