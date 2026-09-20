#!/usr/bin/env python3
"""Inspect Annex B H.264 parameter sets without decoding or installing FFmpeg."""
from __future__ import annotations

import argparse
from collections import Counter
import json
from pathlib import Path
import re


class Bits:
    def __init__(self, data: bytes):
        self.data = data
        self.pos = 0

    def read(self, count: int) -> int:
        if count < 0 or self.pos + count > len(self.data) * 8:
            raise ValueError("truncated SPS")
        value = 0
        for _ in range(count):
            value = (value << 1) | ((self.data[self.pos // 8] >> (7 - self.pos % 8)) & 1)
            self.pos += 1
        return value

    def ue(self) -> int:
        zeros = 0
        while not self.read(1):
            zeros += 1
            if zeros > 31:
                raise ValueError("oversized Exp-Golomb field")
        return (1 << zeros) - 1 + self.read(zeros)

    def se(self) -> int:
        value = self.ue()
        return (value + 1) // 2 if value & 1 else -(value // 2)


def parse_sps(nal: bytes) -> dict:
    if not nal or nal[0] & 31 != 7 or nal[0] & 0x80:
        raise ValueError("not an SPS NAL")
    bits = Bits(nal[1:].replace(b"\x00\x00\x03", b"\x00\x00"))
    profile, constraints, level = bits.read(8), bits.read(8), bits.read(8)
    sps_id = bits.ue()
    chroma, separate, luma_depth, chroma_depth = 1, 0, 8, 8
    if profile in (44, 83, 86, 100, 110, 118, 122, 128, 134, 135, 138, 139, 144, 244):
        chroma = bits.ue()
        if chroma > 3:
            raise ValueError("invalid chroma_format_idc")
        if chroma == 3:
            separate = bits.read(1)
        luma_depth, chroma_depth = bits.ue() + 8, bits.ue() + 8
        bits.read(1)
        if bits.read(1):
            for i in range(12 if chroma == 3 else 8):
                if bits.read(1):
                    last, next_scale = 8, 8
                    for _ in range(16 if i < 6 else 64):
                        if next_scale:
                            next_scale = (last + bits.se() + 256) % 256
                        last = next_scale or last
    bits.ue()  # log2_max_frame_num_minus4
    order = bits.ue()
    if order == 0:
        bits.ue()
    elif order == 1:
        bits.read(1)
        bits.se()
        bits.se()
        cycle = bits.ue()
        if cycle > 255:
            raise ValueError("invalid POC cycle")
        for _ in range(cycle):
            bits.se()
    elif order != 2:
        raise ValueError("invalid pic_order_cnt_type")
    refs = bits.ue()
    bits.read(1)
    width_mbs, height_units = bits.ue() + 1, bits.ue() + 1
    frame_only = bits.read(1)
    if not frame_only:
        bits.read(1)
    bits.read(1)
    crop = [bits.ue() for _ in range(4)] if bits.read(1) else [0, 0, 0, 0]
    chroma_array = 0 if separate else chroma
    crop_x = 2 if chroma_array in (1, 2) else 1
    crop_y = (2 if chroma_array == 1 else 1) * (2 - frame_only)
    coded_width, coded_height = width_mbs * 16, height_units * 16 * (2 - frame_only)
    width = coded_width - crop_x * (crop[0] + crop[1])
    height = coded_height - crop_y * (crop[2] + crop[3])
    if not 0 < width <= 65536 or not 0 < height <= 65536:
        raise ValueError("invalid cropped dimensions")
    return {"sps_id": sps_id, "profile_idc": profile, "constraint_flags": constraints,
            "level_idc": level, "chroma_format_idc": chroma, "bit_depth_luma": luma_depth,
            "bit_depth_chroma": chroma_depth, "progressive": bool(frame_only),
            "max_reference_frames": refs, "coded_size": [coded_width, coded_height],
            "visible_size": [width, height], "matches_800x480": [width, height] == [800, 480]}


def inspect(data: bytes) -> dict:
    starts = list(re.finditer(b"\x00\x00(?:\x00)?\x01", data))
    types: Counter = Counter()
    sps, errors, seen = [], [], set()
    for index, start in enumerate(starts):
        end = starts[index + 1].start() if index + 1 < len(starts) else len(data)
        nal = data[start.end():end].rstrip(b"\x00")
        if not nal:
            continue
        kind = nal[0] & 31
        types[str(kind)] += 1
        if kind == 7 and nal not in seen:
            seen.add(nal)
            try:
                item = parse_sps(nal)
                item["offset"] = start.start()
                sps.append(item)
            except ValueError as exc:
                errors.append({"offset": start.start(), "error": str(exc)})
    return {"bytes": len(data), "nal_counts": dict(types), "sps": sps, "errors": errors,
            "note": "SPS dimensions only; matching 800x480 does not prove head-unit compatibility."}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("video", type=Path)
    print(json.dumps(inspect(parser.parse_args().video.read_bytes()), indent=2))
