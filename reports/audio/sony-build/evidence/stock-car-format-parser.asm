
/var/folders/wb/38qjft055l18_4qj_94p15cc0000gn/T/smartbox-sony-eft9p193/baseline/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0002ac94 <_HandleProxyEventConnectionClose@@Base+0x3f0>:
   2ac94:	10a05663          	blez	a0,2ada0 <_HandleProxyEventConnectionClose@@Base+0x4fc>
   2ac98:	080007b7          	lui	a5,0x8000
   2ac9c:	10078d93          	addi	s11,a5,256 # 8000100 <AOAProxy::sReaderBuffer@@Base+0x7ecf80c>
   2aca0:	01c0006f          	j	2acbc <_HandleProxyEventConnectionClose@@Base+0x418>
   2aca4:	405a68db          	.insn	4, 0x405a68db
   2aca8:	0ea4855b          	.insn	4, 0x0ea4855b
   2acac:	09852023          	sw	s8,128(a0)
   2acb0:	09952223          	sw	s9,132(a0)
   2acb4:	5712                	lw	a4,36(sp)
   2acb6:	0905                	addi	s2,s2,1
   2acb8:	0f270463          	beq	a4,s2,2ada0 <_HandleProxyEventConnectionClose@@Base+0x4fc>
   2acbc:	85ca                	mv	a1,s2
   2acbe:	856a                	mv	a0,s10
   2acc0:	ffff5097          	auipc	ra,0xffff5
   2acc4:	6b0080e7          	jalr	1712(ra) # 20370 <CFArrayGetValueAtIndex@plt>
   2acc8:	8622                	mv	a2,s0
   2acca:	000db597          	auipc	a1,0xdb
   2acce:	ec258593          	addi	a1,a1,-318 # 105b8c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa072c>
   2acd2:	8c2a                	mv	s8,a0
   2acd4:	ffff5097          	auipc	ra,0xffff5
   2acd8:	b6c080e7          	jalr	-1172(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2acdc:	00050a13          	mv	s4,a0
   2ace0:	ffff7097          	auipc	ra,0xffff7
   2ace4:	f30080e7          	jalr	-208(ra) # 21c10 <CFStringGetTypeID@plt>
   2ace8:	86a2                	mv	a3,s0
   2acea:	862a                	mv	a2,a0
   2acec:	000db597          	auipc	a1,0xdb
   2acf0:	23858593          	addi	a1,a1,568 # 105f24 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0ac4>
   2acf4:	000c0513          	mv	a0,s8
   2acf8:	ffff6097          	auipc	ra,0xffff6
   2acfc:	e38080e7          	jalr	-456(ra) # 20b30 <CFDictionaryGetTypedValue@plt>
   2ad00:	8622                	mv	a2,s0
   2ad02:	89aa                	mv	s3,a0
   2ad04:	000db597          	auipc	a1,0xdb
   2ad08:	23458593          	addi	a1,a1,564 # 105f38 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0ad8>
   2ad0c:	000c0513          	mv	a0,s8
   2ad10:	ffff5097          	auipc	ra,0xffff5
   2ad14:	b30080e7          	jalr	-1232(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2ad18:	8622                	mv	a2,s0
   2ad1a:	8b2a                	mv	s6,a0
   2ad1c:	8bae                	mv	s7,a1
   2ad1e:	8562                	mv	a0,s8
   2ad20:	000db597          	auipc	a1,0xdb
   2ad24:	23458593          	addi	a1,a1,564 # 105f54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0af4>
   2ad28:	ffff5097          	auipc	ra,0xffff5
   2ad2c:	b18080e7          	jalr	-1256(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2ad30:	000dd697          	auipc	a3,0xdd
   2ad34:	53c68693          	addi	a3,a3,1340 # 10826c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2e0c>
   2ad38:	8c2a                	mv	s8,a0
   2ad3a:	8cae                	mv	s9,a1
   2ad3c:	854e                	mv	a0,s3
   2ad3e:	85ee                	mv	a1,s11
   2ad40:	00098863          	beqz	s3,2ad50 <_HandleProxyEventConnectionClose@@Base+0x4ac>
   2ad44:	ffff5097          	auipc	ra,0xffff5
   2ad48:	c8c080e7          	jalr	-884(ra) # 1f9d0 <CFStringGetCStringPtr@plt>
   2ad4c:	00050693          	mv	a3,a0
   2ad50:	885a                	mv	a6,s6
   2ad52:	88de                	mv	a7,s7
   2ad54:	8762                	mv	a4,s8
   2ad56:	87e6                	mv	a5,s9
   2ad58:	000a0613          	mv	a2,s4
   2ad5c:	000da597          	auipc	a1,0xda
   2ad60:	76058593          	addi	a1,a1,1888 # 1054bc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa005c> ; DATA 'AudioFormats streamtype:%d audioType:%s output:0x%llx input:0x%llx'
   2ad64:	000da517          	auipc	a0,0xda
   2ad68:	eb850513          	addi	a0,a0,-328 # 104c1c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f7bc> ; DATA 'ProxyClient'
   2ad6c:	ffff7097          	auipc	ra,0xffff7
   2ad70:	f94080e7          	jalr	-108(ra) # 21d00 <MLOGD@plt>
   2ad74:	00098513          	mv	a0,s3
   2ad78:	ffff6097          	auipc	ra,0xffff6
   2ad7c:	498080e7          	jalr	1176(ra) # 21210 <AudioTypeGetInt32Value@plt>
   2ad80:	f24a62db          	.insn	4, 0xf24a62db
   2ad84:	0ea487db          	.insn	4, 0x0ea487db
   2ad88:	5712                	lw	a4,36(sp)
   2ad8a:	0905                	addi	s2,s2,1
   2ad8c:	0567a423          	sw	s6,72(a5)
   2ad90:	0577a623          	sw	s7,76(a5)
   2ad94:	0187a823          	sw	s8,16(a5)
   2ad98:	0197aa23          	sw	s9,20(a5)
   2ad9c:	f32710e3          	bne	a4,s2,2acbc <_HandleProxyEventConnectionClose@@Base+0x418>
   2ada0:	4088                	lw	a0,0(s1)
   2ada2:	c509                	beqz	a0,2adac <_HandleProxyEventConnectionClose@@Base+0x508>
   2ada4:	ffff7097          	auipc	ra,0xffff7
   2ada8:	d3c080e7          	jalr	-708(ra) # 21ae0 <CFRelease@plt>
   2adac:	85ea                	mv	a1,s10
   2adae:	4501                	li	a0,0
   2adb0:	ffff5097          	auipc	ra,0xffff5
   2adb4:	a20080e7          	jalr	-1504(ra) # 1f7d0 <CFArrayCreateCopy@plt>
   2adb8:	00a4a023          	sw	a0,0(s1)
   2adbc:	ffff5097          	auipc	ra,0xffff5
   2adc0:	7e4080e7          	jalr	2020(ra) # 205a0 <CFArrayGetTypeID@plt>
