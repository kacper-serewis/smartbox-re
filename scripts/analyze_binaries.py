#!/usr/bin/env python3
"""Static ELF comparison; does not load or execute firmware code."""
import argparse
from collections import Counter
import hashlib
import io
import json
from pathlib import Path
import re

import capstone
import cxxfilt
from elftools.elf.elffile import ELFFile


def sha(data):
    return hashlib.sha256(data).hexdigest()


def demangle(name):
    try:
        return cxxfilt.demangle(name)
    except (cxxfilt.InvalidName, OSError):
        return name


def inspect(path):
    raw = path.read_bytes()
    elf = ELFFile(io.BytesIO(raw))
    sections = {}
    for s in elf.iter_sections():
        if s.name and s['sh_type'] != 'SHT_NOBITS':
            sections[s.name] = {'size':s['sh_size'], 'sha256':sha(s.data())}
    symbols = list(elf.get_section_by_name('.dynsym').iter_symbols())
    imports = sorted({s.name for s in symbols if s.name and s['st_shndx']=='SHN_UNDEF'})
    exports = sorted({s.name for s in symbols if s.name and s['st_shndx']!='SHN_UNDEF'})
    functions = {}
    cs = capstone.Cs(capstone.CS_ARCH_RISCV, capstone.CS_MODE_RISCV32 | capstone.CS_MODE_RISCVC)
    cs.skipdata = True
    cs.skipdata_setup = ('.insn', lambda code, size, offset, _: 4 if ord(code[offset]) & 3 == 3 else 2, None)
    for s in symbols:
        if s['st_info']['type'] != 'STT_FUNC' or not isinstance(s['st_shndx'], int) or not s['st_size']:
            continue
        section = elf.get_section(s['st_shndx'])
        start = s['st_value'] - section['sh_addr']
        code = section.data()[start:start+s['st_size']]
        # Mnemonic-only fingerprints are only a coarse structural comparison.
        # They deliberately ignore operands and cannot establish semantic equality.
        mnemonics = []
        unknown = 0
        covered = 0
        for insn in cs.disasm(code, s['st_value']):
            covered += insn.size
            if insn.id == 0:
                unknown += 1
                mnemonics.append('unknown:' + bytes(insn.bytes).hex())
            else:
                mnemonics.append(insn.mnemonic)
        if covered != len(code):
            raise ValueError(f'Incomplete instruction scan: {path}: {s.name}: {covered}/{len(code)} bytes')
        functions[s.name] = {'name':demangle(s.name), 'address':s['st_value'], 'size':s['st_size'], 'sha256':sha(code), 'mnemonic_sha256':sha('\n'.join(mnemonics).encode()), 'instruction_count':len(mnemonics), 'undecoded_instructions':unknown}
    dynamic = elf.get_section_by_name('.dynamic')
    needed = [t.needed for t in dynamic.iter_tags() if t.entry.d_tag == 'DT_NEEDED']
    strings = set()
    for section_name in ('.rodata', '.data', '.comment'):
        s = elf.get_section_by_name(section_name)
        if s:
            strings.update(x.decode('ascii') for x in re.findall(rb'[\x20-\x7e]{6,}', s.data()))
    return {'size':len(raw), 'sha256':sha(raw), 'sections':sections, 'needed':needed, 'imports':imports, 'exports':exports, 'functions':functions, 'data_strings':sorted(strings)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path('firmwares/hw501'))
    parser.add_argument('--output', type=Path, default=Path('reports/binaries'))
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    versions = [str(r['version']) for r in json.loads((args.root/'manifest.json').read_text())['releases']]
    inventories = {}
    cache = {}
    for version in versions:
        inv = {}
        root = args.root/version/'rootfs'
        for p in sorted(root.rglob('*')):
            if p.is_symlink() or not p.is_file():
                continue
            data = p.read_bytes()
            if data[:4] != b'\x7fELF':
                continue
            h = sha(data)
            if h not in cache:
                cache[h] = inspect(p)
            inv[p.relative_to(root).as_posix()] = cache[h]
        inventories[version] = inv
        (args.output/f'{version}.json').write_text(json.dumps(inv, indent=2)+'\n')
        print(f'Analyzed {version}: {len(inv)} ELF files', flush=True)
    pairs = []
    for a,b in zip(versions, versions[1:]):
        comparison = {'from':a,'to':b,'files':{}}
        before, after = inventories[a], inventories[b]
        for rel in sorted(before.keys() | after.keys()):
            left,right=before.get(rel),after.get(rel)
            if left is None or right is None:
                comparison['files'][rel]={'status':'added' if left is None else 'removed'}
                continue
            if left['sha256']==right['sha256']:
                comparison['files'][rel]={'status':'identical'}
                continue
            changes={'status':'changed','bytes_before':left['size'],'bytes_after':right['size']}
            for field in ('needed','imports','exports','data_strings'):
                changes[field+'_added']=sorted(set(right[field])-set(left[field]))
                changes[field+'_removed']=sorted(set(left[field])-set(right[field]))
            funcs={}
            for name in sorted(left['functions'].keys() | right['functions'].keys()):
                old,new=left['functions'].get(name),right['functions'].get(name)
                if old is None or new is None:
                    status='added' if old is None else 'removed'
                elif old['sha256']==new['sha256']:
                    status='identical_bytes'
                elif old['mnemonic_sha256']==new['mnemonic_sha256']:
                    status='same_mnemonic_sequence_different_bytes'
                else:
                    status='different_instruction_structure'
                funcs[name]={'name':demangle(name),'status':status,'size_before':old['size'] if old else None,'size_after':new['size'] if new else None}
            changes['functions']=funcs
            changes['function_summary']=dict(Counter(v['status'] for v in funcs.values()))
            comparison['files'][rel]=changes
        pairs.append(comparison)
    (args.output/'comparison.json').write_text(json.dumps(pairs, indent=2)+'\n')
    print('Saved section hashes, dependencies, symbols, function fingerprints, and data-section string changes.', flush=True)


if __name__=='__main__':
    main()
