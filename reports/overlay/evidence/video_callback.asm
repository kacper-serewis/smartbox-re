
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

000360f0 <carplay_video_process(int, void*, int, bool)@@Base>:
   360f0:	1101                	addi	sp,sp,-32
   360f2:	ce06                	sw	ra,28(sp)
   360f4:	cc22                	sw	s0,24(sp)
   360f6:	ca26                	sw	s1,20(sp)
   360f8:	06255e5b          	.insn	4, 0x06255e5b
   360fc:	08155a5b          	.insn	4, 0x08155a5b
   36100:	00050863          	beqz	a0,36110 <carplay_video_process(int, void*, int, bool)@@Base+0x20>
   36104:	40f2                	lw	ra,28(sp)
   36106:	4462                	lw	s0,24(sp)
   36108:	44d2                	lw	s1,20(sp)
   3610a:	6105                	addi	sp,sp,32
   3610c:	00008067          	ret
   36110:	000d2597          	auipc	a1,0xd2
   36114:	a9058593          	addi	a1,a1,-1392 # 107ba0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2740> ; DATA 'link video stop'
   36118:	000d1517          	auipc	a0,0xd1
   3611c:	07c50513          	addi	a0,a0,124 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   36120:	fffec097          	auipc	ra,0xfffec
   36124:	be0080e7          	jalr	-1056(ra) # 21d00 <MLOGD@plt>
   36128:	d91fc0ef          	jal	32eb8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xdf8>
   3612c:	4701                	li	a4,0
   3612e:	4781                	li	a5,0
   36130:	4681                	li	a3,0
   36132:	4601                	li	a2,0
   36134:	4d400593          	li	a1,1236
   36138:	64e1                	lui	s1,0x18
   3613a:	4479                	li	s0,30
   3613c:	6a048493          	addi	s1,s1,1696 # 186a0 <CFArrayCreateCopy@plt-0x7130>
   36140:	fffea097          	auipc	ra,0xfffea
   36144:	b60080e7          	jalr	-1184(ra) # 1fca0 <MSNAppBase::postEvent(unsigned int, void*, int, long long)@plt>
   36148:	0140006f          	j	3615c <carplay_video_process(int, void*, int, bool)@@Base+0x6c>
   3614c:	00048513          	mv	a0,s1
   36150:	fffeb097          	auipc	ra,0xfffeb
   36154:	3e0080e7          	jalr	992(ra) # 21530 <usleep@plt>
   36158:	fa0406e3          	beqz	s0,36104 <carplay_video_process(int, void*, int, bool)@@Base+0x14>
   3615c:	fff40413          	addi	s0,s0,-1
   36160:	d59fc0ef          	jal	32eb8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xdf8>
   36164:	fecff0ef          	jal	35950 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2a94>
   36168:	f175                	bnez	a0,3614c <carplay_video_process(int, void*, int, bool)@@Base+0x5c>
   3616a:	40f2                	lw	ra,28(sp)
   3616c:	4462                	lw	s0,24(sp)
   3616e:	44d2                	lw	s1,20(sp)
   36170:	6105                	addi	sp,sp,32
   36172:	8082                	ret
   36174:	c636                	sw	a3,12(sp)
   36176:	c432                	sw	a2,8(sp)
   36178:	00b12223          	sw	a1,4(sp)
   3617c:	d3dfc0ef          	jal	32eb8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xdf8>
   36180:	4462                	lw	s0,24(sp)
   36182:	46b2                	lw	a3,12(sp)
   36184:	4622                	lw	a2,8(sp)
   36186:	4592                	lw	a1,4(sp)
   36188:	40f2                	lw	ra,28(sp)
   3618a:	44d2                	lw	s1,20(sp)
   3618c:	6105                	addi	sp,sp,32
   3618e:	b30d                	j	35eb0 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2ff4>
   36190:	4462                	lw	s0,24(sp)
   36192:	40f2                	lw	ra,28(sp)
   36194:	44d2                	lw	s1,20(sp)
   36196:	000d2597          	auipc	a1,0xd2
   3619a:	9f658593          	addi	a1,a1,-1546 # 107b8c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa272c> ; DATA 'link video start'
   3619e:	000d1517          	auipc	a0,0xd1
   361a2:	ff650513          	addi	a0,a0,-10 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   361a6:	6105                	addi	sp,sp,32
   361a8:	fffec317          	auipc	t1,0xfffec
   361ac:	b5830067          	jr	-1192(t1) # 21d00 <MLOGD@plt>
