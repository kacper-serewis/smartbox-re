
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

000393f4 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2ecc>:
   393f4:	000cf517          	auipc	a0,0xcf
   393f8:	1c850513          	addi	a0,a0,456 # 1085bc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa315c> ; DATA 'PROXY_AP_USE_WIFI4'
   393fc:	fffe6097          	auipc	ra,0xfffe6
   39400:	754080e7          	jalr	1876(ra) # 1fb50 <getenv@plt>
   39404:	892a                	mv	s2,a0
   39406:	c909                	beqz	a0,39418 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2ef0>
   39408:	4629                	li	a2,10
   3940a:	4581                	li	a1,0
   3940c:	fffe9097          	auipc	ra,0xfffe9
   39410:	884080e7          	jalr	-1916(ra) # 21c90 <strtol@plt>
   39414:	1e051063          	bnez	a0,395f4 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x30cc>
   39418:	000ce517          	auipc	a0,0xce
   3941c:	00050513          	mv	a0,a0
   39420:	fffe6097          	auipc	ra,0xfffe6
   39424:	730080e7          	jalr	1840(ra) # 1fb50 <getenv@plt>
   39428:	cd01                	beqz	a0,39440 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2f18>
   3942a:	4629                	li	a2,10
   3942c:	00000593          	li	a1,0
   39430:	fffe9097          	auipc	ra,0xfffe9
   39434:	860080e7          	jalr	-1952(ra) # 21c90 <strtol@plt>
   39438:	013507b7          	lui	a5,0x1350
   3943c:	0ea7c663          	blt	a5,a0,39528 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x3000>
   39440:	6789                	lui	a5,0x2
   39442:	97a6                	add	a5,a5,s1
   39444:	3bc7c503          	lbu	a0,956(a5) # 23bc <CFArrayCreateCopy@plt-0x1d414>
   39448:	08050c63          	beqz	a0,394e0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2fb8>
   3944c:	4785                	li	a5,1
   3944e:	4605                	li	a2,1
   39450:	6909                	lui	s2,0x2
   39452:	9926                	add	s2,s2,s1
   39454:	000cf597          	auipc	a1,0xcf
   39458:	17c58593          	addi	a1,a1,380 # 1085d0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa3170> ; DATA 'check license status:%d\n'
   3945c:	000ce517          	auipc	a0,0xce
   39460:	d3850513          	addi	a0,a0,-712 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   39464:	3af90e23          	sb	a5,956(s2) # 23bc <CFArrayCreateCopy@plt-0x1d414>
   39468:	fffe9097          	auipc	ra,0xfffe9
   3946c:	898080e7          	jalr	-1896(ra) # 21d00 <MLOGD@plt>
   39470:	3bc94783          	lbu	a5,956(s2)
   39474:	02078a63          	beqz	a5,394a8 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2f80>
   39478:	00048513          	mv	a0,s1
   3947c:	ab4ff0ef          	jal	38730 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2208>
   39480:	00048513          	mv	a0,s1
   39484:	a38fb0ef          	jal	346bc <CarPlayProxyApp::HWTestThread(void*)@@Base+0x1800>
   39488:	00048513          	mv	a0,s1
   3948c:	de0fd0ef          	jal	36a6c <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x544>
   39490:	50f6                	lw	ra,124(sp)
   39492:	5466                	lw	s0,120(sp)
   39494:	54d6                	lw	s1,116(sp)
   39496:	5946                	lw	s2,112(sp)
   39498:	59b6                	lw	s3,108(sp)
   3949a:	5a26                	lw	s4,104(sp)
   3949c:	5a96                	lw	s5,100(sp)
   3949e:	5b06                	lw	s6,96(sp)
   394a0:	4bf6                	lw	s7,92(sp)
   394a2:	4505                	li	a0,1
   394a4:	6109                	addi	sp,sp,128
   394a6:	8082                	ret
   394a8:	4785                	li	a5,1
   394aa:	4581                	li	a1,0
   394ac:	00040513          	mv	a0,s0
   394b0:	00fa8623          	sb	a5,12(s5)
   394b4:	3a090ea3          	sb	zero,957(s2)
   394b8:	5710f0ef          	jal	49228 <std::vector<MString, std::allocator<MString> >::vector(std::vector<MString, std::allocator<MString> > const&)@@Base+0x1a98>
   394bc:	00048513          	mv	a0,s1
   394c0:	5cd2a0ef          	jal	6428c <AOAProxy::aoaReadThread(void*)@@Base+0xc3c>
   394c4:	00100593          	li	a1,1
   394c8:	7042b0ef          	jal	64bcc <AOAProxy::aoaReadThread(void*)@@Base+0x157c>
   394cc:	00048513          	mv	a0,s1
   394d0:	5bd2a0ef          	jal	6428c <AOAProxy::aoaReadThread(void*)@@Base+0xc3c>
   394d4:	7d000593          	li	a1,2000
   394d8:	7742b0ef          	jal	64c4c <AOAProxy::aoaReadThread(void*)@@Base+0x15fc>
   394dc:	f9dff06f          	j	39478 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2f50>
   394e0:	00048513          	mv	a0,s1
   394e4:	5a92a0ef          	jal	6428c <AOAProxy::aoaReadThread(void*)@@Base+0xc3c>
   394e8:	4cc2b0ef          	jal	649b4 <AOAProxy::aoaReadThread(void*)@@Base+0x1364>
   394ec:	87aa                	mv	a5,a0
   394ee:	862a                	mv	a2,a0
   394f0:	f61ff06f          	j	39450 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2f28>
   394f4:	000f6417          	auipc	s0,0xf6
   394f8:	ad042403          	lw	s0,-1328(s0) # 12efc4 <APChannels@@Base+0xf6c> ; DATA ELF relocation: APChannels
   394fc:	0ca4055b          	.insn	4, 0x0ca4055b
   39500:	00052603          	lw	a2,0(a0)
   39504:	000cf597          	auipc	a1,0xcf
   39508:	05858593          	addi	a1,a1,88 # 10855c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa30fc> ; DATA 'set ap channel:%d'
   3950c:	000ce517          	auipc	a0,0xce
   39510:	c8850513          	addi	a0,a0,-888 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   39514:	fffe8097          	auipc	ra,0xfffe8
   39518:	7ec080e7          	jalr	2028(ra) # 21d00 <MLOGD@plt>
   3951c:	5782                	lw	a5,32(sp)
   3951e:	0cf407db          	.insn	4, 0x0cf407db
   39522:	0007aa03          	lw	s4,0(a5)
   39526:	bd7d                	j	393e4 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2ebc>
   39528:	6909                	lui	s2,0x2
   3952a:	8526                	mv	a0,s1
   3952c:	00990933          	add	s2,s2,s1
   39530:	fbdf90ef          	jal	334ec <CarPlayProxyApp::HWTestThread(void*)@@Base+0x630>
   39534:	3aa90e23          	sb	a0,956(s2) # 23bc <CFArrayCreateCopy@plt-0x1d414>
   39538:	f0051ae3          	bnez	a0,3944c <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2f24>
   3953c:	00048513          	mv	a0,s1
   39540:	eedfe0ef          	jal	3842c <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x1f04>
   39544:	3aa90e23          	sb	a0,956(s2)
   39548:	f01ff06f          	j	39448 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2f20>
   3954c:	000d3597          	auipc	a1,0xd3
   39550:	22058593          	addi	a1,a1,544 # 10c76c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa730c> ; DATA 'in'
   39554:	000b0513          	mv	a0,s6
   39558:	fffe8097          	auipc	ra,0xfffe8
   3955c:	7c8080e7          	jalr	1992(ra) # 21d20 <gpio_set_dir(unsigned int, char const*)@plt>
   39560:	a60518e3          	bnez	a0,38fd0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2aa8>
   39564:	000cf597          	auipc	a1,0xcf
   39568:	ee458593          	addi	a1,a1,-284 # 108448 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2fe8> ; DATA 'both'
   3956c:	000b0513          	mv	a0,s6
   39570:	fffe8097          	auipc	ra,0xfffe8
   39574:	c40080e7          	jalr	-960(ra) # 211b0 <gpio_set_edge(unsigned int, char const*)@plt>
   39578:	a4051ce3          	bnez	a0,38fd0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2aa8>
   3957c:	4581                	li	a1,0
   3957e:	855a                	mv	a0,s6
   39580:	fffe9097          	auipc	ra,0xfffe9
   39584:	8d0080e7          	jalr	-1840(ra) # 21e50 <gpio_fd_open(unsigned int, unsigned int)@plt>
   39588:	54a42c23          	sw	a0,1368(s0)
   3958c:	a53502e3          	beq	a0,s3,38fd0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2aa8>
   39590:	182c                	addi	a1,sp,56
   39592:	4609                	li	a2,2
   39594:	02011c23          	sh	zero,56(sp)
   39598:	fffe9097          	auipc	ra,0xfffe9
   3959c:	aa8080e7          	jalr	-1368(ra) # 22040 <read@plt>
   395a0:	55842503          	lw	a0,1368(s0)
   395a4:	4681                	li	a3,0
   395a6:	4601                	li	a2,0
   395a8:	00000593          	li	a1,0
   395ac:	fffe8097          	auipc	ra,0xfffe8
   395b0:	2e4080e7          	jalr	740(ra) # 21890 <lseek@plt>
   395b4:	55842683          	lw	a3,1368(s0)
   395b8:	000b0613          	mv	a2,s6
   395bc:	000cf597          	auipc	a1,0xcf
   395c0:	e9458593          	addi	a1,a1,-364 # 108450 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2ff0> ; DATA 'open reset gpio:%d fd:%d succussed\n'
   395c4:	000ce517          	auipc	a0,0xce
   395c8:	bd050513          	addi	a0,a0,-1072 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   395cc:	fffe8097          	auipc	ra,0xfffe8
   395d0:	734080e7          	jalr	1844(ra) # 21d00 <MLOGD@plt>
   395d4:	058a0693          	addi	a3,s4,88
   395d8:	55842583          	lw	a1,1368(s0)
   395dc:	80000737          	lui	a4,0x80000
   395e0:	96a6                	add	a3,a3,s1
   395e2:	4615                	li	a2,5
   395e4:	00048513          	mv	a0,s1
   395e8:	fffe9097          	auipc	ra,0xfffe9
   395ec:	ce8080e7          	jalr	-792(ra) # 222d0 <MRunLoop::addIOReadNotify(int, MIOType, MNotify*, int)@plt>
   395f0:	9e1ff06f          	j	38fd0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2aa8>
   395f4:	4629                	li	a2,10
   395f6:	4581                	li	a1,0
   395f8:	00090513          	mv	a0,s2
   395fc:	fffe8097          	auipc	ra,0xfffe8
   39600:	694080e7          	jalr	1684(ra) # 21c90 <strtol@plt>
   39604:	85aa                	mv	a1,a0
   39606:	8522                	mv	a0,s0
   39608:	1f10e0ef          	jal	47ff8 <std::vector<MString, std::allocator<MString> >::vector(std::vector<MString, std::allocator<MString> > const&)@@Base+0x868>
   3960c:	e0dff06f          	j	39418 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2ef0>
   39610:	57a2                	lw	a5,40(sp)
   39612:	c0be                	sw	a5,64(sp)
   39614:	57b2                	lw	a5,44(sp)
   39616:	c2be                	sw	a5,68(sp)
   39618:	57c2                	lw	a5,48(sp)
   3961a:	c4be                	sw	a5,72(sp)
   3961c:	57d2                	lw	a5,52(sp)
   3961e:	c6be                	sw	a5,76(sp)
   39620:	a01ff06f          	j	39020 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2af8>
   39624:	00000613          	li	a2,0
   39628:	000cf597          	auipc	a1,0xcf
   3962c:	e5c58593          	addi	a1,a1,-420 # 108484 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa3024> ; DATA 'wlan0'
   39630:	000cf517          	auipc	a0,0xcf
   39634:	e4450513          	addi	a0,a0,-444 # 108474 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa3014> ; DATA 'carplay_ifname'
   39638:	fffe7097          	auipc	ra,0xfffe7
   3963c:	088080e7          	jalr	136(ra) # 206c0 <setenv@plt>
   39640:	a3dff06f          	j	3907c <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2b54>
   39644:	479d                	li	a5,7
   39646:	d03e                	sw	a5,32(sp)
   39648:	d69ff06f          	j	393b0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2e88>
   3964c:	4785                	li	a5,1
   3964e:	d03e                	sw	a5,32(sp)
   39650:	d61ff06f          	j	393b0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2e88>
   39654:	4789                	li	a5,2
   39656:	d03e                	sw	a5,32(sp)
   39658:	d59ff06f          	j	393b0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2e88>
   3965c:	478d                	li	a5,3
   3965e:	d03e                	sw	a5,32(sp)
   39660:	d51ff06f          	j	393b0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2e88>
   39664:	4791                	li	a5,4
   39666:	d03e                	sw	a5,32(sp)
   39668:	d49ff06f          	j	393b0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2e88>
   3966c:	4795                	li	a5,5
   3966e:	d03e                	sw	a5,32(sp)
   39670:	d41ff06f          	j	393b0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2e88>
   39674:	4799                	li	a5,6
   39676:	d03e                	sw	a5,32(sp)
   39678:	d39ff06f          	j	393b0 <CarPlayProxyApp::proxyMicInputNotify(void*, int)@@Base+0x2e88>
   3967c:	47a1                	li	a5,8
   3967e:	d03e                	sw	a5,32(sp)
