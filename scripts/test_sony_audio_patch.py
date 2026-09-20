"""Execute the patched RV32 bytes and stock negotiation code in Unicorn.

CF/log APIs are modeled. Andes conditional branches in the stock helpers are
interpreted according to Andes QEMU's XAndesV5Isa.decode; no hardware is modeled.
"""
import io
from pathlib import Path
import random
import struct
import unittest

from elftools.elf.elffile import ELFFile
from unicorn import Uc, UC_ARCH_RISCV, UC_MODE_RISCV32, UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn import riscv_const as rv

from sony_audio_patch import (patch, BASE, HOOK, CONTINUE, STUB, EXPECTED, REG,
                              MEDIA_PCM, MEDIA_AAC, PCM_44100, PCM_48000, AAC_44100)

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'firmwares/hw501/131/rootfs/bin/CPAAProxyEx'
INFO = 0x200000
STACK = 0x310000
STOP = 0x3f0000


class Machine:
    def __init__(self, raw):
        self.uc = Uc(UC_ARCH_RISCV, UC_MODE_RISCV32)
        self.uc.mem_map(0, 0x400000)
        elf = ELFFile(io.BytesIO(raw))
        for segment in elf.iter_segments():
            if segment['p_type'] == 'PT_LOAD':
                self.uc.mem_write(segment['p_vaddr'], segment.data())
        self.put('sp', STACK)

    def get(self, reg):
        return self.uc.reg_read(getattr(rv, 'UC_RISCV_REG_' + reg.upper()))

    def put(self, reg, value):
        self.uc.reg_write(getattr(rv, 'UC_RISCV_REG_' + reg.upper()), value & 0xffffffff)

    def word(self, address):
        return struct.unpack('<I', self.uc.mem_read(address, 4))[0]

    def setword(self, address, value):
        self.uc.mem_write(address, struct.pack('<I', value & 0xffffffff))

    def cstring(self, address):
        return bytes(self.uc.mem_read(address, 256)).split(b'\0', 1)[0].decode()

    def returned(self, result=0, high=0):
        ret = self.get('ra')
        # Deliberately clobber caller registers to catch accidental dependencies.
        for reg in ['t0', 't1', 't2', 't3', 't4', 't5', 't6'] + [f'a{i}' for i in range(8)]:
            self.put(reg, 0xdeadbeef)
        self.put('a0', result)
        self.put('a1', high)
        self.put('pc', ret)

    def andes_branch(self, address):
        word = self.word(address)
        if word & 0x7f != 0x5b:
            return False
        funct = (word >> 12) & 7
        if funct not in (5, 6, 7):
            raise AssertionError(f'Unmodeled Andes instruction {word:#x} at {address:#x}')
        reg = list(REG)[(word >> 15) & 31]
        value = self.get(reg)
        immediate = (((word >> 31) & 1) << 10) | (((word >> 25) & 31) << 5) | (((word >> 8) & 15) << 1)
        if immediate & 1024:
            immediate -= 2048
        constant = (((word >> 7) & 1) << 5) | ((word >> 20) & 31)
        if funct == 7:
            take = bool(value & (1 << constant)) == bool((word >> 30) & 1)
        else:
            constant |= ((word >> 30) & 1) << 6
            take = (value == constant) if funct == 5 else (value != constant)
        self.put('pc', address + (immediate if take else 4))
        return True


def run_mask_hook(raw, info):
    m = Machine(raw)
    m.uc.mem_write(INFO, bytes(info))
    for name, number in REG.items():
        if name not in ('zero', 'sp'):
            m.put(name, 0x220000 + number * 0x100)
    m.put('s1', INFO)
    before = {reg: m.get(reg) for reg in REG}
    logs = []
    writes = []
    def code(uc, address, size, user):
        if address == CONTINUE:
            uc.emu_stop()
        elif address == 0x21d00:
            logs.append((m.cstring(m.get('a0')), m.cstring(m.get('a1')), m.get('a2'), m.get('a3')))
            m.returned()
        elif address == 0x1f7d0:
            # The displaced CFArrayCreateCopy must receive unchanged arguments.
            assert m.get('a0') == before['a0'] and m.get('a1') == before['a1']
            assert m.get('ra') == CONTINUE
            m.returned(0x240000)
    def write(uc, access, address, size, value, user):
        writes.append((address, size))
    m.uc.hook_add(UC_HOOK_CODE, code)
    m.uc.hook_add(UC_HOOK_MEM_WRITE, write)
    m.uc.emu_start(HOOK, STOP, count=2000)
    assert m.get('pc') == CONTINUE, 'Hook failed to reach stock continuation'
    for reg in ['sp', 'gp', 'tp'] + [f's{i}' for i in range(12)]:
        assert m.get(reg) == before[reg], (reg, hex(m.get(reg)), hex(before[reg]))
    assert m.get('a0') == 0x240000
    assert all(address in (INFO + 16, INFO + 48) or STACK - 64 <= address < STACK
               for address, size in writes), writes
    return bytes(m.uc.mem_read(INFO, len(info))), logs


def negotiate(raw, info, mode=0):
    """Execute the entire stock audioFormats property branch and its helpers."""
    m = Machine(raw)
    m.uc.mem_write(INFO, bytes(info))
    m.put('a0', 0x220000)
    m.put('a1', 0x10ae6c)  # audioFormats CFString
    m.put('a3', 0x230000)  # outErr
    m.put('ra', STOP)
    formats = []
    logs = []
    def code(uc, address, size, user):
        if address == STOP:
            uc.emu_stop()
        elif address == 0x28420:
            m.returned(INFO)
        elif address == 0x201b0:  # CFEqual(audioFormats, audioFormats)
            m.returned(1)
        elif address == 0x21d00:
            logs.append(m.cstring(m.get('a1')))
            m.returned()
        elif address == 0x207f0:
            key = m.get('a2')
            input_mask = m.get('a3') | (m.get('a4') << 32)
            output_mask = m.get('a5') | (m.get('a6') << 32)
            formats.append((m.get('a1'), key, input_mask, output_mask))
            m.setword(m.get('a0'), 0x240000)
            m.returned()
        elif address == 0x20bf0:
            m.returned(m.get('a0'))
        elif address == 0x32eb8:
            m.returned(0x220000)
        elif address == 0x34f8c:
            m.returned({0: 0, 1: 0x800000, 2: AAC_44100}[mode])
        else:
            m.andes_branch(address)
    m.uc.hook_add(UC_HOOK_CODE, code)
    m.uc.emu_start(0x4d1e0, STOP, count=10000)
    assert m.get('pc') == STOP and m.get('sp') == STACK
    assert m.get('a0') == 0x240000 and m.word(0x230000) == 0
    return formats


class SonyAudioTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.stock = SOURCE.read_bytes()
        cls.patched, cls.meta = patch(cls.stock)

    def test_reject_wrong_or_already_patched_binary(self):
        for data in (b'wrong', self.patched, self.stock[:-1]):
            with self.assertRaises(ValueError):
                patch(data)

    def test_only_declared_ranges_change_and_load_segment_covers_hook(self):
        h = self.meta['program_header_size_offset']
        allowed = [(h, h + 8), (STUB - BASE, STUB - BASE + self.meta['stub_bytes'])]
        allowed += [(address - BASE, address - BASE + len(data)) for address, data in EXPECTED.items()]
        self.assertEqual(len(self.stock), len(self.patched))
        for i, (old, new) in enumerate(zip(self.stock, self.patched)):
            if old != new:
                self.assertTrue(any(start <= i < stop for start, stop in allowed), hex(i))
        elf = ELFFile(io.BytesIO(self.patched))
        self.assertTrue(any(s['p_type'] == 'PT_LOAD' and s['p_flags'] & 1 and
                            s['p_vaddr'] <= STUB < STUB + self.meta['stub_bytes'] <= s['p_vaddr'] + s['p_filesz']
                            for s in elf.iter_segments()))

    def test_mask_hook_preserves_registers_inputs_other_streams_and_high_words(self):
        rng = random.Random(501)
        for mask in (0, PCM_48000, PCM_44100, 0x8800, 0xffffffff):
            data = bytearray(rng.randbytes(624))
            struct.pack_into('<I', data, 16, mask)
            struct.pack_into('<I', data, 48, mask)
            expected = bytearray(data)
            for offset in (16, 48):
                struct.pack_into('<I', expected, offset, (mask & ~PCM_48000) | PCM_44100)
            actual, logs = run_mask_hook(self.patched, data)
            self.assertEqual(actual, expected)
            self.assertEqual(len(logs), 1)
            self.assertEqual(logs[0][0], 'SonyAudio')
            self.assertEqual(logs[0][2:], ((mask & ~PCM_48000) | PCM_44100,) * 2)
            self.assertEqual(run_mask_hook(self.patched, actual)[0], actual)

    def test_actual_negotiation_overrides_every_media_setting(self):
        info = bytearray(624)
        for offset in range(16, 184, 8):
            struct.pack_into('<Q', info, offset, 0x8850)
        fixed, _ = run_mask_hook(self.patched, info)
        for mode in (0, 1, 2):
            formats = negotiate(self.patched, fixed, mode)
            self.assertEqual(len(formats), 9)
            media = [(stream, i, o) for stream, key, i, o in formats if key == 0x10aebc]
            self.assertEqual(media, [(100, 0, PCM_44100), (102, 0, AAC_44100)])
            stock = negotiate(self.stock, info, mode)
            for record in formats:
                # Mic, telephony and speech-recognition advertisement are retained.
                if record[1] in (0x10aecc, 0x10aee0):
                    self.assertIn(record, stock)

    def test_negotiation_with_missing_44100_and_missing_media_capability(self):
        info = bytearray(624)
        struct.pack_into('<Q', info, 16, PCM_48000)
        fixed, _ = run_mask_hook(self.patched, info)
        formats = negotiate(self.patched, fixed)
        media = [r for r in formats if r[1] == 0x10aebc]
        self.assertEqual([r[3] for r in media], [PCM_44100, AAC_44100])

    def test_actual_stock_pcm_setup_mapping_does_not_relabel_samples(self):
        for rate, expected in ((44100, PCM_44100), (48000, PCM_48000)):
            m = Machine(self.patched)
            m.put('a0', rate)
            m.put('a1', 16)
            m.put('a2', 2)
            m.put('ra', STOP)
            def code(uc, address, size, user):
                m.andes_branch(address)
            m.uc.hook_add(UC_HOOK_CODE, code)
            m.uc.emu_start(0x2375c, STOP, count=1000)
            self.assertEqual(m.get('pc'), STOP)
            self.assertEqual(m.get('a0') | (m.get('a1') << 32), expected)


if __name__ == '__main__':
    unittest.main()
