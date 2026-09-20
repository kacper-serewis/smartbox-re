"""Fixed Sony audio profile for the SHA-pinned stock HW501 v131 executable.

This is an experimental negotiation patch, not a sample-rate converter. It
targets the XAV-AX1005DB; the profile is unconditional, without brand detection.
"""
import hashlib
import io
import struct

from elftools.elf.elffile import ELFFile

from display_patch import STOCK_SHA

BASE = 0x10000
HOOK = 0x2ADB0
CONTINUE = 0x2ADB8
STUB = 0x12B860
PADDING_END = 0x12BFA8
MEDIA_PCM = 0x4D41A
MEDIA_AAC = 0x4D604
PCM_44100 = 0x800
PCM_48000 = 0x8000
AAC_44100 = 0x400000
PROFILE = 'sony-ax1005db-audio-v1'
EXPECTED = {HOOK: bytes.fromhex('9750ffffe78000a2'),
            MEDIA_PCM: bytes.fromhex('2563'),
            MEDIA_AAC: bytes.fromhex('ef709e98')}
REG = dict(zip(('zero ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 '
                's2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6').split(), range(32)))
CALLER = ['ra', 't0', 't1', 't2'] + [f'a{i}' for i in range(8)] + ['t3', 't4', 't5', 't6']


class Code:
    """Only the base RV32 instructions used by this hook; no Andes opcodes."""
    def __init__(self):
        self.words = []

    @property
    def pc(self):
        return STUB + 4 * len(self.words)

    def emit(self, word):
        self.words.append(word)

    def addi(self, rd, rs, immediate):
        if not -2048 <= immediate < 2048:
            raise ValueError('ADDI immediate out of range')
        self.emit(((immediate & 4095) << 20) | (REG[rs] << 15) | (REG[rd] << 7) | 0x13)

    def li(self, rd, value):
        signed = (value & 0xffffffff)
        if signed >= 0x80000000:
            signed -= 1 << 32
        hi = (signed + 0x800) >> 12
        self.emit(((hi & 0xfffff) << 12) | (REG[rd] << 7) | 0x37)
        self.addi(rd, rd, signed - (hi << 12))

    def lw(self, rd, base, offset):
        self.emit(((offset & 4095) << 20) | (REG[base] << 15) | (2 << 12) | (REG[rd] << 7) | 3)

    def sw(self, rs, base, offset):
        self.emit((((offset >> 5) & 127) << 25) | (REG[rs] << 20) | (REG[base] << 15)
                  | (2 << 12) | ((offset & 31) << 7) | 0x23)

    def bitop(self, op, rd, left, right):
        self.emit((REG[right] << 20) | (REG[left] << 15) | ({'and': 7, 'or': 6}[op] << 12)
                  | (REG[rd] << 7) | 0x33)

    def call(self, address):
        self.li('t0', address)
        self.emit((REG['t0'] << 15) | (REG['ra'] << 7) | 0x67)

    def data(self):
        return b''.join(struct.pack('<I', word) for word in self.words)


def patch(raw):
    if hashlib.sha256(raw).hexdigest() != STOCK_SHA:
        raise ValueError('Sony profile requires the exact archived stock HW501 v131 CPAAProxyEx')
    elf = ELFFile(io.BytesIO(raw))
    if elf['e_machine'] != 'EM_RISCV' or elf.elfclass != 32:
        raise ValueError('Expected RV32 ELF')
    for address, expected in EXPECTED.items():
        if raw[address - BASE:address - BASE + len(expected)] != expected:
            raise ValueError(f'Unexpected instruction at {address:#x}')

    code = Code()
    # s1 is gProxyInfos after the car's /info audio-format loop. Preserve every
    # caller-saved integer register across logging, including the original
    # CFArrayCreateCopy arguments. The hook replaces that existing call.
    code.addi('sp', 'sp', -64)
    for index, reg in enumerate(CALLER):
        code.sw(reg, 'sp', index * 4)
    code.li('t0', ~PCM_48000)
    code.li('a0', PCM_44100)
    for offset in (16, 48):  # Main generic output and main Media output; not input/mic.
        code.lw('a1', 's1', offset)
        code.bitop('and', 'a1', 'a1', 't0')
        code.bitop('or', 'a1', 'a1', 'a0')
        code.sw('a1', 's1', offset)
    # Address placeholders for the log strings, filled after instruction layout.
    tag_index = len(code.words)
    code.li('a0', 0)
    message_index = len(code.words)
    code.li('a1', 0)
    code.lw('a2', 's1', 16)
    code.lw('a3', 's1', 48)
    code.call(0x21D00)  # MLOGD@plt, verified in the pinned executable.
    for index, reg in enumerate(CALLER):
        code.lw(reg, 'sp', index * 4)
    code.addi('sp', 'sp', 64)
    code.li('t0', 0x1F7D0)  # Tail-call the displaced CFArrayCreateCopy@plt.
    code.emit((REG['t0'] << 15) | 0x67)
    instruction_bytes = len(code.words) * 4
    tag = b'SonyAudio\0'
    message = (b'EXPERIMENTAL Sony AX1005DB v1: main=0x%x media=0x%x; '
               b'44.1kHz PCM / wireless AAC-LC; fixed Sony profile\n\0')
    for index, reg, address in ((tag_index, 'a0', code.pc),
                                (message_index, 'a1', code.pc + len(tag))):
        load = Code()
        load.li(reg, address)
        code.words[index:index + 2] = load.words
    stub = code.data() + tag + message
    end = STUB + len(stub)
    if end > PADDING_END or any(raw[STUB - BASE:end - BASE]):
        raise ValueError('Hook does not fit verified unused padding')
    result = bytearray(raw)
    # Stub is beyond JAL's +/-1 MiB reach. Use the original eight-byte call
    # slot for AUIPC ra / JALR ra, giving exactly the original return address.
    delta = STUB - HOOK
    hi = (delta + 0x800) >> 12
    lo = delta - (hi << 12)
    result[HOOK - BASE:HOOK - BASE + 8] = struct.pack(
        '<II', (hi << 12) | (1 << 7) | 0x17,
        ((lo & 4095) << 20) | (1 << 15) | (1 << 7) | 0x67)
    # c.lui t1,1 followed by existing addi t1,t1,-2048 yields 0x800,
    # replacing the stock 0x8800 offer for stream 100 Media.
    result[MEDIA_PCM - BASE:MEDIA_PCM - BASE + 2] = bytes.fromhex('0563')
    # Replace media-mode getter call with lui a0,0x400. Existing continuation
    # sets the upper mask word to zero and offers AAC-LC/44100 for stream 102.
    result[MEDIA_AAC - BASE:MEDIA_AAC - BASE + 4] = struct.pack('<I', 0x00400537)
    result[STUB - BASE:end - BASE] = stub
    changed_headers = []
    for index, segment in enumerate(elf.iter_segments()):
        if segment['p_type'] == 'PT_LOAD' and segment['p_offset'] == 0 and segment['p_vaddr'] == BASE:
            if segment['p_flags'] != 5 or segment['p_filesz'] != segment['p_memsz'] or segment['p_filesz'] > STUB - BASE:
                raise ValueError('Unexpected executable segment layout')
            header = elf['e_phoff'] + index * elf['e_phentsize']
            struct.pack_into('<II', result, header + 16, end - BASE, end - BASE)
            changed_headers.append(header + 16)
    if len(changed_headers) != 1 or len(result) != len(raw):
        raise ValueError('Invalid patched ELF layout')
    metadata = {
        'profile': PROFILE, 'target_radio': 'Sony XAV-AX1005DB',
        'scope': 'Fixed Sony-only tuning; no runtime brand lock or model detection',
        'stock_sha256': STOCK_SHA, 'patched_sha256': hashlib.sha256(result).hexdigest(),
        'hook': HOOK, 'continuation': CONTINUE, 'stub': STUB, 'stub_bytes': len(stub),
        'instruction_bytes': instruction_bytes, 'program_header_size_offset': changed_headers[0],
        'media_pcm_instruction': MEDIA_PCM, 'media_aac_instruction': MEDIA_AAC,
        'main_output_offsets': [16, 48], 'pcm_format': PCM_44100,
        'wireless_media_format': AAC_44100,
        'limitations': ['Physical Sony/HW501 validation pending',
                        'No new resampler; negotiated media must arrive at 44100 Hz',
                        'Stock pairing, microphone, telephony and alternate audio paths retained'],
    }
    return bytes(result), metadata
