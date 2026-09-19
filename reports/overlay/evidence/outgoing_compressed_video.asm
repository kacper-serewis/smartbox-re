
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0004ee7c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe94>:
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
   4eea0:	044080e7          	jalr	68(ra) # 1fee0 <pthread_mutex_lock@plt>
   4eea4:	000aab03          	lw	s6,0(s5)
   4eea8:	220b4a63          	bltz	s6,4f0dc <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x10f4>
   4eeac:	09090513          	addi	a0,s2,144
   4eeb0:	88dff0ef          	jal	4e73c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x754>
   4eeb4:	842a                	mv	s0,a0
   4eeb6:	22050d63          	beqz	a0,4f0f0 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1108>
   4eeba:	07c00613          	li	a2,124
   4eebe:	4581                	li	a1,0
   4eec0:	00450513          	addi	a0,a0,4
   4eec4:	fffd3097          	auipc	ra,0xfffd3
   4eec8:	14c080e7          	jalr	332(ra) # 22010 <memset@plt>
   4eecc:	ffc90993          	addi	s3,s2,-4
   4eed0:	3c89a75b          	.insn	4, 0x3c89a75b
   4eed4:	00899793          	slli	a5,s3,0x8
   4eed8:	8fd9                	or	a5,a5,a4
   4eeda:	000e0717          	auipc	a4,0xe0
   4eede:	11a72703          	lw	a4,282(a4) # 12eff4 <gPairVerifySessionHomeKit@@Base-0xbe0> ; DATA ELF relocation: gPairVerifySessionHomeKit
   4eee2:	4318                	lw	a4,0(a4)
   4eee4:	0189d613          	srli	a2,s3,0x18
   4eee8:	4109d693          	srai	a3,s3,0x10
   4eeec:	01242023          	sw	s2,0(s0)
   4eef0:	08c40023          	sb	a2,128(s0)
   4eef4:	08d400a3          	sb	a3,129(s0)
   4eef8:	08f41123          	sh	a5,130(s0)
   4eefc:	08040a13          	addi	s4,s0,128
   4ef00:	1a070263          	beqz	a4,4f0a4 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x10bc>
   4ef04:	1390148b          	.insn	4, 0x1390148b
   4ef08:	0084c783          	lbu	a5,8(s1)
   4ef0c:	1e078e63          	beqz	a5,4f108 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1120>
   4ef10:	2510160b          	.insn	4, 0x2510160b
   4ef14:	2310158b          	.insn	4, 0x2310158b
   4ef18:	1450150b          	.insn	4, 0x1450150b
   4ef1c:	01090913          	addi	s2,s2,16
   4ef20:	01242023          	sw	s2,0(s0)
   4ef24:	fffd1097          	auipc	ra,0xfffd1
   4ef28:	41c080e7          	jalr	1052(ra) # 20340 <chacha20_poly1305_init_64x64@plt>
   4ef2c:	08000613          	li	a2,128
   4ef30:	00040593          	mv	a1,s0
   4ef34:	1450150b          	.insn	4, 0x1450150b
   4ef38:	fffd1097          	auipc	ra,0xfffd1
   4ef3c:	f38080e7          	jalr	-200(ra) # 1fe70 <chacha20_poly1305_add_aad@plt>
   4ef40:	86d2                	mv	a3,s4
   4ef42:	4611                	li	a2,4
   4ef44:	000a0593          	mv	a1,s4
   4ef48:	1450150b          	.insn	4, 0x1450150b
   4ef4c:	fffd2097          	auipc	ra,0xfffd2
   4ef50:	874080e7          	jalr	-1932(ra) # 207c0 <chacha20_poly1305_encrypt@plt>
   4ef54:	00098613          	mv	a2,s3
   4ef58:	00aa06b3          	add	a3,s4,a0
   4ef5c:	004b8593          	addi	a1,s7,4
   4ef60:	1450150b          	.insn	4, 0x1450150b
   4ef64:	fffd2097          	auipc	ra,0xfffd2
   4ef68:	85c080e7          	jalr	-1956(ra) # 207c0 <chacha20_poly1305_encrypt@plt>
   4ef6c:	4010                	lw	a2,0(s0)
   4ef6e:	892a                	mv	s2,a0
   4ef70:	1641                	addi	a2,a2,-16
   4ef72:	00aa05b3          	add	a1,s4,a0
   4ef76:	9652                	add	a2,a2,s4
   4ef78:	1450150b          	.insn	4, 0x1450150b
   4ef7c:	fffd2097          	auipc	ra,0xfffd2
   4ef80:	0b4080e7          	jalr	180(ra) # 21030 <chacha20_poly1305_final@plt>
   4ef84:	401c                	lw	a5,0(s0)
   4ef86:	954a                	add	a0,a0,s2
   4ef88:	17c1                	addi	a5,a5,-16
   4ef8a:	18a79b63          	bne	a5,a0,4f120 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1138>
   4ef8e:	1184c783          	lbu	a5,280(s1)
   4ef92:	0785                	addi	a5,a5,1
   4ef94:	0ff7f793          	zext.b	a5,a5
   4ef98:	10f48c23          	sb	a5,280(s1)
   4ef9c:	e7b5                	bnez	a5,4f008 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1020>
   4ef9e:	1194c783          	lbu	a5,281(s1)
   4efa2:	0785                	addi	a5,a5,1
   4efa4:	0ff7f793          	zext.b	a5,a5
   4efa8:	10f48ca3          	sb	a5,281(s1)
   4efac:	efb1                	bnez	a5,4f008 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1020>
   4efae:	11a4c783          	lbu	a5,282(s1)
   4efb2:	0785                	addi	a5,a5,1
   4efb4:	0ff7f793          	zext.b	a5,a5
   4efb8:	10f48d23          	sb	a5,282(s1)
   4efbc:	e7b1                	bnez	a5,4f008 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1020>
   4efbe:	11b4c783          	lbu	a5,283(s1)
   4efc2:	0785                	addi	a5,a5,1
   4efc4:	0ff7f793          	zext.b	a5,a5
   4efc8:	10f48da3          	sb	a5,283(s1)
   4efcc:	ef95                	bnez	a5,4f008 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1020>
   4efce:	11c4c783          	lbu	a5,284(s1)
   4efd2:	0785                	addi	a5,a5,1
   4efd4:	0ff7f793          	zext.b	a5,a5
   4efd8:	10f48e23          	sb	a5,284(s1)
   4efdc:	e795                	bnez	a5,4f008 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1020>
   4efde:	11d4c783          	lbu	a5,285(s1)
   4efe2:	0785                	addi	a5,a5,1
   4efe4:	0ff7f793          	zext.b	a5,a5
   4efe8:	10f48ea3          	sb	a5,285(s1)
   4efec:	ef91                	bnez	a5,4f008 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1020>
   4efee:	11e4c783          	lbu	a5,286(s1)
   4eff2:	0785                	addi	a5,a5,1
   4eff4:	0ff7f793          	zext.b	a5,a5
   4eff8:	10f48f23          	sb	a5,286(s1)
   4effc:	e791                	bnez	a5,4f008 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1020>
   4effe:	11f4c783          	lbu	a5,287(s1)
   4f002:	0785                	addi	a5,a5,1
   4f004:	10f48fa3          	sb	a5,287(s1)
   4f008:	4010                	lw	a2,0(s0)
   4f00a:	85a2                	mv	a1,s0
   4f00c:	08060613          	addi	a2,a2,128
   4f010:	000b0513          	mv	a0,s6
   4f014:	e35dd0ef          	jal	2ce48 <_HandleProxyEventConnectionClose@@Base+0x25a4>
   4f018:	00042783          	lw	a5,0(s0)
   4f01c:	08078793          	addi	a5,a5,128
   4f020:	04f50e63          	beq	a0,a5,4f07c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1094>
   4f024:	fffd1097          	auipc	ra,0xfffd1
   4f028:	f3c080e7          	jalr	-196(ra) # 1ff60 <__errno_location@plt>
   4f02c:	4104                	lw	s1,0(a0)
   4f02e:	e489                	bnez	s1,4f038 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1050>
   4f030:	ffffe4b7          	lui	s1,0xffffe
   4f034:	5d448493          	addi	s1,s1,1492 # ffffe5d4 <AOAProxy::sReaderBuffer@@Base+0xffecdce0>
   4f038:	3990150b          	.insn	4, 0x3990150b
   4f03c:	fffd1097          	auipc	ra,0xfffd1
   4f040:	4c4080e7          	jalr	1220(ra) # 20500 <pthread_mutex_unlock@plt>
   4f044:	00048693          	mv	a3,s1
   4f048:	000bc617          	auipc	a2,0xbc
   4f04c:	34460613          	addi	a2,a2,836 # 10b38c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5f2c> ; DATA 'SendProxyScreenFrame'
   4f050:	000bc597          	auipc	a1,0xbc
   4f054:	1b458593          	addi	a1,a1,436 # 10b204 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5da4> ; DATA '%s failed, err:%d\n'
   4f058:	000bc517          	auipc	a0,0xbc
   4f05c:	0c850513          	addi	a0,a0,200 # 10b120 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5cc0> ; DATA 'ProxyVideo'
   4f060:	fffd3097          	auipc	ra,0xfffd3
   4f064:	ca0080e7          	jalr	-864(ra) # 21d00 <MLOGD@plt>
   4f068:	000aa703          	lw	a4,0(s5)
   4f06c:	57fd                	li	a5,-1
   4f06e:	00f70f63          	beq	a4,a5,4f08c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x10a4>
   4f072:	4581                	li	a1,0
   4f074:	4501                	li	a0,0
   4f076:	36c9                	jal	4ec38 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xc50>
   4f078:	0140006f          	j	4f08c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x10a4>
   4f07c:	3990150b          	.insn	4, 0x3990150b
   4f080:	00000493          	li	s1,0
   4f084:	fffd1097          	auipc	ra,0xfffd1
   4f088:	47c080e7          	jalr	1148(ra) # 20500 <pthread_mutex_unlock@plt>
   4f08c:	50b2                	lw	ra,44(sp)
   4f08e:	5422                	lw	s0,40(sp)
   4f090:	5902                	lw	s2,32(sp)
   4f092:	49f2                	lw	s3,28(sp)
   4f094:	4a62                	lw	s4,24(sp)
   4f096:	4ad2                	lw	s5,20(sp)
   4f098:	4b42                	lw	s6,16(sp)
   4f09a:	4bb2                	lw	s7,12(sp)
   4f09c:	8526                	mv	a0,s1
   4f09e:	5492                	lw	s1,36(sp)
   4f0a0:	6145                	addi	sp,sp,48
   4f0a2:	8082                	ret
   4f0a4:	86d2                	mv	a3,s4
   4f0a6:	4611                	li	a2,4
   4f0a8:	000a0593          	mv	a1,s4
   4f0ac:	2790150b          	.insn	4, 0x2790150b
   4f0b0:	fffd2097          	auipc	ra,0xfffd2
   4f0b4:	590080e7          	jalr	1424(ra) # 21640 <AES_CTR_Update@plt>
   4f0b8:	84aa                	mv	s1,a0
   4f0ba:	fd3d                	bnez	a0,4f038 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1050>
   4f0bc:	08440693          	addi	a3,s0,132
   4f0c0:	00098613          	mv	a2,s3
   4f0c4:	004b8593          	addi	a1,s7,4
   4f0c8:	2790150b          	.insn	4, 0x2790150b
   4f0cc:	fffd2097          	auipc	ra,0xfffd2
   4f0d0:	574080e7          	jalr	1396(ra) # 21640 <AES_CTR_Update@plt>
   4f0d4:	84aa                	mv	s1,a0
   4f0d6:	f20509e3          	beqz	a0,4f008 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1020>
   4f0da:	bfb9                	j	4f038 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x1050>
   4f0dc:	3990150b          	.insn	4, 0x3990150b
   4f0e0:	fff00493          	li	s1,-1
   4f0e4:	fffd1097          	auipc	ra,0xfffd1
   4f0e8:	41c080e7          	jalr	1052(ra) # 20500 <pthread_mutex_unlock@plt>
   4f0ec:	f59ff06f          	j	4f044 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x105c>
   4f0f0:	3990150b          	.insn	4, 0x3990150b
   4f0f4:	ffffe4b7          	lui	s1,0xffffe
   4f0f8:	5b848493          	addi	s1,s1,1464 # ffffe5b8 <AOAProxy::sReaderBuffer@@Base+0xffecdcc4>
   4f0fc:	fffd1097          	auipc	ra,0xfffd1
   4f100:	404080e7          	jalr	1028(ra) # 20500 <pthread_mutex_unlock@plt>
   4f104:	f41ff06f          	j	4f044 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x105c>
   4f108:	3990150b          	.insn	4, 0x3990150b
   4f10c:	ffffe4b7          	lui	s1,0xffffe
   4f110:	5cb48493          	addi	s1,s1,1483 # ffffe5cb <AOAProxy::sReaderBuffer@@Base+0xffecdcd7>
   4f114:	fffd1097          	auipc	ra,0xfffd1
   4f118:	3ec080e7          	jalr	1004(ra) # 20500 <pthread_mutex_unlock@plt>
   4f11c:	f29ff06f          	j	4f044 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x105c>
   4f120:	3990150b          	.insn	4, 0x3990150b
   4f124:	ffffe4b7          	lui	s1,0xffffe
   4f128:	59648493          	addi	s1,s1,1430 # ffffe596 <AOAProxy::sReaderBuffer@@Base+0xffecdca2>
   4f12c:	fffd1097          	auipc	ra,0xfffd1
   4f130:	3d4080e7          	jalr	980(ra) # 20500 <pthread_mutex_unlock@plt>
   4f134:	f11ff06f          	j	4f044 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x105c>
