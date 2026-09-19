
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0002aee4 <_HandleProxyEventConnectionClose@@Base+0x640>:
   2aee4:	ffff5097          	auipc	ra,0xffff5
   2aee8:	6bc080e7          	jalr	1724(ra) # 205a0 <CFArrayGetTypeID@plt>
   2aeec:	4681                	li	a3,0
   2aeee:	862a                	mv	a2,a0
   2aef0:	000db597          	auipc	a1,0xdb
   2aef4:	0b058593          	addi	a1,a1,176 # 105fa0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b40> ; CFSTRING 'displays'
   2aef8:	000a8513          	mv	a0,s5
   2aefc:	ffff6097          	auipc	ra,0xffff6
   2af00:	c34080e7          	jalr	-972(ra) # 20b30 <CFDictionaryGetTypedValue@plt>
   2af04:	00050413          	mv	s0,a0
   2af08:	240500e3          	beqz	a0,2b948 <_HandleProxyEventConnectionClose@@Base+0x10a4>
   2af0c:	ffff6097          	auipc	ra,0xffff6
   2af10:	5b4080e7          	jalr	1460(ra) # 214c0 <CFArrayGetCount@plt>
   2af14:	000da597          	auipc	a1,0xda
   2af18:	5ec58593          	addi	a1,a1,1516 # 105500 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa00a0> ; DATA 'Recv proxy disply count:%d\n'
   2af1c:	8baa                	mv	s7,a0
   2af1e:	862a                	mv	a2,a0
   2af20:	000da517          	auipc	a0,0xda
   2af24:	cfc50513          	addi	a0,a0,-772 # 104c1c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f7bc> ; DATA 'ProxyClient'
   2af28:	00000913          	li	s2,0
   2af2c:	ffff7097          	auipc	ra,0xffff7
   2af30:	dd4080e7          	jalr	-556(ra) # 21d00 <MLOGD@plt>
   2af34:	07705663          	blez	s7,2afa0 <_HandleProxyEventConnectionClose@@Base+0x6fc>
   2af38:	6685                	lui	a3,0x1
   2af3a:	9f898b13          	addi	s6,s3,-1544
   2af3e:	63068713          	addi	a4,a3,1584 # 1630 <CFArrayCreateCopy@plt-0x1e1a0>
   2af42:	975a                	add	a4,a4,s6
   2af44:	1010                	addi	a2,sp,32
   2af46:	00c70b33          	add	s6,a4,a2
   2af4a:	63068713          	addi	a4,a3,1584
   2af4e:	974e                	add	a4,a4,s3
   2af50:	00c709b3          	add	s3,a4,a2
   2af54:	000dbc17          	auipc	s8,0xdb
   2af58:	c38c0c13          	addi	s8,s8,-968 # 105b8c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa072c>
   2af5c:	ffff5097          	auipc	ra,0xffff5
   2af60:	794080e7          	jalr	1940(ra) # 206f0 <CFDictionaryGetTypeID@plt>
   2af64:	85ca                	mv	a1,s2
   2af66:	862a                	mv	a2,a0
   2af68:	86da                	mv	a3,s6
   2af6a:	8522                	mv	a0,s0
   2af6c:	ffff6097          	auipc	ra,0xffff6
   2af70:	704080e7          	jalr	1796(ra) # 21670 <CFArrayGetTypedValueAtIndex@plt>
   2af74:	9f89a783          	lw	a5,-1544(s3)
   2af78:	8a2a                	mv	s4,a0
   2af7a:	4601                	li	a2,0
   2af7c:	85e2                	mv	a1,s8
   2af7e:	0905                	addi	s2,s2,1
   2af80:	180796e3          	bnez	a5,2b90c <_HandleProxyEventConnectionClose@@Base+0x1068>
   2af84:	ffff5097          	auipc	ra,0xffff5
   2af88:	8bc080e7          	jalr	-1860(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2af8c:	00b567b3          	or	a5,a0,a1
   2af90:	240784e3          	beqz	a5,2b9d8 <_HandleProxyEventConnectionClose@@Base+0x1134>
   2af94:	40e564db          	.insn	4, 0x40e564db
   2af98:	23d0006f          	j	2b9d4 <_HandleProxyEventConnectionClose@@Base+0x1130>
   2af9c:	fd2b90e3          	bne	s7,s2,2af5c <_HandleProxyEventConnectionClose@@Base+0x6b8>
