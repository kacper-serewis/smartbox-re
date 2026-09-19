#!/usr/bin/env python3
"""Save GNU objdump excerpts with ELF data-reference annotations."""
import argparse
import io
import json
from pathlib import Path
import re
import shutil
import subprocess

from elftools.elf.elffile import ELFFile


TARGETS = {
    'bin/CPAAProxyEx': ['_WaitConnectTimeoutHandler', 'iap2_dev_recv_data', '_ZN15CarPlayProxyApp21check_sys_code_threadEPv', '_Z21carplay_video_processiPvib'],
    'lib/libCoreUtils.so': ['MFiPlatform_Initialize'],
    'lib/libiAP2Link.so': ['iAP2LinkQueueSendData', 'iAP2LinkSendWindowAvailable'],
}


def annotate(path, text):
    elf=ELFFile(io.BytesIO(path.read_bytes()))
    relocations={}
    for section in elf.iter_sections():
        if section['sh_type'] in ('SHT_REL','SHT_RELA'):
            symbols=elf.get_section(section['sh_link'])
            for rel in section.iter_relocations():
                if rel['r_info_sym']:
                    relocations[rel['r_offset']]=symbols.get_symbol(rel['r_info_sym']).name
    def describe(addr):
        if addr in relocations:
            return 'ELF relocation: '+relocations[addr]
        for section in elf.iter_sections():
            if section.name not in ('.rodata','.data'):
                continue
            offset=addr-section['sh_addr']
            if 0 <= offset < section['sh_size']:
                data=section.data()[offset:].split(b'\0',1)[0]
                if data and all(32<=b<127 or b in (9,10,13) for b in data) and len(data)<512:
                    return repr(data.decode())
        return None
    lines=[]
    for line in text.splitlines():
        m=re.search(r'# ([0-9a-f]+)',line)
        extra=describe(int(m[1],16)) if m else None
        lines.append(line + (' ; DATA '+extra if extra else ''))
    return '\n'.join(lines)+'\n'


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--objdump', default=shutil.which('gobjdump') or '/opt/homebrew/opt/binutils/bin/gobjdump')
    args=parser.parse_args()
    output=Path('reports/binaries/disassembly');output.mkdir(parents=True,exist_ok=True)
    for v in (126,128,131):
        inv=json.loads(Path(f'reports/binaries/{v}.json').read_text())
        for rel,names in TARGETS.items():
            path=Path(f'firmwares/hw501/{v}/rootfs')/rel
            for name in names:
                f=inv[rel]['functions'].get(name)
                if not f:
                    continue
                text=subprocess.check_output([args.objdump,'-d','-C',f'--start-address={f["address"]}',f'--stop-address={f["address"]+f["size"]}',str(path)],text=True)
                filename=f'{v}__{Path(rel).name}__{name}.asm'
                (output/filename).write_text(annotate(path,text))
    path=Path('firmwares/hw501/131/rootfs/bin/CPAAProxyEx')
    ranges=[('wifi_configuration',0x393f4,0x39680),('ap_password_configuration',0x49890,0x498e0),('bt_address_configuration',0x3eecc,0x3ef10)]
    for name,start,stop in ranges:
        text=subprocess.check_output([args.objdump,'-d','-C',f'--start-address={start}',f'--stop-address={stop}',str(path)],text=True)
        (output/f'131__CPAAProxyEx__{name}.asm').write_text(annotate(path,text))
    print('Saved annotated function disassembly excerpts.')


if __name__=='__main__':
    main()
