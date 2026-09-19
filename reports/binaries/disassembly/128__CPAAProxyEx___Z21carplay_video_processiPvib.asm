
firmwares/hw501/128/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00035710 <carplay_video_process(int, void*, int, bool)@@Base>:
   35710:	1101                	addi	sp,sp,-32
   35712:	ce06                	sw	ra,28(sp)
   35714:	cc22                	sw	s0,24(sp)
   35716:	ca26                	sw	s1,20(sp)
   35718:	06255e5b          	.insn	4, 0x06255e5b
   3571c:	842a                	mv	s0,a0
   3571e:	0815595b          	.insn	4, 0x0815595b
   35722:	c519                	beqz	a0,35730 <carplay_video_process(int, void*, int, bool)@@Base+0x20>
   35724:	40f2                	lw	ra,28(sp)
   35726:	4462                	lw	s0,24(sp)
   35728:	44d2                	lw	s1,20(sp)
   3572a:	6105                	addi	sp,sp,32
   3572c:	00008067          	ret
   35730:	000cf597          	auipc	a1,0xcf
   35734:	e1858593          	addi	a1,a1,-488 # 104548 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1044> ; DATA 'link video stop'
   35738:	000ce517          	auipc	a0,0xce
   3573c:	42050513          	addi	a0,a0,1056 # 103b58 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0654> ; DATA 'GalProxy'
   35740:	fffec097          	auipc	ra,0xfffec
   35744:	3d0080e7          	jalr	976(ra) # 21b10 <MLOGD@plt>
   35748:	a84fd0ef          	jal	329cc <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xdf4>
   3574c:	4701                	li	a4,0
   3574e:	4781                	li	a5,0
   35750:	4681                	li	a3,0
   35752:	4601                	li	a2,0
   35754:	4d400593          	li	a1,1236
   35758:	64e1                	lui	s1,0x18
   3575a:	4479                	li	s0,30
   3575c:	6a048493          	addi	s1,s1,1696 # 186a0 <CFArrayCreateCopy@plt-0x6f70>
   35760:	fffea097          	auipc	ra,0xfffea
   35764:	370080e7          	jalr	880(ra) # 1fad0 <MSNAppBase::postEvent(unsigned int, void*, int, long long)@plt>
   35768:	0140006f          	j	3577c <carplay_video_process(int, void*, int, bool)@@Base+0x6c>
   3576c:	00048513          	mv	a0,s1
   35770:	fffec097          	auipc	ra,0xfffec
   35774:	bf0080e7          	jalr	-1040(ra) # 21360 <usleep@plt>
   35778:	fa0406e3          	beqz	s0,35724 <carplay_video_process(int, void*, int, bool)@@Base+0x14>
   3577c:	fff40413          	addi	s0,s0,-1
   35780:	a4cfd0ef          	jal	329cc <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xdf4>
   35784:	8d5ff0ef          	jal	35058 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2688>
   35788:	f175                	bnez	a0,3576c <carplay_video_process(int, void*, int, bool)@@Base+0x5c>
   3578a:	40f2                	lw	ra,28(sp)
   3578c:	4462                	lw	s0,24(sp)
   3578e:	44d2                	lw	s1,20(sp)
   35790:	6105                	addi	sp,sp,32
   35792:	8082                	ret
   35794:	c636                	sw	a3,12(sp)
   35796:	c432                	sw	a2,8(sp)
   35798:	00b12223          	sw	a1,4(sp)
   3579c:	a30fd0ef          	jal	329cc <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xdf4>
   357a0:	4462                	lw	s0,24(sp)
   357a2:	46b2                	lw	a3,12(sp)
   357a4:	4622                	lw	a2,8(sp)
   357a6:	4592                	lw	a1,4(sp)
   357a8:	40f2                	lw	ra,28(sp)
   357aa:	44d2                	lw	s1,20(sp)
   357ac:	6105                	addi	sp,sp,32
   357ae:	b3cd                	j	35590 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2bc0>
   357b0:	000cf597          	auipc	a1,0xcf
   357b4:	d8458593          	addi	a1,a1,-636 # 104534 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1030> ; DATA 'link video start'
   357b8:	000ce517          	auipc	a0,0xce
   357bc:	3a050513          	addi	a0,a0,928 # 103b58 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0654> ; DATA 'GalProxy'
   357c0:	fffec097          	auipc	ra,0xfffec
   357c4:	350080e7          	jalr	848(ra) # 21b10 <MLOGD@plt>
   357c8:	40f2                	lw	ra,28(sp)
   357ca:	d48dc72b          	.insn	4, 0xd48dc72b
   357ce:	4462                	lw	s0,24(sp)
   357d0:	44d2                	lw	s1,20(sp)
   357d2:	6105                	addi	sp,sp,32
   357d4:	00008067          	ret
