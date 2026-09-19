
firmwares/hw501/126/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00040424 <_WaitConnectTimeoutHandler@@Base>:
   40424:	1141                	addi	sp,sp,-16
   40426:	00195597          	auipc	a1,0x195
   4042a:	eda58593          	addi	a1,a1,-294 # 1d5300 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e73c> ; DATA 'Wait for CarPlay connect to proxy ctrl timeout\n'
   4042e:	00195517          	auipc	a0,0x195
   40432:	c3a50513          	addi	a0,a0,-966 # 1d5068 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e4a4> ; DATA 'ProxyServer'
   40436:	c422                	sw	s0,8(sp)
   40438:	c606                	sw	ra,12(sp)
   4043a:	00219417          	auipc	s0,0x219
   4043e:	87e42403          	lw	s0,-1922(s0) # 258cb8 <gProxyCtrlConnected@@Base-0x2fc> ; DATA ELF relocation: gProxyCtrlConnected
   40442:	c226                	sw	s1,4(sp)
   40444:	ffff8097          	auipc	ra,0xffff8
   40448:	08c080e7          	jalr	140(ra) # 384d0 <MLOGD@plt>
   4044c:	00042783          	lw	a5,0(s0)
   40450:	eb81                	bnez	a5,40460 <_WaitConnectTimeoutHandler@@Base+0x3c>
   40452:	00218797          	auipc	a5,0x218
   40456:	a0a7a783          	lw	a5,-1526(a5) # 257e5c <gHostNameWithInterfaceNdx@@Base-0x111c> ; DATA ELF relocation: gHostNameWithInterfaceNdx
   4045a:	439c                	lw	a5,0(a5)
   4045c:	0e078e63          	beqz	a5,40558 <_WaitConnectTimeoutHandler@@Base+0x134>
   40460:	00218797          	auipc	a5,0x218
   40464:	fc87a783          	lw	a5,-56(a5) # 258428 <gClientReady@@Base-0xb90> ; DATA ELF relocation: gClientReady
   40468:	439c                	lw	a5,0(a5)
   4046a:	c3dd                	beqz	a5,40510 <_WaitConnectTimeoutHandler@@Base+0xec>
   4046c:	401c                	lw	a5,0(s0)
   4046e:	c799                	beqz	a5,4047c <_WaitConnectTimeoutHandler@@Base+0x58>
   40470:	40b2                	lw	ra,12(sp)
   40472:	4422                	lw	s0,8(sp)
   40474:	4492                	lw	s1,4(sp)
   40476:	0141                	addi	sp,sp,16
   40478:	00008067          	ret
   4047c:	815f940b          	.insn	4, 0x815f940b
   40480:	4808                	lw	a0,16(s0)
   40482:	cd09                	beqz	a0,4049c <_WaitConnectTimeoutHandler@@Base+0x78>
   40484:	ffff8097          	auipc	ra,0xffff8
   40488:	bbc080e7          	jalr	-1092(ra) # 38040 <dispatch_source_cancel@plt>
   4048c:	01042503          	lw	a0,16(s0)
   40490:	ffff7097          	auipc	ra,0xffff7
   40494:	830080e7          	jalr	-2000(ra) # 36cc0 <dispatch_release@plt>
   40498:	820fc3ab          	.insn	4, 0x820fc3ab
   4049c:	4408                	lw	a0,8(s0)
   4049e:	cd09                	beqz	a0,404b8 <_WaitConnectTimeoutHandler@@Base+0x94>
   404a0:	ffff8097          	auipc	ra,0xffff8
   404a4:	ba0080e7          	jalr	-1120(ra) # 38040 <dispatch_source_cancel@plt>
   404a8:	00842503          	lw	a0,8(s0)
   404ac:	ffff7097          	auipc	ra,0xffff7
   404b0:	814080e7          	jalr	-2028(ra) # 36cc0 <dispatch_release@plt>
   404b4:	800fcfab          	.insn	4, 0x800fcfab
   404b8:	4048                	lw	a0,4(s0)
   404ba:	c91d                	beqz	a0,404f0 <_WaitConnectTimeoutHandler@@Base+0xcc>
   404bc:	ffff8097          	auipc	ra,0xffff8
   404c0:	7a4080e7          	jalr	1956(ra) # 38c60 <DNSServiceRefDeallocate@plt>
   404c4:	00195697          	auipc	a3,0x195
   404c8:	eb868693          	addi	a3,a3,-328 # 1d537c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e7b8> ; DATA 'timeout'
   404cc:	00195617          	auipc	a2,0x195
   404d0:	ba860613          	addi	a2,a2,-1112 # 1d5074 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e4b0> ; DATA '_carplay-ctrl._tcp'
   404d4:	00195597          	auipc	a1,0x195
   404d8:	eb058593          	addi	a1,a1,-336 # 1d5384 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e7c0> ; DATA 'Deregistered Bonjour %s for %s\n'
   404dc:	00195517          	auipc	a0,0x195
   404e0:	b8c50513          	addi	a0,a0,-1140 # 1d5068 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e4a4> ; DATA 'ProxyServer'
   404e4:	800fcdab          	.insn	4, 0x800fcdab
   404e8:	ffff8097          	auipc	ra,0xffff8
   404ec:	fe8080e7          	jalr	-24(ra) # 384d0 <MLOGD@plt>
   404f0:	4008                	lw	a0,0(s0)
   404f2:	dd3d                	beqz	a0,40470 <_WaitConnectTimeoutHandler@@Base+0x4c>
   404f4:	4422                	lw	s0,8(sp)
   404f6:	40b2                	lw	ra,12(sp)
   404f8:	4492                	lw	s1,4(sp)
   404fa:	00000617          	auipc	a2,0x0
   404fe:	9be60613          	addi	a2,a2,-1602 # 3feb8 <IAP2LinkStatusChangeNotify@@Base+0x2bc>
   40502:	4581                	li	a1,0
   40504:	01010113          	addi	sp,sp,16
   40508:	ffff7317          	auipc	t1,0xffff7
   4050c:	10830067          	jr	264(t1) # 37610 <dispatch_async_f@plt>
   40510:	815f948b          	.insn	4, 0x815f948b
   40514:	4cc8                	lw	a0,28(s1)
   40516:	d939                	beqz	a0,4046c <_WaitConnectTimeoutHandler@@Base+0x48>
   40518:	ffff8097          	auipc	ra,0xffff8
   4051c:	f08080e7          	jalr	-248(ra) # 38420 <BonjourBrowser_Stop@plt>
   40520:	00195517          	auipc	a0,0x195
   40524:	e3450513          	addi	a0,a0,-460 # 1d5354 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e790> ; DATA 'carplay_proxy_ifname'
   40528:	ffff7097          	auipc	ra,0xffff7
   4052c:	1f8080e7          	jalr	504(ra) # 37720 <getenv@plt>
   40530:	86aa                	mv	a3,a0
   40532:	4cc8                	lw	a0,28(s1)
   40534:	00000713          	li	a4,0
   40538:	080007b7          	lui	a5,0x8000
   4053c:	00195617          	auipc	a2,0x195
   40540:	bf460613          	addi	a2,a2,-1036 # 1d5130 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e56c> ; DATA 'local.'
   40544:	00195597          	auipc	a1,0x195
   40548:	e2858593          	addi	a1,a1,-472 # 1d536c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e7a8> ; DATA '_airplay._tcp.'
   4054c:	ffff8097          	auipc	ra,0xffff8
   40550:	784080e7          	jalr	1924(ra) # 38cd0 <BonjourBrowser_Start@plt>
   40554:	f19ff06f          	j	4046c <_WaitConnectTimeoutHandler@@Base+0x48>
   40558:	4422                	lw	s0,8(sp)
   4055a:	40b2                	lw	ra,12(sp)
   4055c:	4492                	lw	s1,4(sp)
   4055e:	00195517          	auipc	a0,0x195
   40562:	dd250513          	addi	a0,a0,-558 # 1d5330 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e76c> ; DATA 'killall -9 mdnsd;sleep 0.1;mdnsd &'
   40566:	0141                	addi	sp,sp,16
   40568:	ffff7317          	auipc	t1,0xffff7
   4056c:	1e830067          	jr	488(t1) # 37750 <system@plt>
