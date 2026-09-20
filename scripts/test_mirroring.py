#!/usr/bin/env python3
"""Offline parser tests and a local RTSP/PIN smoke test for the built receiver."""
import json
from pathlib import Path
import plistlib
import selectors
import socket
import subprocess
import tempfile
import time
import unittest

from capture_mirroring import BINARY
from inspect_h264 import inspect, parse_sps


def ue(value):
    binary = f"{value + 1:b}"
    return "0" * (len(binary) - 1) + binary


def sps(width, coded_height, crop_bottom=0, profile=66):
    fields = f"{profile:08b}" + "00000000" + f"{31:08b}" + ue(0)
    if profile == 100:
        fields += ue(1) + ue(0) + ue(0) + "00"
    fields += ue(0) + ue(0) + ue(0) + ue(1) + "0"
    fields += ue(width // 16 - 1) + ue(coded_height // 16 - 1) + "11"
    fields += ("1" + ue(0) + ue(0) + ue(0) + ue(crop_bottom)) if crop_bottom else "0"
    fields += "01"  # no VUI, rbsp stop bit
    fields += "0" * (-len(fields) % 8)
    raw = int(fields, 2).to_bytes(len(fields) // 8, "big")
    escaped, zeros = bytearray(), 0
    for byte in raw:
        if zeros == 2 and byte <= 3:
            escaped.append(3)
            zeros = 0
        escaped.append(byte)
        zeros = zeros + 1 if byte == 0 else 0
    return b"\x67" + escaped


class ParameterSets(unittest.TestCase):
    def test_baseline_800x480(self):
        self.assertTrue(parse_sps(sps(800, 480))["matches_800x480"])

    def test_high_profile_crop(self):
        info = parse_sps(sps(1920, 1088, 4, 100))
        self.assertEqual(info["visible_size"], [1920, 1080])
        self.assertEqual(info["coded_size"], [1920, 1088])
        self.assertEqual(info["bit_depth_luma"], 8)

    def test_rotation_and_duplicate_parameter_sets(self):
        wide, tall = sps(800, 480), sps(480, 800)
        stream = b"\x00\x00\x00\x01" + wide + b"\x00\x00\x01" + wide
        stream += b"\x00\x00\x01" + tall
        report = inspect(stream)
        self.assertEqual(report["nal_counts"], {"7": 3})
        self.assertEqual([x["visible_size"] for x in report["sps"]], [[800, 480], [480, 800]])

    def test_truncated_and_empty(self):
        self.assertEqual(inspect(b"")["sps"], [])
        self.assertEqual(len(inspect(b"\x00\x00\x01\x67\x42")["errors"]), 1)
        with self.assertRaises(ValueError):
            parse_sps(b"\x67\x42\x00\x1f" + b"\x00" * 10)


@unittest.skipUnless(BINARY.is_file(), "Build receiver first")
class ReceiverSmoke(unittest.TestCase):
    def test_info_pin_and_clean_stop(self):
        with tempfile.TemporaryDirectory() as folder:
            proc = subprocess.Popen([str(BINARY), "SmartBox Test", "02:00:00:01:02:03", "15", "2", "1024", "0"],
                                    cwd=folder, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, bufsize=0)
            transcript = bytearray()
            try:
                with selectors.DefaultSelector() as selector:
                    selector.register(proc.stdout, selectors.EVENT_READ)
                    deadline, port = time.monotonic() + 10, None
                    while time.monotonic() < deadline:
                        if not selector.select(0.1):
                            continue
                        line = proc.stdout.readline()
                        if not line:
                            break
                        transcript.extend(line)
                        if line.startswith(b"READY "):
                            port = int(line.split(b"port=")[1].split()[0])
                            break
                self.assertIsNotNone(port, transcript.decode())

                def request(method, path):
                    with socket.create_connection(("127.0.0.1", port), timeout=3) as sock:
                        sock.sendall(f"{method} {path} RTSP/1.0\r\nCSeq: 1\r\nContent-Length: 0\r\n\r\n".encode())
                        with sock.makefile("rb") as response:
                            self.assertIn(b"200", response.readline())
                            size = 0
                            while (line := response.readline()) != b"\r\n":
                                self.assertTrue(line)
                                if line.lower().startswith(b"content-length:"):
                                    size = int(line.split(b":", 1)[1])
                            return response.read(size)

                info = plistlib.loads(request("GET", "/info"))
                display = info["displays"][0]
                self.assertEqual([display["widthPixels"], display["heightPixels"], display["maxFPS"]], [800, 480, 30])
                self.assertTrue(info["features"] & (1 << 7))
                self.assertTrue(info["features"] & (1 << 27))
                self.assertFalse(info["features"] & ((1 << 42) | (1 << 4) | 1))
                request("POST", "/pair-pin-start")
            finally:
                proc.terminate()
                tail, _ = proc.communicate(timeout=10)
                transcript.extend(tail)
            self.assertEqual(proc.returncode, 0, transcript.decode())
            self.assertRegex(transcript.decode(), r"Enter this AirPlay PIN on your iPhone: \d{4}")
            summary = json.loads(Path(folder, "receiver-summary.json").read_text())
            self.assertEqual(summary["bytes"], 0)
            self.assertFalse(summary["failed"])


if __name__ == "__main__":
    unittest.main()
