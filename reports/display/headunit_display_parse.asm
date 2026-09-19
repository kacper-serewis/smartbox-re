
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0002b990 <_HandleProxyEventConnectionClose@@Base+0x10ec>:
   2b990:	5732                	lw	a4,44(sp)
   2b992:	5642                	lw	a2,48(sp)
   2b994:	0705                	addi	a4,a4,1
   2b996:	86de                	mv	a3,s7
   2b998:	000da597          	auipc	a1,0xda
   2b99c:	d5c58593          	addi	a1,a1,-676 # 1056f4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0294> ; DATA 'Reset hid name:%s uuid to %s\n'
   2b9a0:	000d9517          	auipc	a0,0xd9
   2b9a4:	27c50513          	addi	a0,a0,636 # 104c1c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f7bc> ; DATA 'ProxyClient'
   2b9a8:	02e12623          	sw	a4,44(sp)
   2b9ac:	ffff6097          	auipc	ra,0xffff6
   2b9b0:	354080e7          	jalr	852(ra) # 21d00 <MLOGD@plt>
   2b9b4:	9bdff06f          	j	2b370 <_HandleProxyEventConnectionClose@@Base+0xacc>
   2b9b8:	0c04a623          	sw	zero,204(s1)
   2b9bc:	0d04a503          	lw	a0,208(s1)
   2b9c0:	9e0502e3          	beqz	a0,2b3a4 <_HandleProxyEventConnectionClose@@Base+0xb00>
   2b9c4:	ffff6097          	auipc	ra,0xffff6
   2b9c8:	11c080e7          	jalr	284(ra) # 21ae0 <CFRelease@plt>
   2b9cc:	0c04a823          	sw	zero,208(s1)
   2b9d0:	9d5ff06f          	j	2b3a4 <_HandleProxyEventConnectionClose@@Base+0xb00>
   2b9d4:	dc059463          	bnez	a1,2af9c <_HandleProxyEventConnectionClose@@Base+0x6f8>
   2b9d8:	4701                	li	a4,0
   2b9da:	10000693          	li	a3,256
   2b9de:	0f048613          	addi	a2,s1,240
   2b9e2:	000da597          	auipc	a1,0xda
   2b9e6:	3b658593          	addi	a1,a1,950 # 105d98 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0938>
   2b9ea:	8552                	mv	a0,s4
   2b9ec:	0e048823          	sb	zero,240(s1)
   2b9f0:	ffff4097          	auipc	ra,0xffff4
   2b9f4:	540080e7          	jalr	1344(ra) # 1ff30 <CFDictionaryGetCString@plt>
   2b9f8:	4601                	li	a2,0
   2b9fa:	000da597          	auipc	a1,0xda
   2b9fe:	27658593          	addi	a1,a1,630 # 105c70 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0810>
   2ba02:	8552                	mv	a0,s4
   2ba04:	ffff4097          	auipc	ra,0xffff4
   2ba08:	e3c080e7          	jalr	-452(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2ba0c:	4601                	li	a2,0
   2ba0e:	892a                	mv	s2,a0
   2ba10:	89ae                	mv	s3,a1
   2ba12:	8552                	mv	a0,s4
   2ba14:	000da597          	auipc	a1,0xda
   2ba18:	5a058593          	addi	a1,a1,1440 # 105fb4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b54>
   2ba1c:	ffff4097          	auipc	ra,0xffff4
   2ba20:	e24080e7          	jalr	-476(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2ba24:	6741                	lui	a4,0x10
   2ba26:	8bae                	mv	s7,a1
   2ba28:	8b2a                	mv	s6,a0
   2ba2a:	4801                	li	a6,0
   2ba2c:	177d                	addi	a4,a4,-1 # ffff <CFArrayCreateCopy@plt-0xf7d1>
   2ba2e:	4781                	li	a5,0
   2ba30:	4601                	li	a2,0
   2ba32:	4681                	li	a3,0
   2ba34:	000da597          	auipc	a1,0xda
   2ba38:	59c58593          	addi	a1,a1,1436 # 105fd0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b70>
   2ba3c:	000a0513          	mv	a0,s4
   2ba40:	ffff5097          	auipc	ra,0xffff5
   2ba44:	f50080e7          	jalr	-176(ra) # 20990 <CFDictionaryGetInt64Ranged@plt>
   2ba48:	6741                	lui	a4,0x10
   2ba4a:	3c0528db          	.insn	4, 0x3c0528db
   2ba4e:	4801                	li	a6,0
   2ba50:	177d                	addi	a4,a4,-1 # ffff <CFArrayCreateCopy@plt-0xf7d1>
   2ba52:	4781                	li	a5,0
   2ba54:	4601                	li	a2,0
   2ba56:	4681                	li	a3,0
   2ba58:	000da597          	auipc	a1,0xda
   2ba5c:	58c58593          	addi	a1,a1,1420 # 105fe4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b84>
   2ba60:	000a0513          	mv	a0,s4
   2ba64:	2514a023          	sw	a7,576(s1)
   2ba68:	ffff5097          	auipc	ra,0xffff5
   2ba6c:	f28080e7          	jalr	-216(ra) # 20990 <CFDictionaryGetInt64Ranged@plt>
   2ba70:	6741                	lui	a4,0x10
   2ba72:	3c0528db          	.insn	4, 0x3c0528db
   2ba76:	4801                	li	a6,0
   2ba78:	177d                	addi	a4,a4,-1 # ffff <CFArrayCreateCopy@plt-0xf7d1>
   2ba7a:	4781                	li	a5,0
   2ba7c:	4601                	li	a2,0
   2ba7e:	4681                	li	a3,0
   2ba80:	000da597          	auipc	a1,0xda
   2ba84:	57c58593          	addi	a1,a1,1404 # 105ffc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b9c>
   2ba88:	000a0513          	mv	a0,s4
   2ba8c:	2514a223          	sw	a7,580(s1)
   2ba90:	ffff5097          	auipc	ra,0xffff5
   2ba94:	f00080e7          	jalr	-256(ra) # 20990 <CFDictionaryGetInt64Ranged@plt>
   2ba98:	2404a303          	lw	t1,576(s1)
   2ba9c:	2444a883          	lw	a7,580(s1)
   2baa0:	6741                	lui	a4,0x10
   2baa2:	ffe37313          	andi	t1,t1,-2
   2baa6:	3c052e5b          	.insn	4, 0x3c052e5b
   2baaa:	ffe8f893          	andi	a7,a7,-2
   2baae:	4801                	li	a6,0
   2bab0:	177d                	addi	a4,a4,-1 # ffff <CFArrayCreateCopy@plt-0xf7d1>
   2bab2:	4781                	li	a5,0
   2bab4:	4601                	li	a2,0
   2bab6:	4681                	li	a3,0
   2bab8:	000da597          	auipc	a1,0xda
   2babc:	55458593          	addi	a1,a1,1364 # 10600c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0bac>
   2bac0:	000a0513          	mv	a0,s4
   2bac4:	25c4a823          	sw	t3,592(s1)
   2bac8:	2464a023          	sw	t1,576(s1)
   2bacc:	2264ac23          	sw	t1,568(s1)
   2bad0:	2514a223          	sw	a7,580(s1)
   2bad4:	2314ae23          	sw	a7,572(s1)
   2bad8:	2204aa23          	sw	zero,564(s1)
   2badc:	2204a823          	sw	zero,560(s1)
   2bae0:	ffff5097          	auipc	ra,0xffff5
   2bae4:	eb0080e7          	jalr	-336(ra) # 20990 <CFDictionaryGetInt64Ranged@plt>
   2bae8:	6741                	lui	a4,0x10
   2baea:	3c0528db          	.insn	4, 0x3c0528db
   2baee:	4601                	li	a2,0
   2baf0:	4681                	li	a3,0
   2baf2:	4801                	li	a6,0
   2baf4:	177d                	addi	a4,a4,-1 # ffff <CFArrayCreateCopy@plt-0xf7d1>
   2baf6:	4781                	li	a5,0
   2baf8:	000da597          	auipc	a1,0xda
   2bafc:	52c58593          	addi	a1,a1,1324 # 106024 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0bc4>
   2bb00:	000a0513          	mv	a0,s4
   2bb04:	2514a423          	sw	a7,584(s1)
   2bb08:	ffff5097          	auipc	ra,0xffff5
   2bb0c:	e88080e7          	jalr	-376(ra) # 20990 <CFDictionaryGetInt64Ranged@plt>
   2bb10:	2484af03          	lw	t5,584(s1)
   2bb14:	2504ae83          	lw	t4,592(s1)
   2bb18:	2444ae03          	lw	t3,580(s1)
   2bb1c:	2404a303          	lw	t1,576(s1)
   2bb20:	3c0526db          	.insn	4, 0x3c0526db
   2bb24:	24d4a623          	sw	a3,588(s1)
   2bb28:	88de                	mv	a7,s7
   2bb2a:	885a                	mv	a6,s6
   2bb2c:	874a                	mv	a4,s2
   2bb2e:	87ce                	mv	a5,s3
   2bb30:	0f048613          	addi	a2,s1,240
   2bb34:	000da597          	auipc	a1,0xda
   2bb38:	9e858593          	addi	a1,a1,-1560 # 10551c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa00bc> ; DATA 'Recv proxy disply infos: UUID:%s features:%lld inputPrimitDevice:%lld VideoWidth=%u VideoHeight=%u FPS=%d WidthMM=%u HeightMM=%u\n'
   2bb3c:	000d9517          	auipc	a0,0xd9
   2bb40:	0e050513          	addi	a0,a0,224 # 104c1c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f7bc> ; DATA 'ProxyClient'
   2bb44:	c836                	sw	a3,16(sp)
   2bb46:	c67a                	sw	t5,12(sp)
   2bb48:	c476                	sw	t4,8(sp)
   2bb4a:	c272                	sw	t3,4(sp)
   2bb4c:	00612023          	sw	t1,0(sp)
   2bb50:	ffff6097          	auipc	ra,0xffff6
   2bb54:	1b0080e7          	jalr	432(ra) # 21d00 <MLOGD@plt>
