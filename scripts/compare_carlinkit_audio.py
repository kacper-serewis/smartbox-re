#!/usr/bin/env python3
"""Download and statically compare two pinned Carlinkit U2W AUTOKIT updates.

Requires OpenSSL and capstone (scripts/requirements-analysis.txt). No firmware
program is executed. No device is contacted. Restored ELF PT_LOAD segments are
analysis artifacts, not complete unpacked executables or installable images.

Packing format references, at UPSTREAM_COMMIT:
  Firmware_Tools/FirmwareU2W.sh (outer AES format, Ludwig V.)
  Kernel/new-files/drivers/crypto/mxs-dcp-hewei.c (inner AES parameters)
UPX block layout/LZMA properties: upx/upx v3.96 src/p_unix.cpp,
src/p_lx_elf.cpp, and src/compress_lzma.cpp. Implementation here uses Python's
LZMA decoder and OpenSSL; it does not execute the upstream firmware tools.
"""
import argparse
import difflib
import hashlib
import io
import json
import lzma
from pathlib import Path, PurePosixPath
import re
import struct
import subprocess
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parents[1]
REPOSITORY = 'ludwig-v/wireless-carplay-dongle-reverse-engineering'
UPSTREAM_COMMIT = 'b437135316275a5d3c375bdd1ceac2a6bcf1315b'
RELEASES = {
    '2022.01.24.1903': (12798562, '40980d6cd99bf9228afa821beb568fabc98488832bdd6f559c5f696a1f6becd9'),
    '2022.06.08.1109': (13444618, '3987f4bb633c10ca6f11764d3a456d014d63efe065fb353af91c84d8f9840060'),
}
PROGRAMS = ('fakeiOSDevice', 'AppleCarPlay', 'riddleBoxCfg')
AUDIO = re.compile(r'audio|sony|USB4931|MediaQuality|sample|resampl|latency|pair-setup HK|MFiSAP', re.I)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def save_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def aes_decrypt(data, key, iv):
    return subprocess.run(
        ['openssl', 'enc', '-d', '-aes-128-cbc', '-nopad', '-K', key.hex(), '-iv', iv.hex()],
        input=data, capture_output=True, check=True).stdout


def get_image(base, version):
    folder = base / version
    folder.mkdir(parents=True, exist_ok=True)
    path = folder / 'U2W_AUTOKIT_Update.img'
    url = (f'https://raw.githubusercontent.com/{REPOSITORY}/{UPSTREAM_COMMIT}/'
           f'Firmware/U2W/_AUTOKIT/{version}/{path.name}')
    size, digest = RELEASES[version]
    if path.exists():
        data = path.read_bytes()
    else:
        with urlopen(url, timeout=60) as response:
            data = response.read(size + 1)
    if len(data) != size or sha(data) != digest:
        raise ValueError(f'Pinned image size/hash mismatch: {version}')
    if not path.exists():
        path.write_bytes(data)
    manifest = dict(version=version, url=url, upstream_commit=UPSTREAM_COMMIT,
                    bytes=size, sha256=digest)
    save_json(folder / 'manifest.json', manifest)
    return data, manifest


def extract_files(raw):
    """Read bounded regular files into memory; never materialize archive links."""
    import tarfile
    files, inventory = {}, {}
    total = 0
    with tarfile.open(fileobj=io.BytesIO(raw), mode='r:gz') as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            if path.is_absolute() or '..' in path.parts:
                raise ValueError(f'Unsafe archive path: {member.name}')
            if member.isdir():
                continue
            name = str(path)
            if name in inventory:
                raise ValueError(f'Duplicate archive member: {name}')
            if member.issym():
                inventory[name] = dict(type='symlink', target=member.linkname, mode=oct(member.mode))
                continue
            if not member.isfile():
                raise ValueError(f'Unexpected non-regular member: {name}')
            total += member.size
            if member.size > 64 * 1024**2 or total > 256 * 1024**2:
                raise ValueError('Archive exceeds analysis limits')
            content = archive.extractfile(member).read()
            files[name] = content
            inventory[name] = dict(type='file', size=len(content), mode=oct(member.mode), sha256=sha(content))
    return files, inventory


def decode_load_segments(packed):
    """Restore the three unfiltered LZMA blocks in these specific ARM programs.

    Original section-table/trailer bytes outside PT_LOAD are deliberately not
    synthesized. This decoder rejects other layouts and executable filters.
    """
    if (len(packed) < 184 or packed[:7] != b'\x7fELF\x01\x01\x01' or
            struct.unpack_from('<H', packed, 18)[0] != 40 or
            packed[152:156] != bytes.fromhex('55225522')):
        raise ValueError('Unsupported packed ARM ELF layout')
    pos, blocks, evidence = 172, [], []
    for index in range(3):
        if pos + 12 > len(packed):
            raise ValueError('Truncated block header')
        unc, compressed, method, filter_id, cto, unused = struct.unpack_from('<IIBBBB', packed, pos)
        pos += 12
        if not 0 < compressed <= unc <= 32 * 1024**2 or method != 14 or filter_id != 0:
            raise ValueError('Unsupported compression/filter/size')
        blob = packed[pos:pos + compressed]
        if len(blob) != compressed:
            raise ValueError('Truncated compressed block')
        encrypted = blob.startswith(bytes.fromhex('45c1417e'))
        if encrypted:
            if compressed < 8192:
                raise ValueError('Short encrypted block')
            # Both C constants in the upstream driver include a terminal NUL.
            blob = aes_decrypt(blob[:8192], b'coding=utf-8    \0', b'clang 11.0.0 (cl\0') + blob[8192:]
        pos += compressed
        if unc == compressed:
            content = blob
        else:
            pb, lp, lc = blob[0] & 7, blob[1] >> 4, blob[1] & 15
            if pb > 4 or lp > 4 or lc > 8 or blob[0] >> 3 != lp + lc:
                raise ValueError('Invalid UPX LZMA properties')
            decoder = lzma.LZMADecompressor(format=lzma.FORMAT_RAW, filters=[dict(
                id=lzma.FILTER_LZMA1, dict_size=max(unc, 4096), pb=pb, lp=lp, lc=lc)])
            # UPX supplies the output length externally; its LZMA blocks need
            # not carry an end marker. Stop at that length, like UPX's decoder.
            content = decoder.decompress(blob[2:], max_length=unc)
        if len(content) != unc:
            raise ValueError('Decoded length differs from block header')
        blocks.append(content)
        evidence.append(dict(index=index, uncompressed=unc, compressed=compressed,
                             encrypted_prefix=8192 if encrypted else 0, sha256=sha(content)))
    header = blocks[0]
    if len(header) != 308 or header[:7] != b'\x7fELF\x01\x01\x01':
        raise ValueError('Unexpected original ELF header')
    phdrs = list(struct.iter_unpack('<IIIIIIII', header[52:308]))
    loads = [p for p in phdrs if p[0] == 1]
    if (len(loads) != 2 or loads[0][1] != 0 or
            loads[0][4] != len(header) + len(blocks[1]) or loads[1][4] != len(blocks[2]) or
            loads[1][1] < loads[0][4] or loads[1][1] + loads[1][4] > 32 * 1024**2):
        raise ValueError('Decoded blocks do not match original PT_LOAD layout')
    raw = bytearray(loads[1][1] + loads[1][4])
    raw[:len(header)] = header
    raw[len(header):loads[0][4]] = blocks[1]
    raw[loads[1][1]:] = blocks[2]
    return bytes(raw), evidence


class ArmEvidence:
    def __init__(self, data):
        import capstone
        self.cs_module = capstone
        self.data = data
        phdrs = list(struct.iter_unpack('<IIIIIIII', data[52:308]))
        self.loads = [p for p in phdrs if p[0] == 1]
        dynamic = next(p for p in phdrs if p[0] == 2)
        tags = dict(struct.iter_unpack('<II', data[dynamic[1]:dynamic[1] + dynamic[4]]))
        symbols = {}
        for i in range(self.word(tags[4] + 4)):
            name = self.word(tags[6] + 16 * i)
            symbols[i] = self.cstring(tags[5] + name)
        imports = {}
        for offset in range(0, tags[2], 8):
            target, info = struct.unpack_from('<II', data, self.offset(tags[23]) + offset)
            imports[target] = symbols[info >> 8]
        self.plt = {}
        cs = self.disassembler(False)
        for address in range(tags[12], tags[12] + 0x2000, 4):
            off = self.offset(address)
            ins = list(cs.disasm(data[off:off + 12], address))
            if (len(ins) == 3 and ins[0].mnemonic == 'add' and ins[0].op_str.startswith('ip, pc, #')
                    and ins[1].mnemonic == 'add' and ins[1].op_str.startswith('ip, ip, #')
                    and ins[2].mnemonic == 'ldr' and ins[2].op_str.startswith('pc, [ip, #')):
                got = address + 8 + ins[0].operands[2].imm + ins[1].operands[2].imm + ins[2].operands[1].mem.disp
                if got in imports:
                    self.plt[address] = imports[got]

    def offset(self, address):
        for p in self.loads:
            if p[2] <= address < p[2] + p[4]:
                return p[1] + address - p[2]
        raise ValueError(f'Address outside PT_LOAD: {address:#x}')

    def word(self, address):
        return struct.unpack_from('<I', self.data, self.offset(address))[0]

    def cstring(self, address):
        off = self.offset(address)
        raw = self.data[off:off + 300].split(b'\0', 1)[0]
        return raw.decode() if raw and all(x in (9, 10, 13) or 32 <= x < 127 for x in raw) else ''

    def disassembler(self, thumb):
        c = self.cs_module
        cs = c.Cs(c.CS_ARCH_ARM, c.CS_MODE_THUMB if thumb else c.CS_MODE_ARM)
        cs.detail = True
        return cs

    def disassemble(self, start, stop, thumb=False):
        c = self.cs_module
        lines = [f'; ARM ELF virtual addresses; mode={"Thumb" if thumb else "ARM"}; static analysis only']
        off = self.offset(start)
        end = start
        for ins in self.disassembler(thumb).disasm(self.data[off:off + stop - start], start):
            note = ''
            if (ins.mnemonic.startswith('ldr') and len(ins.operands) > 1 and
                    ins.operands[1].type == c.arm.ARM_OP_MEM and ins.operands[1].mem.base == c.arm.ARM_REG_PC):
                literal = ((ins.address + 4) & ~3) if thumb else ins.address + 8
                literal += ins.operands[1].mem.disp
                try:
                    value = self.word(literal)
                    note = f' ; [{literal:#x}]={value:#x}'
                    label = self.cstring(value)
                    if label:
                        note += ' ' + repr(label)
                except ValueError:
                    pass
            if ins.mnemonic in ('bl', 'blx') and ins.operands[0].type == c.arm.ARM_OP_IMM:
                if ins.operands[0].imm in self.plt:
                    note += ' ; ' + self.plt[ins.operands[0].imm]
            lines.append(f'{ins.address:08x}: {ins.bytes.hex():10} {ins.mnemonic:8} {ins.op_str}{note}')
            end = ins.address + ins.size
        if end != stop:
            raise ValueError(f'Incomplete disassembly at {end:#x}, expected {stop:#x}')
        return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cache', type=Path, default=ROOT / 'firmwares/carlinkit')
    parser.add_argument('--output', type=Path, default=ROOT / 'reports/audio/carlinkit')
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    diffdir = args.output / 'diffs'
    diffdir.mkdir(exist_ok=True)
    images, inventories, decoded, manifests, decode_records = {}, {}, {}, {}, {}
    for version in RELEASES:
        packed, manifests[version] = get_image(args.cache, version)
        aligned = len(packed) // 16 * 16
        raw = aes_decrypt(packed[:aligned], b'CarPlay5KBP6ClJv\0', b'CarPlay5KBP6ClJv\0') + packed[aligned:]
        files, inventories[version] = extract_files(raw)
        if files['etc/software_version'].decode().strip() != version:
            raise ValueError('Internal software version differs from requested release')
        (args.cache / version / 'decrypted.tar.gz').write_bytes(raw)
        images[version] = files
        decoded[version], decode_records[version] = {}, {}
        folder = args.cache / version / 'unpacked'
        folder.mkdir(exist_ok=True)
        for name in PROGRAMS:
            content, records = decode_load_segments(files['usr/sbin/' + name])
            decoded[version][name] = content
            decode_records[version][name] = dict(bytes=len(content), sha256=sha(content), blocks=records)
            (folder / (name + '.load-segments')).write_bytes(content)
        print(f'{version}: verified image, {len(files)} files, {len(PROGRAMS)} programs decoded')
    old, new = RELEASES
    changes = {}
    for path in sorted(inventories[old].keys() | inventories[new].keys()):
        a, b = inventories[old].get(path), inventories[new].get(path)
        if a == b:
            continue
        changes[path] = dict(before=a, after=b)
        if path in images[old] and path in images[new] and path.endswith(('.sh', '.conf')):
            try:
                before, after = [images[v][path].decode().splitlines(True) for v in (old, new)]
            except UnicodeError:
                continue
            (diffdir / (path.replace('/', '__') + '.diff')).write_text(''.join(difflib.unified_diff(
                before, after, fromfile=old + '/' + path, tofile=new + '/' + path)))
    for name in PROGRAMS:
        before, after = [set(x.decode() for x in re.findall(rb'[\x20-\x7e]{6,}', decoded[v][name])) for v in (old, new)]
        for label, strings in [('added', after - before), ('removed', before - after)]:
            relevant = sorted(x for x in strings if AUDIO.search(x))
            (diffdir / (name + '.audio-strings.' + label + '.txt')).write_text('\n'.join(relevant) + '\n')
    ranges = {
        'before-format-selection.asm': (old, 0x33b3e, 0x33bb0, True),
        'sony-format-selection.asm': (new, 0x41090, 0x41158, False),
        'format-context.asm': (new, 0x40cd0, 0x41090, False),
        'format-result.asm': (new, 0x411f0, 0x41260, False),
        'sony-pairing-selection.asm': (new, 0x39e18, 0x39e64, False),
        'pair-setup-hk-log.asm': (new, 0x39718, 0x39738, False),
        'usb-product-name.asm': (new, 0x52038, 0x520a0, False),
    }
    evidence = args.output / 'evidence'
    evidence.mkdir(exist_ok=True)
    for filename, (version, start, stop, thumb) in ranges.items():
        text = ArmEvidence(decoded[version]['fakeiOSDevice']).disassemble(start, stop, thumb)
        (evidence / filename).write_text(text)
    save_json(args.output / 'comparison.json', dict(
        source_repository=REPOSITORY, upstream_commit=UPSTREAM_COMMIT, manifests=manifests,
        inventories=inventories, changed_files=changes, decoded_programs=decode_records,
        evidence_ranges=ranges, limitations=[
            'The earlier image is the nearest earlier AUTOKIT version in the inspected archive, not a proven immediate predecessor.',
            'Image hashes identify the public mirror; they are not vendor signatures.',
            'Only PT_LOAD segments of selected executables are reconstructed. No section-table reconstruction or UPX checksum validation is claimed.',
            'No firmware executable was run and no hardware fix was tested.']))
    print(f'{len(changes)} changed top-level files; evidence saved to {args.output}')


if __name__ == '__main__':
    main()
