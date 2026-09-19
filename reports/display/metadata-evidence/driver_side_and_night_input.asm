
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0002b7a0 <_HandleProxyEventConnectionClose@@Base+0xefc>:
   2b7a0:	747d                	lui	s0,0xfffff
   2b7a2:	6c85                	lui	s9,0x1
   2b7a4:	9f840613          	addi	a2,s0,-1544 # ffffe9f8 <AOAProxy::sReaderBuffer@@Base+0xffece104>
   2b7a8:	630c8693          	addi	a3,s9,1584 # 1630 <CFArrayCreateCopy@plt-0x1e1a0>
   2b7ac:	1018                	addi	a4,sp,32
   2b7ae:	96b2                	add	a3,a3,a2
   2b7b0:	00e68633          	add	a2,a3,a4
   2b7b4:	000db597          	auipc	a1,0xdb
   2b7b8:	a8058593          	addi	a1,a1,-1408 # 106234 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0dd4> ; CFSTRING 'rightHandDrive'
   2b7bc:	000a8513          	mv	a0,s5
   2b7c0:	0b24ac23          	sw	s2,184(s1)
   2b7c4:	ffff4097          	auipc	ra,0xffff4
   2b7c8:	07c080e7          	jalr	124(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2b7cc:	630c8713          	addi	a4,s9,1584
   2b7d0:	9722                	add	a4,a4,s0
   2b7d2:	1010                	addi	a2,sp,32
   2b7d4:	00c70433          	add	s0,a4,a2
   2b7d8:	77f9                	lui	a5,0xffffe
   2b7da:	9f842703          	lw	a4,-1544(s0)
   2b7de:	5b978793          	addi	a5,a5,1465 # ffffe5b9 <AOAProxy::sReaderBuffer@@Base+0xffecdcc5>
   2b7e2:	58f70d63          	beq	a4,a5,2bd7c <_HandleProxyEventConnectionClose@@Base+0x14d8>
   2b7e6:	8d4d                	or	a0,a0,a1
   2b7e8:	5a050463          	beqz	a0,2bd90 <_HandleProxyEventConnectionClose@@Base+0x14ec>
   2b7ec:	00104797          	auipc	a5,0x104
   2b7f0:	a407a783          	lw	a5,-1472(a5) # 12f22c <kCFLBooleanTrue@Base> ; DATA ELF relocation: kCFLBooleanTrue
   2b7f4:	0007a783          	lw	a5,0(a5)
   2b7f8:	0ef4a223          	sw	a5,228(s1)
   2b7fc:	747d                	lui	s0,0xfffff
   2b7fe:	6b85                	lui	s7,0x1
   2b800:	9f840613          	addi	a2,s0,-1544 # ffffe9f8 <AOAProxy::sReaderBuffer@@Base+0xffece104>
   2b804:	630b8693          	addi	a3,s7,1584 # 1630 <CFArrayCreateCopy@plt-0x1e1a0>
   2b808:	96b2                	add	a3,a3,a2
   2b80a:	1018                	addi	a4,sp,32
   2b80c:	00e68633          	add	a2,a3,a4
   2b810:	000da597          	auipc	a1,0xda
   2b814:	54458593          	addi	a1,a1,1348 # 105d54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa08f4> ; CFSTRING 'nightMode'
   2b818:	000a8513          	mv	a0,s5
   2b81c:	ffff4097          	auipc	ra,0xffff4
   2b820:	024080e7          	jalr	36(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2b824:	630b8713          	addi	a4,s7,1584
   2b828:	9722                	add	a4,a4,s0
   2b82a:	1014                	addi	a3,sp,32
   2b82c:	00d70433          	add	s0,a4,a3
   2b830:	77f9                	lui	a5,0xffffe
   2b832:	9f842703          	lw	a4,-1544(s0)
   2b836:	5b978793          	addi	a5,a5,1465 # ffffe5b9 <AOAProxy::sReaderBuffer@@Base+0xffecdcc5>
   2b83a:	52f70963          	beq	a4,a5,2bd6c <_HandleProxyEventConnectionClose@@Base+0x14c8>
   2b83e:	8d4d                	or	a0,a0,a1
   2b840:	5a050263          	beqz	a0,2bde4 <_HandleProxyEventConnectionClose@@Base+0x1540>
   2b844:	00104797          	auipc	a5,0x104
   2b848:	9e87a783          	lw	a5,-1560(a5) # 12f22c <kCFLBooleanTrue@Base> ; DATA ELF relocation: kCFLBooleanTrue
   2b84c:	0007a783          	lw	a5,0(a5)
   2b850:	0ef4a423          	sw	a5,232(s1)
