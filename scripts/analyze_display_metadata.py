#!/usr/bin/env python3
"""Save static display-property evidence from the archived v131 executable."""
import hashlib
import io
import json
from pathlib import Path
import re
import shutil
import subprocess

from elftools.elf.elffile import ELFFile
from disassemble_evidence import annotate
from display_patch import STOCK_SHA

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT/'firmwares/hw501/131/rootfs/bin/CPAAProxyEx'
OUTPUT = ROOT/'reports/display/metadata-evidence'
RANGES = {
    'display_array_input': (0x2aee4, 0x2afa0),
    'display_geometry_input': (0x2b9d4, 0x2bd60),
    'driver_side_and_night_input': (0x2b7a0, 0x2b854),
    'driver_side_and_night_output': (0x4d870, 0x4d8cc),
    'night_mode_command': (0x294f0, 0x2957c),
    'cached_display_output': (0x4dc4c, 0x4dcfc),
    'video_config_packet': (0x4eca8, 0x4eea0),
}
KEYS = {
    'displays', 'widthPixels', 'heightPixels', 'widthPhysical',
    'heightPhysical', 'maxFPS', 'primaryInputDevice', 'initialViewArea',
    'viewAreas', 'originXPixels', 'originYPixels', 'safeArea',
    'drawUIOutsideSafeArea', 'rightHandDrive', 'nightMode', 'setNightMode',
    'displayUUID', 'hidDevices', 'hidDescriptor', 'features',
}


def main():
    raw = SOURCE.read_bytes()
    if hashlib.sha256(raw).hexdigest() != STOCK_SHA:
        raise ValueError('Evidence ranges require the exact archived stock v131 executable')
    elf = ELFFile(io.BytesIO(raw))
    strings = {}
    records = []
    for section in elf.iter_sections():
        if section.name not in ('.rodata', '.data'):
            continue
        data = section.data()
        for match in re.finditer(rb'[ -~]{4,}\x00', data):
            value = match.group()[:-1].decode()
            address = section['sh_addr'] + match.start()
            if value not in KEYS:
                continue
            record = {'key': value, 'string_address': hex(address)}
            # This firmware's inline constant CFStrings have an eight-byte header.
            if match.start() >= 8 and data[match.start()-8:match.start()] == bytes.fromhex('56070100ffffff7f'):
                strings[address-8] = value
                record['cfstring_address'] = hex(address-8)
            records.append(record)
    objdump = shutil.which('gobjdump') or '/opt/homebrew/opt/binutils/bin/gobjdump'
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for name, (start, stop) in RANGES.items():
        text = subprocess.check_output([
            objdump, '-d', '-C', f'--start-address={start}',
            f'--stop-address={stop}', str(SOURCE)], text=True)
        lines = []
        for line in annotate(SOURCE, text).splitlines():
            match = re.search(r'# ([0-9a-f]+)', line)
            key = strings.get(int(match[1], 16)) if match else None
            lines.append(line + (f' ; CFSTRING {key!r}' if key else ''))
        (OUTPUT/f'{name}.asm').write_text('\n'.join(lines)+'\n')
    evidence = {
        'source': str(SOURCE.relative_to(ROOT)), 'sha256': STOCK_SHA,
        'scope': 'Static evidence only; no firmware execution or device writes',
        'keys': records,
        'ranges': {name: [hex(start), hex(stop)] for name, (start, stop) in RANGES.items()},
        'limitation': 'GNU objdump leaves vendor-specific Andes instructions undecoded; nearest symbol labels may not name the containing function.',
    }
    (OUTPUT/'index.json').write_text(json.dumps(evidence, indent=2)+'\n')
    print(f'Saved {len(RANGES)} annotated ranges and {len(records)} key occurrences to {OUTPUT}')


if __name__ == '__main__':
    main()
