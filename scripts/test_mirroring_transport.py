#!/usr/bin/env python3
"""Send generated H.264 through real encrypted mirroring TCP and decode capture.

This enters UxPlay after session/key negotiation. It does NOT test Apple pairing,
iOS resolution selection, the stock adapter, or the car-facing connection.
"""
import argparse
import base64
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess

from capture_mirroring import BUILD, ROOT
from inspect_h264 import inspect


def annexb(avcc):
    result, pos = bytearray(), 0
    while pos < len(avcc):
        size = struct.unpack_from(">I", avcc, pos)[0]
        pos += 4
        if not 0 < size <= len(avcc) - pos:
            raise ValueError("Invalid generated AVCC NAL length")
        result.extend(b"\x00\x00\x00\x01" + avcc[pos:pos + size])
        pos += size
    return bytes(result)


def header(payload, kind, index, width, height):
    data = bytearray(128)
    struct.pack_into("<I", data, 0, len(payload))
    data[4] = kind
    struct.pack_into("<Q", data, 8, (1000 << 32) + ((index << 32) // 30))
    if kind == 1:
        data[6:8] = b"\x16\x01"
        for offset in (16, 40, 56):
            struct.pack_into("<ff", data, offset, width, height)
    return data + payload


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--riscv', action='store_true', help='test the RV32 receiver with stock crypto under Andes QEMU')
    args = parser.parse_args()
    os.umask(0o077)
    output = ROOT / "device-snapshots" / ("transport-test-" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ"))
    output.mkdir(parents=True)
    fixture_binary = BUILD / "video-fixture"
    subprocess.run(["swiftc", "-O", str(ROOT / "experiments/mirroring/video_fixture.swift"),
                    "-o", str(fixture_binary)], check=True)
    subprocess.run([str(fixture_binary), "generate", str(output / "source.json")], check=True)
    frames = json.loads((output / "source.json").read_text())
    # Independent sender encryption: hashlib + OpenSSL CLI, not UxPlay's cipher wrapper.
    key_material = bytes(range(16))
    stream_id = b"123456789"
    key = hashlib.sha512(b"AirPlayStreamKey" + stream_id + key_material).digest()[:16]
    iv = hashlib.sha512(b"AirPlayStreamIV" + stream_id + key_material).digest()[:16]
    plaintext = b"".join(base64.b64decode(frame["avcc"]) for frame in frames)
    encrypted = subprocess.run(["openssl", "enc", "-aes-128-ctr", "-K", key.hex(), "-iv", iv.hex(), "-nopad"],
                               input=plaintext, stdout=subprocess.PIPE, check=True).stdout
    wire, expected = bytearray(), bytearray()
    expected_packets, offset, previous = [], 0, None
    for index, frame in enumerate(frames):
        sps, pps, avcc = (base64.b64decode(frame[k]) for k in ("sps", "pps", "avcc"))
        prefix = b""
        if previous != (sps, pps) or index % 24 == 0:
            config = b"\x01" + sps[1:4] + b"\xff\xe1" + struct.pack(">H", len(sps)) + sps
            config += b"\x01" + struct.pack(">H", len(pps)) + pps
            wire += header(config, 1, index, frame["width"], frame["height"])
            prefix = b"\x00\x00\x00\x01" + sps + b"\x00\x00\x00\x01" + pps
            previous = (sps, pps)
        wire += header(encrypted[offset:offset + len(avcc)], 0, index, frame["width"], frame["height"])
        offset += len(avcc)
        packet = prefix + annexb(avcc)
        expected_packets.append(packet)
        expected += packet
    (output / "input.wire").write_bytes(wire)
    command = [str(BUILD / "test-transport"), str(output / "input.wire"), str(len(frames))]
    if args.riscv:
        sysroot = '/work/firmwares/research/mirror-deps/riscv32-ilp32d--glibc--bleeding-edge-2021.11-1/riscv32-buildroot-linux-gnu/sysroot'
        command = ['docker', 'run', '--rm', '--platform', 'linux/amd64', '--network', 'none',
                   '-v', f'{ROOT}:/work:ro', '-v', f'{output}:/capture', '-w', '/capture',
                   'smartbox-emulation:local', 'timeout', '--signal=KILL', '25', '/work/firmwares/research/qemu-andes-build/qemu-riscv32',
                   '-cpu', 'andes-a25', '-L', sysroot, '-E', f'LD_LIBRARY_PATH=/work/firmwares/hw501/131/rootfs/lib:{sysroot}/lib',
                   '/work/firmwares/research/mirroring-riscv/test-transport', '/capture/input.wire', str(len(frames))]
    subprocess.run(command, cwd=output, check=True, timeout=35)
    captured = (output / "video.h264").read_bytes()
    assert captured == expected, "Capture differs from encoded source after decrypt/framing"
    events = [json.loads(line) for line in (output / "events.jsonl").read_text().splitlines()]
    packets = [event for event in events if event["event"] == "packet"]
    dimensions = [event["display"] for event in events if event["event"] == "dimensions"]
    assert len(packets) == 72
    assert dimensions == [[800, 480], [480, 800], [800, 480]], dimensions
    decode_frames, sps, pps, next_offset = [], None, None, 0
    for event, expected_packet in zip(packets, expected_packets):
        assert event["offset"] == next_offset
        packet = captured[next_offset:next_offset + event["length"]]
        assert packet == expected_packet
        next_offset += event["length"]
        nals = re.split(b"\x00\x00(?:\x00)?\x01", packet)[1:]
        assert event["nals"] == len(nals)
        avcc = bytearray()
        for nal in nals:
            kind = nal[0] & 31
            if kind == 7:
                sps = nal
            elif kind == 8:
                pps = nal
            else:
                avcc.extend(struct.pack(">I", len(nal)) + nal)
        assert sps and pps
        decode_frames.append({"width": 0, "height": 0, "sps": base64.b64encode(sps).decode(),
                              "pps": base64.b64encode(pps).decode(), "avcc": base64.b64encode(avcc).decode()})
    for first, second in zip(packets, packets[1:]):
        assert abs(second["remote_ns"] - first["remote_ns"] - 1_000_000_000 / 30) < 2
    (output / "captured.json").write_text(json.dumps(decode_frames))
    decoded = json.loads(subprocess.check_output([str(fixture_binary), "decode", str(output / "captured.json")], text=True))
    assert not decoded["errors"] and len(decoded["decoded"]) == 72
    expected_sizes = [[800, 480]] * 24 + [[480, 800]] * 24 + [[800, 480]] * 24
    assert [[x["width"], x["height"]] for x in decoded["decoded"]] == expected_sizes
    assert len({x["pixel_sum"] for x in decoded["decoded"]}) >= 20, "Decoded image is not changing"
    report = {"result": "passed", "receiver_platform": "RV32 Andes QEMU with stock libcrypto" if args.riscv else "macOS",
              "generated_frames": len(frames), "decoded_frames": len(decoded["decoded"]),
              "capture_bytes": len(captured), "sha256": hashlib.sha256(captured).hexdigest(),
              "dimension_transitions": dimensions, "aes_packet_length_residues": sorted({len(base64.b64decode(f["avcc"])) % 16 for f in frames}),
              "checks": ["real Apple VideoToolbox H.264 encoder", "independently encrypted AES-CTR stream",
                         "fragmented TCP through UxPlay mirror receiver", "byte-exact capture and callback boundaries",
                         "nanosecond timestamp spacing", "landscape/portrait/landscape config changes",
                         "real Apple VideoToolbox decode of captured video"],
              "not_tested": ["AirPlay pairing/key negotiation", "iOS 27", "dongle execution", "Corsa video output"],
              "video_analysis": inspect(captured)}
    (output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    print(f"Evidence saved: {output}")


if __name__ == "__main__":
    main()
