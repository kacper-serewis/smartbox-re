
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0002b9d4 <_HandleProxyEventConnectionClose@@Base+0x1130>:
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
   2b9fe:	27658593          	addi	a1,a1,630 # 105c70 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0810> ; CFSTRING 'features'
   2ba02:	8552                	mv	a0,s4
   2ba04:	ffff4097          	auipc	ra,0xffff4
   2ba08:	e3c080e7          	jalr	-452(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2ba0c:	4601                	li	a2,0
   2ba0e:	892a                	mv	s2,a0
   2ba10:	89ae                	mv	s3,a1
   2ba12:	8552                	mv	a0,s4
   2ba14:	000da597          	auipc	a1,0xda
   2ba18:	5a058593          	addi	a1,a1,1440 # 105fb4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b54> ; CFSTRING 'primaryInputDevice'
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
   2ba38:	59c58593          	addi	a1,a1,1436 # 105fd0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b70> ; CFSTRING 'widthPixels'
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
   2ba5c:	58c58593          	addi	a1,a1,1420 # 105fe4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b84> ; CFSTRING 'heightPixels'
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
   2ba84:	57c58593          	addi	a1,a1,1404 # 105ffc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b9c> ; CFSTRING 'maxFPS'
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
   2babc:	55458593          	addi	a1,a1,1364 # 10600c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0bac> ; CFSTRING 'widthPhysical'
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
   2bafc:	52c58593          	addi	a1,a1,1324 # 106024 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0bc4> ; CFSTRING 'heightPhysical'
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
   2bb58:	4601                	li	a2,0
   2bb5a:	000da597          	auipc	a1,0xda
   2bb5e:	4e258593          	addi	a1,a1,1250 # 10603c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0bdc> ; CFSTRING 'initialViewArea'
   2bb62:	8552                	mv	a0,s4
   2bb64:	ffff4097          	auipc	ra,0xffff4
   2bb68:	cdc080e7          	jalr	-804(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2bb6c:	d82a                	sw	a0,48(sp)
   2bb6e:	de2e                	sw	a1,60(sp)
   2bb70:	8c2a                	mv	s8,a0
   2bb72:	8bae                	mv	s7,a1
   2bb74:	000a0513          	mv	a0,s4
   2bb78:	000da597          	auipc	a1,0xda
   2bb7c:	4dc58593          	addi	a1,a1,1244 # 106054 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0bf4> ; CFSTRING 'viewAreas'
   2bb80:	ffff5097          	auipc	ra,0xffff5
   2bb84:	640080e7          	jalr	1600(ra) # 211c0 <CFDictionaryGetValue@plt>
   2bb88:	00050c93          	mv	s9,a0
   2bb8c:	28050663          	beqz	a0,2be18 <_HandleProxyEventConnectionClose@@Base+0x1574>
   2bb90:	ffff6097          	auipc	ra,0xffff6
   2bb94:	930080e7          	jalr	-1744(ra) # 214c0 <CFArrayGetCount@plt>
   2bb98:	8762                	mv	a4,s8
   2bb9a:	8b2a                	mv	s6,a0
   2bb9c:	862a                	mv	a2,a0
   2bb9e:	da2a                	sw	a0,52(sp)
   2bba0:	000b8793          	mv	a5,s7
   2bba4:	000da597          	auipc	a1,0xda
   2bba8:	9fc58593          	addi	a1,a1,-1540 # 1055a0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0140> ; DATA 'Recv proxy disply viewareas:%d inInitialArea:%lld\n'
   2bbac:	000d9517          	auipc	a0,0xd9
   2bbb0:	07050513          	addi	a0,a0,112 # 104c1c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f7bc> ; DATA 'ProxyClient'
   2bbb4:	ffff6097          	auipc	ra,0xffff6
   2bbb8:	14c080e7          	jalr	332(ra) # 21d00 <MLOGD@plt>
   2bbbc:	bf605263          	blez	s6,2afa0 <_HandleProxyEventConnectionClose@@Base+0x6fc>
   2bbc0:	41fb5793          	srai	a5,s6,0x1f
   2bbc4:	00fbc663          	blt	s7,a5,2bbd0 <_HandleProxyEventConnectionClose@@Base+0x132c>
   2bbc8:	bd779c63          	bne	a5,s7,2afa0 <_HandleProxyEventConnectionClose@@Base+0x6fc>
   2bbcc:	bd6c7a63          	bgeu	s8,s6,2afa0 <_HandleProxyEventConnectionClose@@Base+0x6fc>
   2bbd0:	4d81                	li	s11,0
   2bbd2:	000dad17          	auipc	s10,0xda
   2bbd6:	3fed0d13          	addi	s10,s10,1022 # 105fd0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b70> ; CFSTRING 'widthPixels'
   2bbda:	d202                	sw	zero,36(sp)
   2bbdc:	0140006f          	j	2bbf0 <_HandleProxyEventConnectionClose@@Base+0x134c>
   2bbe0:	5712                	lw	a4,36(sp)
   2bbe2:	8dbe                	mv	s11,a5
   2bbe4:	96ba                	add	a3,a3,a4
   2bbe6:	d236                	sw	a3,36(sp)
   2bbe8:	03412683          	lw	a3,52(sp)
   2bbec:	bad7da63          	bge	a5,a3,2afa0 <_HandleProxyEventConnectionClose@@Base+0x6fc>
   2bbf0:	85ee                	mv	a1,s11
   2bbf2:	8566                	mv	a0,s9
   2bbf4:	ffff4097          	auipc	ra,0xffff4
   2bbf8:	77c080e7          	jalr	1916(ra) # 20370 <CFArrayGetValueAtIndex@plt>
   2bbfc:	4601                	li	a2,0
   2bbfe:	85ea                	mv	a1,s10
   2bc00:	00050913          	mv	s2,a0
   2bc04:	ffff4097          	auipc	ra,0xffff4
   2bc08:	c3c080e7          	jalr	-964(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2bc0c:	4601                	li	a2,0
   2bc0e:	8a2a                	mv	s4,a0
   2bc10:	d62e                	sw	a1,44(sp)
   2bc12:	854a                	mv	a0,s2
   2bc14:	000da597          	auipc	a1,0xda
   2bc18:	3d058593          	addi	a1,a1,976 # 105fe4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b84> ; CFSTRING 'heightPixels'
   2bc1c:	ffff4097          	auipc	ra,0xffff4
   2bc20:	c24080e7          	jalr	-988(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2bc24:	4601                	li	a2,0
   2bc26:	89aa                	mv	s3,a0
   2bc28:	8bae                	mv	s7,a1
   2bc2a:	854a                	mv	a0,s2
   2bc2c:	000da597          	auipc	a1,0xda
   2bc30:	43c58593          	addi	a1,a1,1084 # 106068 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0c08> ; CFSTRING 'originXPixels'
   2bc34:	ffff4097          	auipc	ra,0xffff4
   2bc38:	c0c080e7          	jalr	-1012(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2bc3c:	4601                	li	a2,0
   2bc3e:	8b2a                	mv	s6,a0
   2bc40:	d42e                	sw	a1,40(sp)
   2bc42:	854a                	mv	a0,s2
   2bc44:	000da597          	auipc	a1,0xda
   2bc48:	43c58593          	addi	a1,a1,1084 # 106080 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0c20> ; CFSTRING 'originYPixels'
   2bc4c:	ffff4097          	auipc	ra,0xffff4
   2bc50:	bf4080e7          	jalr	-1036(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2bc54:	58b2                	lw	a7,44(sp)
   2bc56:	56a2                	lw	a3,40(sp)
   2bc58:	87ae                	mv	a5,a1
   2bc5a:	872a                	mv	a4,a0
   2bc5c:	865a                	mv	a2,s6
   2bc5e:	8852                	mv	a6,s4
   2bc60:	000da597          	auipc	a1,0xda
   2bc64:	97458593          	addi	a1,a1,-1676 # 1055d4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0174> ; DATA 'Recv proxy disply viewarea infos origin:%lldx%lld size:%lldx%lld\n'
   2bc68:	8c2a                	mv	s8,a0
   2bc6a:	000d9517          	auipc	a0,0xd9
   2bc6e:	fb250513          	addi	a0,a0,-78 # 104c1c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f7bc> ; DATA 'ProxyClient'
   2bc72:	c04e                	sw	s3,0(sp)
   2bc74:	01712223          	sw	s7,4(sp)
   2bc78:	ffff6097          	auipc	ra,0xffff6
   2bc7c:	088080e7          	jalr	136(ra) # 21d00 <MLOGD@plt>
   2bc80:	000da597          	auipc	a1,0xda
   2bc84:	41858593          	addi	a1,a1,1048 # 106098 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0c38> ; CFSTRING 'safeArea'
   2bc88:	00090513          	mv	a0,s2
   2bc8c:	ffff5097          	auipc	ra,0xffff5
   2bc90:	534080e7          	jalr	1332(ra) # 211c0 <CFDictionaryGetValue@plt>
   2bc94:	4601                	li	a2,0
   2bc96:	892a                	mv	s2,a0
   2bc98:	85ea                	mv	a1,s10
   2bc9a:	cd59                	beqz	a0,2bd38 <_HandleProxyEventConnectionClose@@Base+0x1494>
   2bc9c:	ffff4097          	auipc	ra,0xffff4
   2bca0:	ba4080e7          	jalr	-1116(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2bca4:	4601                	li	a2,0
   2bca6:	8a2a                	mv	s4,a0
   2bca8:	dc2e                	sw	a1,56(sp)
   2bcaa:	854a                	mv	a0,s2
   2bcac:	000da597          	auipc	a1,0xda
   2bcb0:	33858593          	addi	a1,a1,824 # 105fe4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0b84> ; CFSTRING 'heightPixels'
   2bcb4:	ffff4097          	auipc	ra,0xffff4
   2bcb8:	b8c080e7          	jalr	-1140(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2bcbc:	4601                	li	a2,0
   2bcbe:	89aa                	mv	s3,a0
   2bcc0:	8bae                	mv	s7,a1
   2bcc2:	854a                	mv	a0,s2
   2bcc4:	000da597          	auipc	a1,0xda
   2bcc8:	3a458593          	addi	a1,a1,932 # 106068 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0c08> ; CFSTRING 'originXPixels'
   2bccc:	ffff4097          	auipc	ra,0xffff4
   2bcd0:	b74080e7          	jalr	-1164(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2bcd4:	4601                	li	a2,0
   2bcd6:	8b2a                	mv	s6,a0
   2bcd8:	d62e                	sw	a1,44(sp)
   2bcda:	854a                	mv	a0,s2
   2bcdc:	000da597          	auipc	a1,0xda
   2bce0:	3a458593          	addi	a1,a1,932 # 106080 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0c20> ; CFSTRING 'originYPixels'
   2bce4:	ffff4097          	auipc	ra,0xffff4
   2bce8:	b5c080e7          	jalr	-1188(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2bcec:	4601                	li	a2,0
   2bcee:	8c2a                	mv	s8,a0
   2bcf0:	d42e                	sw	a1,40(sp)
   2bcf2:	854a                	mv	a0,s2
   2bcf4:	000da597          	auipc	a1,0xda
   2bcf8:	3b858593          	addi	a1,a1,952 # 1060ac <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0c4c> ; CFSTRING 'drawUIOutsideSafeArea'
   2bcfc:	ffff4097          	auipc	ra,0xffff4
   2bd00:	b44080e7          	jalr	-1212(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2bd04:	58e2                	lw	a7,56(sp)
   2bd06:	8dc9                	or	a1,a1,a0
   2bd08:	57a2                	lw	a5,40(sp)
   2bd0a:	56b2                	lw	a3,44(sp)
   2bd0c:	00b03eb3          	snez	t4,a1
   2bd10:	8852                	mv	a6,s4
   2bd12:	8762                	mv	a4,s8
   2bd14:	865a                	mv	a2,s6
   2bd16:	000da597          	auipc	a1,0xda
   2bd1a:	90258593          	addi	a1,a1,-1790 # 105618 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa01b8> ; DATA 'Recv proxy disply safeArea origin:%lldx%lld size:%lldx%lld drawUIOutsideSafeArea:%d\n'
   2bd1e:	000d9517          	auipc	a0,0xd9
   2bd22:	efe50513          	addi	a0,a0,-258 # 104c1c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f7bc> ; DATA 'ProxyClient'
   2bd26:	c476                	sw	t4,8(sp)
   2bd28:	c602                	sw	zero,12(sp)
   2bd2a:	c04e                	sw	s3,0(sp)
   2bd2c:	01712223          	sw	s7,4(sp)
   2bd30:	ffff6097          	auipc	ra,0xffff6
   2bd34:	fd0080e7          	jalr	-48(ra) # 21d00 <MLOGD@plt>
   2bd38:	5742                	lw	a4,48(sp)
   2bd3a:	001d8793          	addi	a5,s11,1
   2bd3e:	01b7b6b3          	sltu	a3,a5,s11
   2bd42:	e9b71fe3          	bne	a4,s11,2bbe0 <_HandleProxyEventConnectionClose@@Base+0x133c>
   2bd46:	5772                	lw	a4,60(sp)
   2bd48:	5612                	lw	a2,36(sp)
   2bd4a:	e8c71be3          	bne	a4,a2,2bbe0 <_HandleProxyEventConnectionClose@@Base+0x133c>
   2bd4e:	2364a823          	sw	s6,560(s1)
   2bd52:	2384aa23          	sw	s8,564(s1)
   2bd56:	2344ac23          	sw	s4,568(s1)
   2bd5a:	2334ae23          	sw	s3,572(s1)
   2bd5e:	b549                	j	2bbe0 <_HandleProxyEventConnectionClose@@Base+0x133c>
