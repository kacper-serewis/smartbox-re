
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0004eca8 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xcc0>:
   4eca8:	715d                	addi	sp,sp,-80
   4ecaa:	d06a                	sw	s10,32(sp)
   4ecac:	8d2a                	mv	s10,a0
   4ecae:	3990150b          	.insn	4, 0x3990150b
   4ecb2:	c2a6                	sw	s1,68(sp)
   4ecb4:	c0ca                	sw	s2,64(sp)
   4ecb6:	de4e                	sw	s3,60(sp)
   4ecb8:	dc52                	sw	s4,56(sp)
   4ecba:	da56                	sw	s5,52(sp)
   4ecbc:	d85a                	sw	s6,48(sp)
   4ecbe:	d65e                	sw	s7,44(sp)
   4ecc0:	89b2                	mv	s3,a2
   4ecc2:	8936                	mv	s2,a3
   4ecc4:	c686                	sw	ra,76(sp)
   4ecc6:	c4a2                	sw	s0,72(sp)
   4ecc8:	d462                	sw	s8,40(sp)
   4ecca:	d266                	sw	s9,36(sp)
   4eccc:	84ae                	mv	s1,a1
   4ecce:	8bba                	mv	s7,a4
   4ecd0:	8b3e                	mv	s6,a5
   4ecd2:	8a42                	mv	s4,a6
   4ecd4:	00088a93          	mv	s5,a7
   4ecd8:	fffd1097          	auipc	ra,0xfffd1
   4ecdc:	208080e7          	jalr	520(ra) # 1fee0 <pthread_mutex_lock@plt>
   4ece0:	03298533          	mul	a0,s3,s2
   4ece4:	a59ff0ef          	jal	4e73c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x754>
   4ece8:	14050663          	beqz	a0,4ee34 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe4c>
   4ecec:	dc8d9c0b          	.insn	4, 0xdc8d9c0b
   4ecf0:	000c2c83          	lw	s9,0(s8)
   4ecf4:	140cce63          	bltz	s9,4ee50 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe68>
   4ecf8:	16905663          	blez	s1,4ee64 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe7c>
   4ecfc:	842a                	mv	s0,a0
   4ecfe:	88d2                	mv	a7,s4
   4ed00:	885a                	mv	a6,s6
   4ed02:	87de                	mv	a5,s7
   4ed04:	874a                	mv	a4,s2
   4ed06:	86ce                	mv	a3,s3
   4ed08:	000bc617          	auipc	a2,0xbc
   4ed0c:	66460613          	addi	a2,a2,1636 # 10b36c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5f0c> ; DATA 'SendProxyScreenVideoConfigFrame'
   4ed10:	000bc597          	auipc	a1,0xbc
   4ed14:	4b858593          	addi	a1,a1,1208 # 10b1c8 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5d68> ; DATA '%s sps pps width:%d height:%d pos:%dx%d size:%dx%d len:%d!\n'
   4ed18:	000bc517          	auipc	a0,0xbc
   4ed1c:	40850513          	addi	a0,a0,1032 # 10b120 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5cc0> ; DATA 'ProxyVideo'
   4ed20:	c226                	sw	s1,4(sp)
   4ed22:	c056                	sw	s5,0(sp)
   4ed24:	fffd3097          	auipc	ra,0xfffd3
   4ed28:	fdc080e7          	jalr	-36(ra) # 21d00 <MLOGD@plt>
   4ed2c:	08000613          	li	a2,128
   4ed30:	4581                	li	a1,0
   4ed32:	8522                	mv	a0,s0
   4ed34:	00012e23          	sw	zero,28(sp)
   4ed38:	fffd3097          	auipc	ra,0xfffd3
   4ed3c:	2d8080e7          	jalr	728(ra) # 22010 <memset@plt>
   4ed40:	85a6                	mv	a1,s1
   4ed42:	4785                	li	a5,1
   4ed44:	0874                	addi	a3,sp,28
   4ed46:	08040613          	addi	a2,s0,128
   4ed4a:	856a                	mv	a0,s10
   4ed4c:	00f40223          	sb	a5,4(s0)
   4ed50:	a9dff0ef          	jal	4e7ec <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x804>
   4ed54:	84aa                	mv	s1,a0
   4ed56:	ed49                	bnez	a0,4edf0 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe08>
   4ed58:	d00bf6d3          	fcvt.s.w	fa3,s7
   4ed5c:	47f2                	lw	a5,28(sp)
   4ed5e:	05400713          	li	a4,84
   4ed62:	d00b7753          	fcvt.s.w	fa4,s6
   4ed66:	00e41323          	sh	a4,6(s0)
   4ed6a:	00042023          	sw	zero,0(s0)
   4ed6e:	d00af7d3          	fcvt.s.w	fa5,s5
   4ed72:	f014                	fsw	fa3,32(s0)
   4ed74:	f814                	fsw	fa3,48(s0)
   4ed76:	f058                	fsw	fa4,36(s0)
   4ed78:	d009f6d3          	fcvt.s.w	fa3,s3
   4ed7c:	f858                	fsw	fa4,52(s0)
   4ed7e:	f45c                	fsw	fa5,44(s0)
   4ed80:	d0097753          	fcvt.s.w	fa4,s2
   4ed84:	fc1c                	fsw	fa5,56(s0)
   4ed86:	d00a77d3          	fcvt.s.w	fa5,s4
   4ed8a:	e814                	fsw	fa3,16(s0)
   4ed8c:	e858                	fsw	fa4,20(s0)
   4ed8e:	f41c                	fsw	fa5,40(s0)
   4ed90:	02f04863          	bgtz	a5,4edc0 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xdd8>
   4ed94:	3990150b          	.insn	4, 0x3990150b
   4ed98:	fffd1097          	auipc	ra,0xfffd1
   4ed9c:	768080e7          	jalr	1896(ra) # 20500 <pthread_mutex_unlock@plt>
   4eda0:	40b6                	lw	ra,76(sp)
   4eda2:	4426                	lw	s0,72(sp)
   4eda4:	4906                	lw	s2,64(sp)
   4eda6:	59f2                	lw	s3,60(sp)
   4eda8:	5a62                	lw	s4,56(sp)
   4edaa:	5ad2                	lw	s5,52(sp)
   4edac:	5b42                	lw	s6,48(sp)
   4edae:	5bb2                	lw	s7,44(sp)
   4edb0:	5c22                	lw	s8,40(sp)
   4edb2:	5c92                	lw	s9,36(sp)
   4edb4:	5d02                	lw	s10,32(sp)
   4edb6:	8526                	mv	a0,s1
   4edb8:	4496                	lw	s1,68(sp)
   4edba:	6161                	addi	sp,sp,80
   4edbc:	00008067          	ret
   4edc0:	08078913          	addi	s2,a5,128
   4edc4:	c01c                	sw	a5,0(s0)
   4edc6:	864a                	mv	a2,s2
   4edc8:	47d1                	li	a5,20
   4edca:	85a2                	mv	a1,s0
   4edcc:	000c8513          	mv	a0,s9
   4edd0:	00f40323          	sb	a5,6(s0)
   4edd4:	874de0ef          	jal	2ce48 <_HandleProxyEventConnectionClose@@Base+0x25a4>
   4edd8:	faa90ee3          	beq	s2,a0,4ed94 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xdac>
   4eddc:	fffd1097          	auipc	ra,0xfffd1
   4ede0:	184080e7          	jalr	388(ra) # 1ff60 <__errno_location@plt>
   4ede4:	4104                	lw	s1,0(a0)
   4ede6:	e489                	bnez	s1,4edf0 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe08>
   4ede8:	ffffe4b7          	lui	s1,0xffffe
   4edec:	5d448493          	addi	s1,s1,1492 # ffffe5d4 <AOAProxy::sReaderBuffer@@Base+0xffecdce0>
   4edf0:	3990150b          	.insn	4, 0x3990150b
   4edf4:	fffd1097          	auipc	ra,0xfffd1
   4edf8:	70c080e7          	jalr	1804(ra) # 20500 <pthread_mutex_unlock@plt>
   4edfc:	00048693          	mv	a3,s1
   4ee00:	000bc617          	auipc	a2,0xbc
   4ee04:	56c60613          	addi	a2,a2,1388 # 10b36c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5f0c> ; DATA 'SendProxyScreenVideoConfigFrame'
   4ee08:	000bc597          	auipc	a1,0xbc
   4ee0c:	3fc58593          	addi	a1,a1,1020 # 10b204 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5da4> ; DATA '%s failed, err:%d\n'
   4ee10:	000bc517          	auipc	a0,0xbc
   4ee14:	31050513          	addi	a0,a0,784 # 10b120 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5cc0> ; DATA 'ProxyVideo'
   4ee18:	fffd3097          	auipc	ra,0xfffd3
   4ee1c:	ee8080e7          	jalr	-280(ra) # 21d00 <MLOGD@plt>
   4ee20:	000c2703          	lw	a4,0(s8)
   4ee24:	57fd                	li	a5,-1
   4ee26:	f6f70de3          	beq	a4,a5,4eda0 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xdb8>
   4ee2a:	4581                	li	a1,0
   4ee2c:	4501                	li	a0,0
   4ee2e:	3529                	jal	4ec38 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xc50>
   4ee30:	f71ff06f          	j	4eda0 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xdb8>
   4ee34:	3990150b          	.insn	4, 0x3990150b
   4ee38:	ffffe4b7          	lui	s1,0xffffe
   4ee3c:	5b848493          	addi	s1,s1,1464 # ffffe5b8 <AOAProxy::sReaderBuffer@@Base+0xffecdcc4>
   4ee40:	dc8d9c0b          	.insn	4, 0xdc8d9c0b
   4ee44:	fffd1097          	auipc	ra,0xfffd1
   4ee48:	6bc080e7          	jalr	1724(ra) # 20500 <pthread_mutex_unlock@plt>
   4ee4c:	fb1ff06f          	j	4edfc <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe14>
   4ee50:	3990150b          	.insn	4, 0x3990150b
   4ee54:	fff00493          	li	s1,-1
   4ee58:	fffd1097          	auipc	ra,0xfffd1
   4ee5c:	6a8080e7          	jalr	1704(ra) # 20500 <pthread_mutex_unlock@plt>
   4ee60:	f9dff06f          	j	4edfc <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe14>
   4ee64:	3990150b          	.insn	4, 0x3990150b
   4ee68:	ffffe4b7          	lui	s1,0xffffe
   4ee6c:	5cf48493          	addi	s1,s1,1487 # ffffe5cf <AOAProxy::sReaderBuffer@@Base+0xffecdcdb>
   4ee70:	fffd1097          	auipc	ra,0xfffd1
   4ee74:	690080e7          	jalr	1680(ra) # 20500 <pthread_mutex_unlock@plt>
   4ee78:	f85ff06f          	j	4edfc <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe14>
   4ee7c:	7179                	addi	sp,sp,-48
   4ee7e:	ca56                	sw	s5,20(sp)
   4ee80:	c65e                	sw	s7,12(sp)
   4ee82:	dc8d9a8b          	.insn	4, 0xdc8d9a8b
   4ee86:	8baa                	mv	s7,a0
   4ee88:	3990150b          	.insn	4, 0x3990150b
   4ee8c:	d04a                	sw	s2,32(sp)
   4ee8e:	c85a                	sw	s6,16(sp)
   4ee90:	892e                	mv	s2,a1
   4ee92:	d606                	sw	ra,44(sp)
   4ee94:	d422                	sw	s0,40(sp)
   4ee96:	d226                	sw	s1,36(sp)
   4ee98:	ce4e                	sw	s3,28(sp)
   4ee9a:	cc52                	sw	s4,24(sp)
   4ee9c:	fffd1097          	auipc	ra,0xfffd1
