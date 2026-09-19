
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00030418 <iap2_dev_recv_data@@Base>:
   30418:	515c                	lw	a5,36(a0)
   3041a:	7131                	addi	sp,sp,-192
   3041c:	db26                	sw	s1,180(sp)
   3041e:	4784                	lw	s1,8(a5)
   30420:	d94a                	sw	s2,176(sp)
   30422:	df06                	sw	ra,188(sp)
   30424:	dd22                	sw	s0,184(sp)
   30426:	d74e                	sw	s3,172(sp)
   30428:	d552                	sw	s4,168(sp)
   3042a:	d356                	sw	s5,164(sp)
   3042c:	d15a                	sw	s6,160(sp)
   3042e:	cf5e                	sw	s7,156(sp)
   30430:	0744c783          	lbu	a5,116(s1)
   30434:	72fd                	lui	t0,0xfffff
   30436:	9116                	add	sp,sp,t0
   30438:	00068913          	mv	s2,a3
   3043c:	04d78a63          	beq	a5,a3,30490 <iap2_dev_recv_data@@Base+0x78>
   30440:	0754c783          	lbu	a5,117(s1)
   30444:	02d78263          	beq	a5,a3,30468 <iap2_dev_recv_data@@Base+0x50>
   30448:	00100513          	li	a0,1
   3044c:	6285                	lui	t0,0x1
   3044e:	9116                	add	sp,sp,t0
   30450:	50fa                	lw	ra,188(sp)
   30452:	546a                	lw	s0,184(sp)
   30454:	54da                	lw	s1,180(sp)
   30456:	594a                	lw	s2,176(sp)
   30458:	59ba                	lw	s3,172(sp)
   3045a:	5a2a                	lw	s4,168(sp)
   3045c:	5a9a                	lw	s5,164(sp)
   3045e:	5b0a                	lw	s6,160(sp)
   30460:	4bfa                	lw	s7,156(sp)
   30462:	6129                	addi	sp,sp,192
   30464:	00008067          	ret
   30468:	000ff797          	auipc	a5,0xff
   3046c:	ce87a783          	lw	a5,-792(a5) # 12f150 <gOverCarplayLink@@Base-0xca0> ; DATA ELF relocation: gOverCarplayLink
   30470:	4388                	lw	a0,0(a5)
   30472:	d979                	beqz	a0,30448 <iap2_dev_recv_data@@Base+0x30>
   30474:	000ff797          	auipc	a5,0xff
   30478:	c347a783          	lw	a5,-972(a5) # 12f0a8 <gOverCarPlayBufferSession@@Base-0xd44> ; DATA ELF relocation: gOverCarPlayBufferSession
   3047c:	0007c683          	lbu	a3,0(a5)
   30480:	4701                	li	a4,0
   30482:	4781                	li	a5,0
   30484:	ffff1097          	auipc	ra,0xffff1
   30488:	a5c080e7          	jalr	-1444(ra) # 20ee0 <iAP2LinkQueueSendData@plt>
   3048c:	fbdff06f          	j	30448 <iap2_dev_recv_data@@Base+0x30>
   30490:	0045d403          	lhu	s0,4(a1)
   30494:	0005c783          	lbu	a5,0(a1)
   30498:	3c84275b          	.insn	4, 0x3c84275b
   3049c:	20f4245b          	.insn	4, 0x20f4245b
   304a0:	8aaa                	mv	s5,a0
   304a2:	89ae                	mv	s3,a1
   304a4:	8a32                	mv	s4,a2
   304a6:	8c59                	or	s0,s0,a4
   304a8:	4607d85b          	.insn	4, 0x4607d85b
   304ac:	0b44d783          	lhu	a5,180(s1)
   304b0:	cbd1                	beqz	a5,30544 <iap2_dev_recv_data@@Base+0x12c>
   304b2:	0b64d703          	lhu	a4,182(s1)
   304b6:	014786b3          	add	a3,a5,s4
   304ba:	f8d767e3          	bltu	a4,a3,30448 <iap2_dev_recv_data@@Base+0x30>
   304be:	0b04a503          	lw	a0,176(s1)
   304c2:	8652                	mv	a2,s4
   304c4:	85ce                	mv	a1,s3
   304c6:	953e                	add	a0,a0,a5
   304c8:	ffff2097          	auipc	ra,0xffff2
   304cc:	dd8080e7          	jalr	-552(ra) # 222a0 <memcpy@plt>
   304d0:	0b44d703          	lhu	a4,180(s1)
   304d4:	0b64d783          	lhu	a5,182(s1)
   304d8:	9752                	add	a4,a4,s4
   304da:	0b84d603          	lhu	a2,184(s1)
   304de:	3c07275b          	.insn	4, 0x3c07275b
   304e2:	86d2                	mv	a3,s4
   304e4:	000d6597          	auipc	a1,0xd6
   304e8:	7ec58593          	addi	a1,a1,2028 # 106cd0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1870> ; DATA 'recv buffer msg id = %04x datalen=%d recvlen:%d msglen=%d\n'
   304ec:	000d6517          	auipc	a0,0xd6
   304f0:	f8850513          	addi	a0,a0,-120 # 106474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1014> ; DATA 'ProxyIAP2'
   304f4:	0ae49a23          	sh	a4,180(s1)
   304f8:	ffff2097          	auipc	ra,0xffff2
   304fc:	808080e7          	jalr	-2040(ra) # 21d00 <MLOGD@plt>
   30500:	0b64d783          	lhu	a5,182(s1)
   30504:	0b44da03          	lhu	s4,180(s1)
   30508:	f4fa10e3          	bne	s4,a5,30448 <iap2_dev_recv_data@@Base+0x30>
   3050c:	0b04a983          	lw	s3,176(s1)
   30510:	0b84d403          	lhu	s0,184(s1)
   30514:	0280006f          	j	3053c <iap2_dev_recv_data@@Base+0x124>
   30518:	0015c783          	lbu	a5,1(a1)
   3051c:	f807e85b          	.insn	4, 0xf807e85b
   30520:	00500793          	li	a5,5
   30524:	f8c7f4e3          	bgeu	a5,a2,304ac <iap2_dev_recv_data@@Base+0x94>
   30528:	0025d783          	lhu	a5,2(a1)
   3052c:	3c87ab5b          	.insn	4, 0x3c87ab5b
   30530:	20f7a7db          	.insn	4, 0x20f7a7db
   30534:	0167eb33          	or	s6,a5,s6
   30538:	7d666863          	bltu	a2,s6,30d08 <iap2_dev_recv_data@@Base+0x8f0>
   3053c:	0a04aa23          	sw	zero,180(s1)
   30540:	0a049c23          	sh	zero,184(s1)
   30544:	67c1                	lui	a5,0x10
   30546:	17ed                	addi	a5,a5,-5 # fffb <CFArrayCreateCopy@plt-0xf7d5>
   30548:	0ef41263          	bne	s0,a5,3062c <iap2_dev_recv_data@@Base+0x214>
   3054c:	8652                	mv	a2,s4
   3054e:	85ce                	mv	a1,s3
   30550:	00040513          	mv	a0,s0
   30554:	dfcfe0ef          	jal	2eb50 <_HandleProxyEventConnectionClose@@Base+0x42ac>
   30558:	7b7d                	lui	s6,0xfffff
   3055a:	f26b0793          	addi	a5,s6,-218 # ffffef26 <AOAProxy::sReaderBuffer@@Base+0xffece632>
   3055e:	97a2                	add	a5,a5,s0
   30560:	3c07a7db          	.insn	4, 0x3c07a7db
   30564:	470d                	li	a4,3
   30566:	14f77b63          	bgeu	a4,a5,306bc <iap2_dev_recv_data@@Base+0x2a4>
   3056a:	77ed                	lui	a5,0xffffb
   3056c:	40078793          	addi	a5,a5,1024 # ffffb400 <AOAProxy::sReaderBuffer@@Base+0xffecab0c>
   30570:	97a2                	add	a5,a5,s0
   30572:	3c07a7db          	.insn	4, 0x3c07a7db
   30576:	46a5                	li	a3,9
   30578:	2cf6e663          	bltu	a3,a5,30844 <iap2_dev_recv_data@@Base+0x42c>
   3057c:	000ff497          	auipc	s1,0xff
   30580:	bd44a483          	lw	s1,-1068(s1) # 12f150 <gOverCarplayLink@@Base-0xca0> ; DATA ELF relocation: gOverCarplayLink
   30584:	409c                	lw	a5,0(s1)
   30586:	2a078363          	beqz	a5,3082c <iap2_dev_recv_data@@Base+0x414>
   3058a:	6b85                	lui	s7,0x1
   3058c:	080b8593          	addi	a1,s7,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30590:	0814                	addi	a3,sp,16
   30592:	95da                	add	a1,a1,s6
   30594:	00d58433          	add	s0,a1,a3
   30598:	7fc00613          	li	a2,2044
   3059c:	00000593          	li	a1,0
   305a0:	00440513          	addi	a0,s0,4
   305a4:	00042023          	sw	zero,0(s0)
   305a8:	ffff2097          	auipc	ra,0xffff2
   305ac:	a68080e7          	jalr	-1432(ra) # 22010 <memset@plt>
   305b0:	fc0b0693          	addi	a3,s6,-64
   305b4:	080b8593          	addi	a1,s7,128
   305b8:	95b6                	add	a1,a1,a3
   305ba:	0814                	addi	a3,sp,16
   305bc:	000ff797          	auipc	a5,0xff
   305c0:	ce07a783          	lw	a5,-800(a5) # 12f29c <gMediaUniqueId@@Base-0xabc> ; DATA ELF relocation: gMediaUniqueId
   305c4:	fa8b0613          	addi	a2,s6,-88
   305c8:	96ae                	add	a3,a3,a1
   305ca:	080b8593          	addi	a1,s7,128
   305ce:	0007a803          	lw	a6,0(a5)
   305d2:	95b2                	add	a1,a1,a2
   305d4:	4f9c                	lw	a5,24(a5)
   305d6:	000d6897          	auipc	a7,0xd6
   305da:	52e88893          	addi	a7,a7,1326 # 106b04 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa16a4> ; DATA 'E9746442-B1A7-4E38-95CE-D1274F5E4A1A-MPB-14.4'
   305de:	0810                	addi	a2,sp,16
   305e0:	962e                	add	a2,a2,a1
   305e2:	fb142423          	sw	a7,-88(s0)
   305e6:	8722                	mv	a4,s0
   305e8:	000d6897          	auipc	a7,0xd6
   305ec:	54c88893          	addi	a7,a7,1356 # 106b34 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa16d4> ; DATA 'E9746442-B1A7-4E38-95CE-D1274F5E4A1A-4954524C-14.4'
   305f0:	85d2                	mv	a1,s4
   305f2:	854e                	mv	a0,s3
   305f4:	fb142623          	sw	a7,-84(s0)
   305f8:	fd042023          	sw	a6,-64(s0)
   305fc:	fcf42223          	sw	a5,-60(s0)
   30600:	428230ef          	jal	53a28 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x1eb4>
   30604:	862a                	mv	a2,a0
   30606:	4505                	li	a0,1
   30608:	e40602e3          	beqz	a2,3044c <iap2_dev_recv_data@@Base+0x34>
   3060c:	000ff797          	auipc	a5,0xff
   30610:	a707a783          	lw	a5,-1424(a5) # 12f07c <gOverCarPlayCtrlSession@@Base-0xd71> ; DATA ELF relocation: gOverCarPlayCtrlSession
   30614:	0007c683          	lbu	a3,0(a5)
   30618:	4088                	lw	a0,0(s1)
   3061a:	4781                	li	a5,0
   3061c:	4701                	li	a4,0
   3061e:	85a2                	mv	a1,s0
   30620:	ffff1097          	auipc	ra,0xffff1
   30624:	8c0080e7          	jalr	-1856(ra) # 20ee0 <iAP2LinkQueueSendData@plt>
   30628:	e25ff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   3062c:	874a                	mv	a4,s2
   3062e:	86d2                	mv	a3,s4
   30630:	00040613          	mv	a2,s0
   30634:	000d6597          	auipc	a1,0xd6
   30638:	6d858593          	addi	a1,a1,1752 # 106d0c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa18ac> ; DATA 'recv msg id = %04x datalen=%d session=%d\n'
   3063c:	000d6517          	auipc	a0,0xd6
   30640:	e3850513          	addi	a0,a0,-456 # 106474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1014> ; DATA 'ProxyIAP2'
   30644:	ffff1097          	auipc	ra,0xffff1
   30648:	6bc080e7          	jalr	1724(ra) # 21d00 <MLOGD@plt>
   3064c:	8652                	mv	a2,s4
   3064e:	85ce                	mv	a1,s3
   30650:	00040513          	mv	a0,s0
   30654:	cfcfe0ef          	jal	2eb50 <_HandleProxyEventConnectionClose@@Base+0x42ac>
   30658:	7771                	lui	a4,0xffffc
   3065a:	eac70793          	addi	a5,a4,-340 # ffffbeac <AOAProxy::sReaderBuffer@@Base+0xffecb5b8>
   3065e:	97a2                	add	a5,a5,s0
   30660:	3c07a7db          	.insn	4, 0x3c07a7db
   30664:	46c1                	li	a3,16
   30666:	04f6e363          	bltu	a3,a5,306ac <iap2_dev_recv_data@@Base+0x294>
   3066a:	000ff797          	auipc	a5,0xff
   3066e:	ae67a783          	lw	a5,-1306(a5) # 12f150 <gOverCarplayLink@@Base-0xca0> ; DATA ELF relocation: gOverCarplayLink
   30672:	4388                	lw	a0,0(a5)
   30674:	04050c63          	beqz	a0,306cc <iap2_dev_recv_data@@Base+0x2b4>
   30678:	000ff797          	auipc	a5,0xff
   3067c:	a047a783          	lw	a5,-1532(a5) # 12f07c <gOverCarPlayCtrlSession@@Base-0xd71> ; DATA ELF relocation: gOverCarPlayCtrlSession
   30680:	0007c683          	lbu	a3,0(a5)
   30684:	6285                	lui	t0,0x1
   30686:	9116                	add	sp,sp,t0
   30688:	50fa                	lw	ra,188(sp)
   3068a:	546a                	lw	s0,184(sp)
   3068c:	54da                	lw	s1,180(sp)
   3068e:	594a                	lw	s2,176(sp)
   30690:	5a9a                	lw	s5,164(sp)
   30692:	5b0a                	lw	s6,160(sp)
   30694:	4bfa                	lw	s7,156(sp)
   30696:	8652                	mv	a2,s4
   30698:	85ce                	mv	a1,s3
   3069a:	5a2a                	lw	s4,168(sp)
   3069c:	59ba                	lw	s3,172(sp)
   3069e:	4781                	li	a5,0
   306a0:	4701                	li	a4,0
   306a2:	6129                	addi	sp,sp,192
   306a4:	ffff1317          	auipc	t1,0xffff1
   306a8:	83c30067          	jr	-1988(t1) # 20ee0 <iAP2LinkQueueSendData@plt>
   306ac:	e9070793          	addi	a5,a4,-368
   306b0:	97a2                	add	a5,a5,s0
   306b2:	3c07a7db          	.insn	4, 0x3c07a7db
   306b6:	4709                	li	a4,2
   306b8:	eaf760e3          	bltu	a4,a5,30558 <iap2_dev_recv_data@@Base+0x140>
   306bc:	000ff797          	auipc	a5,0xff
   306c0:	a947a783          	lw	a5,-1388(a5) # 12f150 <gOverCarplayLink@@Base-0xca0> ; DATA ELF relocation: gOverCarplayLink
   306c4:	4388                	lw	a0,0(a5)
   306c6:	f94d                	bnez	a0,30678 <iap2_dev_recv_data@@Base+0x260>
   306c8:	d81ff06f          	j	30448 <iap2_dev_recv_data@@Base+0x30>
   306cc:	6791                	lui	a5,0x4
   306ce:	15478713          	addi	a4,a5,340 # 4154 <CFArrayCreateCopy@plt-0x1b67c>
   306d2:	70e40f63          	beq	s0,a4,30df0 <iap2_dev_recv_data@@Base+0x9d8>
   306d6:	15778793          	addi	a5,a5,343
   306da:	00f41963          	bne	s0,a5,306ec <iap2_dev_recv_data@@Base+0x2d4>
   306de:	85ca                	mv	a1,s2
   306e0:	000a8513          	mv	a0,s5
   306e4:	3b0220ef          	jal	52a94 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0xf20>
   306e8:	4505                	li	a0,1
   306ea:	b38d                	j	3044c <iap2_dev_recv_data@@Base+0x34>
   306ec:	6789                	lui	a5,0x2
   306ee:	d0178793          	addi	a5,a5,-767 # 1d01 <CFArrayCreateCopy@plt-0x1dacf>
   306f2:	d4f41be3          	bne	s0,a5,30448 <iap2_dev_recv_data@@Base+0x30>
   306f6:	50e8                	lw	a0,100(s1)
   306f8:	00050a63          	beqz	a0,3070c <iap2_dev_recv_data@@Base+0x2f4>
   306fc:	ffff0097          	auipc	ra,0xffff0
   30700:	7b4080e7          	jalr	1972(ra) # 20eb0 <free@plt>
   30704:	0604a223          	sw	zero,100(s1)
   30708:	0604a423          	sw	zero,104(s1)
   3070c:	54e8                	lw	a0,108(s1)
   3070e:	c909                	beqz	a0,30720 <iap2_dev_recv_data@@Base+0x308>
   30710:	ffff0097          	auipc	ra,0xffff0
   30714:	7a0080e7          	jalr	1952(ra) # 20eb0 <free@plt>
   30718:	0604a623          	sw	zero,108(s1)
   3071c:	0604a823          	sw	zero,112(s1)
   30720:	0bc4a503          	lw	a0,188(s1)
   30724:	00050863          	beqz	a0,30734 <iap2_dev_recv_data@@Base+0x31c>
   30728:	ffff0097          	auipc	ra,0xffff0
   3072c:	788080e7          	jalr	1928(ra) # 20eb0 <free@plt>
   30730:	0a04ae23          	sw	zero,188(s1)
   30734:	0804a503          	lw	a0,128(s1)
   30738:	00050863          	beqz	a0,30748 <iap2_dev_recv_data@@Base+0x330>
   3073c:	ffff0097          	auipc	ra,0xffff0
   30740:	774080e7          	jalr	1908(ra) # 20eb0 <free@plt>
   30744:	0804a023          	sw	zero,128(s1)
   30748:	08448313          	addi	t1,s1,132
   3074c:	0bc48593          	addi	a1,s1,188
   30750:	08048893          	addi	a7,s1,128
   30754:	07e48813          	addi	a6,s1,126
   30758:	07048793          	addi	a5,s1,112
   3075c:	06c48713          	addi	a4,s1,108
   30760:	06848693          	addi	a3,s1,104
   30764:	06448613          	addi	a2,s1,100
   30768:	854e                	mv	a0,s3
   3076a:	c01a                	sw	t1,0(sp)
   3076c:	2c5230ef          	jal	54230 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x26bc>
   30770:	0804a583          	lw	a1,128(s1)
   30774:	0a0586e3          	beqz	a1,31020 <iap2_dev_recv_data@@Base+0xc08>
   30778:	6685                	lui	a3,0x1
   3077a:	747d                	lui	s0,0xfffff
   3077c:	08068693          	addi	a3,a3,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30780:	96a2                	add	a3,a3,s0
   30782:	0810                	addi	a2,sp,16
   30784:	00c68433          	add	s0,a3,a2
   30788:	0844d603          	lhu	a2,132(s1)
   3078c:	00040513          	mv	a0,s0
   30790:	ffff1097          	auipc	ra,0xffff1
   30794:	450080e7          	jalr	1104(ra) # 21be0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   30798:	0844d683          	lhu	a3,132(s1)
   3079c:	00042603          	lw	a2,0(s0) # fffff000 <AOAProxy::sReaderBuffer@@Base+0xffece70c>
   307a0:	000d6597          	auipc	a1,0xd6
   307a4:	5fc58593          	addi	a1,a1,1532 # 106d9c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa193c> ; DATA 'recv loc info:%s len:%d\n'
   307a8:	000d6517          	auipc	a0,0xd6
   307ac:	ccc50513          	addi	a0,a0,-820 # 106474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1014> ; DATA 'ProxyIAP2'
   307b0:	ffff1097          	auipc	ra,0xffff1
   307b4:	550080e7          	jalr	1360(ra) # 21d00 <MLOGD@plt>
   307b8:	6585                	lui	a1,0x1
   307ba:	77fd                	lui	a5,0xfffff
   307bc:	08058613          	addi	a2,a1,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   307c0:	963e                	add	a2,a2,a5
   307c2:	080c                	addi	a1,sp,16
   307c4:	00b607b3          	add	a5,a2,a1
   307c8:	4388                	lw	a0,0(a5)
   307ca:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffece714>
   307cc:	00f50663          	beq	a0,a5,307d8 <iap2_dev_recv_data@@Base+0x3c0>
   307d0:	ffff0097          	auipc	ra,0xffff0
   307d4:	040080e7          	jalr	64(ra) # 20810 <operator delete(void*)@plt>
   307d8:	0804a783          	lw	a5,128(s1)
   307dc:	cb91                	beqz	a5,307f0 <iap2_dev_recv_data@@Base+0x3d8>
   307de:	faf00713          	li	a4,-81
   307e2:	00e78223          	sb	a4,4(a5)
   307e6:	0804a783          	lw	a5,128(s1)
   307ea:	5769                	li	a4,-6
   307ec:	00e782a3          	sb	a4,5(a5)
   307f0:	0c44a783          	lw	a5,196(s1)
   307f4:	c791                	beqz	a5,30800 <iap2_dev_recv_data@@Base+0x3e8>
   307f6:	0c84a503          	lw	a0,200(s1)
   307fa:	45a1                	li	a1,8
   307fc:	000780e7          	jalr	a5
   30800:	85ca                	mv	a1,s2
   30802:	8556                	mv	a0,s5
   30804:	698210ef          	jal	51e9c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x328>
   30808:	0764c783          	lbu	a5,118(s1)
   3080c:	0027e45b          	.insn	4, 0x0027e45b
   30810:	7f40006f          	j	31004 <iap2_dev_recv_data@@Base+0xbec>
   30814:	58b4                	lw	a3,112(s1)
   30816:	54f0                	lw	a2,108(s1)
   30818:	85ca                	mv	a1,s2
   3081a:	8556                	mv	a0,s5
   3081c:	065240ef          	jal	55080 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x350c>
   30820:	0bc4a503          	lw	a0,188(s1)
   30824:	b6dfe0ef          	jal	2f390 <_HandleProxyEventConnectionClose@@Base+0x4aec>
   30828:	4505                	li	a0,1
   3082a:	b10d                	j	3044c <iap2_dev_recv_data@@Base+0x34>
   3082c:	6795                	lui	a5,0x5
   3082e:	c0078793          	addi	a5,a5,-1024 # 4c00 <CFArrayCreateCopy@plt-0x1abd0>
   30832:	c0f41be3          	bne	s0,a5,30448 <iap2_dev_recv_data@@Base+0x30>
   30836:	85ca                	mv	a1,s2
   30838:	000a8513          	mv	a0,s5
   3083c:	67d220ef          	jal	536b8 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x1b44>
   30840:	4505                	li	a0,1
   30842:	b129                	j	3044c <iap2_dev_recv_data@@Base+0x34>
   30844:	77ed                	lui	a5,0xffffb
   30846:	97a2                	add	a5,a5,s0
   30848:	3c07a7db          	.insn	4, 0x3c07a7db
   3084c:	04f76c63          	bltu	a4,a5,308a4 <iap2_dev_recv_data@@Base+0x48c>
   30850:	000ff797          	auipc	a5,0xff
   30854:	9007a783          	lw	a5,-1792(a5) # 12f150 <gOverCarplayLink@@Base-0xca0> ; DATA ELF relocation: gOverCarplayLink
   30858:	0007a503          	lw	a0,0(a5)
   3085c:	e0051ee3          	bnez	a0,30678 <iap2_dev_recv_data@@Base+0x260>
   30860:	6795                	lui	a5,0x5
   30862:	fcf415e3          	bne	s0,a5,3082c <iap2_dev_recv_data@@Base+0x414>
   30866:	6585                	lui	a1,0x1
   30868:	747d                	lui	s0,0xfffff
   3086a:	08058613          	addi	a2,a1,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   3086e:	9622                	add	a2,a2,s0
   30870:	080c                	addi	a1,sp,16
   30872:	00b60433          	add	s0,a2,a1
   30876:	8522                	mv	a0,s0
   30878:	06000613          	li	a2,96
   3087c:	00000593          	li	a1,0
   30880:	ffff1097          	auipc	ra,0xffff1
   30884:	790080e7          	jalr	1936(ra) # 22010 <memset@plt>
   30888:	8622                	mv	a2,s0
   3088a:	85d2                	mv	a1,s4
   3088c:	00098513          	mv	a0,s3
   30890:	39c220ef          	jal	52c2c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x10b8>
   30894:	8622                	mv	a2,s0
   30896:	85ca                	mv	a1,s2
   30898:	000a8513          	mv	a0,s5
   3089c:	698220ef          	jal	52f34 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x13c0>
   308a0:	4505                	li	a0,1
   308a2:	b66d                	j	3044c <iap2_dev_recv_data@@Base+0x34>
   308a4:	6bc1                	lui	s7,0x10
   308a6:	ffbb8793          	addi	a5,s7,-5 # fffb <CFArrayCreateCopy@plt-0xf7d5>
   308aa:	68f40f63          	beq	s0,a5,30f48 <iap2_dev_recv_data@@Base+0xb30>
   308ae:	ff0b8793          	addi	a5,s7,-16
   308b2:	68f40b63          	beq	s0,a5,30f48 <iap2_dev_recv_data@@Base+0xb30>
   308b6:	6795                	lui	a5,0x5
   308b8:	70378713          	addi	a4,a5,1795 # 5703 <CFArrayCreateCopy@plt-0x1a0cd>
   308bc:	4ae40263          	beq	s0,a4,30d60 <iap2_dev_recv_data@@Base+0x948>
   308c0:	40877e63          	bgeu	a4,s0,30cdc <iap2_dev_recv_data@@Base+0x8c4>
   308c4:	67ad                	lui	a5,0xb
   308c6:	a0378713          	addi	a4,a5,-1533 # aa03 <CFArrayCreateCopy@plt-0x14dcd>
   308ca:	4ae40363          	beq	s0,a4,30d70 <iap2_dev_recv_data@@Base+0x958>
   308ce:	02877d63          	bgeu	a4,s0,30908 <iap2_dev_recv_data@@Base+0x4f0>
   308d2:	e0078793          	addi	a5,a5,-512
   308d6:	4ef40563          	beq	s0,a5,30dc0 <iap2_dev_recv_data@@Base+0x9a8>
   308da:	67ad                	lui	a5,0xb
   308dc:	e0378713          	addi	a4,a5,-509 # ae03 <CFArrayCreateCopy@plt-0x149cd>
   308e0:	06e41e63          	bne	s0,a4,3095c <iap2_dev_recv_data@@Base+0x544>
   308e4:	0a848783          	lb	a5,168(s1)
   308e8:	b60790e3          	bnez	a5,30448 <iap2_dev_recv_data@@Base+0x30>
   308ec:	0a44a683          	lw	a3,164(s1)
   308f0:	0a04a603          	lw	a2,160(s1)
   308f4:	4785                	li	a5,1
   308f6:	85ca                	mv	a1,s2
   308f8:	000a8513          	mv	a0,s5
   308fc:	0af48423          	sb	a5,168(s1)
   30900:	610210ef          	jal	51f10 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x39c>
   30904:	4505                	li	a0,1
   30906:	b699                	j	3044c <iap2_dev_recv_data@@Base+0x34>
   30908:	679d                	lui	a5,0x7
   3090a:	80278793          	addi	a5,a5,-2046 # 6802 <CFArrayCreateCopy@plt-0x18fce>
   3090e:	5af40f63          	beq	s0,a5,30ecc <iap2_dev_recv_data@@Base+0xab4>
   30912:	67ad                	lui	a5,0xb
   30914:	a0178793          	addi	a5,a5,-1535 # aa01 <CFArrayCreateCopy@plt-0x14dcf>
   30918:	0cf41c63          	bne	s0,a5,309f0 <iap2_dev_recv_data@@Base+0x5d8>
   3091c:	0029d783          	lhu	a5,2(s3)
   30920:	000d6597          	auipc	a1,0xd6
   30924:	43058593          	addi	a1,a1,1072 # 106d50 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa18f0> ; DATA 'recv authentication certificate len:%d'
   30928:	00879613          	slli	a2,a5,0x8
   3092c:	3c87a7db          	.insn	4, 0x3c87a7db
   30930:	8e5d                	or	a2,a2,a5
   30932:	1659                	addi	a2,a2,-10
   30934:	3c06265b          	.insn	4, 0x3c06265b
   30938:	000d6517          	auipc	a0,0xd6
   3093c:	b3c50513          	addi	a0,a0,-1220 # 106474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1014> ; DATA 'ProxyIAP2'
   30940:	00c12e23          	sw	a2,28(sp)
   30944:	ffff1097          	auipc	ra,0xffff1
   30948:	3bc080e7          	jalr	956(ra) # 21d00 <MLOGD@plt>
   3094c:	4672                	lw	a2,28(sp)
   3094e:	85ca                	mv	a1,s2
   30950:	000a8513          	mv	a0,s5
   30954:	338210ef          	jal	51c8c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x118>
   30958:	4505                	li	a0,1
   3095a:	bccd                	j	3044c <iap2_dev_recv_data@@Base+0x34>
   3095c:	a0678793          	addi	a5,a5,-1530
   30960:	aef414e3          	bne	s0,a5,30448 <iap2_dev_recv_data@@Base+0x30>
   30964:	6685                	lui	a3,0x1
   30966:	747d                	lui	s0,0xfffff
   30968:	08068613          	addi	a2,a3,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   3096c:	9622                	add	a2,a2,s0
   3096e:	0818                	addi	a4,sp,16
   30970:	fc040593          	addi	a1,s0,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffece6cc>
   30974:	00e60433          	add	s0,a2,a4
   30978:	08068613          	addi	a2,a3,128
   3097c:	962e                	add	a2,a2,a1
   3097e:	00e605b3          	add	a1,a2,a4
   30982:	854e                	mv	a0,s3
   30984:	fc041023          	sh	zero,-64(s0)
   30988:	504240ef          	jal	54e8c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x3318>
   3098c:	6a050e63          	beqz	a0,31048 <iap2_dev_recv_data@@Base+0xc30>
   30990:	fc045603          	lhu	a2,-64(s0)
   30994:	85aa                	mv	a1,a0
   30996:	8522                	mv	a0,s0
   30998:	ffff1097          	auipc	ra,0xffff1
   3099c:	248080e7          	jalr	584(ra) # 21be0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   309a0:	fc045683          	lhu	a3,-64(s0)
   309a4:	00042603          	lw	a2,0(s0)
   309a8:	000d6597          	auipc	a1,0xd6
   309ac:	3d058593          	addi	a1,a1,976 # 106d78 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1918> ; DATA 'recv mfi serial number:%s len:%d\n'
   309b0:	000d6517          	auipc	a0,0xd6
   309b4:	ac450513          	addi	a0,a0,-1340 # 106474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1014> ; DATA 'ProxyIAP2'
   309b8:	ffff1097          	auipc	ra,0xffff1
   309bc:	348080e7          	jalr	840(ra) # 21d00 <MLOGD@plt>
   309c0:	6605                	lui	a2,0x1
   309c2:	77fd                	lui	a5,0xfffff
   309c4:	08060593          	addi	a1,a2,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   309c8:	95be                	add	a1,a1,a5
   309ca:	0814                	addi	a3,sp,16
   309cc:	00d587b3          	add	a5,a1,a3
   309d0:	4388                	lw	a0,0(a5)
   309d2:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffece714>
   309d4:	00f50663          	beq	a0,a5,309e0 <iap2_dev_recv_data@@Base+0x5c8>
   309d8:	ffff0097          	auipc	ra,0xffff0
   309dc:	e38080e7          	jalr	-456(ra) # 20810 <operator delete(void*)@plt>
   309e0:	4601                	li	a2,0
   309e2:	85ca                	mv	a1,s2
   309e4:	000a8513          	mv	a0,s5
   309e8:	341220ef          	jal	53528 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x19b4>
   309ec:	4505                	li	a0,1
   309ee:	bcb9                	j	3044c <iap2_dev_recv_data@@Base+0x34>
   309f0:	679d                	lui	a5,0x7
   309f2:	80078793          	addi	a5,a5,-2048 # 6800 <CFArrayCreateCopy@plt-0x18fd0>
   309f6:	a4f419e3          	bne	s0,a5,30448 <iap2_dev_recv_data@@Base+0x30>
   309fa:	6b85                	lui	s7,0x1
   309fc:	797d                	lui	s2,0xfffff
   309fe:	080b8593          	addi	a1,s7,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30a02:	95ca                	add	a1,a1,s2
   30a04:	0814                	addi	a3,sp,16
   30a06:	00d58433          	add	s0,a1,a3
   30a0a:	6605                	lui	a2,0x1
   30a0c:	1671                	addi	a2,a2,-4 # ffc <CFArrayCreateCopy@plt-0x1e7d4>
   30a0e:	4581                	li	a1,0
   30a10:	00440513          	addi	a0,s0,4
   30a14:	fa041023          	sh	zero,-96(s0)
   30a18:	fa041123          	sh	zero,-94(s0)
   30a1c:	fa041223          	sh	zero,-92(s0)
   30a20:	f8040fa3          	sb	zero,-97(s0)
   30a24:	00042023          	sw	zero,0(s0)
   30a28:	ffff1097          	auipc	ra,0xffff1
   30a2c:	5e8080e7          	jalr	1512(ra) # 22010 <memset@plt>
   30a30:	fa690813          	addi	a6,s2,-90 # ffffefa6 <AOAProxy::sReaderBuffer@@Base+0xffece6b2>
   30a34:	080b8513          	addi	a0,s7,128
   30a38:	9542                	add	a0,a0,a6
   30a3a:	081c                	addi	a5,sp,16
   30a3c:	00f50833          	add	a6,a0,a5
   30a40:	f9f90713          	addi	a4,s2,-97
   30a44:	080b8513          	addi	a0,s7,128
   30a48:	953a                	add	a0,a0,a4
   30a4a:	0818                	addi	a4,sp,16
   30a4c:	972a                	add	a4,a4,a0
   30a4e:	fa490693          	addi	a3,s2,-92
   30a52:	080b8513          	addi	a0,s7,128
   30a56:	9536                	add	a0,a0,a3
   30a58:	0814                	addi	a3,sp,16
   30a5a:	96aa                	add	a3,a3,a0
   30a5c:	fa290613          	addi	a2,s2,-94
   30a60:	080b8513          	addi	a0,s7,128
   30a64:	9532                	add	a0,a0,a2
   30a66:	0810                	addi	a2,sp,16
   30a68:	fa090593          	addi	a1,s2,-96
   30a6c:	962a                	add	a2,a2,a0
   30a6e:	080b8513          	addi	a0,s7,128
   30a72:	952e                	add	a0,a0,a1
   30a74:	080c                	addi	a1,sp,16
   30a76:	87a2                	mv	a5,s0
   30a78:	95aa                	add	a1,a1,a0
   30a7a:	854e                	mv	a0,s3
   30a7c:	fa041323          	sh	zero,-90(s0)
   30a80:	2c9230ef          	jal	54548 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x29d4>
   30a84:	fa645903          	lhu	s2,-90(s0)
   30a88:	85a2                	mv	a1,s0
   30a8a:	864a                	mv	a2,s2
   30a8c:	fc040513          	addi	a0,s0,-64
   30a90:	fa045983          	lhu	s3,-96(s0)
   30a94:	fa245a03          	lhu	s4,-94(s0)
   30a98:	fa445a83          	lhu	s5,-92(s0)
   30a9c:	f9f44b03          	lbu	s6,-97(s0)
   30aa0:	ffff1097          	auipc	ra,0xffff1
   30aa4:	140080e7          	jalr	320(ra) # 21be0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   30aa8:	fc042883          	lw	a7,-64(s0)
   30aac:	884a                	mv	a6,s2
   30aae:	87da                	mv	a5,s6
   30ab0:	8756                	mv	a4,s5
   30ab2:	86d2                	mv	a3,s4
   30ab4:	00098613          	mv	a2,s3
   30ab8:	000d6597          	auipc	a1,0xd6
   30abc:	33058593          	addi	a1,a1,816 # 106de8 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1988> ; DATA 'parse hid info, id:%d vid:%d pid:%d countrycode:%d reportlen:%d report:%s\n'
   30ac0:	000d6517          	auipc	a0,0xd6
   30ac4:	9b450513          	addi	a0,a0,-1612 # 106474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1014> ; DATA 'ProxyIAP2'
   30ac8:	ffff1097          	auipc	ra,0xffff1
   30acc:	238080e7          	jalr	568(ra) # 21d00 <MLOGD@plt>
   30ad0:	fc042503          	lw	a0,-64(s0)
   30ad4:	fc840793          	addi	a5,s0,-56
   30ad8:	00f50663          	beq	a0,a5,30ae4 <iap2_dev_recv_data@@Base+0x6cc>
   30adc:	ffff0097          	auipc	ra,0xffff0
   30ae0:	d34080e7          	jalr	-716(ra) # 20810 <operator delete(void*)@plt>
   30ae4:	747d                	lui	s0,0xfffff
   30ae6:	6b05                	lui	s6,0x1
   30ae8:	fc040413          	addi	s0,s0,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffece6cc>
   30aec:	080b0613          	addi	a2,s6,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30af0:	9622                	add	a2,a2,s0
   30af2:	080c                	addi	a1,sp,16
   30af4:	00b60433          	add	s0,a2,a1
   30af8:	00040513          	mv	a0,s0
   30afc:	000d6597          	auipc	a1,0xd6
   30b00:	17058593          	addi	a1,a1,368 # 106c6c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa180c> ; DATA 'hid'
   30b04:	ffff1097          	auipc	ra,0xffff1
   30b08:	0fc080e7          	jalr	252(ra) # 21c00 <MString::MString(char const*)@plt>
   30b0c:	00040593          	mv	a1,s0
   30b10:	000fe517          	auipc	a0,0xfe
   30b14:	70852503          	lw	a0,1800(a0) # 12f218 <gHIDDevicesConfig@@Base-0xb70> ; DATA ELF relocation: gHIDDevicesConfig
   30b18:	ffff2097          	auipc	ra,0xffff2
   30b1c:	908080e7          	jalr	-1784(ra) # 22420 <MIniConfig::beginGroup(MString const&)@plt>
   30b20:	77fd                	lui	a5,0xfffff
   30b22:	080b0593          	addi	a1,s6,128
   30b26:	95be                	add	a1,a1,a5
   30b28:	01010693          	addi	a3,sp,16
   30b2c:	00d58733          	add	a4,a1,a3
   30b30:	fc072503          	lw	a0,-64(a4)
   30b34:	fc870793          	addi	a5,a4,-56
   30b38:	00f50663          	beq	a0,a5,30b44 <iap2_dev_recv_data@@Base+0x72c>
   30b3c:	ffff0097          	auipc	ra,0xffff0
   30b40:	cd4080e7          	jalr	-812(ra) # 20810 <operator delete(void*)@plt>
   30b44:	747d                	lui	s0,0xfffff
   30b46:	6b85                	lui	s7,0x1
   30b48:	fc040913          	addi	s2,s0,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffece6cc>
   30b4c:	080b8593          	addi	a1,s7,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30b50:	0810                	addi	a2,sp,16
   30b52:	95ca                	add	a1,a1,s2
   30b54:	00c58933          	add	s2,a1,a2
   30b58:	00090513          	mv	a0,s2
   30b5c:	000d6597          	auipc	a1,0xd6
   30b60:	13c58593          	addi	a1,a1,316 # 106c98 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1838> ; DATA 'report'
   30b64:	ffff1097          	auipc	ra,0xffff1
   30b68:	09c080e7          	jalr	156(ra) # 21c00 <MString::MString(char const*)@plt>
   30b6c:	080b8613          	addi	a2,s7,128
   30b70:	9622                	add	a2,a2,s0
   30b72:	080c                	addi	a1,sp,16
   30b74:	00b60433          	add	s0,a2,a1
   30b78:	000d7697          	auipc	a3,0xd7
   30b7c:	6f468693          	addi	a3,a3,1780 # 10826c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2e0c>
   30b80:	00090613          	mv	a2,s2
   30b84:	000fe597          	auipc	a1,0xfe
   30b88:	6945a583          	lw	a1,1684(a1) # 12f218 <gHIDDevicesConfig@@Base-0xb70> ; DATA ELF relocation: gHIDDevicesConfig
   30b8c:	fa840513          	addi	a0,s0,-88
   30b90:	ffff1097          	auipc	ra,0xffff1
   30b94:	e40080e7          	jalr	-448(ra) # 219d0 <MIniConfig::value(MString const&, char const*)@plt>
   30b98:	fc042503          	lw	a0,-64(s0)
   30b9c:	fc840793          	addi	a5,s0,-56
   30ba0:	00f50663          	beq	a0,a5,30bac <iap2_dev_recv_data@@Base+0x794>
   30ba4:	ffff0097          	auipc	ra,0xffff0
   30ba8:	c6c080e7          	jalr	-916(ra) # 20810 <operator delete(void*)@plt>
   30bac:	000fe517          	auipc	a0,0xfe
   30bb0:	66c52503          	lw	a0,1644(a0) # 12f218 <gHIDDevicesConfig@@Base-0xb70> ; DATA ELF relocation: gHIDDevicesConfig
   30bb4:	ffff0097          	auipc	ra,0xffff0
   30bb8:	2dc080e7          	jalr	732(ra) # 20e90 <MIniConfig::endGroup()@plt>
   30bbc:	0ac4a783          	lw	a5,172(s1)
   30bc0:	cfa5                	beqz	a5,30c38 <iap2_dev_recv_data@@Base+0x820>
   30bc2:	6405                	lui	s0,0x1
   30bc4:	75fd                	lui	a1,0xfffff
   30bc6:	08040693          	addi	a3,s0,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30bca:	0810                	addi	a2,sp,16
   30bcc:	00b686b3          	add	a3,a3,a1
   30bd0:	00c685b3          	add	a1,a3,a2
   30bd4:	fa65d603          	lhu	a2,-90(a1) # ffffefa6 <AOAProxy::sReaderBuffer@@Base+0xffece6b2>
   30bd8:	fc058513          	addi	a0,a1,-64
   30bdc:	ffff1097          	auipc	ra,0xffff1
   30be0:	004080e7          	jalr	4(ra) # 21be0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   30be4:	77fd                	lui	a5,0xfffff
   30be6:	08040593          	addi	a1,s0,128
   30bea:	95be                	add	a1,a1,a5
   30bec:	01010693          	addi	a3,sp,16
   30bf0:	00d587b3          	add	a5,a1,a3
   30bf4:	fac7a603          	lw	a2,-84(a5) # ffffefac <AOAProxy::sReaderBuffer@@Base+0xffece6b8>
   30bf8:	fc47a703          	lw	a4,-60(a5)
   30bfc:	fc07a403          	lw	s0,-64(a5)
   30c00:	48e60663          	beq	a2,a4,3108c <iap2_dev_recv_data@@Base+0xc74>
   30c04:	6585                	lui	a1,0x1
   30c06:	77fd                	lui	a5,0xfffff
   30c08:	08058693          	addi	a3,a1,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30c0c:	96be                	add	a3,a3,a5
   30c0e:	0810                	addi	a2,sp,16
   30c10:	00c687b3          	add	a5,a3,a2
   30c14:	fc878793          	addi	a5,a5,-56 # ffffefc8 <AOAProxy::sReaderBuffer@@Base+0xffece6d4>
   30c18:	00f40863          	beq	s0,a5,30c28 <iap2_dev_recv_data@@Base+0x810>
   30c1c:	00040513          	mv	a0,s0
   30c20:	ffff0097          	auipc	ra,0xffff0
   30c24:	bf0080e7          	jalr	-1040(ra) # 20810 <operator delete(void*)@plt>
   30c28:	0ac4a503          	lw	a0,172(s1)
   30c2c:	00050663          	beqz	a0,30c38 <iap2_dev_recv_data@@Base+0x820>
   30c30:	ffff1097          	auipc	ra,0xffff1
   30c34:	eb0080e7          	jalr	-336(ra) # 21ae0 <CFRelease@plt>
   30c38:	6405                	lui	s0,0x1
   30c3a:	787d                	lui	a6,0xfffff
   30c3c:	08040613          	addi	a2,s0,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30c40:	9642                	add	a2,a2,a6
   30c42:	080c                	addi	a1,sp,16
   30c44:	00b60833          	add	a6,a2,a1
   30c48:	fa085503          	lhu	a0,-96(a6) # ffffefa0 <AOAProxy::sReaderBuffer@@Base+0xffece6ac>
   30c4c:	65c1                	lui	a1,0x10
   30c4e:	fa685883          	lhu	a7,-90(a6)
   30c52:	f9f84783          	lbu	a5,-97(a6)
   30c56:	fa485703          	lhu	a4,-92(a6)
   30c5a:	fa285683          	lhu	a3,-94(a6)
   30c5e:	faa58593          	addi	a1,a1,-86 # ffaa <CFArrayCreateCopy@plt-0xf826>
   30c62:	95aa                	add	a1,a1,a0
   30c64:	000d6317          	auipc	t1,0xd6
   30c68:	4e830313          	addi	t1,t1,1256 # 10714c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1cec>
   30c6c:	0a04a623          	sw	zero,172(s1)
   30c70:	000d7617          	auipc	a2,0xd7
   30c74:	5fc60613          	addi	a2,a2,1532 # 10826c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2e0c>
   30c78:	0ac48513          	addi	a0,s1,172
   30c7c:	00612023          	sw	t1,0(sp)
   30c80:	ffff1097          	auipc	ra,0xffff1
   30c84:	640080e7          	jalr	1600(ra) # 222c0 <AirPlayInfoArrayAddHIDDevice@plt>
   30c88:	77fd                	lui	a5,0xfffff
   30c8a:	08040593          	addi	a1,s0,128
   30c8e:	95be                	add	a1,a1,a5
   30c90:	01010613          	addi	a2,sp,16
   30c94:	00c587b3          	add	a5,a1,a2
   30c98:	fa67d803          	lhu	a6,-90(a5) # ffffefa6 <AOAProxy::sReaderBuffer@@Base+0xffece6b2>
   30c9c:	f9f7c703          	lbu	a4,-97(a5)
   30ca0:	fa47d683          	lhu	a3,-92(a5)
   30ca4:	fa27d603          	lhu	a2,-94(a5)
   30ca8:	fa07d583          	lhu	a1,-96(a5)
   30cac:	0bc4a503          	lw	a0,188(s1)
   30cb0:	a00ff0ef          	jal	2feb0 <_HandleProxyEventConnectionClose@@Base+0x560c>
   30cb4:	6605                	lui	a2,0x1
   30cb6:	77fd                	lui	a5,0xfffff
   30cb8:	08060593          	addi	a1,a2,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30cbc:	95be                	add	a1,a1,a5
   30cbe:	0814                	addi	a3,sp,16
   30cc0:	00d58733          	add	a4,a1,a3
   30cc4:	fa872503          	lw	a0,-88(a4)
   30cc8:	fb070793          	addi	a5,a4,-80
   30ccc:	f6f50e63          	beq	a0,a5,30448 <iap2_dev_recv_data@@Base+0x30>
   30cd0:	ffff0097          	auipc	ra,0xffff0
   30cd4:	b40080e7          	jalr	-1216(ra) # 20810 <operator delete(void*)@plt>
   30cd8:	f70ff06f          	j	30448 <iap2_dev_recv_data@@Base+0x30>
   30cdc:	6711                	lui	a4,0x4
   30cde:	30170713          	addi	a4,a4,769 # 4301 <CFArrayCreateCopy@plt-0x1b4cf>
   30ce2:	10e40f63          	beq	s0,a4,30e00 <iap2_dev_recv_data@@Base+0x9e8>
   30ce6:	9e8773e3          	bgeu	a4,s0,306cc <iap2_dev_recv_data@@Base+0x2b4>
   30cea:	e0378793          	addi	a5,a5,-509 # ffffee03 <AOAProxy::sReaderBuffer@@Base+0xffece50f>
   30cee:	b6f419e3          	bne	s0,a5,30860 <iap2_dev_recv_data@@Base+0x448>
   30cf2:	07e4d603          	lhu	a2,126(s1)
   30cf6:	85ca                	mv	a1,s2
   30cf8:	000a8513          	mv	a0,s5
   30cfc:	1e0230ef          	jal	53edc <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x2368>
   30d00:	00100513          	li	a0,1
   30d04:	f48ff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   30d08:	0b04a503          	lw	a0,176(s1)
   30d0c:	000b0593          	mv	a1,s6
   30d10:	fffef097          	auipc	ra,0xfffef
   30d14:	fe0080e7          	jalr	-32(ra) # 1fcf0 <realloc@plt>
   30d18:	0aa4a823          	sw	a0,176(s1)
   30d1c:	3c050a63          	beqz	a0,310f0 <iap2_dev_recv_data@@Base+0xcd8>
   30d20:	8652                	mv	a2,s4
   30d22:	85ce                	mv	a1,s3
   30d24:	0a849c23          	sh	s0,184(s1)
   30d28:	0b649b23          	sh	s6,182(s1)
   30d2c:	ffff1097          	auipc	ra,0xffff1
   30d30:	574080e7          	jalr	1396(ra) # 222a0 <memcpy@plt>
   30d34:	875a                	mv	a4,s6
   30d36:	86d2                	mv	a3,s4
   30d38:	00040613          	mv	a2,s0
   30d3c:	000d6597          	auipc	a1,0xd6
   30d40:	f6458593          	addi	a1,a1,-156 # 106ca0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1840> ; DATA 'recv buffer msg id = %04x datalen=%d msglen=%d\n'
   30d44:	000d5517          	auipc	a0,0xd5
   30d48:	73050513          	addi	a0,a0,1840 # 106474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1014> ; DATA 'ProxyIAP2'
   30d4c:	0b449a23          	sh	s4,180(s1)
   30d50:	ffff1097          	auipc	ra,0xffff1
   30d54:	fb0080e7          	jalr	-80(ra) # 21d00 <MLOGD@plt>
   30d58:	00100513          	li	a0,1
   30d5c:	ef0ff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   30d60:	85ca                	mv	a1,s2
   30d62:	8556                	mv	a0,s5
   30d64:	6f0210ef          	jal	52454 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x8e0>
   30d68:	00100513          	li	a0,1
   30d6c:	ee0ff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   30d70:	09e4c783          	lbu	a5,158(s1)
   30d74:	22079e63          	bnez	a5,30fb0 <iap2_dev_recv_data@@Base+0xb98>
   30d78:	0c44a783          	lw	a5,196(s1)
   30d7c:	c791                	beqz	a5,30d88 <iap2_dev_recv_data@@Base+0x970>
   30d7e:	0c84a503          	lw	a0,200(s1)
   30d82:	45a9                	li	a1,10
   30d84:	000780e7          	jalr	a5
   30d88:	4605                	li	a2,1
   30d8a:	85ca                	mv	a1,s2
   30d8c:	000a8513          	mv	a0,s5
   30d90:	01c210ef          	jal	51dac <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x238>
   30d94:	0764c783          	lbu	a5,118(s1)
   30d98:	3227d85b          	.insn	4, 0x3227d85b
   30d9c:	0744c583          	lbu	a1,116(s1)
   30da0:	000a8513          	mv	a0,s5
   30da4:	088210ef          	jal	51e2c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x2b8>
   30da8:	0c44a783          	lw	a5,196(s1)
   30dac:	e8078e63          	beqz	a5,30448 <iap2_dev_recv_data@@Base+0x30>
   30db0:	0c84a503          	lw	a0,200(s1)
   30db4:	45ad                	li	a1,11
   30db6:	9782                	jalr	a5
   30db8:	00100513          	li	a0,1
   30dbc:	e90ff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   30dc0:	0a04a503          	lw	a0,160(s1)
   30dc4:	00050a63          	beqz	a0,30dd8 <iap2_dev_recv_data@@Base+0x9c0>
   30dc8:	ffff0097          	auipc	ra,0xffff0
   30dcc:	0e8080e7          	jalr	232(ra) # 20eb0 <free@plt>
   30dd0:	0a04a023          	sw	zero,160(s1)
   30dd4:	0a04a223          	sw	zero,164(s1)
   30dd8:	00098513          	mv	a0,s3
   30ddc:	0a448613          	addi	a2,s1,164
   30de0:	0a048593          	addi	a1,s1,160
   30de4:	6c4230ef          	jal	544a8 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x2934>
   30de8:	00100513          	li	a0,1
   30dec:	e60ff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   30df0:	85ca                	mv	a1,s2
   30df2:	8556                	mv	a0,s5
   30df4:	185210ef          	jal	52778 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0xc04>
   30df8:	00100513          	li	a0,1
   30dfc:	e50ff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   30e00:	6a85                	lui	s5,0x1
   30e02:	080a8593          	addi	a1,s5,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30e06:	95da                	add	a1,a1,s6
   30e08:	0810                	addi	a2,sp,16
   30e0a:	00c58433          	add	s0,a1,a2
   30e0e:	00440513          	addi	a0,s0,4
   30e12:	07c00613          	li	a2,124
   30e16:	4581                	li	a1,0
   30e18:	fc042023          	sw	zero,-64(s0)
   30e1c:	fc042223          	sw	zero,-60(s0)
   30e20:	fc042423          	sw	zero,-56(s0)
   30e24:	fc042623          	sw	zero,-52(s0)
   30e28:	fc042823          	sw	zero,-48(s0)
   30e2c:	fc042a23          	sw	zero,-44(s0)
   30e30:	fc042c23          	sw	zero,-40(s0)
   30e34:	fc042e23          	sw	zero,-36(s0)
   30e38:	fe042023          	sw	zero,-32(s0)
   30e3c:	fe042223          	sw	zero,-28(s0)
   30e40:	fe042423          	sw	zero,-24(s0)
   30e44:	fe042623          	sw	zero,-20(s0)
   30e48:	fe042823          	sw	zero,-16(s0)
   30e4c:	fe042a23          	sw	zero,-12(s0)
   30e50:	fe042c23          	sw	zero,-8(s0)
   30e54:	fe042e23          	sw	zero,-4(s0)
   30e58:	00042023          	sw	zero,0(s0)
   30e5c:	ffff1097          	auipc	ra,0xffff1
   30e60:	1b4080e7          	jalr	436(ra) # 22010 <memset@plt>
   30e64:	fc0b0493          	addi	s1,s6,-64
   30e68:	080a8593          	addi	a1,s5,128
   30e6c:	95a6                	add	a1,a1,s1
   30e6e:	0814                	addi	a3,sp,16
   30e70:	00d584b3          	add	s1,a1,a3
   30e74:	080a8613          	addi	a2,s5,128
   30e78:	fa8b0693          	addi	a3,s6,-88
   30e7c:	9636                	add	a2,a2,a3
   30e7e:	0814                	addi	a3,sp,16
   30e80:	96b2                	add	a3,a3,a2
   30e82:	85d2                	mv	a1,s4
   30e84:	8626                	mv	a2,s1
   30e86:	854e                	mv	a0,s3
   30e88:	00040713          	mv	a4,s0
   30e8c:	fa042423          	sw	zero,-88(s0)
   30e90:	060240ef          	jal	54ef0 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x337c>
   30e94:	fa842683          	lw	a3,-88(s0)
   30e98:	8626                	mv	a2,s1
   30e9a:	8722                	mv	a4,s0
   30e9c:	000d6597          	auipc	a1,0xd6
   30ea0:	f1c58593          	addi	a1,a1,-228 # 106db8 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1958> ; DATA 'recv carplay start session ip:%s port:%d pi:%s\n'
   30ea4:	000d5517          	auipc	a0,0xd5
   30ea8:	5d050513          	addi	a0,a0,1488 # 106474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1014> ; DATA 'ProxyIAP2'
   30eac:	ffff1097          	auipc	ra,0xffff1
   30eb0:	e54080e7          	jalr	-428(ra) # 21d00 <MLOGD@plt>
   30eb4:	fa842603          	lw	a2,-88(s0)
   30eb8:	d9767863          	bgeu	a2,s7,30448 <iap2_dev_recv_data@@Base+0x30>
   30ebc:	4701                	li	a4,0
   30ebe:	86a2                	mv	a3,s0
   30ec0:	85a6                	mv	a1,s1
   30ec2:	4509                	li	a0,2
   30ec4:	facf50ef          	jal	26670 <_IAP2LinkStatusChangeCallBack@@Base+0x844>
   30ec8:	d80ff06f          	j	30448 <iap2_dev_recv_data@@Base+0x30>
   30ecc:	6b05                	lui	s6,0x1
   30ece:	74fd                	lui	s1,0xfffff
   30ed0:	080b0593          	addi	a1,s6,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   30ed4:	95a6                	add	a1,a1,s1
   30ed6:	0810                	addi	a2,sp,16
   30ed8:	00c58433          	add	s0,a1,a2
   30edc:	6605                	lui	a2,0x1
   30ede:	1671                	addi	a2,a2,-4 # ffc <CFArrayCreateCopy@plt-0x1e7d4>
   30ee0:	00000593          	li	a1,0
   30ee4:	00440513          	addi	a0,s0,4
   30ee8:	fa041423          	sh	zero,-88(s0)
   30eec:	00042023          	sw	zero,0(s0)
   30ef0:	ffff1097          	auipc	ra,0xffff1
   30ef4:	120080e7          	jalr	288(ra) # 22010 <memset@plt>
   30ef8:	fc048693          	addi	a3,s1,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffece6cc>
   30efc:	fa848593          	addi	a1,s1,-88
   30f00:	080b0613          	addi	a2,s6,128
   30f04:	080b0713          	addi	a4,s6,128
   30f08:	972e                	add	a4,a4,a1
   30f0a:	9636                	add	a2,a2,a3
   30f0c:	080c                	addi	a1,sp,16
   30f0e:	0814                	addi	a3,sp,16
   30f10:	96b2                	add	a3,a3,a2
   30f12:	95ba                	add	a1,a1,a4
   30f14:	8622                	mv	a2,s0
   30f16:	854e                	mv	a0,s3
   30f18:	000fe917          	auipc	s2,0xfe
   30f1c:	24492903          	lw	s2,580(s2) # 12f15c <gProxyDelegate@@Base-0x428> ; DATA ELF relocation: gProxyDelegate
   30f20:	fc041023          	sh	zero,-64(s0)
   30f24:	5fd230ef          	jal	54d20 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x31ac>
   30f28:	00492783          	lw	a5,4(s2)
   30f2c:	9782                	jalr	a5
   30f2e:	84aa                	mv	s1,a0
   30f30:	d0050c63          	beqz	a0,30448 <iap2_dev_recv_data@@Base+0x30>
   30f34:	fc045683          	lhu	a3,-64(s0)
   30f38:	12069c63          	bnez	a3,31070 <iap2_dev_recv_data@@Base+0xc58>
   30f3c:	00892783          	lw	a5,8(s2)
   30f40:	8526                	mv	a0,s1
   30f42:	9782                	jalr	a5
   30f44:	d04ff06f          	j	30448 <iap2_dev_recv_data@@Base+0x30>
   30f48:	000fe417          	auipc	s0,0xfe
   30f4c:	20842403          	lw	s0,520(s0) # 12f150 <gOverCarplayLink@@Base-0xca0> ; DATA ELF relocation: gOverCarplayLink
   30f50:	00042783          	lw	a5,0(s0)
   30f54:	ce078a63          	beqz	a5,30448 <iap2_dev_recv_data@@Base+0x30>
   30f58:	cd0d948b          	.insn	4, 0xcd0d948b
   30f5c:	0004c503          	lbu	a0,0(s1)
   30f60:	0ff00793          	li	a5,255
   30f64:	02f50063          	beq	a0,a5,30f84 <iap2_dev_recv_data@@Base+0xb6c>
   30f68:	0015545b          	.insn	4, 0x0015545b
   30f6c:	cdcff06f          	j	30448 <iap2_dev_recv_data@@Base+0x30>
   30f70:	000fe797          	auipc	a5,0xfe
   30f74:	10c7a783          	lw	a5,268(a5) # 12f07c <gOverCarPlayCtrlSession@@Base-0xd71> ; DATA ELF relocation: gOverCarPlayCtrlSession
   30f78:	0007c683          	lbu	a3,0(a5)
   30f7c:	00042503          	lw	a0,0(s0)
   30f80:	f04ff06f          	j	30684 <iap2_dev_recv_data@@Base+0x26c>
   30f84:	000d6517          	auipc	a0,0xd6
   30f88:	db450513          	addi	a0,a0,-588 # 106d38 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa18d8> ; DATA 'PROXY_ENABLE_GPS_SYNC'
   30f8c:	fffef097          	auipc	ra,0xfffef
   30f90:	bc4080e7          	jalr	-1084(ra) # 1fb50 <getenv@plt>
   30f94:	14050463          	beqz	a0,310dc <iap2_dev_recv_data@@Base+0xcc4>
   30f98:	4629                	li	a2,10
   30f9a:	4581                	li	a1,0
   30f9c:	ffff1097          	auipc	ra,0xffff1
   30fa0:	cf4080e7          	jalr	-780(ra) # 21c90 <strtol@plt>
   30fa4:	00a03533          	snez	a0,a0
   30fa8:	00a48023          	sb	a0,0(s1)
   30fac:	fbdff06f          	j	30f68 <iap2_dev_recv_data@@Base+0xb50>
   30fb0:	0904a503          	lw	a0,144(s1)
   30fb4:	00050663          	beqz	a0,30fc0 <iap2_dev_recv_data@@Base+0xba8>
   30fb8:	ffff0097          	auipc	ra,0xffff0
   30fbc:	ef8080e7          	jalr	-264(ra) # 20eb0 <free@plt>
   30fc0:	0029d783          	lhu	a5,2(s3)
   30fc4:	3c87a75b          	.insn	4, 0x3c87a75b
   30fc8:	20f7a45b          	.insn	4, 0x20f7a45b
   30fcc:	8c59                	or	s0,s0,a4
   30fce:	1459                	addi	s0,s0,-10
   30fd0:	00040513          	mv	a0,s0
   30fd4:	0884aa23          	sw	s0,148(s1)
   30fd8:	ffff1097          	auipc	ra,0xffff1
   30fdc:	ba8080e7          	jalr	-1112(ra) # 21b80 <malloc@plt>
   30fe0:	08a4a823          	sw	a0,144(s1)
   30fe4:	10050263          	beqz	a0,310e8 <iap2_dev_recv_data@@Base+0xcd0>
   30fe8:	00040613          	mv	a2,s0
   30fec:	00a98593          	addi	a1,s3,10
   30ff0:	ffff1097          	auipc	ra,0xffff1
   30ff4:	2b0080e7          	jalr	688(ra) # 222a0 <memcpy@plt>
   30ff8:	00100513          	li	a0,1
   30ffc:	08048f23          	sb	zero,158(s1)
   31000:	c4cff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   31004:	0684d583          	lhu	a1,104(s1)
   31008:	0644a503          	lw	a0,100(s1)
   3100c:	4f4220ef          	jal	53500 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x198c>
   31010:	85ca                	mv	a1,s2
   31012:	862a                	mv	a2,a0
   31014:	000a8513          	mv	a0,s5
   31018:	510220ef          	jal	53528 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x19b4>
   3101c:	805ff06f          	j	30820 <iap2_dev_recv_data@@Base+0x408>
   31020:	0844d683          	lhu	a3,132(s1)
   31024:	000d7617          	auipc	a2,0xd7
   31028:	24860613          	addi	a2,a2,584 # 10826c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2e0c>
   3102c:	000d6597          	auipc	a1,0xd6
   31030:	d7058593          	addi	a1,a1,-656 # 106d9c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa193c> ; DATA 'recv loc info:%s len:%d\n'
   31034:	000d5517          	auipc	a0,0xd5
   31038:	44050513          	addi	a0,a0,1088 # 106474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1014> ; DATA 'ProxyIAP2'
   3103c:	ffff1097          	auipc	ra,0xffff1
   31040:	cc4080e7          	jalr	-828(ra) # 21d00 <MLOGD@plt>
   31044:	f94ff06f          	j	307d8 <iap2_dev_recv_data@@Base+0x3c0>
   31048:	fc045683          	lhu	a3,-64(s0)
   3104c:	000d4617          	auipc	a2,0xd4
   31050:	17060613          	addi	a2,a2,368 # 1051bc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9fd5c> ; DATA 'null'
   31054:	000d6597          	auipc	a1,0xd6
   31058:	d2458593          	addi	a1,a1,-732 # 106d78 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1918> ; DATA 'recv mfi serial number:%s len:%d\n'
   3105c:	000d5517          	auipc	a0,0xd5
   31060:	41850513          	addi	a0,a0,1048 # 106474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1014> ; DATA 'ProxyIAP2'
   31064:	ffff1097          	auipc	ra,0xffff1
   31068:	c9c080e7          	jalr	-868(ra) # 21d00 <MLOGD@plt>
   3106c:	975ff06f          	j	309e0 <iap2_dev_recv_data@@Base+0x5c8>
   31070:	fa845583          	lhu	a1,-88(s0)
   31074:	67c1                	lui	a5,0x10
   31076:	faa78793          	addi	a5,a5,-86 # ffaa <CFArrayCreateCopy@plt-0xf826>
   3107a:	8622                	mv	a2,s0
   3107c:	00f585b3          	add	a1,a1,a5
   31080:	ffff0097          	auipc	ra,0xffff0
   31084:	1a0080e7          	jalr	416(ra) # 21220 <AirPlayReceiverSessionSendHIDReport@plt>
   31088:	eb5ff06f          	j	30f3c <iap2_dev_recv_data@@Base+0xb24>
   3108c:	ca11                	beqz	a2,310a0 <iap2_dev_recv_data@@Base+0xc88>
   3108e:	fa87a503          	lw	a0,-88(a5)
   31092:	85a2                	mv	a1,s0
   31094:	fffef097          	auipc	ra,0xfffef
   31098:	80c080e7          	jalr	-2036(ra) # 1f8a0 <memcmp@plt>
   3109c:	b60514e3          	bnez	a0,30c04 <iap2_dev_recv_data@@Base+0x7ec>
   310a0:	6605                	lui	a2,0x1
   310a2:	77fd                	lui	a5,0xfffff
   310a4:	08060593          	addi	a1,a2,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   310a8:	95be                	add	a1,a1,a5
   310aa:	0810                	addi	a2,sp,16
   310ac:	00c587b3          	add	a5,a1,a2
   310b0:	fc878793          	addi	a5,a5,-56 # ffffefc8 <AOAProxy::sReaderBuffer@@Base+0xffece6d4>
   310b4:	c0f400e3          	beq	s0,a5,30cb4 <iap2_dev_recv_data@@Base+0x89c>
   310b8:	00040513          	mv	a0,s0
   310bc:	fffef097          	auipc	ra,0xfffef
   310c0:	754080e7          	jalr	1876(ra) # 20810 <operator delete(void*)@plt>
   310c4:	bf1ff06f          	j	30cb4 <iap2_dev_recv_data@@Base+0x89c>
   310c8:	58b4                	lw	a3,112(s1)
   310ca:	54f0                	lw	a2,108(s1)
   310cc:	8556                	mv	a0,s5
   310ce:	85ca                	mv	a1,s2
   310d0:	7b1230ef          	jal	55080 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x350c>
   310d4:	00100513          	li	a0,1
   310d8:	b74ff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   310dc:	cc0db80b          	.insn	4, 0xcc0db80b
   310e0:	00100513          	li	a0,1
   310e4:	b68ff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   310e8:	0804aa23          	sw	zero,148(s1)
   310ec:	f0dff06f          	j	30ff8 <iap2_dev_recv_data@@Base+0xbe0>
   310f0:	00000513          	li	a0,0
   310f4:	b58ff06f          	j	3044c <iap2_dev_recv_data@@Base+0x34>
   310f8:	6685                	lui	a3,0x1
   310fa:	77fd                	lui	a5,0xfffff
   310fc:	08068593          	addi	a1,a3,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   31100:	95be                	add	a1,a1,a5
   31102:	0810                	addi	a2,sp,16
   31104:	00c58733          	add	a4,a1,a2
   31108:	87ba                	mv	a5,a4
   3110a:	fc072703          	lw	a4,-64(a4)
   3110e:	fc878793          	addi	a5,a5,-56 # ffffefc8 <AOAProxy::sReaderBuffer@@Base+0xffece6d4>
   31112:	842a                	mv	s0,a0
   31114:	00f70863          	beq	a4,a5,31124 <iap2_dev_recv_data@@Base+0xd0c>
   31118:	00070513          	mv	a0,a4
   3111c:	fffef097          	auipc	ra,0xfffef
   31120:	6f4080e7          	jalr	1780(ra) # 20810 <operator delete(void*)@plt>
   31124:	00040513          	mv	a0,s0
   31128:	ffff0097          	auipc	ra,0xffff0
   3112c:	be8080e7          	jalr	-1048(ra) # 20d10 <_Unwind_Resume@plt>
   31130:	6685                	lui	a3,0x1
   31132:	77fd                	lui	a5,0xfffff
   31134:	08068613          	addi	a2,a3,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   31138:	963e                	add	a2,a2,a5
   3113a:	080c                	addi	a1,sp,16
   3113c:	00b60733          	add	a4,a2,a1
   31140:	87ba                	mv	a5,a4
   31142:	fa872703          	lw	a4,-88(a4)
   31146:	fb078793          	addi	a5,a5,-80 # ffffefb0 <AOAProxy::sReaderBuffer@@Base+0xffece6bc>
   3114a:	842a                	mv	s0,a0
   3114c:	fcf716e3          	bne	a4,a5,31118 <iap2_dev_recv_data@@Base+0xd00>
   31150:	fd5ff06f          	j	31124 <iap2_dev_recv_data@@Base+0xd0c>
   31154:	6605                	lui	a2,0x1
   31156:	77fd                	lui	a5,0xfffff
   31158:	08060693          	addi	a3,a2,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   3115c:	96be                	add	a3,a3,a5
   3115e:	080c                	addi	a1,sp,16
   31160:	00b687b3          	add	a5,a3,a1
   31164:	4398                	lw	a4,0(a5)
   31166:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffece714>
   31168:	842a                	mv	s0,a0
   3116a:	faf717e3          	bne	a4,a5,31118 <iap2_dev_recv_data@@Base+0xd00>
   3116e:	bf5d                	j	31124 <iap2_dev_recv_data@@Base+0xd0c>
   31170:	6685                	lui	a3,0x1
   31172:	77fd                	lui	a5,0xfffff
   31174:	08068613          	addi	a2,a3,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   31178:	963e                	add	a2,a2,a5
   3117a:	080c                	addi	a1,sp,16
   3117c:	00b607b3          	add	a5,a2,a1
   31180:	4398                	lw	a4,0(a5)
   31182:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffece714>
   31184:	842a                	mv	s0,a0
   31186:	f8f719e3          	bne	a4,a5,31118 <iap2_dev_recv_data@@Base+0xd00>
   3118a:	bf69                	j	31124 <iap2_dev_recv_data@@Base+0xd0c>
   3118c:	6585                	lui	a1,0x1
   3118e:	77fd                	lui	a5,0xfffff
   31190:	08058693          	addi	a3,a1,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   31194:	96be                	add	a3,a3,a5
   31196:	0810                	addi	a2,sp,16
   31198:	00c68733          	add	a4,a3,a2
   3119c:	f6dff06f          	j	31108 <iap2_dev_recv_data@@Base+0xcf0>
   311a0:	6605                	lui	a2,0x1
   311a2:	77fd                	lui	a5,0xfffff
   311a4:	08060593          	addi	a1,a2,128 # 1080 <CFArrayCreateCopy@plt-0x1e750>
   311a8:	95be                	add	a1,a1,a5
   311aa:	0814                	addi	a3,sp,16
   311ac:	00d58733          	add	a4,a1,a3
   311b0:	f59ff06f          	j	31108 <iap2_dev_recv_data@@Base+0xcf0>
