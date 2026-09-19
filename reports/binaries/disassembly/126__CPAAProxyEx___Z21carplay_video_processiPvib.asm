
firmwares/hw501/126/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0004fe68 <carplay_video_process(int, void*, int, bool)@@Base>:
   4fe68:	1101                	addi	sp,sp,-32
   4fe6a:	ce06                	sw	ra,28(sp)
   4fe6c:	cc22                	sw	s0,24(sp)
   4fe6e:	ca26                	sw	s1,20(sp)
   4fe70:	06255e5b          	.insn	4, 0x06255e5b
   4fe74:	08155a5b          	.insn	4, 0x08155a5b
   4fe78:	00050863          	beqz	a0,4fe88 <carplay_video_process(int, void*, int, bool)@@Base+0x20>
   4fe7c:	40f2                	lw	ra,28(sp)
   4fe7e:	4462                	lw	s0,24(sp)
   4fe80:	44d2                	lw	s1,20(sp)
   4fe82:	6105                	addi	sp,sp,32
   4fe84:	00008067          	ret
   4fe88:	00189597          	auipc	a1,0x189
   4fe8c:	8f058593          	addi	a1,a1,-1808 # 1d8778 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1bb4> ; DATA 'link video stop'
   4fe90:	00188517          	auipc	a0,0x188
   4fe94:	fdc50513          	addi	a0,a0,-36 # 1d7e6c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa12a8> ; DATA 'CPAAProxy'
   4fe98:	fffe8097          	auipc	ra,0xfffe8
   4fe9c:	638080e7          	jalr	1592(ra) # 384d0 <MLOGD@plt>
   4fea0:	c09fd0ef          	jal	4daa8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xf44>
   4fea4:	4701                	li	a4,0
   4fea6:	4781                	li	a5,0
   4fea8:	4681                	li	a3,0
   4feaa:	4601                	li	a2,0
   4feac:	4d400593          	li	a1,1236
   4feb0:	64e1                	lui	s1,0x18
   4feb2:	4479                	li	s0,30
   4feb4:	6a048493          	addi	s1,s1,1696 # 186a0 <HTimerEx::stop()@plt-0x1d9c0>
   4feb8:	fffe8097          	auipc	ra,0xfffe8
   4febc:	f88080e7          	jalr	-120(ra) # 37e40 <MSNAppBase::postEvent(unsigned int, void*, int, long long)@plt>
   4fec0:	0140006f          	j	4fed4 <carplay_video_process(int, void*, int, bool)@@Base+0x6c>
   4fec4:	00048513          	mv	a0,s1
   4fec8:	fffe6097          	auipc	ra,0xfffe6
   4fecc:	3c8080e7          	jalr	968(ra) # 36290 <usleep@plt>
   4fed0:	fa0406e3          	beqz	s0,4fe7c <carplay_video_process(int, void*, int, bool)@@Base+0x14>
   4fed4:	fff40413          	addi	s0,s0,-1
   4fed8:	bd1fd0ef          	jal	4daa8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xf44>
   4fedc:	9c5ff0ef          	jal	4f8a0 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x1df4>
   4fee0:	f175                	bnez	a0,4fec4 <carplay_video_process(int, void*, int, bool)@@Base+0x5c>
   4fee2:	40f2                	lw	ra,28(sp)
   4fee4:	4462                	lw	s0,24(sp)
   4fee6:	44d2                	lw	s1,20(sp)
   4fee8:	6105                	addi	sp,sp,32
   4feea:	8082                	ret
   4feec:	c636                	sw	a3,12(sp)
   4feee:	c432                	sw	a2,8(sp)
   4fef0:	00b12223          	sw	a1,4(sp)
   4fef4:	bb5fd0ef          	jal	4daa8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xf44>
   4fef8:	4462                	lw	s0,24(sp)
   4fefa:	46b2                	lw	a3,12(sp)
   4fefc:	4622                	lw	a2,8(sp)
   4fefe:	4592                	lw	a1,4(sp)
   4ff00:	40f2                	lw	ra,28(sp)
   4ff02:	44d2                	lw	s1,20(sp)
   4ff04:	6105                	addi	sp,sp,32
   4ff06:	b5c9                	j	4fdc8 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x231c>
   4ff08:	00189597          	auipc	a1,0x189
   4ff0c:	85c58593          	addi	a1,a1,-1956 # 1d8764 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1ba0> ; DATA 'link video start'
   4ff10:	00188517          	auipc	a0,0x188
   4ff14:	f5c50513          	addi	a0,a0,-164 # 1d7e6c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa12a8> ; DATA 'CPAAProxy'
   4ff18:	fffe8097          	auipc	ra,0xfffe8
   4ff1c:	5b8080e7          	jalr	1464(ra) # 384d0 <MLOGD@plt>
   4ff20:	b89fd0ef          	jal	4daa8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xf44>
   4ff24:	4781                	li	a5,0
   4ff26:	4701                	li	a4,0
   4ff28:	4681                	li	a3,0
   4ff2a:	4601                	li	a2,0
   4ff2c:	4d100593          	li	a1,1233
   4ff30:	fffe8097          	auipc	ra,0xfffe8
   4ff34:	f10080e7          	jalr	-240(ra) # 37e40 <MSNAppBase::postEvent(unsigned int, void*, int, long long)@plt>
   4ff38:	00208797          	auipc	a5,0x208
   4ff3c:	6d47a783          	lw	a5,1748(a5) # 25860c <gEnableCompatibilityMode@@Base-0x1898> ; DATA ELF relocation: gEnableCompatibilityMode
   4ff40:	439c                	lw	a5,0(a5)
   4ff42:	64e1                	lui	s1,0x18
   4ff44:	4479                	li	s0,30
   4ff46:	6a048493          	addi	s1,s1,1696 # 186a0 <HTimerEx::stop()@plt-0x1d9c0>
   4ff4a:	cb99                	beqz	a5,4ff60 <carplay_video_process(int, void*, int, bool)@@Base+0xf8>
   4ff4c:	0500006f          	j	4ff9c <carplay_video_process(int, void*, int, bool)@@Base+0x134>
   4ff50:	00048513          	mv	a0,s1
   4ff54:	fffe6097          	auipc	ra,0xfffe6
   4ff58:	33c080e7          	jalr	828(ra) # 36290 <usleep@plt>
   4ff5c:	00040a63          	beqz	s0,4ff70 <carplay_video_process(int, void*, int, bool)@@Base+0x108>
   4ff60:	fff40413          	addi	s0,s0,-1
   4ff64:	b45fd0ef          	jal	4daa8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xf44>
   4ff68:	939ff0ef          	jal	4f8a0 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x1df4>
   4ff6c:	fe0512e3          	bnez	a0,4ff50 <carplay_video_process(int, void*, int, bool)@@Base+0xe8>
   4ff70:	64e1                	lui	s1,0x18
   4ff72:	4479                	li	s0,30
   4ff74:	6a048493          	addi	s1,s1,1696 # 186a0 <HTimerEx::stop()@plt-0x1d9c0>
   4ff78:	0140006f          	j	4ff8c <carplay_video_process(int, void*, int, bool)@@Base+0x124>
   4ff7c:	00048513          	mv	a0,s1
   4ff80:	fffe6097          	auipc	ra,0xfffe6
   4ff84:	310080e7          	jalr	784(ra) # 36290 <usleep@plt>
   4ff88:	ee040ae3          	beqz	s0,4fe7c <carplay_video_process(int, void*, int, bool)@@Base+0x14>
   4ff8c:	fff40413          	addi	s0,s0,-1
   4ff90:	b19fd0ef          	jal	4daa8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xf44>
   4ff94:	90dff0ef          	jal	4f8a0 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x1df4>
   4ff98:	d175                	beqz	a0,4ff7c <carplay_video_process(int, void*, int, bool)@@Base+0x114>
   4ff9a:	b5cd                	j	4fe7c <carplay_video_process(int, void*, int, bool)@@Base+0x14>
   4ff9c:	4462                	lw	s0,24(sp)
   4ff9e:	40f2                	lw	ra,28(sp)
   4ffa0:	44d2                	lw	s1,20(sp)
   4ffa2:	651d                	lui	a0,0x7
   4ffa4:	53050513          	addi	a0,a0,1328 # 7530 <HTimerEx::stop()@plt-0x2eb30>
   4ffa8:	02010113          	addi	sp,sp,32
   4ffac:	fffe6317          	auipc	t1,0xfffe6
   4ffb0:	2e430067          	jr	740(t1) # 36290 <usleep@plt>
