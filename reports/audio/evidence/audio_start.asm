
CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0003632c <carplay_audio_stop(int, int, bool)@@Base+0x28>:
   3632c:	7179                	addi	sp,sp,-48
   3632e:	d422                	sw	s0,40(sp)
   36330:	d226                	sw	s1,36(sp)
   36332:	842e                	mv	s0,a1
   36334:	d04a                	sw	s2,32(sp)
   36336:	ce4e                	sw	s3,28(sp)
   36338:	8942                	mv	s2,a6
   3633a:	cc52                	sw	s4,24(sp)
   3633c:	ca56                	sw	s5,20(sp)
   3633e:	c85a                	sw	s6,16(sp)
   36340:	84b2                	mv	s1,a2
   36342:	8a36                	mv	s4,a3
   36344:	89ba                	mv	s3,a4
   36346:	8abe                	mv	s5,a5
   36348:	8b2a                	mv	s6,a0
   3634a:	88be                	mv	a7,a5
   3634c:	883a                	mv	a6,a4
   3634e:	87b6                	mv	a5,a3
   36350:	8732                	mv	a4,a2
   36352:	86ae                	mv	a3,a1
   36354:	000d2617          	auipc	a2,0xd2
   36358:	8d460613          	addi	a2,a2,-1836 # 107c28 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa27c8> ; DATA 'writeCarPlayAudioInit'
   3635c:	000d2597          	auipc	a1,0xd2
   36360:	8e458593          	addi	a1,a1,-1820 # 107c40 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa27e0> ; DATA '%s stream type:%d audio type:%d format:%d rate:%d channel:%d input:%d'
   36364:	000d1517          	auipc	a0,0xd1
   36368:	e3050513          	addi	a0,a0,-464 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   3636c:	d606                	sw	ra,44(sp)
   3636e:	c04a                	sw	s2,0(sp)
   36370:	fffec097          	auipc	ra,0xfffec
   36374:	990080e7          	jalr	-1648(ra) # 21d00 <MLOGD@plt>
   36378:	42645edb          	.insn	4, 0x42645edb
   3637c:	f9c40793          	addi	a5,s0,-100
   36380:	4705                	li	a4,1
   36382:	08f77963          	bgeu	a4,a5,36414 <carplay_audio_stop(int, int, bool)@@Base+0x110>
   36386:	8622                	mv	a2,s0
   36388:	5422                	lw	s0,40(sp)
   3638a:	50b2                	lw	ra,44(sp)
   3638c:	5902                	lw	s2,32(sp)
   3638e:	49f2                	lw	s3,28(sp)
   36390:	4a62                	lw	s4,24(sp)
   36392:	4ad2                	lw	s5,20(sp)
   36394:	4b42                	lw	s6,16(sp)
   36396:	86a6                	mv	a3,s1
   36398:	5492                	lw	s1,36(sp)
   3639a:	000d2597          	auipc	a1,0xd2
   3639e:	91258593          	addi	a1,a1,-1774 # 107cac <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa284c> ; DATA 'not support audio stream type:%d audio type:%d'
   363a2:	000d1517          	auipc	a0,0xd1
   363a6:	df250513          	addi	a0,a0,-526 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   363aa:	6145                	addi	sp,sp,48
   363ac:	fffec317          	auipc	t1,0xfffec
   363b0:	95430067          	jr	-1708(t1) # 21d00 <MLOGD@plt>
   363b4:	8626                	mv	a2,s1
   363b6:	86ca                	mv	a3,s2
   363b8:	855a                	mv	a0,s6
   363ba:	06400593          	li	a1,100
   363be:	3d6d                	jal	36278 <carplay_audio_process(int, int, void*, int)@@Base+0xa8>
   363c0:	85a6                	mv	a1,s1
   363c2:	864a                	mv	a2,s2
   363c4:	4681                	li	a3,0
   363c6:	8856                	mv	a6,s5
   363c8:	87d2                	mv	a5,s4
   363ca:	874e                	mv	a4,s3
   363cc:	06400513          	li	a0,100
   363d0:	aa4ee0ef          	jal	24674 <lv_obj_set_style_pad_left@plt+0x21a4>
   363d4:	000d2617          	auipc	a2,0xd2
   363d8:	85460613          	addi	a2,a2,-1964 # 107c28 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa27c8> ; DATA 'writeCarPlayAudioInit'
   363dc:	84aa                	mv	s1,a0
   363de:	86aa                	mv	a3,a0
   363e0:	000d2597          	auipc	a1,0xd2
   363e4:	8a858593          	addi	a1,a1,-1880 # 107c88 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2828> ; DATA '%s start new audio play handler:%x '
   363e8:	000d1517          	auipc	a0,0xd1
   363ec:	dac50513          	addi	a0,a0,-596 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   363f0:	fffec097          	auipc	ra,0xfffec
   363f4:	910080e7          	jalr	-1776(ra) # 21d00 <MLOGD@plt>
   363f8:	78904e2b          	.insn	4, 0x78904e2b
   363fc:	06091463          	bnez	s2,36464 <carplay_audio_stop(int, int, bool)@@Base+0x160>
   36400:	50b2                	lw	ra,44(sp)
   36402:	5422                	lw	s0,40(sp)
   36404:	5492                	lw	s1,36(sp)
   36406:	5902                	lw	s2,32(sp)
   36408:	49f2                	lw	s3,28(sp)
   3640a:	4a62                	lw	s4,24(sp)
   3640c:	4ad2                	lw	s5,20(sp)
   3640e:	4b42                	lw	s6,16(sp)
   36410:	6145                	addi	sp,sp,48
   36412:	8082                	ret
   36414:	8626                	mv	a2,s1
   36416:	86ca                	mv	a3,s2
   36418:	85a2                	mv	a1,s0
   3641a:	855a                	mv	a0,s6
   3641c:	e5dff0ef          	jal	36278 <carplay_audio_process(int, int, void*, int)@@Base+0xa8>
   36420:	85a6                	mv	a1,s1
   36422:	864a                	mv	a2,s2
   36424:	4681                	li	a3,0
   36426:	8856                	mv	a6,s5
   36428:	87d2                	mv	a5,s4
   3642a:	874e                	mv	a4,s3
   3642c:	00040513          	mv	a0,s0
   36430:	a44ee0ef          	jal	24674 <lv_obj_set_style_pad_left@plt+0x21a4>
   36434:	000d1617          	auipc	a2,0xd1
   36438:	7f460613          	addi	a2,a2,2036 # 107c28 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa27c8> ; DATA 'writeCarPlayAudioInit'
   3643c:	84aa                	mv	s1,a0
   3643e:	86aa                	mv	a3,a0
   36440:	000d2597          	auipc	a1,0xd2
   36444:	84858593          	addi	a1,a1,-1976 # 107c88 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2828> ; DATA '%s start new audio play handler:%x '
   36448:	000d1517          	auipc	a0,0xd1
   3644c:	d4c50513          	addi	a0,a0,-692 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   36450:	fffec097          	auipc	ra,0xfffec
   36454:	8b0080e7          	jalr	-1872(ra) # 21d00 <MLOGD@plt>
   36458:	fa5460db          	.insn	4, 0xfa5460db
   3645c:	78904c2b          	.insn	4, 0x78904c2b
   36460:	fa0900e3          	beqz	s2,36400 <carplay_audio_stop(int, int, bool)@@Base+0xfc>
   36464:	5422                	lw	s0,40(sp)
   36466:	50b2                	lw	ra,44(sp)
   36468:	5902                	lw	s2,32(sp)
   3646a:	49f2                	lw	s3,28(sp)
   3646c:	4a62                	lw	s4,24(sp)
   3646e:	4ad2                	lw	s5,20(sp)
   36470:	8626                	mv	a2,s1
   36472:	855a                	mv	a0,s6
   36474:	5492                	lw	s1,36(sp)
   36476:	4b42                	lw	s6,16(sp)
   36478:	4585                	li	a1,1
   3647a:	6145                	addi	sp,sp,48
   3647c:	d85ff06f          	j	36200 <carplay_audio_process(int, int, void*, int)@@Base+0x30>
