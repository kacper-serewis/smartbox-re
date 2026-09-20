#!/usr/bin/env python3
"""Archive boundary checks and optional regression checks on pinned real images."""
import io
from pathlib import Path
import tarfile
import tempfile
import unittest

import compare_carlinkit_audio as analysis


def archive_bytes(entries):
    stream = io.BytesIO()
    with tarfile.open(fileobj=stream, mode='w:gz') as archive:
        for name, kind, content in entries:
            member = tarfile.TarInfo(name)
            if kind == 'link':
                member.type = tarfile.SYMTYPE
                member.linkname = content
                archive.addfile(member)
            else:
                member.size = len(content)
                archive.addfile(member, io.BytesIO(content))
    return stream.getvalue()


class ArchiveTests(unittest.TestCase):
    def test_rejects_path_traversal_and_absolute_paths(self):
        for name in ('../../outside', '/tmp/outside'):
            with self.subTest(name=name), self.assertRaises(ValueError):
                analysis.extract_files(archive_bytes([(name, 'file', b'x')]))

    def test_does_not_follow_links(self):
        raw = archive_bytes([('etc/link', 'link', '/etc/passwd'), ('etc/version', 'file', b'1')])
        files, inventory = analysis.extract_files(raw)
        self.assertEqual(files, {'etc/version': b'1'})
        self.assertEqual(inventory['etc/link']['target'], '/etc/passwd')
        self.assertEqual(inventory['etc/link']['type'], 'symlink')

    def test_rejects_duplicate_members(self):
        with self.assertRaises(ValueError):
            analysis.extract_files(archive_bytes([('file', 'file', b'a'), ('file', 'file', b'b')]))

    def test_rejects_wrong_cached_image_without_downloading(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            version = next(iter(analysis.RELEASES))
            (root / version).mkdir()
            (root / version / 'U2W_AUTOKIT_Update.img').write_bytes(b'incorrect image')
            with self.assertRaisesRegex(ValueError, 'size/hash mismatch'):
                analysis.get_image(root, version)

    def test_rejects_incomplete_packed_header(self):
        for data in (b'', b'\x7fELF\x01\x01\x01', bytes(184)):
            with self.subTest(length=len(data)), self.assertRaises(ValueError):
                analysis.decode_load_segments(data)


class RealImageTests(unittest.TestCase):
    def test_pinned_images_and_sony_disassembly(self):
        cache = analysis.ROOT / 'firmwares/carlinkit'
        if not all((cache / v / 'U2W_AUTOKIT_Update.img').exists() for v in analysis.RELEASES):
            self.skipTest('Run compare_carlinkit_audio.py to download pinned images first')
        expected = {
            '2022.01.24.1903': '6e5fafa8a698199fdcb0ca4d5e4c962b6bd4d00eafaa6b916537709ea6caa47b',
            '2022.06.08.1109': 'ece7cd0c8a2fdf80e9520afa8058666364d7d09fcdb9b85da74c5e8de9ec9377',
        }
        for version in analysis.RELEASES:
            with self.subTest(version=version):
                packed = (cache / version / 'U2W_AUTOKIT_Update.img').read_bytes()
                size, digest = analysis.RELEASES[version]
                self.assertEqual((len(packed), analysis.sha(packed)), (size, digest))
                full = len(packed) // 16 * 16
                raw = analysis.aes_decrypt(packed[:full], b'CarPlay5KBP6ClJv\0', b'CarPlay5KBP6ClJv\0') + packed[full:]
                files, inventory = analysis.extract_files(raw)
                self.assertEqual(len(inventory), 81)
                self.assertEqual(files['etc/software_version'].decode().strip(), version)
                decoded, blocks = analysis.decode_load_segments(files['usr/sbin/fakeiOSDevice'])
                self.assertEqual(analysis.sha(decoded), expected[version])
                self.assertEqual(blocks[1]['encrypted_prefix'], 8192)
                if version == '2022.01.24.1903':
                    self.assertNotIn(b'SONY CAR AUDIO', decoded)
                else:
                    evidence = analysis.ArmEvidence(decoded).disassemble(0x410ac, 0x410e4)
                    self.assertIn("'SONY CAR AUDIO'", evidence)
                    self.assertIn('; strstr', evidence)
                    self.assertEqual(evidence.count('orr      r2, r2, #0x800'), 2)
                    self.assertIn("'MediaQuality'", evidence)


if __name__ == '__main__':
    unittest.main()
