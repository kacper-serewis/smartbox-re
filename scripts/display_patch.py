"""RV32 hook for a copied CarPlay display description in the exact stock v131 ELF.

No head-unit state is mutated. The getter returns a newly allocated array with a
copied dictionary only for the observed single 800x480, 152x91 mm display.
"""
import hashlib
import io
import struct
from elftools.elf.elffile import ELFFile

STOCK_SHA = 'a147d1b4fd2f73ed5a70b76c45cc5e5ca1aeaa8b1544d4aabc99b7a6618ecc84'
HOOK = 0x4dc74
NORMAL_RETURN = 0x4dc78
OWNED_RETURN = 0x4d694
STUB = 0x12b860
BASE = 0x10000
EXPECTED = {'widthPixels':800,'heightPixels':480,'widthPhysical':152,'heightPhysical':91}
TARGET = {'widthPhysical':190,'heightPhysical':114}
REG = {'zero':0,'ra':1,'sp':2,'t0':5,'s0':8,'s1':9,'a0':10,'a1':11,'a2':12,'a3':13,'s2':18,'s3':19,'s4':20}


def jump(rd, offset):
    if offset % 2 or not -(1<<20) <= offset < (1<<20):
        raise ValueError('JAL out of range')
    n = offset & 0x1fffff
    return ((n>>20)<<31) | (((n>>1)&1023)<<21) | (((n>>11)&1)<<20) | (((n>>12)&255)<<12) | (rd<<7) | 0x6f


class Assembler:
    def __init__(self):
        self.words=[]; self.labels={}; self.fixups=[]

    @property
    def pc(self): return STUB+4*len(self.words)

    def emit(self, word): self.words.append(word)
    def label(self,name): self.labels[name]=self.pc

    def addi(self,rd,rs,n):
        assert -2048<=n<=2047
        self.emit(((n&4095)<<20)|(REG[rs]<<15)|(REG[rd]<<7)|0x13)

    def li(self,rd,n):
        hi=(n+0x800)>>12; lo=n-(hi<<12)
        self.emit((hi<<12)|(REG[rd]<<7)|0x37)
        self.addi(rd,rd,lo)

    def address(self,rd,label):
        self.fixups.append((len(self.words),'address',rd,label))
        self.emit(0); self.emit(0)

    def lw(self,rd,rs,offset):
        self.emit(((offset&4095)<<20)|(REG[rs]<<15)|(2<<12)|(REG[rd]<<7)|3)

    def sw(self,rs,base,offset):
        self.emit((((offset>>5)&127)<<25)|(REG[rs]<<20)|(REG[base]<<15)|(2<<12)|((offset&31)<<7)|0x23)

    def branch(self,kind,left,right,label):
        self.fixups.append((len(self.words),'branch',(kind,left,right),label));self.emit(0)

    def call(self,address):
        self.li('t0',address)
        self.emit((REG['t0']<<15)|(REG['ra']<<7)|0x67)

    def j(self,address): self.emit(jump(0,address-self.pc))

    def finish(self,strings):
        extra=b''
        for name,text in strings.items():
            self.labels[name]=self.pc+len(extra)
            extra+=text.encode()+b'\0'
        for index,kind,arg,label in self.fixups:
            address=self.labels[label]
            if kind=='address':
                hi=(address+0x800)>>12;lo=address-(hi<<12);r=REG[arg]
                self.words[index]=(hi<<12)|(r<<7)|0x37
                self.words[index+1]=((lo&4095)<<20)|(r<<15)|(r<<7)|0x13
            else:
                op,left,right=arg;offset=address-(STUB+index*4)
                assert offset%2==0 and -4096<=offset<4096
                n=offset&8191
                self.words[index]=(((n>>12)&1)<<31)|(((n>>5)&63)<<25)|(REG[right]<<20)|(REG[left]<<15)|((0 if op=='eq' else 1)<<12)|(((n>>1)&15)<<8)|(((n>>11)&1)<<7)|0x63
        return b''.join(struct.pack('<I',w) for w in self.words)+extra


def patch(raw):
    if hashlib.sha256(raw).hexdigest()!=STOCK_SHA:
        raise ValueError('This patch only supports the archived stock v131 CPAAProxyEx')
    elf=ELFFile(io.BytesIO(raw))
    symbols={s.name:s['st_value'] for s in elf.get_section_by_name('.dynsym').iter_symbols()}
    section=elf.get_section_by_name('.rodata');data=section.data();keys={}
    for key in EXPECTED:
        token=key.encode()+b'\0'; assert data.count(token)>=1
        offset=data.index(token)
        assert data[offset-8:offset]==bytes.fromhex('56070100ffffff7f')
        keys[key]=section['sh_addr']+offset-8
    a=Assembler()
    a.lw('s0','s1',200)  # Exact original instruction replaced at HOOK.
    a.addi('sp','sp',-32)
    for reg,offset in [('ra',28),('s2',24),('s3',20),('s4',16)]:a.sw(reg,'sp',offset)
    a.sw('zero','sp',0);a.addi('s3','zero',0)
    a.addi('a0','s0',0);a.call(symbols['CFArrayGetCount'])
    a.addi('t0','zero',1);a.branch('ne','a0','t0','fallback')
    a.addi('a0','s0',0);a.addi('a1','zero',0);a.call(symbols['CFArrayGetValueAtIndex'])
    a.branch('eq','a0','zero','fallback');a.addi('s2','a0',0)
    a.call(symbols['CFGetTypeID']);a.addi('s4','a0',0)
    a.call(symbols['CFDictionaryGetTypeID']);a.branch('ne','a0','s4','fallback')
    for key,value in EXPECTED.items():
        a.addi('a0','s2',0);a.li('a1',keys[key]);a.addi('a2','zero',0)
        a.call(symbols['CFDictionaryGetInt64'])
        a.branch('ne','a1','zero','fallback');a.addi('t0','zero',value)
        a.branch('ne','a0','t0','fallback')
    a.addi('a0','zero',0);a.addi('a1','zero',0);a.addi('a2','s2',0)
    a.call(symbols['CFDictionaryCreateMutableCopy']);a.addi('s3','a0',0)
    a.branch('eq','s3','zero','fallback')
    for key,value in TARGET.items():
        a.addi('a0','s3',0);a.li('a1',keys[key]);a.addi('a2','zero',value);a.addi('a3','zero',0)
        a.call(symbols['CFDictionarySetInt64']);a.branch('ne','a0','zero','fallback')
    a.addi('a0','sp',0);a.addi('a1','s3',0)
    a.call(symbols['CFArrayEnsureCreatedAndAppend']);a.branch('ne','a0','zero','fallback')
    a.lw('s4','sp',0);a.branch('eq','s4','zero','fallback')
    a.addi('a0','s3',0);a.call(symbols['CFRelease'])
    a.addi('s0','s4',0)
    a.address('a0','tag');a.address('a1','message');a.call(symbols['MLOGD'])
    def restore():
        for reg,offset in [('ra',28),('s2',24),('s3',20),('s4',16)]:a.lw(reg,'sp',offset)
        a.addi('sp','sp',32)
    restore();a.addi('s1','zero',0);a.j(OWNED_RETURN)
    a.label('fallback')
    a.branch('eq','s3','zero','no_dictionary')
    a.addi('a0','s3',0);a.call(symbols['CFRelease'])
    a.label('no_dictionary');a.lw('a0','sp',0)
    a.branch('eq','a0','zero','restore')
    a.call(symbols['CFRelease'])
    a.label('restore');restore();a.j(NORMAL_RETURN)
    instructions_size=len(a.words)*4
    stub=a.finish({'tag':'DisplayScale','message':'Phone display override: 800x480 152x91mm -> 190x114mm (experimental)\n'})
    output=bytearray(raw)
    start=STUB-BASE;stop=start+len(stub)
    if stop>0x11bfa8 or any(raw[start:stop]):raise ValueError('Insufficient zero padding')
    original=struct.pack('<I',(200<<20)|(9<<15)|(2<<12)|(8<<7)|3)
    assert raw[HOOK-BASE:HOOK-BASE+4]==original
    output[HOOK-BASE:HOOK-BASE+4]=struct.pack('<I',jump(0,STUB-HOOK))
    output[start:stop]=stub
    loads=[]
    for index,seg in enumerate(elf.iter_segments()):
        if seg['p_type']=='PT_LOAD' and seg['p_offset']==0 and seg['p_vaddr']==BASE:
            header=elf['e_phoff']+index*elf['e_phentsize']
            assert seg['p_flags']==5 and seg['p_filesz']==seg['p_memsz'] and seg['p_filesz']<=start
            struct.pack_into('<II',output,header+16,stop,stop)
            loads.append(index)
    assert len(loads)==1 and len(output)==len(raw)
    meta={'stock_sha256':STOCK_SHA,'patched_sha256':hashlib.sha256(output).hexdigest(),'hook':HOOK,'stub':STUB,'stub_bytes':len(stub),'instructions_bytes':instructions_size,'keys':keys,'symbols':{k:symbols[k] for k in ('CFArrayGetCount','CFArrayGetValueAtIndex','CFGetTypeID','CFDictionaryGetTypeID','CFDictionaryGetInt64','CFDictionaryCreateMutableCopy','CFDictionarySetInt64','CFArrayEnsureCreatedAndAppend','CFRelease','MLOGD')},'expected':EXPECTED,'target':TARGET,'normal_return':NORMAL_RETURN,'owned_return':OWNED_RETURN}
    return bytes(output),meta
