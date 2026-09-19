
firmwares/hw501/126/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0004b0e0 <iap2_dev_recv_data@@Base>:
   4b0e0:	515c                	lw	a5,36(a0)
   4b0e2:	7131                	addi	sp,sp,-192
   4b0e4:	db26                	sw	s1,180(sp)
   4b0e6:	4784                	lw	s1,8(a5)
   4b0e8:	d94a                	sw	s2,176(sp)
   4b0ea:	df06                	sw	ra,188(sp)
   4b0ec:	dd22                	sw	s0,184(sp)
   4b0ee:	d74e                	sw	s3,172(sp)
   4b0f0:	d552                	sw	s4,168(sp)
   4b0f2:	d356                	sw	s5,164(sp)
   4b0f4:	d15a                	sw	s6,160(sp)
   4b0f6:	cf5e                	sw	s7,156(sp)
   4b0f8:	0744c783          	lbu	a5,116(s1)
   4b0fc:	72fd                	lui	t0,0xfffff
   4b0fe:	9116                	add	sp,sp,t0
   4b100:	00068913          	mv	s2,a3
   4b104:	04d78a63          	beq	a5,a3,4b158 <iap2_dev_recv_data@@Base+0x78>
   4b108:	0754c783          	lbu	a5,117(s1)
   4b10c:	02d78263          	beq	a5,a3,4b130 <iap2_dev_recv_data@@Base+0x50>
   4b110:	00100513          	li	a0,1
   4b114:	6285                	lui	t0,0x1
   4b116:	9116                	add	sp,sp,t0
   4b118:	50fa                	lw	ra,188(sp)
   4b11a:	546a                	lw	s0,184(sp)
   4b11c:	54da                	lw	s1,180(sp)
   4b11e:	594a                	lw	s2,176(sp)
   4b120:	59ba                	lw	s3,172(sp)
   4b122:	5a2a                	lw	s4,168(sp)
   4b124:	5a9a                	lw	s5,164(sp)
   4b126:	5b0a                	lw	s6,160(sp)
   4b128:	4bfa                	lw	s7,156(sp)
   4b12a:	6129                	addi	sp,sp,192
   4b12c:	00008067          	ret
   4b130:	0020e797          	auipc	a5,0x20e
   4b134:	9187a783          	lw	a5,-1768(a5) # 258a48 <gOverCarplayLink@@Base-0xf48> ; DATA ELF relocation: gOverCarplayLink
   4b138:	4388                	lw	a0,0(a5)
   4b13a:	d979                	beqz	a0,4b110 <iap2_dev_recv_data@@Base+0x30>
   4b13c:	0020d797          	auipc	a5,0x20d
   4b140:	eb47a783          	lw	a5,-332(a5) # 257ff0 <gOverCarPlayBufferSession@@Base-0x199c> ; DATA ELF relocation: gOverCarPlayBufferSession
   4b144:	0007c683          	lbu	a3,0(a5)
   4b148:	4701                	li	a4,0
   4b14a:	4781                	li	a5,0
   4b14c:	fffec097          	auipc	ra,0xfffec
   4b150:	4d4080e7          	jalr	1236(ra) # 37620 <iAP2LinkQueueSendData@plt>
   4b154:	fbdff06f          	j	4b110 <iap2_dev_recv_data@@Base+0x30>
   4b158:	0045d403          	lhu	s0,4(a1)
   4b15c:	0005c783          	lbu	a5,0(a1)
   4b160:	3c84275b          	.insn	4, 0x3c84275b
   4b164:	20f4245b          	.insn	4, 0x20f4245b
   4b168:	8aaa                	mv	s5,a0
   4b16a:	89ae                	mv	s3,a1
   4b16c:	8a32                	mv	s4,a2
   4b16e:	8c59                	or	s0,s0,a4
   4b170:	4607d85b          	.insn	4, 0x4607d85b
   4b174:	0b44d783          	lhu	a5,180(s1)
   4b178:	cbd1                	beqz	a5,4b20c <iap2_dev_recv_data@@Base+0x12c>
   4b17a:	0b64d703          	lhu	a4,182(s1)
   4b17e:	014786b3          	add	a3,a5,s4
   4b182:	f8d767e3          	bltu	a4,a3,4b110 <iap2_dev_recv_data@@Base+0x30>
   4b186:	0b04a503          	lw	a0,176(s1)
   4b18a:	8652                	mv	a2,s4
   4b18c:	85ce                	mv	a1,s3
   4b18e:	953e                	add	a0,a0,a5
   4b190:	fffec097          	auipc	ra,0xfffec
   4b194:	8d0080e7          	jalr	-1840(ra) # 36a60 <memcpy@plt>
   4b198:	0b44d703          	lhu	a4,180(s1)
   4b19c:	0b64d783          	lhu	a5,182(s1)
   4b1a0:	9752                	add	a4,a4,s4
   4b1a2:	0b84d603          	lhu	a2,184(s1)
   4b1a6:	3c07275b          	.insn	4, 0x3c07275b
   4b1aa:	86d2                	mv	a3,s4
   4b1ac:	0018d597          	auipc	a1,0x18d
   4b1b0:	81c58593          	addi	a1,a1,-2020 # 1d79c8 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0e04> ; DATA 'recv buffer msg id = %04x datalen=%d recvlen:%d msglen=%d\n'
   4b1b4:	0018c517          	auipc	a0,0x18c
   4b1b8:	fac50513          	addi	a0,a0,-84 # 1d7160 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa059c> ; DATA 'ProxyIAP2'
   4b1bc:	0ae49a23          	sh	a4,180(s1)
   4b1c0:	fffed097          	auipc	ra,0xfffed
   4b1c4:	310080e7          	jalr	784(ra) # 384d0 <MLOGD@plt>
   4b1c8:	0b64d783          	lhu	a5,182(s1)
   4b1cc:	0b44da03          	lhu	s4,180(s1)
   4b1d0:	f4fa10e3          	bne	s4,a5,4b110 <iap2_dev_recv_data@@Base+0x30>
   4b1d4:	0b04a983          	lw	s3,176(s1)
   4b1d8:	0b84d403          	lhu	s0,184(s1)
   4b1dc:	0280006f          	j	4b204 <iap2_dev_recv_data@@Base+0x124>
   4b1e0:	0015c783          	lbu	a5,1(a1)
   4b1e4:	f807e85b          	.insn	4, 0xf807e85b
   4b1e8:	00500793          	li	a5,5
   4b1ec:	f8c7f4e3          	bgeu	a5,a2,4b174 <iap2_dev_recv_data@@Base+0x94>
   4b1f0:	0025d783          	lhu	a5,2(a1)
   4b1f4:	3c87ab5b          	.insn	4, 0x3c87ab5b
   4b1f8:	20f7a7db          	.insn	4, 0x20f7a7db
   4b1fc:	0167eb33          	or	s6,a5,s6
   4b200:	7f666663          	bltu	a2,s6,4b9ec <iap2_dev_recv_data@@Base+0x90c>
   4b204:	0a04aa23          	sw	zero,180(s1)
   4b208:	0a049c23          	sh	zero,184(s1)
   4b20c:	67c1                	lui	a5,0x10
   4b20e:	17ed                	addi	a5,a5,-5 # fffb <HTimerEx::stop()@plt-0x26065>
   4b210:	0ef41263          	bne	s0,a5,4b2f4 <iap2_dev_recv_data@@Base+0x214>
   4b214:	8652                	mv	a2,s4
   4b216:	85ce                	mv	a1,s3
   4b218:	00040513          	mv	a0,s0
   4b21c:	df4fe0ef          	jal	49810 <_HandleProxyEventConnectionClose@@Base+0x3fa0>
   4b220:	7b7d                	lui	s6,0xfffff
   4b222:	f26b0793          	addi	a5,s6,-218 # ffffef26 <AOAProxy::sReaderBuffer@@Base+0xffd9bbb6>
   4b226:	97a2                	add	a5,a5,s0
   4b228:	3c07a7db          	.insn	4, 0x3c07a7db
   4b22c:	470d                	li	a4,3
   4b22e:	14f77b63          	bgeu	a4,a5,4b384 <iap2_dev_recv_data@@Base+0x2a4>
   4b232:	77ed                	lui	a5,0xffffb
   4b234:	40078793          	addi	a5,a5,1024 # ffffb400 <AOAProxy::sReaderBuffer@@Base+0xffd98090>
   4b238:	97a2                	add	a5,a5,s0
   4b23a:	3c07a7db          	.insn	4, 0x3c07a7db
   4b23e:	46a5                	li	a3,9
   4b240:	2cf6ec63          	bltu	a3,a5,4b518 <iap2_dev_recv_data@@Base+0x438>
   4b244:	0020e497          	auipc	s1,0x20e
   4b248:	8044a483          	lw	s1,-2044(s1) # 258a48 <gOverCarplayLink@@Base-0xf48> ; DATA ELF relocation: gOverCarplayLink
   4b24c:	409c                	lw	a5,0(s1)
   4b24e:	2a078763          	beqz	a5,4b4fc <iap2_dev_recv_data@@Base+0x41c>
   4b252:	6b85                	lui	s7,0x1
   4b254:	080b8613          	addi	a2,s7,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b258:	965a                	add	a2,a2,s6
   4b25a:	080c                	addi	a1,sp,16
   4b25c:	00b60433          	add	s0,a2,a1
   4b260:	00440513          	addi	a0,s0,4
   4b264:	7fc00613          	li	a2,2044
   4b268:	00000593          	li	a1,0
   4b26c:	00042023          	sw	zero,0(s0)
   4b270:	fffec097          	auipc	ra,0xfffec
   4b274:	770080e7          	jalr	1904(ra) # 379e0 <memset@plt>
   4b278:	fc0b0693          	addi	a3,s6,-64
   4b27c:	080b8593          	addi	a1,s7,128
   4b280:	95b6                	add	a1,a1,a3
   4b282:	0814                	addi	a3,sp,16
   4b284:	0020d797          	auipc	a5,0x20d
   4b288:	4a07a783          	lw	a5,1184(a5) # 258724 <gMediaUniqueId@@Base-0x11d4> ; DATA ELF relocation: gMediaUniqueId
   4b28c:	fa8b0613          	addi	a2,s6,-88
   4b290:	96ae                	add	a3,a3,a1
   4b292:	080b8593          	addi	a1,s7,128
   4b296:	0007a803          	lw	a6,0(a5)
   4b29a:	95b2                	add	a1,a1,a2
   4b29c:	4f9c                	lw	a5,24(a5)
   4b29e:	0018c897          	auipc	a7,0x18c
   4b2a2:	55e88893          	addi	a7,a7,1374 # 1d77fc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0c38> ; DATA 'E9746442-B1A7-4E38-95CE-D1274F5E4A1A-MPB-14.4'
   4b2a6:	0810                	addi	a2,sp,16
   4b2a8:	962e                	add	a2,a2,a1
   4b2aa:	fb142423          	sw	a7,-88(s0)
   4b2ae:	8722                	mv	a4,s0
   4b2b0:	0018c897          	auipc	a7,0x18c
   4b2b4:	57c88893          	addi	a7,a7,1404 # 1d782c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0c68> ; DATA 'E9746442-B1A7-4E38-95CE-D1274F5E4A1A-4954524C-14.4'
   4b2b8:	85d2                	mv	a1,s4
   4b2ba:	854e                	mv	a0,s3
   4b2bc:	fb142623          	sw	a7,-84(s0)
   4b2c0:	fd042023          	sw	a6,-64(s0)
   4b2c4:	fcf42223          	sw	a5,-60(s0)
   4b2c8:	2d0200ef          	jal	6b598 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x1ebc>
   4b2cc:	862a                	mv	a2,a0
   4b2ce:	4505                	li	a0,1
   4b2d0:	e40602e3          	beqz	a2,4b114 <iap2_dev_recv_data@@Base+0x34>
   4b2d4:	0020d797          	auipc	a5,0x20d
   4b2d8:	5787a783          	lw	a5,1400(a5) # 25884c <gOverCarPlayCtrlSession@@Base-0x1141> ; DATA ELF relocation: gOverCarPlayCtrlSession
   4b2dc:	0007c683          	lbu	a3,0(a5)
   4b2e0:	4088                	lw	a0,0(s1)
   4b2e2:	4781                	li	a5,0
   4b2e4:	4701                	li	a4,0
   4b2e6:	85a2                	mv	a1,s0
   4b2e8:	fffec097          	auipc	ra,0xfffec
   4b2ec:	338080e7          	jalr	824(ra) # 37620 <iAP2LinkQueueSendData@plt>
   4b2f0:	e25ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4b2f4:	874a                	mv	a4,s2
   4b2f6:	86d2                	mv	a3,s4
   4b2f8:	00040613          	mv	a2,s0
   4b2fc:	0018c597          	auipc	a1,0x18c
   4b300:	70858593          	addi	a1,a1,1800 # 1d7a04 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0e40> ; DATA 'recv msg id = %04x datalen=%d session=%d\n'
   4b304:	0018c517          	auipc	a0,0x18c
   4b308:	e5c50513          	addi	a0,a0,-420 # 1d7160 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa059c> ; DATA 'ProxyIAP2'
   4b30c:	fffed097          	auipc	ra,0xfffed
   4b310:	1c4080e7          	jalr	452(ra) # 384d0 <MLOGD@plt>
   4b314:	8652                	mv	a2,s4
   4b316:	85ce                	mv	a1,s3
   4b318:	00040513          	mv	a0,s0
   4b31c:	cf4fe0ef          	jal	49810 <_HandleProxyEventConnectionClose@@Base+0x3fa0>
   4b320:	7771                	lui	a4,0xffffc
   4b322:	eac70793          	addi	a5,a4,-340 # ffffbeac <AOAProxy::sReaderBuffer@@Base+0xffd98b3c>
   4b326:	97a2                	add	a5,a5,s0
   4b328:	3c07a7db          	.insn	4, 0x3c07a7db
   4b32c:	46c1                	li	a3,16
   4b32e:	04f6e363          	bltu	a3,a5,4b374 <iap2_dev_recv_data@@Base+0x294>
   4b332:	0020d797          	auipc	a5,0x20d
   4b336:	7167a783          	lw	a5,1814(a5) # 258a48 <gOverCarplayLink@@Base-0xf48> ; DATA ELF relocation: gOverCarplayLink
   4b33a:	4388                	lw	a0,0(a5)
   4b33c:	04050c63          	beqz	a0,4b394 <iap2_dev_recv_data@@Base+0x2b4>
   4b340:	0020d797          	auipc	a5,0x20d
   4b344:	50c7a783          	lw	a5,1292(a5) # 25884c <gOverCarPlayCtrlSession@@Base-0x1141> ; DATA ELF relocation: gOverCarPlayCtrlSession
   4b348:	0007c683          	lbu	a3,0(a5)
   4b34c:	6285                	lui	t0,0x1
   4b34e:	9116                	add	sp,sp,t0
   4b350:	50fa                	lw	ra,188(sp)
   4b352:	546a                	lw	s0,184(sp)
   4b354:	54da                	lw	s1,180(sp)
   4b356:	594a                	lw	s2,176(sp)
   4b358:	5a9a                	lw	s5,164(sp)
   4b35a:	5b0a                	lw	s6,160(sp)
   4b35c:	4bfa                	lw	s7,156(sp)
   4b35e:	8652                	mv	a2,s4
   4b360:	85ce                	mv	a1,s3
   4b362:	5a2a                	lw	s4,168(sp)
   4b364:	59ba                	lw	s3,172(sp)
   4b366:	4781                	li	a5,0
   4b368:	4701                	li	a4,0
   4b36a:	6129                	addi	sp,sp,192
   4b36c:	fffec317          	auipc	t1,0xfffec
   4b370:	2b430067          	jr	692(t1) # 37620 <iAP2LinkQueueSendData@plt>
   4b374:	e9070793          	addi	a5,a4,-368
   4b378:	97a2                	add	a5,a5,s0
   4b37a:	3c07a7db          	.insn	4, 0x3c07a7db
   4b37e:	4709                	li	a4,2
   4b380:	eaf760e3          	bltu	a4,a5,4b220 <iap2_dev_recv_data@@Base+0x140>
   4b384:	0020d797          	auipc	a5,0x20d
   4b388:	6c47a783          	lw	a5,1732(a5) # 258a48 <gOverCarplayLink@@Base-0xf48> ; DATA ELF relocation: gOverCarplayLink
   4b38c:	4388                	lw	a0,0(a5)
   4b38e:	f94d                	bnez	a0,4b340 <iap2_dev_recv_data@@Base+0x260>
   4b390:	d81ff06f          	j	4b110 <iap2_dev_recv_data@@Base+0x30>
   4b394:	6791                	lui	a5,0x4
   4b396:	15478713          	addi	a4,a5,340 # 4154 <HTimerEx::stop()@plt-0x31f0c>
   4b39a:	72e40563          	beq	s0,a4,4bac4 <iap2_dev_recv_data@@Base+0x9e4>
   4b39e:	15778793          	addi	a5,a5,343
   4b3a2:	00f41b63          	bne	s0,a5,4b3b8 <iap2_dev_recv_data@@Base+0x2d8>
   4b3a6:	85ca                	mv	a1,s2
   4b3a8:	000a8513          	mv	a0,s5
   4b3ac:	2501f0ef          	jal	6a5fc <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0xf20>
   4b3b0:	00100513          	li	a0,1
   4b3b4:	d61ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4b3b8:	6789                	lui	a5,0x2
   4b3ba:	d0178793          	addi	a5,a5,-767 # 1d01 <HTimerEx::stop()@plt-0x3435f>
   4b3be:	d4f419e3          	bne	s0,a5,4b110 <iap2_dev_recv_data@@Base+0x30>
   4b3c2:	50e8                	lw	a0,100(s1)
   4b3c4:	00050a63          	beqz	a0,4b3d8 <iap2_dev_recv_data@@Base+0x2f8>
   4b3c8:	fffec097          	auipc	ra,0xfffec
   4b3cc:	0e8080e7          	jalr	232(ra) # 374b0 <free@plt>
   4b3d0:	0604a223          	sw	zero,100(s1)
   4b3d4:	0604a423          	sw	zero,104(s1)
   4b3d8:	54e8                	lw	a0,108(s1)
   4b3da:	c909                	beqz	a0,4b3ec <iap2_dev_recv_data@@Base+0x30c>
   4b3dc:	fffec097          	auipc	ra,0xfffec
   4b3e0:	0d4080e7          	jalr	212(ra) # 374b0 <free@plt>
   4b3e4:	0604a623          	sw	zero,108(s1)
   4b3e8:	0604a823          	sw	zero,112(s1)
   4b3ec:	0bc4a503          	lw	a0,188(s1)
   4b3f0:	00050863          	beqz	a0,4b400 <iap2_dev_recv_data@@Base+0x320>
   4b3f4:	fffec097          	auipc	ra,0xfffec
   4b3f8:	0bc080e7          	jalr	188(ra) # 374b0 <free@plt>
   4b3fc:	0a04ae23          	sw	zero,188(s1)
   4b400:	0804a503          	lw	a0,128(s1)
   4b404:	00050863          	beqz	a0,4b414 <iap2_dev_recv_data@@Base+0x334>
   4b408:	fffec097          	auipc	ra,0xfffec
   4b40c:	0a8080e7          	jalr	168(ra) # 374b0 <free@plt>
   4b410:	0804a023          	sw	zero,128(s1)
   4b414:	08448313          	addi	t1,s1,132
   4b418:	0bc48593          	addi	a1,s1,188
   4b41c:	08048893          	addi	a7,s1,128
   4b420:	07e48813          	addi	a6,s1,126
   4b424:	07048793          	addi	a5,s1,112
   4b428:	06c48713          	addi	a4,s1,108
   4b42c:	06848693          	addi	a3,s1,104
   4b430:	06448613          	addi	a2,s1,100
   4b434:	854e                	mv	a0,s3
   4b436:	c01a                	sw	t1,0(sp)
   4b438:	181200ef          	jal	6bdb8 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x26dc>
   4b43c:	0804a583          	lw	a1,128(s1)
   4b440:	0a058ae3          	beqz	a1,4bcf4 <iap2_dev_recv_data@@Base+0xc14>
   4b444:	6605                	lui	a2,0x1
   4b446:	747d                	lui	s0,0xfffff
   4b448:	08060693          	addi	a3,a2,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b44c:	96a2                	add	a3,a3,s0
   4b44e:	0810                	addi	a2,sp,16
   4b450:	00c68433          	add	s0,a3,a2
   4b454:	0844d603          	lhu	a2,132(s1)
   4b458:	00040513          	mv	a0,s0
   4b45c:	fffed097          	auipc	ra,0xfffed
   4b460:	184080e7          	jalr	388(ra) # 385e0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   4b464:	0844d683          	lhu	a3,132(s1)
   4b468:	00042603          	lw	a2,0(s0) # fffff000 <AOAProxy::sReaderBuffer@@Base+0xffd9bc90>
   4b46c:	0018c597          	auipc	a1,0x18c
   4b470:	62858593          	addi	a1,a1,1576 # 1d7a94 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0ed0> ; DATA 'recv loc info:%s len:%d\n'
   4b474:	0018c517          	auipc	a0,0x18c
   4b478:	cec50513          	addi	a0,a0,-788 # 1d7160 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa059c> ; DATA 'ProxyIAP2'
   4b47c:	fffed097          	auipc	ra,0xfffed
   4b480:	054080e7          	jalr	84(ra) # 384d0 <MLOGD@plt>
   4b484:	6585                	lui	a1,0x1
   4b486:	77fd                	lui	a5,0xfffff
   4b488:	08058613          	addi	a2,a1,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b48c:	963e                	add	a2,a2,a5
   4b48e:	080c                	addi	a1,sp,16
   4b490:	00b607b3          	add	a5,a2,a1
   4b494:	4388                	lw	a0,0(a5)
   4b496:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffd9bc98>
   4b498:	00f50663          	beq	a0,a5,4b4a4 <iap2_dev_recv_data@@Base+0x3c4>
   4b49c:	fffec097          	auipc	ra,0xfffec
   4b4a0:	144080e7          	jalr	324(ra) # 375e0 <operator delete(void*)@plt>
   4b4a4:	0804a783          	lw	a5,128(s1)
   4b4a8:	cb91                	beqz	a5,4b4bc <iap2_dev_recv_data@@Base+0x3dc>
   4b4aa:	faf00713          	li	a4,-81
   4b4ae:	00e78223          	sb	a4,4(a5)
   4b4b2:	0804a783          	lw	a5,128(s1)
   4b4b6:	5769                	li	a4,-6
   4b4b8:	00e782a3          	sb	a4,5(a5)
   4b4bc:	0c44a783          	lw	a5,196(s1)
   4b4c0:	c791                	beqz	a5,4b4cc <iap2_dev_recv_data@@Base+0x3ec>
   4b4c2:	0c84a503          	lw	a0,200(s1)
   4b4c6:	45a1                	li	a1,8
   4b4c8:	000780e7          	jalr	a5
   4b4cc:	85ca                	mv	a1,s2
   4b4ce:	8556                	mv	a0,s5
   4b4d0:	5341e0ef          	jal	69a04 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x328>
   4b4d4:	0764c783          	lbu	a5,118(s1)
   4b4d8:	0027e45b          	.insn	4, 0x0027e45b
   4b4dc:	7fc0006f          	j	4bcd8 <iap2_dev_recv_data@@Base+0xbf8>
   4b4e0:	58b4                	lw	a3,112(s1)
   4b4e2:	54f0                	lw	a2,108(s1)
   4b4e4:	85ca                	mv	a1,s2
   4b4e6:	8556                	mv	a0,s5
   4b4e8:	728210ef          	jal	6cc10 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x3534>
   4b4ec:	0bc4a503          	lw	a0,188(s1)
   4b4f0:	b61fe0ef          	jal	4a050 <_HandleProxyEventConnectionClose@@Base+0x47e0>
   4b4f4:	00100513          	li	a0,1
   4b4f8:	c1dff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4b4fc:	6795                	lui	a5,0x5
   4b4fe:	c0078793          	addi	a5,a5,-1024 # 4c00 <HTimerEx::stop()@plt-0x31460>
   4b502:	c0f417e3          	bne	s0,a5,4b110 <iap2_dev_recv_data@@Base+0x30>
   4b506:	85ca                	mv	a1,s2
   4b508:	000a8513          	mv	a0,s5
   4b50c:	5191f0ef          	jal	6b224 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x1b48>
   4b510:	00100513          	li	a0,1
   4b514:	c01ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4b518:	77ed                	lui	a5,0xffffb
   4b51a:	97a2                	add	a5,a5,s0
   4b51c:	3c07a7db          	.insn	4, 0x3c07a7db
   4b520:	04f76e63          	bltu	a4,a5,4b57c <iap2_dev_recv_data@@Base+0x49c>
   4b524:	0020d797          	auipc	a5,0x20d
   4b528:	5247a783          	lw	a5,1316(a5) # 258a48 <gOverCarplayLink@@Base-0xf48> ; DATA ELF relocation: gOverCarplayLink
   4b52c:	0007a503          	lw	a0,0(a5)
   4b530:	e00518e3          	bnez	a0,4b340 <iap2_dev_recv_data@@Base+0x260>
   4b534:	6795                	lui	a5,0x5
   4b536:	fcf413e3          	bne	s0,a5,4b4fc <iap2_dev_recv_data@@Base+0x41c>
   4b53a:	6585                	lui	a1,0x1
   4b53c:	747d                	lui	s0,0xfffff
   4b53e:	08058613          	addi	a2,a1,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b542:	9622                	add	a2,a2,s0
   4b544:	080c                	addi	a1,sp,16
   4b546:	00b60433          	add	s0,a2,a1
   4b54a:	8522                	mv	a0,s0
   4b54c:	06000613          	li	a2,96
   4b550:	00000593          	li	a1,0
   4b554:	fffec097          	auipc	ra,0xfffec
   4b558:	48c080e7          	jalr	1164(ra) # 379e0 <memset@plt>
   4b55c:	8622                	mv	a2,s0
   4b55e:	85d2                	mv	a1,s4
   4b560:	00098513          	mv	a0,s3
   4b564:	2301f0ef          	jal	6a794 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x10b8>
   4b568:	8622                	mv	a2,s0
   4b56a:	85ca                	mv	a1,s2
   4b56c:	000a8513          	mv	a0,s5
   4b570:	52c1f0ef          	jal	6aa9c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x13c0>
   4b574:	00100513          	li	a0,1
   4b578:	b9dff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4b57c:	6bc1                	lui	s7,0x10
   4b57e:	ffbb8793          	addi	a5,s7,-5 # fffb <HTimerEx::stop()@plt-0x26065>
   4b582:	68f40d63          	beq	s0,a5,4bc1c <iap2_dev_recv_data@@Base+0xb3c>
   4b586:	ff0b8793          	addi	a5,s7,-16
   4b58a:	68f40963          	beq	s0,a5,4bc1c <iap2_dev_recv_data@@Base+0xb3c>
   4b58e:	6795                	lui	a5,0x5
   4b590:	70378713          	addi	a4,a5,1795 # 5703 <HTimerEx::stop()@plt-0x3095d>
   4b594:	4ae40863          	beq	s0,a4,4ba44 <iap2_dev_recv_data@@Base+0x964>
   4b598:	42877463          	bgeu	a4,s0,4b9c0 <iap2_dev_recv_data@@Base+0x8e0>
   4b59c:	67ad                	lui	a5,0xb
   4b59e:	a0378713          	addi	a4,a5,-1533 # aa03 <HTimerEx::stop()@plt-0x2b65d>
   4b5a2:	4ae40963          	beq	s0,a4,4ba54 <iap2_dev_recv_data@@Base+0x974>
   4b5a6:	02877f63          	bgeu	a4,s0,4b5e4 <iap2_dev_recv_data@@Base+0x504>
   4b5aa:	e0078793          	addi	a5,a5,-512
   4b5ae:	4ef40363          	beq	s0,a5,4ba94 <iap2_dev_recv_data@@Base+0x9b4>
   4b5b2:	67ad                	lui	a5,0xb
   4b5b4:	e0378713          	addi	a4,a5,-509 # ae03 <HTimerEx::stop()@plt-0x2b25d>
   4b5b8:	08e41263          	bne	s0,a4,4b63c <iap2_dev_recv_data@@Base+0x55c>
   4b5bc:	0a848783          	lb	a5,168(s1)
   4b5c0:	b40798e3          	bnez	a5,4b110 <iap2_dev_recv_data@@Base+0x30>
   4b5c4:	0a44a683          	lw	a3,164(s1)
   4b5c8:	0a04a603          	lw	a2,160(s1)
   4b5cc:	4785                	li	a5,1
   4b5ce:	85ca                	mv	a1,s2
   4b5d0:	000a8513          	mv	a0,s5
   4b5d4:	0af48423          	sb	a5,168(s1)
   4b5d8:	4a01e0ef          	jal	69a78 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x39c>
   4b5dc:	00100513          	li	a0,1
   4b5e0:	b35ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4b5e4:	679d                	lui	a5,0x7
   4b5e6:	80278793          	addi	a5,a5,-2046 # 6802 <HTimerEx::stop()@plt-0x2f85e>
   4b5ea:	5af40b63          	beq	s0,a5,4bba0 <iap2_dev_recv_data@@Base+0xac0>
   4b5ee:	67ad                	lui	a5,0xb
   4b5f0:	a0178793          	addi	a5,a5,-1535 # aa01 <HTimerEx::stop()@plt-0x2b65f>
   4b5f4:	0ef41063          	bne	s0,a5,4b6d4 <iap2_dev_recv_data@@Base+0x5f4>
   4b5f8:	0029d783          	lhu	a5,2(s3)
   4b5fc:	0018c597          	auipc	a1,0x18c
   4b600:	44c58593          	addi	a1,a1,1100 # 1d7a48 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0e84> ; DATA 'recv authentication certificate len:%d'
   4b604:	00879613          	slli	a2,a5,0x8
   4b608:	3c87a7db          	.insn	4, 0x3c87a7db
   4b60c:	8e5d                	or	a2,a2,a5
   4b60e:	1659                	addi	a2,a2,-10
   4b610:	3c06265b          	.insn	4, 0x3c06265b
   4b614:	0018c517          	auipc	a0,0x18c
   4b618:	b4c50513          	addi	a0,a0,-1204 # 1d7160 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa059c> ; DATA 'ProxyIAP2'
   4b61c:	00c12e23          	sw	a2,28(sp)
   4b620:	fffed097          	auipc	ra,0xfffed
   4b624:	eb0080e7          	jalr	-336(ra) # 384d0 <MLOGD@plt>
   4b628:	4672                	lw	a2,28(sp)
   4b62a:	85ca                	mv	a1,s2
   4b62c:	000a8513          	mv	a0,s5
   4b630:	1c41e0ef          	jal	697f4 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x118>
   4b634:	00100513          	li	a0,1
   4b638:	addff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4b63c:	a0678793          	addi	a5,a5,-1530
   4b640:	acf418e3          	bne	s0,a5,4b110 <iap2_dev_recv_data@@Base+0x30>
   4b644:	6685                	lui	a3,0x1
   4b646:	747d                	lui	s0,0xfffff
   4b648:	08068613          	addi	a2,a3,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b64c:	9622                	add	a2,a2,s0
   4b64e:	0818                	addi	a4,sp,16
   4b650:	fc040593          	addi	a1,s0,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffd9bc50>
   4b654:	00e60433          	add	s0,a2,a4
   4b658:	08068613          	addi	a2,a3,128
   4b65c:	962e                	add	a2,a2,a1
   4b65e:	00e605b3          	add	a1,a2,a4
   4b662:	854e                	mv	a0,s3
   4b664:	fc041023          	sh	zero,-64(s0)
   4b668:	3b4210ef          	jal	6ca1c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x3340>
   4b66c:	6a050863          	beqz	a0,4bd1c <iap2_dev_recv_data@@Base+0xc3c>
   4b670:	fc045603          	lhu	a2,-64(s0)
   4b674:	85aa                	mv	a1,a0
   4b676:	8522                	mv	a0,s0
   4b678:	fffed097          	auipc	ra,0xfffed
   4b67c:	f68080e7          	jalr	-152(ra) # 385e0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   4b680:	fc045683          	lhu	a3,-64(s0)
   4b684:	00042603          	lw	a2,0(s0)
   4b688:	0018c597          	auipc	a1,0x18c
   4b68c:	3e858593          	addi	a1,a1,1000 # 1d7a70 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0eac> ; DATA 'recv mfi serial number:%s len:%d\n'
   4b690:	0018c517          	auipc	a0,0x18c
   4b694:	ad050513          	addi	a0,a0,-1328 # 1d7160 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa059c> ; DATA 'ProxyIAP2'
   4b698:	fffed097          	auipc	ra,0xfffed
   4b69c:	e38080e7          	jalr	-456(ra) # 384d0 <MLOGD@plt>
   4b6a0:	6585                	lui	a1,0x1
   4b6a2:	77fd                	lui	a5,0xfffff
   4b6a4:	08058593          	addi	a1,a1,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b6a8:	95be                	add	a1,a1,a5
   4b6aa:	0814                	addi	a3,sp,16
   4b6ac:	00d587b3          	add	a5,a1,a3
   4b6b0:	4388                	lw	a0,0(a5)
   4b6b2:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffd9bc98>
   4b6b4:	00f50663          	beq	a0,a5,4b6c0 <iap2_dev_recv_data@@Base+0x5e0>
   4b6b8:	fffec097          	auipc	ra,0xfffec
   4b6bc:	f28080e7          	jalr	-216(ra) # 375e0 <operator delete(void*)@plt>
   4b6c0:	4601                	li	a2,0
   4b6c2:	85ca                	mv	a1,s2
   4b6c4:	000a8513          	mv	a0,s5
   4b6c8:	1cd1f0ef          	jal	6b094 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x19b8>
   4b6cc:	00100513          	li	a0,1
   4b6d0:	a45ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4b6d4:	679d                	lui	a5,0x7
   4b6d6:	80078793          	addi	a5,a5,-2048 # 6800 <HTimerEx::stop()@plt-0x2f860>
   4b6da:	a2f41be3          	bne	s0,a5,4b110 <iap2_dev_recv_data@@Base+0x30>
   4b6de:	6b85                	lui	s7,0x1
   4b6e0:	797d                	lui	s2,0xfffff
   4b6e2:	080b8593          	addi	a1,s7,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b6e6:	95ca                	add	a1,a1,s2
   4b6e8:	0814                	addi	a3,sp,16
   4b6ea:	00d58433          	add	s0,a1,a3
   4b6ee:	6605                	lui	a2,0x1
   4b6f0:	1671                	addi	a2,a2,-4 # ffc <HTimerEx::stop()@plt-0x35064>
   4b6f2:	4581                	li	a1,0
   4b6f4:	00440513          	addi	a0,s0,4
   4b6f8:	fa041023          	sh	zero,-96(s0)
   4b6fc:	fa041123          	sh	zero,-94(s0)
   4b700:	fa041223          	sh	zero,-92(s0)
   4b704:	f8040fa3          	sb	zero,-97(s0)
   4b708:	00042023          	sw	zero,0(s0)
   4b70c:	fffec097          	auipc	ra,0xfffec
   4b710:	2d4080e7          	jalr	724(ra) # 379e0 <memset@plt>
   4b714:	fa690813          	addi	a6,s2,-90 # ffffefa6 <AOAProxy::sReaderBuffer@@Base+0xffd9bc36>
   4b718:	080b8513          	addi	a0,s7,128
   4b71c:	9542                	add	a0,a0,a6
   4b71e:	081c                	addi	a5,sp,16
   4b720:	00f50833          	add	a6,a0,a5
   4b724:	f9f90713          	addi	a4,s2,-97
   4b728:	080b8513          	addi	a0,s7,128
   4b72c:	953a                	add	a0,a0,a4
   4b72e:	0818                	addi	a4,sp,16
   4b730:	972a                	add	a4,a4,a0
   4b732:	fa490693          	addi	a3,s2,-92
   4b736:	080b8513          	addi	a0,s7,128
   4b73a:	9536                	add	a0,a0,a3
   4b73c:	0814                	addi	a3,sp,16
   4b73e:	96aa                	add	a3,a3,a0
   4b740:	fa290613          	addi	a2,s2,-94
   4b744:	080b8513          	addi	a0,s7,128
   4b748:	9532                	add	a0,a0,a2
   4b74a:	0810                	addi	a2,sp,16
   4b74c:	fa090593          	addi	a1,s2,-96
   4b750:	962a                	add	a2,a2,a0
   4b752:	080b8513          	addi	a0,s7,128
   4b756:	952e                	add	a0,a0,a1
   4b758:	080c                	addi	a1,sp,16
   4b75a:	87a2                	mv	a5,s0
   4b75c:	95aa                	add	a1,a1,a0
   4b75e:	854e                	mv	a0,s3
   4b760:	fa041323          	sh	zero,-90(s0)
   4b764:	175200ef          	jal	6c0d8 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x29fc>
   4b768:	fa645903          	lhu	s2,-90(s0)
   4b76c:	85a2                	mv	a1,s0
   4b76e:	864a                	mv	a2,s2
   4b770:	fc040513          	addi	a0,s0,-64
   4b774:	fa045983          	lhu	s3,-96(s0)
   4b778:	fa245a03          	lhu	s4,-94(s0)
   4b77c:	fa445a83          	lhu	s5,-92(s0)
   4b780:	f9f44b03          	lbu	s6,-97(s0)
   4b784:	fffed097          	auipc	ra,0xfffed
   4b788:	e5c080e7          	jalr	-420(ra) # 385e0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   4b78c:	fc042883          	lw	a7,-64(s0)
   4b790:	884a                	mv	a6,s2
   4b792:	87da                	mv	a5,s6
   4b794:	8756                	mv	a4,s5
   4b796:	86d2                	mv	a3,s4
   4b798:	00098613          	mv	a2,s3
   4b79c:	0018c597          	auipc	a1,0x18c
   4b7a0:	34458593          	addi	a1,a1,836 # 1d7ae0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0f1c> ; DATA 'parse hid info, id:%d vid:%d pid:%d countrycode:%d reportlen:%d report:%s\n'
   4b7a4:	0018c517          	auipc	a0,0x18c
   4b7a8:	9bc50513          	addi	a0,a0,-1604 # 1d7160 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa059c> ; DATA 'ProxyIAP2'
   4b7ac:	fffed097          	auipc	ra,0xfffed
   4b7b0:	d24080e7          	jalr	-732(ra) # 384d0 <MLOGD@plt>
   4b7b4:	fc042503          	lw	a0,-64(s0)
   4b7b8:	fc840793          	addi	a5,s0,-56
   4b7bc:	00f50663          	beq	a0,a5,4b7c8 <iap2_dev_recv_data@@Base+0x6e8>
   4b7c0:	fffec097          	auipc	ra,0xfffec
   4b7c4:	e20080e7          	jalr	-480(ra) # 375e0 <operator delete(void*)@plt>
   4b7c8:	747d                	lui	s0,0xfffff
   4b7ca:	6b05                	lui	s6,0x1
   4b7cc:	fc040413          	addi	s0,s0,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffd9bc50>
   4b7d0:	080b0613          	addi	a2,s6,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b7d4:	9622                	add	a2,a2,s0
   4b7d6:	0814                	addi	a3,sp,16
   4b7d8:	00d60433          	add	s0,a2,a3
   4b7dc:	00040513          	mv	a0,s0
   4b7e0:	0018c597          	auipc	a1,0x18c
   4b7e4:	18458593          	addi	a1,a1,388 # 1d7964 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0da0> ; DATA 'hid'
   4b7e8:	fffec097          	auipc	ra,0xfffec
   4b7ec:	5b8080e7          	jalr	1464(ra) # 37da0 <MString::MString(char const*)@plt>
   4b7f0:	00040593          	mv	a1,s0
   4b7f4:	0020d517          	auipc	a0,0x20d
   4b7f8:	48852503          	lw	a0,1160(a0) # 258c7c <gHIDDevicesConfig@@Base-0xcac> ; DATA ELF relocation: gHIDDevicesConfig
   4b7fc:	fffeb097          	auipc	ra,0xfffeb
   4b800:	fe4080e7          	jalr	-28(ra) # 367e0 <MIniConfig::beginGroup(MString const&)@plt>
   4b804:	77fd                	lui	a5,0xfffff
   4b806:	080b0593          	addi	a1,s6,128
   4b80a:	95be                	add	a1,a1,a5
   4b80c:	01010613          	addi	a2,sp,16
   4b810:	00c58733          	add	a4,a1,a2
   4b814:	fc072503          	lw	a0,-64(a4)
   4b818:	fc870793          	addi	a5,a4,-56
   4b81c:	00f50663          	beq	a0,a5,4b828 <iap2_dev_recv_data@@Base+0x748>
   4b820:	fffec097          	auipc	ra,0xfffec
   4b824:	dc0080e7          	jalr	-576(ra) # 375e0 <operator delete(void*)@plt>
   4b828:	747d                	lui	s0,0xfffff
   4b82a:	6b85                	lui	s7,0x1
   4b82c:	fc040913          	addi	s2,s0,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffd9bc50>
   4b830:	080b8593          	addi	a1,s7,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b834:	0814                	addi	a3,sp,16
   4b836:	95ca                	add	a1,a1,s2
   4b838:	00d58933          	add	s2,a1,a3
   4b83c:	00090513          	mv	a0,s2
   4b840:	0018c597          	auipc	a1,0x18c
   4b844:	15058593          	addi	a1,a1,336 # 1d7990 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0dcc> ; DATA 'report'
   4b848:	fffec097          	auipc	ra,0xfffec
   4b84c:	558080e7          	jalr	1368(ra) # 37da0 <MString::MString(char const*)@plt>
   4b850:	080b8613          	addi	a2,s7,128
   4b854:	9622                	add	a2,a2,s0
   4b856:	080c                	addi	a1,sp,16
   4b858:	00b60433          	add	s0,a2,a1
   4b85c:	0018d697          	auipc	a3,0x18d
   4b860:	32068693          	addi	a3,a3,800 # 1d8b7c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1fb8>
   4b864:	00090613          	mv	a2,s2
   4b868:	0020d597          	auipc	a1,0x20d
   4b86c:	4145a583          	lw	a1,1044(a1) # 258c7c <gHIDDevicesConfig@@Base-0xcac> ; DATA ELF relocation: gHIDDevicesConfig
   4b870:	fa840513          	addi	a0,s0,-88
   4b874:	fffeb097          	auipc	ra,0xfffeb
   4b878:	d3c080e7          	jalr	-708(ra) # 365b0 <MIniConfig::value(MString const&, char const*)@plt>
   4b87c:	fc042503          	lw	a0,-64(s0)
   4b880:	fc840793          	addi	a5,s0,-56
   4b884:	00f50663          	beq	a0,a5,4b890 <iap2_dev_recv_data@@Base+0x7b0>
   4b888:	fffec097          	auipc	ra,0xfffec
   4b88c:	d58080e7          	jalr	-680(ra) # 375e0 <operator delete(void*)@plt>
   4b890:	0020d517          	auipc	a0,0x20d
   4b894:	3ec52503          	lw	a0,1004(a0) # 258c7c <gHIDDevicesConfig@@Base-0xcac> ; DATA ELF relocation: gHIDDevicesConfig
   4b898:	fffed097          	auipc	ra,0xfffed
   4b89c:	a98080e7          	jalr	-1384(ra) # 38330 <MIniConfig::endGroup()@plt>
   4b8a0:	0ac4a783          	lw	a5,172(s1)
   4b8a4:	cfa5                	beqz	a5,4b91c <iap2_dev_recv_data@@Base+0x83c>
   4b8a6:	6405                	lui	s0,0x1
   4b8a8:	75fd                	lui	a1,0xfffff
   4b8aa:	08040693          	addi	a3,s0,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b8ae:	0810                	addi	a2,sp,16
   4b8b0:	00b686b3          	add	a3,a3,a1
   4b8b4:	00c685b3          	add	a1,a3,a2
   4b8b8:	fa65d603          	lhu	a2,-90(a1) # ffffefa6 <AOAProxy::sReaderBuffer@@Base+0xffd9bc36>
   4b8bc:	fc058513          	addi	a0,a1,-64
   4b8c0:	fffed097          	auipc	ra,0xfffed
   4b8c4:	d20080e7          	jalr	-736(ra) # 385e0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   4b8c8:	77fd                	lui	a5,0xfffff
   4b8ca:	08040593          	addi	a1,s0,128
   4b8ce:	95be                	add	a1,a1,a5
   4b8d0:	01010693          	addi	a3,sp,16
   4b8d4:	00d587b3          	add	a5,a1,a3
   4b8d8:	fac7a603          	lw	a2,-84(a5) # ffffefac <AOAProxy::sReaderBuffer@@Base+0xffd9bc3c>
   4b8dc:	fc47a703          	lw	a4,-60(a5)
   4b8e0:	fc07a403          	lw	s0,-64(a5)
   4b8e4:	46e60e63          	beq	a2,a4,4bd60 <iap2_dev_recv_data@@Base+0xc80>
   4b8e8:	6685                	lui	a3,0x1
   4b8ea:	77fd                	lui	a5,0xfffff
   4b8ec:	08068693          	addi	a3,a3,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b8f0:	96be                	add	a3,a3,a5
   4b8f2:	0810                	addi	a2,sp,16
   4b8f4:	00c687b3          	add	a5,a3,a2
   4b8f8:	fc878793          	addi	a5,a5,-56 # ffffefc8 <AOAProxy::sReaderBuffer@@Base+0xffd9bc58>
   4b8fc:	00f40863          	beq	s0,a5,4b90c <iap2_dev_recv_data@@Base+0x82c>
   4b900:	00040513          	mv	a0,s0
   4b904:	fffec097          	auipc	ra,0xfffec
   4b908:	cdc080e7          	jalr	-804(ra) # 375e0 <operator delete(void*)@plt>
   4b90c:	0ac4a503          	lw	a0,172(s1)
   4b910:	00050663          	beqz	a0,4b91c <iap2_dev_recv_data@@Base+0x83c>
   4b914:	fffeb097          	auipc	ra,0xfffeb
   4b918:	f6c080e7          	jalr	-148(ra) # 36880 <CFRelease@plt>
   4b91c:	6405                	lui	s0,0x1
   4b91e:	787d                	lui	a6,0xfffff
   4b920:	08040613          	addi	a2,s0,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b924:	9642                	add	a2,a2,a6
   4b926:	080c                	addi	a1,sp,16
   4b928:	00b60833          	add	a6,a2,a1
   4b92c:	fa085503          	lhu	a0,-96(a6) # ffffefa0 <AOAProxy::sReaderBuffer@@Base+0xffd9bc30>
   4b930:	65c1                	lui	a1,0x10
   4b932:	fa685883          	lhu	a7,-90(a6)
   4b936:	f9f84783          	lbu	a5,-97(a6)
   4b93a:	fa485703          	lhu	a4,-92(a6)
   4b93e:	fa285683          	lhu	a3,-94(a6)
   4b942:	faa58593          	addi	a1,a1,-86 # ffaa <HTimerEx::stop()@plt-0x260b6>
   4b946:	95aa                	add	a1,a1,a0
   4b948:	0018c317          	auipc	t1,0x18c
   4b94c:	4fc30313          	addi	t1,t1,1276 # 1d7e44 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1280>
   4b950:	0a04a623          	sw	zero,172(s1)
   4b954:	0018d617          	auipc	a2,0x18d
   4b958:	22860613          	addi	a2,a2,552 # 1d8b7c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1fb8>
   4b95c:	0ac48513          	addi	a0,s1,172
   4b960:	00612023          	sw	t1,0(sp)
   4b964:	fffeb097          	auipc	ra,0xfffeb
   4b968:	14c080e7          	jalr	332(ra) # 36ab0 <AirPlayInfoArrayAddHIDDevice@plt>
   4b96c:	77fd                	lui	a5,0xfffff
   4b96e:	08040693          	addi	a3,s0,128
   4b972:	96be                	add	a3,a3,a5
   4b974:	01010613          	addi	a2,sp,16
   4b978:	00c687b3          	add	a5,a3,a2
   4b97c:	fa67d803          	lhu	a6,-90(a5) # ffffefa6 <AOAProxy::sReaderBuffer@@Base+0xffd9bc36>
   4b980:	f9f7c703          	lbu	a4,-97(a5)
   4b984:	fa47d683          	lhu	a3,-92(a5)
   4b988:	fa27d603          	lhu	a2,-94(a5)
   4b98c:	fa07d583          	lhu	a1,-96(a5)
   4b990:	0bc4a503          	lw	a0,188(s1)
   4b994:	9e0ff0ef          	jal	4ab74 <_HandleProxyEventConnectionClose@@Base+0x5304>
   4b998:	6605                	lui	a2,0x1
   4b99a:	77fd                	lui	a5,0xfffff
   4b99c:	08060593          	addi	a1,a2,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4b9a0:	95be                	add	a1,a1,a5
   4b9a2:	0814                	addi	a3,sp,16
   4b9a4:	00d58733          	add	a4,a1,a3
   4b9a8:	fa872503          	lw	a0,-88(a4)
   4b9ac:	fb070793          	addi	a5,a4,-80
   4b9b0:	f6f50063          	beq	a0,a5,4b110 <iap2_dev_recv_data@@Base+0x30>
   4b9b4:	fffec097          	auipc	ra,0xfffec
   4b9b8:	c2c080e7          	jalr	-980(ra) # 375e0 <operator delete(void*)@plt>
   4b9bc:	f54ff06f          	j	4b110 <iap2_dev_recv_data@@Base+0x30>
   4b9c0:	6711                	lui	a4,0x4
   4b9c2:	30170713          	addi	a4,a4,769 # 4301 <HTimerEx::stop()@plt-0x31d5f>
   4b9c6:	10e40763          	beq	s0,a4,4bad4 <iap2_dev_recv_data@@Base+0x9f4>
   4b9ca:	9c8775e3          	bgeu	a4,s0,4b394 <iap2_dev_recv_data@@Base+0x2b4>
   4b9ce:	e0378793          	addi	a5,a5,-509 # ffffee03 <AOAProxy::sReaderBuffer@@Base+0xffd9ba93>
   4b9d2:	b6f411e3          	bne	s0,a5,4b534 <iap2_dev_recv_data@@Base+0x454>
   4b9d6:	07e4d603          	lhu	a2,126(s1)
   4b9da:	85ca                	mv	a1,s2
   4b9dc:	000a8513          	mv	a0,s5
   4b9e0:	084200ef          	jal	6ba64 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x2388>
   4b9e4:	00100513          	li	a0,1
   4b9e8:	f2cff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4b9ec:	0b04a503          	lw	a0,176(s1)
   4b9f0:	000b0593          	mv	a1,s6
   4b9f4:	fffeb097          	auipc	ra,0xfffeb
   4b9f8:	acc080e7          	jalr	-1332(ra) # 364c0 <realloc@plt>
   4b9fc:	0aa4a823          	sw	a0,176(s1)
   4ba00:	3c050263          	beqz	a0,4bdc4 <iap2_dev_recv_data@@Base+0xce4>
   4ba04:	8652                	mv	a2,s4
   4ba06:	85ce                	mv	a1,s3
   4ba08:	0a849c23          	sh	s0,184(s1)
   4ba0c:	0b649b23          	sh	s6,182(s1)
   4ba10:	fffeb097          	auipc	ra,0xfffeb
   4ba14:	050080e7          	jalr	80(ra) # 36a60 <memcpy@plt>
   4ba18:	875a                	mv	a4,s6
   4ba1a:	86d2                	mv	a3,s4
   4ba1c:	00040613          	mv	a2,s0
   4ba20:	0018c597          	auipc	a1,0x18c
   4ba24:	f7858593          	addi	a1,a1,-136 # 1d7998 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0dd4> ; DATA 'recv buffer msg id = %04x datalen=%d msglen=%d\n'
   4ba28:	0018b517          	auipc	a0,0x18b
   4ba2c:	73850513          	addi	a0,a0,1848 # 1d7160 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa059c> ; DATA 'ProxyIAP2'
   4ba30:	0b449a23          	sh	s4,180(s1)
   4ba34:	fffed097          	auipc	ra,0xfffed
   4ba38:	a9c080e7          	jalr	-1380(ra) # 384d0 <MLOGD@plt>
   4ba3c:	00100513          	li	a0,1
   4ba40:	ed4ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4ba44:	85ca                	mv	a1,s2
   4ba46:	8556                	mv	a0,s5
   4ba48:	5741e0ef          	jal	69fbc <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x8e0>
   4ba4c:	00100513          	li	a0,1
   4ba50:	ec4ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4ba54:	09e4c783          	lbu	a5,158(s1)
   4ba58:	22079663          	bnez	a5,4bc84 <iap2_dev_recv_data@@Base+0xba4>
   4ba5c:	0c44a783          	lw	a5,196(s1)
   4ba60:	c791                	beqz	a5,4ba6c <iap2_dev_recv_data@@Base+0x98c>
   4ba62:	0c84a503          	lw	a0,200(s1)
   4ba66:	45a9                	li	a1,10
   4ba68:	000780e7          	jalr	a5
   4ba6c:	4605                	li	a2,1
   4ba6e:	85ca                	mv	a1,s2
   4ba70:	000a8513          	mv	a0,s5
   4ba74:	6a11d0ef          	jal	69914 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x238>
   4ba78:	0764c783          	lbu	a5,118(s1)
   4ba7c:	3227d05b          	.insn	4, 0x3227d05b
   4ba80:	0744c583          	lbu	a1,116(s1)
   4ba84:	000a8513          	mv	a0,s5
   4ba88:	70d1d0ef          	jal	69994 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x2b8>
   4ba8c:	00100513          	li	a0,1
   4ba90:	e84ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4ba94:	0a04a503          	lw	a0,160(s1)
   4ba98:	00050a63          	beqz	a0,4baac <iap2_dev_recv_data@@Base+0x9cc>
   4ba9c:	fffec097          	auipc	ra,0xfffec
   4baa0:	a14080e7          	jalr	-1516(ra) # 374b0 <free@plt>
   4baa4:	0a04a023          	sw	zero,160(s1)
   4baa8:	0a04a223          	sw	zero,164(s1)
   4baac:	00098513          	mv	a0,s3
   4bab0:	0a448613          	addi	a2,s1,164
   4bab4:	0a048593          	addi	a1,s1,160
   4bab8:	580200ef          	jal	6c038 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x295c>
   4babc:	00100513          	li	a0,1
   4bac0:	e54ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4bac4:	85ca                	mv	a1,s2
   4bac6:	8556                	mv	a0,s5
   4bac8:	0191e0ef          	jal	6a2e0 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0xc04>
   4bacc:	00100513          	li	a0,1
   4bad0:	e44ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4bad4:	6a85                	lui	s5,0x1
   4bad6:	080a8613          	addi	a2,s5,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4bada:	965a                	add	a2,a2,s6
   4badc:	080c                	addi	a1,sp,16
   4bade:	00b60433          	add	s0,a2,a1
   4bae2:	00440513          	addi	a0,s0,4
   4bae6:	07c00613          	li	a2,124
   4baea:	4581                	li	a1,0
   4baec:	fc042023          	sw	zero,-64(s0)
   4baf0:	fc042223          	sw	zero,-60(s0)
   4baf4:	fc042423          	sw	zero,-56(s0)
   4baf8:	fc042623          	sw	zero,-52(s0)
   4bafc:	fc042823          	sw	zero,-48(s0)
   4bb00:	fc042a23          	sw	zero,-44(s0)
   4bb04:	fc042c23          	sw	zero,-40(s0)
   4bb08:	fc042e23          	sw	zero,-36(s0)
   4bb0c:	fe042023          	sw	zero,-32(s0)
   4bb10:	fe042223          	sw	zero,-28(s0)
   4bb14:	fe042423          	sw	zero,-24(s0)
   4bb18:	fe042623          	sw	zero,-20(s0)
   4bb1c:	fe042823          	sw	zero,-16(s0)
   4bb20:	fe042a23          	sw	zero,-12(s0)
   4bb24:	fe042c23          	sw	zero,-8(s0)
   4bb28:	fe042e23          	sw	zero,-4(s0)
   4bb2c:	00042023          	sw	zero,0(s0)
   4bb30:	fffec097          	auipc	ra,0xfffec
   4bb34:	eb0080e7          	jalr	-336(ra) # 379e0 <memset@plt>
   4bb38:	fc0b0493          	addi	s1,s6,-64
   4bb3c:	080a8613          	addi	a2,s5,128
   4bb40:	9626                	add	a2,a2,s1
   4bb42:	0814                	addi	a3,sp,16
   4bb44:	00d604b3          	add	s1,a2,a3
   4bb48:	080a8593          	addi	a1,s5,128
   4bb4c:	fa8b0693          	addi	a3,s6,-88
   4bb50:	95b6                	add	a1,a1,a3
   4bb52:	0810                	addi	a2,sp,16
   4bb54:	00c586b3          	add	a3,a1,a2
   4bb58:	854e                	mv	a0,s3
   4bb5a:	8626                	mv	a2,s1
   4bb5c:	85d2                	mv	a1,s4
   4bb5e:	8722                	mv	a4,s0
   4bb60:	fa042423          	sw	zero,-88(s0)
   4bb64:	71d200ef          	jal	6ca80 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x33a4>
   4bb68:	fa842683          	lw	a3,-88(s0)
   4bb6c:	8626                	mv	a2,s1
   4bb6e:	8722                	mv	a4,s0
   4bb70:	0018c597          	auipc	a1,0x18c
   4bb74:	f4058593          	addi	a1,a1,-192 # 1d7ab0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0eec> ; DATA 'recv carplay start session ip:%s port:%d pi:%s\n'
   4bb78:	0018b517          	auipc	a0,0x18b
   4bb7c:	5e850513          	addi	a0,a0,1512 # 1d7160 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa059c> ; DATA 'ProxyIAP2'
   4bb80:	fffed097          	auipc	ra,0xfffed
   4bb84:	950080e7          	jalr	-1712(ra) # 384d0 <MLOGD@plt>
   4bb88:	fa842603          	lw	a2,-88(s0)
   4bb8c:	d9767263          	bgeu	a2,s7,4b110 <iap2_dev_recv_data@@Base+0x30>
   4bb90:	86a2                	mv	a3,s0
   4bb92:	85a6                	mv	a1,s1
   4bb94:	00200513          	li	a0,2
   4bb98:	d51f50ef          	jal	418e8 <_IAP2LinkStatusChangeCallBack@@Base+0x898>
   4bb9c:	d74ff06f          	j	4b110 <iap2_dev_recv_data@@Base+0x30>
   4bba0:	6b05                	lui	s6,0x1
   4bba2:	74fd                	lui	s1,0xfffff
   4bba4:	080b0593          	addi	a1,s6,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4bba8:	95a6                	add	a1,a1,s1
   4bbaa:	0810                	addi	a2,sp,16
   4bbac:	00c58433          	add	s0,a1,a2
   4bbb0:	6605                	lui	a2,0x1
   4bbb2:	1671                	addi	a2,a2,-4 # ffc <HTimerEx::stop()@plt-0x35064>
   4bbb4:	00000593          	li	a1,0
   4bbb8:	00440513          	addi	a0,s0,4
   4bbbc:	fa041423          	sh	zero,-88(s0)
   4bbc0:	00042023          	sw	zero,0(s0)
   4bbc4:	fffec097          	auipc	ra,0xfffec
   4bbc8:	e1c080e7          	jalr	-484(ra) # 379e0 <memset@plt>
   4bbcc:	fc048693          	addi	a3,s1,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffd9bc50>
   4bbd0:	fa848593          	addi	a1,s1,-88
   4bbd4:	080b0613          	addi	a2,s6,128
   4bbd8:	080b0713          	addi	a4,s6,128
   4bbdc:	972e                	add	a4,a4,a1
   4bbde:	9636                	add	a2,a2,a3
   4bbe0:	080c                	addi	a1,sp,16
   4bbe2:	0814                	addi	a3,sp,16
   4bbe4:	96b2                	add	a3,a3,a2
   4bbe6:	95ba                	add	a1,a1,a4
   4bbe8:	8622                	mv	a2,s0
   4bbea:	854e                	mv	a0,s3
   4bbec:	0020d917          	auipc	s2,0x20d
   4bbf0:	9a092903          	lw	s2,-1632(s2) # 25858c <gProxyDelegate@@Base-0xb9c> ; DATA ELF relocation: gProxyDelegate
   4bbf4:	fc041023          	sh	zero,-64(s0)
   4bbf8:	4b9200ef          	jal	6c8b0 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x31d4>
   4bbfc:	00492783          	lw	a5,4(s2)
   4bc00:	9782                	jalr	a5
   4bc02:	84aa                	mv	s1,a0
   4bc04:	d0050663          	beqz	a0,4b110 <iap2_dev_recv_data@@Base+0x30>
   4bc08:	fc045683          	lhu	a3,-64(s0)
   4bc0c:	12069c63          	bnez	a3,4bd44 <iap2_dev_recv_data@@Base+0xc64>
   4bc10:	00892783          	lw	a5,8(s2)
   4bc14:	8526                	mv	a0,s1
   4bc16:	9782                	jalr	a5
   4bc18:	cf8ff06f          	j	4b110 <iap2_dev_recv_data@@Base+0x30>
   4bc1c:	0020d417          	auipc	s0,0x20d
   4bc20:	e2c42403          	lw	s0,-468(s0) # 258a48 <gOverCarplayLink@@Base-0xf48> ; DATA ELF relocation: gOverCarplayLink
   4bc24:	00042783          	lw	a5,0(s0)
   4bc28:	ce078463          	beqz	a5,4b110 <iap2_dev_recv_data@@Base+0x30>
   4bc2c:	9159948b          	.insn	4, 0x9159948b
   4bc30:	0004c503          	lbu	a0,0(s1)
   4bc34:	0ff00793          	li	a5,255
   4bc38:	02f50063          	beq	a0,a5,4bc58 <iap2_dev_recv_data@@Base+0xb78>
   4bc3c:	0015545b          	.insn	4, 0x0015545b
   4bc40:	cd0ff06f          	j	4b110 <iap2_dev_recv_data@@Base+0x30>
   4bc44:	0020d797          	auipc	a5,0x20d
   4bc48:	c087a783          	lw	a5,-1016(a5) # 25884c <gOverCarPlayCtrlSession@@Base-0x1141> ; DATA ELF relocation: gOverCarPlayCtrlSession
   4bc4c:	0007c683          	lbu	a3,0(a5)
   4bc50:	00042503          	lw	a0,0(s0)
   4bc54:	ef8ff06f          	j	4b34c <iap2_dev_recv_data@@Base+0x26c>
   4bc58:	0018c517          	auipc	a0,0x18c
   4bc5c:	dd850513          	addi	a0,a0,-552 # 1d7a30 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0e6c> ; DATA 'PROXY_ENABLE_GPS_SYNC'
   4bc60:	fffec097          	auipc	ra,0xfffec
   4bc64:	ac0080e7          	jalr	-1344(ra) # 37720 <getenv@plt>
   4bc68:	14050463          	beqz	a0,4bdb0 <iap2_dev_recv_data@@Base+0xcd0>
   4bc6c:	4629                	li	a2,10
   4bc6e:	4581                	li	a1,0
   4bc70:	fffea097          	auipc	ra,0xfffea
   4bc74:	7e0080e7          	jalr	2016(ra) # 36450 <strtol@plt>
   4bc78:	00a03533          	snez	a0,a0
   4bc7c:	00a48023          	sb	a0,0(s1)
   4bc80:	fbdff06f          	j	4bc3c <iap2_dev_recv_data@@Base+0xb5c>
   4bc84:	0904a503          	lw	a0,144(s1)
   4bc88:	00050663          	beqz	a0,4bc94 <iap2_dev_recv_data@@Base+0xbb4>
   4bc8c:	fffec097          	auipc	ra,0xfffec
   4bc90:	824080e7          	jalr	-2012(ra) # 374b0 <free@plt>
   4bc94:	0029d783          	lhu	a5,2(s3)
   4bc98:	3c87a75b          	.insn	4, 0x3c87a75b
   4bc9c:	20f7a45b          	.insn	4, 0x20f7a45b
   4bca0:	8c59                	or	s0,s0,a4
   4bca2:	1459                	addi	s0,s0,-10
   4bca4:	00040513          	mv	a0,s0
   4bca8:	0884aa23          	sw	s0,148(s1)
   4bcac:	fffec097          	auipc	ra,0xfffec
   4bcb0:	dd4080e7          	jalr	-556(ra) # 37a80 <malloc@plt>
   4bcb4:	08a4a823          	sw	a0,144(s1)
   4bcb8:	10050263          	beqz	a0,4bdbc <iap2_dev_recv_data@@Base+0xcdc>
   4bcbc:	00040613          	mv	a2,s0
   4bcc0:	00a98593          	addi	a1,s3,10
   4bcc4:	fffeb097          	auipc	ra,0xfffeb
   4bcc8:	d9c080e7          	jalr	-612(ra) # 36a60 <memcpy@plt>
   4bccc:	00100513          	li	a0,1
   4bcd0:	08048f23          	sb	zero,158(s1)
   4bcd4:	c40ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4bcd8:	0684d583          	lhu	a1,104(s1)
   4bcdc:	0644a503          	lw	a0,100(s1)
   4bce0:	38c1f0ef          	jal	6b06c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x1990>
   4bce4:	85ca                	mv	a1,s2
   4bce6:	862a                	mv	a2,a0
   4bce8:	000a8513          	mv	a0,s5
   4bcec:	3a81f0ef          	jal	6b094 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x19b8>
   4bcf0:	ffcff06f          	j	4b4ec <iap2_dev_recv_data@@Base+0x40c>
   4bcf4:	0844d683          	lhu	a3,132(s1)
   4bcf8:	0018d617          	auipc	a2,0x18d
   4bcfc:	e8460613          	addi	a2,a2,-380 # 1d8b7c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1fb8>
   4bd00:	0018c597          	auipc	a1,0x18c
   4bd04:	d9458593          	addi	a1,a1,-620 # 1d7a94 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0ed0> ; DATA 'recv loc info:%s len:%d\n'
   4bd08:	0018b517          	auipc	a0,0x18b
   4bd0c:	45850513          	addi	a0,a0,1112 # 1d7160 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa059c> ; DATA 'ProxyIAP2'
   4bd10:	fffec097          	auipc	ra,0xfffec
   4bd14:	7c0080e7          	jalr	1984(ra) # 384d0 <MLOGD@plt>
   4bd18:	f8cff06f          	j	4b4a4 <iap2_dev_recv_data@@Base+0x3c4>
   4bd1c:	fc045683          	lhu	a3,-64(s0)
   4bd20:	0018a617          	auipc	a2,0x18a
   4bd24:	12c60613          	addi	a2,a2,300 # 1d5e4c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f288> ; DATA 'null'
   4bd28:	0018c597          	auipc	a1,0x18c
   4bd2c:	d4858593          	addi	a1,a1,-696 # 1d7a70 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0eac> ; DATA 'recv mfi serial number:%s len:%d\n'
   4bd30:	0018b517          	auipc	a0,0x18b
   4bd34:	43050513          	addi	a0,a0,1072 # 1d7160 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa059c> ; DATA 'ProxyIAP2'
   4bd38:	fffec097          	auipc	ra,0xfffec
   4bd3c:	798080e7          	jalr	1944(ra) # 384d0 <MLOGD@plt>
   4bd40:	981ff06f          	j	4b6c0 <iap2_dev_recv_data@@Base+0x5e0>
   4bd44:	fa845583          	lhu	a1,-88(s0)
   4bd48:	67c1                	lui	a5,0x10
   4bd4a:	faa78793          	addi	a5,a5,-86 # ffaa <HTimerEx::stop()@plt-0x260b6>
   4bd4e:	8622                	mv	a2,s0
   4bd50:	00f585b3          	add	a1,a1,a5
   4bd54:	fffeb097          	auipc	ra,0xfffeb
   4bd58:	d1c080e7          	jalr	-740(ra) # 36a70 <AirPlayReceiverSessionSendHIDReport@plt>
   4bd5c:	eb5ff06f          	j	4bc10 <iap2_dev_recv_data@@Base+0xb30>
   4bd60:	ca11                	beqz	a2,4bd74 <iap2_dev_recv_data@@Base+0xc94>
   4bd62:	fa87a503          	lw	a0,-88(a5)
   4bd66:	85a2                	mv	a1,s0
   4bd68:	fffeb097          	auipc	ra,0xfffeb
   4bd6c:	5e8080e7          	jalr	1512(ra) # 37350 <memcmp@plt>
   4bd70:	b6051ce3          	bnez	a0,4b8e8 <iap2_dev_recv_data@@Base+0x808>
   4bd74:	6685                	lui	a3,0x1
   4bd76:	77fd                	lui	a5,0xfffff
   4bd78:	08068693          	addi	a3,a3,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4bd7c:	96be                	add	a3,a3,a5
   4bd7e:	0810                	addi	a2,sp,16
   4bd80:	00c687b3          	add	a5,a3,a2
   4bd84:	fc878793          	addi	a5,a5,-56 # ffffefc8 <AOAProxy::sReaderBuffer@@Base+0xffd9bc58>
   4bd88:	c0f408e3          	beq	s0,a5,4b998 <iap2_dev_recv_data@@Base+0x8b8>
   4bd8c:	00040513          	mv	a0,s0
   4bd90:	fffec097          	auipc	ra,0xfffec
   4bd94:	850080e7          	jalr	-1968(ra) # 375e0 <operator delete(void*)@plt>
   4bd98:	c01ff06f          	j	4b998 <iap2_dev_recv_data@@Base+0x8b8>
   4bd9c:	58b4                	lw	a3,112(s1)
   4bd9e:	54f0                	lw	a2,108(s1)
   4bda0:	8556                	mv	a0,s5
   4bda2:	85ca                	mv	a1,s2
   4bda4:	66d200ef          	jal	6cc10 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x3534>
   4bda8:	00100513          	li	a0,1
   4bdac:	b68ff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4bdb0:	9009ba8b          	.insn	4, 0x9009ba8b
   4bdb4:	00100513          	li	a0,1
   4bdb8:	b5cff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4bdbc:	0804aa23          	sw	zero,148(s1)
   4bdc0:	f0dff06f          	j	4bccc <iap2_dev_recv_data@@Base+0xbec>
   4bdc4:	00000513          	li	a0,0
   4bdc8:	b4cff06f          	j	4b114 <iap2_dev_recv_data@@Base+0x34>
   4bdcc:	6685                	lui	a3,0x1
   4bdce:	77fd                	lui	a5,0xfffff
   4bdd0:	08068593          	addi	a1,a3,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4bdd4:	95be                	add	a1,a1,a5
   4bdd6:	0810                	addi	a2,sp,16
   4bdd8:	00c58733          	add	a4,a1,a2
   4bddc:	87ba                	mv	a5,a4
   4bdde:	fc072703          	lw	a4,-64(a4)
   4bde2:	fc878793          	addi	a5,a5,-56 # ffffefc8 <AOAProxy::sReaderBuffer@@Base+0xffd9bc58>
   4bde6:	842a                	mv	s0,a0
   4bde8:	00f70863          	beq	a4,a5,4bdf8 <iap2_dev_recv_data@@Base+0xd18>
   4bdec:	00070513          	mv	a0,a4
   4bdf0:	fffeb097          	auipc	ra,0xfffeb
   4bdf4:	7f0080e7          	jalr	2032(ra) # 375e0 <operator delete(void*)@plt>
   4bdf8:	00040513          	mv	a0,s0
   4bdfc:	fffed097          	auipc	ra,0xfffed
   4be00:	b64080e7          	jalr	-1180(ra) # 38960 <_Unwind_Resume@plt>
   4be04:	6585                	lui	a1,0x1
   4be06:	77fd                	lui	a5,0xfffff
   4be08:	08058613          	addi	a2,a1,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4be0c:	963e                	add	a2,a2,a5
   4be0e:	0814                	addi	a3,sp,16
   4be10:	00d60733          	add	a4,a2,a3
   4be14:	87ba                	mv	a5,a4
   4be16:	fa872703          	lw	a4,-88(a4)
   4be1a:	fb078793          	addi	a5,a5,-80 # ffffefb0 <AOAProxy::sReaderBuffer@@Base+0xffd9bc40>
   4be1e:	842a                	mv	s0,a0
   4be20:	fcf716e3          	bne	a4,a5,4bdec <iap2_dev_recv_data@@Base+0xd0c>
   4be24:	fd5ff06f          	j	4bdf8 <iap2_dev_recv_data@@Base+0xd18>
   4be28:	6605                	lui	a2,0x1
   4be2a:	77fd                	lui	a5,0xfffff
   4be2c:	08060693          	addi	a3,a2,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4be30:	96be                	add	a3,a3,a5
   4be32:	080c                	addi	a1,sp,16
   4be34:	00b687b3          	add	a5,a3,a1
   4be38:	4398                	lw	a4,0(a5)
   4be3a:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffd9bc98>
   4be3c:	842a                	mv	s0,a0
   4be3e:	faf717e3          	bne	a4,a5,4bdec <iap2_dev_recv_data@@Base+0xd0c>
   4be42:	bf5d                	j	4bdf8 <iap2_dev_recv_data@@Base+0xd18>
   4be44:	6605                	lui	a2,0x1
   4be46:	77fd                	lui	a5,0xfffff
   4be48:	08060613          	addi	a2,a2,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4be4c:	963e                	add	a2,a2,a5
   4be4e:	080c                	addi	a1,sp,16
   4be50:	00b607b3          	add	a5,a2,a1
   4be54:	4398                	lw	a4,0(a5)
   4be56:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffd9bc98>
   4be58:	842a                	mv	s0,a0
   4be5a:	f8f719e3          	bne	a4,a5,4bdec <iap2_dev_recv_data@@Base+0xd0c>
   4be5e:	bf69                	j	4bdf8 <iap2_dev_recv_data@@Base+0xd18>
   4be60:	f6dff06f          	j	4bdcc <iap2_dev_recv_data@@Base+0xcec>
   4be64:	6605                	lui	a2,0x1
   4be66:	77fd                	lui	a5,0xfffff
   4be68:	08060593          	addi	a1,a2,128 # 1080 <HTimerEx::stop()@plt-0x34fe0>
   4be6c:	95be                	add	a1,a1,a5
   4be6e:	0814                	addi	a3,sp,16
   4be70:	00d58733          	add	a4,a1,a3
   4be74:	f69ff06f          	j	4bddc <iap2_dev_recv_data@@Base+0xcfc>
