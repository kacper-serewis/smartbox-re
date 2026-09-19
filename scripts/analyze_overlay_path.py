#!/usr/bin/env python3
"""Extract SHA-pinned evidence for the HW501 v131 overlay feasibility investigation.

This script reads local firmware only. It does not patch, execute, or install it.
"""
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

from disassemble_evidence import annotate

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT/'firmwares/hw501/131/rootfs'
OUTPUT = ROOT/'reports/overlay/evidence'
SOURCES = {
    'bin/CPAAProxyEx': {
        'sha256': 'a147d1b4fd2f73ed5a70b76c45cc5e5ca1aeaa8b1544d4aabc99b7a6618ecc84',
        'ranges': {
            'video_callback': (0x360f0, 0x361b0),
            'incoming_compressed_video': (0x35eb0, 0x360f0),
            'video_source_selection': (0x35a58, 0x35c28),
            'local_ui_encode': (0x35c28, 0x35eb0),
            'outgoing_compressed_video': (0x4ee7c, 0x4f138),
            'local_encoder_wrapper': (0x50d98, 0x50e20),
            'ui_blit': (0x5943c, 0x5954c),
        },
    },
    'lib/libCarLifeStub.so': {
        'sha256': '6b410066f059a515f4149b153fb64abd533a82eb8b6cc11205b9ab9c25bb4ecd',
        'ranges': {'incoming_nal_framing': (0x1ed8, 0x2086)},
    },
    'lib/libDecEncLib.so': {
        'sha256': 'ba12ada24bc528dcaf1024fa0780436302286620c9afeebf267eb0fc843e5415',
        'ranges': {'rgb565_to_i420_blit': (0x3878, 0x3a74)},
    },
}


def main():
    # Check all inputs before writing any evidence.
    for relative, details in SOURCES.items():
        if hashlib.sha256((SOURCE/relative).read_bytes()).hexdigest() != details['sha256']:
            raise ValueError(f'Unsupported binary: {relative}')
    objdump = shutil.which('gobjdump') or '/opt/homebrew/opt/binutils/bin/gobjdump'
    OUTPUT.mkdir(parents=True, exist_ok=True)
    records = []
    for relative, details in SOURCES.items():
        path = SOURCE/relative
        for label, (start, stop) in details['ranges'].items():
            text = subprocess.check_output([
                objdump, '-d', '-C', f'--start-address={start}',
                f'--stop-address={stop}', str(path)], text=True)
            # Ensure objdump actually emitted the requested entry instruction.
            if not re.search(rf'^\s*{start:x}:', text, re.M):
                raise ValueError(f'No instruction at requested start: {label}')
            filename = f'{label}.asm'
            (OUTPUT/filename).write_text(annotate(path, text))
            records.append({'file': filename, 'source': relative,
                            'sha256': details['sha256'],
                            'start': hex(start), 'stop_exclusive': hex(stop)})
    (OUTPUT/'index.json').write_text(json.dumps({
        'scope': 'Static evidence; not a working overlay or performance benchmark',
        'ranges': records,
        'limitations': [
            'Vendor-specific Andes instructions may remain undecoded.',
            'Nearest exported symbol labels do not reliably name internal functions.',
            'Application package excludes the base rootfs and kernel.',
        ],
    }, indent=2)+'\n')
    print(f'Saved {len(records)} overlay-path evidence ranges to {OUTPUT}')


if __name__ == '__main__':
    main()
