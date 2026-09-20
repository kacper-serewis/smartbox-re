"""Bounded H.264 AirPlay screen stream reader for an owned-dongle bench session."""
import base64
from contextlib import closing
import hashlib
import json
import os
import select
import shutil
import subprocess
import time
import socket
import struct
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes


def avcc_config(data):
    if len(data) < 7 or data[0] != 1:
        raise ValueError('Expected AVCDecoderConfigurationRecord')
    length_size = (data[4] & 3) + 1
    pos, groups = 6, []
    count = data[5] & 31
    for group in range(2):
        values = []
        for _ in range(count):
            if pos + 2 > len(data):
                raise ValueError('Truncated codec parameter length')
            size = int.from_bytes(data[pos:pos+2], 'big')
            pos += 2
            if not size or pos + size > len(data):
                raise ValueError('Truncated codec parameter')
            values.append(data[pos:pos+size])
            pos += size
        groups.append(values)
        if group == 0:
            if pos >= len(data):
                raise ValueError('Missing picture parameter count')
            count = data[pos]
            pos += 1
    if not all(groups):
        raise ValueError('Missing H.264 parameters')
    return length_size, groups[0][0], groups[1][0]


def normalize_nals(data, length_size):
    result, pos = bytearray(), 0
    while pos < len(data):
        if pos + length_size > len(data):
            raise ValueError('Truncated NAL length')
        size = int.from_bytes(data[pos:pos+length_size], 'big')
        pos += length_size
        if not size or pos + size > len(data):
            raise ValueError('Invalid NAL length: stream decryption or framing mismatch')
        result.extend(size.to_bytes(4, 'big'))
        result.extend(data[pos:pos+size])
        pos += size
    return bytes(result)


class PreviewDecoder:
    def __init__(self, output):
        self.process = None
        self.log = None
        binary = output / 'screen-decoder'
        if binary.exists():
            self.log = (output / 'decoder.log').open('w')
            self.process = subprocess.Popen([str(binary), str(output)], stdin=subprocess.PIPE,
                                            stdout=self.log, stderr=self.log)
            os.set_blocking(self.process.stdin.fileno(), False)

    def send(self, line):
        if not self.process:
            return
        pending = memoryview(line.encode())
        deadline = time.monotonic() + 1
        descriptor = self.process.stdin.fileno()
        while pending:
            if time.monotonic() >= deadline or self.process.poll() is not None:
                raise OSError('Preview decoder stopped or stalled')
            if not select.select([], [descriptor], [], 0.1)[1]:
                continue
            try:
                pending = pending[os.write(descriptor, pending):]
            except BlockingIOError:
                continue

    def close(self):
        if self.process:
            self.process.stdin.close()
            try:
                self.process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                self.process.terminate()
                self.process.wait(timeout=2)
            self.log.close()


def capture(connection, media, stream_id):
    def key(prefix):
        return hashlib.sha512(prefix + str(stream_id).encode('ascii') + media.key).digest()[:16]
    decryptor = Cipher(algorithms.AES(key(b'AirPlayStreamKey')), modes.CTR(key(b'AirPlayStreamIV'))).decryptor()
    def read_exact(size):
        data = bytearray()
        while len(data) < size and media.active():
            try:
                block = connection.recv(min(65536, size-len(data)))
            except socket.timeout:
                continue
            if not block:
                if data:
                    raise ValueError('Truncated screen frame')
                return None
            data.extend(block)
        return bytes(data) if len(data) == size else None

    config, frames, total = None, 0, 0
    budget = getattr(media, "video_budget", dict(bytes=32*1024*1024, frames=1800))
    preview_output = getattr(media, 'preview_output', media.output)
    if (preview_output / 'screen-decoder').exists():
        for name in ('decoder.json', 'frame.jpg'):
            (preview_output / name).unlink(missing_ok=True)
    try:
        with closing(PreviewDecoder(getattr(media, 'preview_output', media.output))) as preview, (media.output / 'screen-packets.jsonl').open('w') as decoded, (media.output / 'screen-wire.bin').open('wb') as wire:
            while media.active() and budget["frames"] > 0 and budget["bytes"] >= 128:
                header = read_exact(128)
                if header is None:
                    break
                length = struct.unpack('<I', header[:4])[0]
                if length > 4*1024*1024 or length + 128 > budget["bytes"]:
                    raise ValueError('Screen capture size limit')
                body = read_exact(length)
                if body is None:
                    break
                wire.write(header + body)
                total += 128 + length
                budget["bytes"] -= 128 + length
                opcode = header[4]
                if opcode == 1:
                    config = avcc_config(body)
                    media.records.append(dict(video_config_bytes=length, header_hex=header.hex()))
                elif opcode == 0:
                    body = decryptor.update(body)
                    if config is None:
                        raise ValueError('Video arrived before codec configuration')
                    nal_size, sps, pps = config
                    avcc = normalize_nals(body, nal_size)
                    line = json.dumps({k:base64.b64encode(v).decode('ascii')
                                       for k,v in dict(sps=sps, pps=pps, avcc=avcc).items()}) + '\n'
                    decoded.write(line)
                    preview.send(line)
                    decoded.flush()
                    frames += 1
                    budget["frames"] -= 1
                elif opcode not in (2, 4, 5):
                    raise ValueError(f'Unsupported screen opcode {opcode}')
    finally:
        preview_output = getattr(media, 'preview_output', media.output)
        if preview_output != media.output:
            for name in ('decoder.json', 'decoder.log', 'frame.jpg'):
                if (preview_output / name).exists():
                    shutil.copy2(preview_output / name, media.output / name)
        media.records.append(dict(video_frames=frames, video_wire_bytes=total, directory=media.output.name))
