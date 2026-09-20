   4e2ec:	1101                	addi	sp,sp,-32
   4e2ee:	cc22                	sw	s0,24(sp)
   4e2f0:	1390140b          	.insn	4, 0x1390140b
   4e2f4:	4018                	lw	a4,0(s0)
   4e2f6:	405c                	lw	a5,4(s0)
   4e2f8:	000bd617          	auipc	a2,0xbd
   4e2fc:	f7860613          	addi	a2,a2,-136 # 10b270 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5e10> ; DATA '_AirplayClientSendCmdSetupScreen'
   4e300:	000bd597          	auipc	a1,0xbd
   4e304:	e0058593          	addi	a1,a1,-512 # 10b100 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5ca0> ; DATA '%s gScreenConnectionId:%llu\n'
   4e308:	000bd517          	auipc	a0,0xbd
   4e30c:	e1850513          	addi	a0,a0,-488 # 10b120 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5cc0> ; DATA 'ProxyVideo'
   4e310:	ce06                	sw	ra,28(sp)
   4e312:	ca26                	sw	s1,20(sp)
   4e314:	c84a                	sw	s2,16(sp)
   4e316:	c402                	sw	zero,8(sp)
   4e318:	00012623          	sw	zero,12(sp)
   4e31c:	fffd4097          	auipc	ra,0xfffd4
   4e320:	9e4080e7          	jalr	-1564(ra) # 21d00 <MLOGD@plt>
   4e324:	401c                	lw	a5,0(s0)
   4e326:	4058                	lw	a4,4(s0)
   4e328:	8fd9                	or	a5,a5,a4
   4e32a:	c39d                	beqz	a5,4e350 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x368>
   4e32c:	4532                	lw	a0,12(sp)
   4e32e:	c509                	beqz	a0,4e338 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x350>
   4e330:	fffd3097          	auipc	ra,0xfffd3
   4e334:	7b0080e7          	jalr	1968(ra) # 21ae0 <CFRelease@plt>
   4e338:	4522                	lw	a0,8(sp)
   4e33a:	c509                	beqz	a0,4e344 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x35c>
   4e33c:	fffd3097          	auipc	ra,0xfffd3
   4e340:	7a4080e7          	jalr	1956(ra) # 21ae0 <CFRelease@plt>
   4e344:	40f2                	lw	ra,28(sp)
   4e346:	4462                	lw	s0,24(sp)
   4e348:	44d2                	lw	s1,20(sp)
   4e34a:	4942                	lw	s2,16(sp)
   4e34c:	6105                	addi	sp,sp,32
   4e34e:	8082                	ret
   4e350:	934da0ef          	jal	28484 <_AirPlayReceiverSessionChangeModesCompletionFunc@@Base+0x10ac>
   4e354:	000e1697          	auipc	a3,0xe1
   4e358:	e986a683          	lw	a3,-360(a3) # 12f1ec <kCFLDictionaryValueCallBacksCFLTypes@Base> ; DATA ELF relocation: kCFLDictionaryValueCallBacksCFLTypes
   4e35c:	c008                	sw	a0,0(s0)
   4e35e:	c04c                	sw	a1,4(s0)
   4e360:	000e1617          	auipc	a2,0xe1
   4e364:	d9c62603          	lw	a2,-612(a2) # 12f0fc <kCFLDictionaryKeyCallBacksCFLTypes@Base> ; DATA ELF relocation: kCFLDictionaryKeyCallBacksCFLTypes
   4e368:	4581                	li	a1,0
   4e36a:	4501                	li	a0,0
   4e36c:	fffd2097          	auipc	ra,0xfffd2
   4e370:	0c4080e7          	jalr	196(ra) # 20430 <CFDictionaryCreateMutable@plt>
   4e374:	892a                	mv	s2,a0
   4e376:	d95d                	beqz	a0,4e32c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x344>
   4e378:	000e1697          	auipc	a3,0xe1
   4e37c:	e746a683          	lw	a3,-396(a3) # 12f1ec <kCFLDictionaryValueCallBacksCFLTypes@Base> ; DATA ELF relocation: kCFLDictionaryValueCallBacksCFLTypes
   4e380:	000e1617          	auipc	a2,0xe1
   4e384:	d7c62603          	lw	a2,-644(a2) # 12f0fc <kCFLDictionaryKeyCallBacksCFLTypes@Base> ; DATA ELF relocation: kCFLDictionaryKeyCallBacksCFLTypes
   4e388:	4581                	li	a1,0
   4e38a:	4501                	li	a0,0
   4e38c:	fffd2097          	auipc	ra,0xfffd2
   4e390:	0a4080e7          	jalr	164(ra) # 20430 <CFDictionaryCreateMutable@plt>
   4e394:	84aa                	mv	s1,a0
   4e396:	12050163          	beqz	a0,4e4b8 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x4d0>
   4e39a:	4010                	lw	a2,0(s0)
   4e39c:	00442683          	lw	a3,4(s0)
   4e3a0:	000bd597          	auipc	a1,0xbd
   4e3a4:	ef458593          	addi	a1,a1,-268 # 10b294 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5e34>
   4e3a8:	fffd2097          	auipc	ra,0xfffd2
   4e3ac:	f58080e7          	jalr	-168(ra) # 20300 <CFDictionarySetInt64@plt>
   4e3b0:	06e00613          	li	a2,110
   4e3b4:	4681                	li	a3,0
   4e3b6:	000bd597          	auipc	a1,0xbd
   4e3ba:	efa58593          	addi	a1,a1,-262 # 10b2b0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5e50>
   4e3be:	8526                	mv	a0,s1
   4e3c0:	fffd2097          	auipc	ra,0xfffd2
   4e3c4:	f40080e7          	jalr	-192(ra) # 20300 <CFDictionarySetInt64@plt>
   4e3c8:	000e1617          	auipc	a2,0xe1
   4e3cc:	d5862603          	lw	a2,-680(a2) # 12f120 <gProxyInfos@@Base-0x488> ; DATA ELF relocation: gProxyInfos
   4e3d0:	56fd                	li	a3,-1
   4e3d2:	0f060613          	addi	a2,a2,240
   4e3d6:	000bd597          	auipc	a1,0xbd
   4e3da:	eea58593          	addi	a1,a1,-278 # 10b2c0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5e60>
   4e3de:	8526                	mv	a0,s1
   4e3e0:	fffd3097          	auipc	ra,0xfffd3
   4e3e4:	db0080e7          	jalr	-592(ra) # 21190 <CFDictionarySetCString@plt>
   4e3e8:	4681                	li	a3,0
   4e3ea:	4665                	li	a2,25
   4e3ec:	000bd597          	auipc	a1,0xbd
   4e3f0:	ee458593          	addi	a1,a1,-284 # 10b2d0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5e70>
   4e3f4:	00048513          	mv	a0,s1
   4e3f8:	fffd2097          	auipc	ra,0xfffd2
   4e3fc:	f08080e7          	jalr	-248(ra) # 20300 <CFDictionarySetInt64@plt>
   4e400:	85a6                	mv	a1,s1
   4e402:	0068                	addi	a0,sp,12
   4e404:	fffd2097          	auipc	ra,0xfffd2
   4e408:	a5c080e7          	jalr	-1444(ra) # 1fe60 <CFArrayEnsureCreatedAndAppend@plt>
   4e40c:	4632                	lw	a2,12(sp)
   4e40e:	000bd597          	auipc	a1,0xbd
   4e412:	ed658593          	addi	a1,a1,-298 # 10b2e4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5e84>
   4e416:	854a                	mv	a0,s2
   4e418:	fffd4097          	auipc	ra,0xfffd4
   4e41c:	db8080e7          	jalr	-584(ra) # 221d0 <CFDictionarySetValue@plt>
   4e420:	8b8da0ef          	jal	284d8 <_AirPlayReceiverSessionChangeModesCompletionFunc@@Base+0x1100>
   4e424:	862a                	mv	a2,a0
   4e426:	c159                	beqz	a0,4e4ac <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x4c4>
   4e428:	86ca                	mv	a3,s2
   4e42a:	000b5597          	auipc	a1,0xb5
   4e42e:	7e258593          	addi	a1,a1,2018 # 103c0c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e7ac> ; DATA 'SETUP'
   4e432:	0028                	addi	a0,sp,8
   4e434:	404010ef          	jal	4f838 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1850>
   4e438:	e915                	bnez	a0,4e46c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x484>
   4e43a:	45a2                	lw	a1,8(sp)
   4e43c:	000e1717          	auipc	a4,0xe1
   4e440:	e6c72703          	lw	a4,-404(a4) # 12f2a8 <gAirPlayClient@@Base-0x938> ; DATA ELF relocation: gAirPlayClient
   4e444:	6785                	lui	a5,0x1
   4e446:	97ae                	add	a5,a5,a1
   4e448:	4308                	lw	a0,0(a4)
   4e44a:	00001717          	auipc	a4,0x1
   4e44e:	dfe70713          	addi	a4,a4,-514 # 4f248 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1260>
   4e452:	8e07aa23          	sw	zero,-1804(a5) # 8f4 <CFArrayCreateCopy@plt-0x1eedc>
   4e456:	8e07ac23          	sw	zero,-1800(a5)
   4e45a:	8e07ae23          	sw	zero,-1796(a5)
   4e45e:	90e7a223          	sw	a4,-1788(a5)
   4e462:	c11d                	beqz	a0,4e488 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x4a0>
   4e464:	fffd4097          	auipc	ra,0xfffd4
   4e468:	d1c080e7          	jalr	-740(ra) # 22180 <HTTPClientSendMessage@plt>
   4e46c:	00090513          	mv	a0,s2
   4e470:	fffd3097          	auipc	ra,0xfffd3
   4e474:	670080e7          	jalr	1648(ra) # 21ae0 <CFRelease@plt>
   4e478:	00048513          	mv	a0,s1
   4e47c:	fffd3097          	auipc	ra,0xfffd3
   4e480:	664080e7          	jalr	1636(ra) # 21ae0 <CFRelease@plt>
   4e484:	ea9ff06f          	j	4e32c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x344>
   4e488:	4681                	li	a3,0
   4e48a:	4701                	li	a4,0
   4e48c:	854a                	mv	a0,s2
   4e48e:	c014                	sw	a3,0(s0)
   4e490:	00e42223          	sw	a4,4(s0)
   4e494:	fffd3097          	auipc	ra,0xfffd3
   4e498:	64c080e7          	jalr	1612(ra) # 21ae0 <CFRelease@plt>
   4e49c:	00048513          	mv	a0,s1
   4e4a0:	fffd3097          	auipc	ra,0xfffd3
   4e4a4:	640080e7          	jalr	1600(ra) # 21ae0 <CFRelease@plt>
   4e4a8:	e85ff06f          	j	4e32c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x344>
