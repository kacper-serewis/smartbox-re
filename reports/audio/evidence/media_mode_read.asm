
CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

000390d4 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2bac>:
   390d4:	000cf597          	auipc	a1,0xcf
   390d8:	3c458593          	addi	a1,a1,964 # 108498 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa3038> ; DATA 'audiomode'
   390dc:	00040513          	mv	a0,s0
   390e0:	fffe9097          	auipc	ra,0xfffe9
   390e4:	b20080e7          	jalr	-1248(ra) # 21c00 <MString::MString(char const*)@plt>
   390e8:	4601                	li	a2,0
   390ea:	85a2                	mv	a1,s0
   390ec:	00090513          	mv	a0,s2
   390f0:	fffe9097          	auipc	ra,0xfffe9
   390f4:	ab0080e7          	jalr	-1360(ra) # 21ba0 <MIniConfig::valueInt(MString const&, int)@plt>
   390f8:	6789                	lui	a5,0x2
   390fa:	97a6                	add	a5,a5,s1
   390fc:	5762                	lw	a4,56(sp)
   390fe:	3ca7aa23          	sw	a0,980(a5) # 23d4 <CFArrayCreateCopy@plt-0x1d3fc>
   39102:	01370763          	beq	a4,s3,39110 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2be8>
   39106:	853a                	mv	a0,a4
   39108:	fffe7097          	auipc	ra,0xfffe7
   3910c:	708080e7          	jalr	1800(ra) # 20810 <operator delete(void*)@plt>
