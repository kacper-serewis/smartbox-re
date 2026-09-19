"""Emulate the actual RV32 patch with modeled CF APIs; never runs on the adapter."""
import copy
from pathlib import Path
import struct
import unittest
from unicorn import Uc, UC_ARCH_RISCV, UC_MODE_RISCV32, UC_HOOK_CODE
from unicorn import riscv_const as rv
from display_patch import patch, HOOK, NORMAL_RETURN, OWNED_RETURN

ROOT=Path(__file__).resolve().parents[1]


def simulate(modifications=None, count=1, failure=None, wrong_type=False, density=125):
    stock=(ROOT/'firmwares/hw501/131/rootfs/bin/CPAAProxyEx').read_bytes()
    patched,meta=patch(stock,density=density)
    uc=Uc(UC_ARCH_RISCV,UC_MODE_RISCV32)
    uc.mem_map(0,0x400000);uc.mem_write(0x10000,patched)
    def get(n):return uc.reg_read(getattr(rv,'UC_RISCV_REG_'+n.upper()))
    def put(n,v):uc.reg_write(getattr(rv,'UC_RISCV_REG_'+n.upper()),v&0xffffffff)
    original={'widthPixels':800,'heightPixels':480,'widthPhysical':152,'heightPhysical':91,'maxFPS':60,'uuid':'unchanged','features':8,'touch':'unchanged'}
    original.update(modifications or {})
    objects={0x210000:[0x210100]*count,0x210100:copy.deepcopy(original)}
    refs={0x210000:1,0x210100:1}
    next_address=0x220000
    logs=[];calls=[];stopped=[]
    def allocate(obj):
        nonlocal next_address
        ptr=next_address;next_address+=0x100
        objects[ptr]=obj;refs[ptr]=1
        return ptr
    def release(ptr):
        refs[ptr]-=1
        assert refs[ptr]>=0,'Reference underflow'
        if refs[ptr]==0 and isinstance(objects[ptr],list):
            for item in objects[ptr]:release(item)
    reverse={v:k for k,v in meta['symbols'].items()}
    keys={v:k for k,v in meta['keys'].items()}
    keep={'ra':0x123456,'s2':0x201000,'s3':0x123400,'s4':0x567800,'s5':0xabc000,'s6':0xbbb000,'s7':0xccc000,'s8':0xddd000,'s9':0xeee000,'s10':0xfff000,'s11':0xaaa000}
    put('sp',0x310000);put('s1',0x200000)
    uc.mem_write(0x200000+200,struct.pack('<I',0x210000))
    for reg,val in keep.items():put(reg,val)
    def on_code(uc,address,size,user):
        if address in (NORMAL_RETURN,OWNED_RETURN):
            stopped.append(address);uc.emu_stop();return
        if address not in reverse:return
        name=reverse[address];calls.append(name)
        a0,a1,a2,a3=(get('a'+str(n)) for n in range(4));ret=get('ra');result=0;high=0
        if name=='CFArrayGetCount':result=len(objects[a0])
        elif name=='CFArrayGetValueAtIndex':result=objects[a0][a1]
        elif name=='CFGetTypeID':result=9 if wrong_type else 2
        elif name=='CFDictionaryGetTypeID':result=2
        elif name=='CFDictionaryGetInt64':
            value=objects[a0].get(keys[a1],0);result=value&0xffffffff;high=(value>>32)&0xffffffff
        elif name=='CFDictionaryCreateMutableCopy':
            result=0 if failure=='copy' else allocate(copy.deepcopy(objects[a2]))
        elif name=='CFDictionarySetInt64':
            if failure==keys[a1]:result=0xffffe5b8
            else:objects[a0][keys[a1]]=a2|(a3<<32)
        elif name=='CFArrayEnsureCreatedAndAppend':
            if failure=='array':result=0xffffe5b8
            else:
                ptr=allocate([a1]);refs[a1]+=1;uc.mem_write(a0,struct.pack('<I',ptr))
        elif name=='CFRelease':release(a0)
        elif name=='MLOGD':
            logs.append(bytes(uc.mem_read(a1,100)).split(b'\0',1)[0].decode())
        else:raise AssertionError(name)
        # Callee-saved registers must survive without relying on caller registers.
        for reg in ['t0','t1','t2','t3','t4','t5','t6']+['a'+str(n) for n in range(8)]:put(reg,0xdeadbeef)
        put('a0',result);put('a1',high);put('pc',ret)
    uc.hook_add(UC_HOOK_CODE,on_code)
    uc.emu_start(HOOK,0x3ffffc,count=10000)
    assert stopped,'Hook did not reach a continuation'
    assert get('sp')==0x310000
    for reg,value in keep.items():assert get(reg)==value,(reg,hex(get(reg)),hex(value))
    assert bytes(uc.mem_read(0x200000+200,4))==struct.pack('<I',0x210000)
    assert objects[0x210100]==original,'Original dictionary was modified'
    assert refs[0x210000]==refs[0x210100]==1,'Original ownership changed'
    result_ptr=get('s0')
    if stopped[0]==OWNED_RETURN:
        assert get('s1')==0
        result=copy.deepcopy(objects[objects[result_ptr][0]])
        assert refs[result_ptr]==1
        release(result_ptr)  # Simulate the receiving caller releasing its result.
    else:
        assert result_ptr==0x210000 and get('s1')==0x200000
        result=None
    assert all(v==0 for p,v in refs.items() if p>=0x220000),'Allocated object leaked'
    return result,logs,calls


class DisplayPatchTests(unittest.TestCase):
    density=125
    dimensions=(190,114)

    def simulate(self, *args, **kwargs):
        return simulate(*args, density=self.density, **kwargs)

    def test_only_physical_dimensions_change(self):
        result,logs,_=self.simulate()
        self.assertEqual(result,{'widthPixels':800,'heightPixels':480,'widthPhysical':self.dimensions[0],'heightPhysical':self.dimensions[1],'maxFPS':60,'uuid':'unchanged','features':8,'touch':'unchanged'})
        self.assertEqual(len(logs),1)
        self.assertIn(f'{self.dimensions[0]}x{self.dimensions[1]}mm',logs[0])

    def test_other_displays_are_unchanged(self):
        for key,value in [('widthPixels',1024),('heightPixels',600),('widthPhysical',160),('heightPhysical',90),('widthPixels',(1<<32)+800)]:
            with self.subTest(key=key,value=value):
                result,logs,_=self.simulate({key:value});self.assertIsNone(result);self.assertEqual(logs,[])

    def test_multiple_displays_unchanged(self):
        self.assertIsNone(self.simulate(count=2)[0])

    def test_wrong_dictionary_type_unchanged(self):
        self.assertIsNone(self.simulate(wrong_type=True)[0])

    def test_allocation_and_number_failures_fall_back_without_leaks(self):
        for failure in ('copy','widthPhysical','heightPhysical','array'):
            with self.subTest(failure=failure):self.assertIsNone(self.simulate(failure=failure)[0])

    def test_wrong_binary_rejected(self):
        with self.assertRaises(ValueError):patch(b'wrong firmware',density=self.density)


class DisplayPatch150Tests(DisplayPatchTests):
    density=150
    dimensions=(228,137)


if __name__=='__main__':unittest.main()
