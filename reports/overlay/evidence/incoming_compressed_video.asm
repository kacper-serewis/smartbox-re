
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00035eb0 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2ff4>:
   35eb0:	7139                	addi	sp,sp,-64
   35eb2:	dc22                	sw	s0,56(sp)
   35eb4:	2b80140b          	.insn	4, 0x2b80140b
   35eb8:	da26                	sw	s1,52(sp)
   35eba:	d84a                	sw	s2,48(sp)
   35ebc:	d64e                	sw	s3,44(sp)
   35ebe:	d452                	sw	s4,40(sp)
   35ec0:	d256                	sw	s5,36(sp)
   35ec2:	de06                	sw	ra,60(sp)
   35ec4:	d05a                	sw	s6,32(sp)
   35ec6:	4d844783          	lbu	a5,1240(s0)
   35eca:	0045c703          	lbu	a4,4(a1)
   35ece:	89ae                	mv	s3,a1
   35ed0:	892a                	mv	s2,a0
   35ed2:	8a32                	mv	s4,a2
   35ed4:	84b6                	mv	s1,a3
   35ed6:	01f77a93          	andi	s5,a4,31
   35eda:	e399                	bnez	a5,35ee0 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3024>
   35edc:	0e7ad45b          	.insn	4, 0x0e7ad45b
   35ee0:	02049263          	bnez	s1,35f04 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3048>
   35ee4:	6789                	lui	a5,0x2
   35ee6:	97ca                	add	a5,a5,s2
   35ee8:	1727c783          	lbu	a5,370(a5) # 2172 <CFArrayCreateCopy@plt-0x1d65e>
   35eec:	cfc5                	beqz	a5,35fa4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x30e8>
   35eee:	50f2                	lw	ra,60(sp)
   35ef0:	5462                	lw	s0,56(sp)
   35ef2:	54d2                	lw	s1,52(sp)
   35ef4:	5942                	lw	s2,48(sp)
   35ef6:	59b2                	lw	s3,44(sp)
   35ef8:	5a22                	lw	s4,40(sp)
   35efa:	5a92                	lw	s5,36(sp)
   35efc:	5b02                	lw	s6,32(sp)
   35efe:	6121                	addi	sp,sp,64
   35f00:	00008067          	ret
   35f04:	6489                	lui	s1,0x2
   35f06:	0e848b13          	addi	s6,s1,232 # 20e8 <CFArrayCreateCopy@plt-0x1d6e8>
   35f0a:	9b4a                	add	s6,s6,s2
   35f0c:	000b0513          	mv	a0,s6
   35f10:	fffeb097          	auipc	ra,0xfffeb
   35f14:	460080e7          	jalr	1120(ra) # 21370 <MMutex::lock()@plt>
   35f18:	4dc42783          	lw	a5,1244(s0)
   35f1c:	12079a63          	bnez	a5,36050 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3194>
   35f20:	012484b3          	add	s1,s1,s2
   35f24:	16d4c783          	lbu	a5,365(s1)
   35f28:	10079c63          	bnez	a5,36040 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3184>
   35f2c:	6489                	lui	s1,0x2
   35f2e:	10100793          	li	a5,257
   35f32:	94ca                	add	s1,s1,s2
   35f34:	16f49623          	sh	a5,364(s1) # 216c <CFArrayCreateCopy@plt-0x1d664>
   35f38:	0a04a423          	sw	zero,168(s1)
   35f3c:	f7dfc0ef          	jal	32eb8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xdf8>
   35f40:	4701                	li	a4,0
   35f42:	4781                	li	a5,0
   35f44:	4681                	li	a3,0
   35f46:	4601                	li	a2,0
   35f48:	4d100593          	li	a1,1233
   35f4c:	fffea097          	auipc	ra,0xfffea
   35f50:	d54080e7          	jalr	-684(ra) # 1fca0 <MSNAppBase::postEvent(unsigned int, void*, int, long long)@plt>
   35f54:	00100513          	li	a0,1
   35f58:	0f9160ef          	jal	4c850 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x1204>
   35f5c:	02d180ef          	jal	4e788 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x7a0>
   35f60:	842a                	mv	s0,a0
   35f62:	855a                	mv	a0,s6
   35f64:	fffea097          	auipc	ra,0xfffea
   35f68:	c9c080e7          	jalr	-868(ra) # 1fc00 <MMutex::unlock()@plt>
   35f6c:	fc25                	bnez	s0,35ee4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3028>
   35f6e:	000f9797          	auipc	a5,0xf9
   35f72:	2de7a783          	lw	a5,734(a5) # 12f24c <gAirPlayModeState@@Base-0x1208> ; DATA ELF relocation: gAirPlayModeState
   35f76:	43c8                	lw	a0,4(a5)
   35f78:	00007b37          	lui	s6,0x7
   35f7c:	06400413          	li	s0,100
   35f80:	530b0b13          	addi	s6,s6,1328 # 7530 <CFArrayCreateCopy@plt-0x182a0>
   35f84:	491180ef          	jal	4ec14 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xc2c>
   35f88:	0140006f          	j	35f9c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x30e0>
   35f8c:	147d                	addi	s0,s0,-1
   35f8e:	855a                	mv	a0,s6
   35f90:	fffeb097          	auipc	ra,0xfffeb
   35f94:	5a0080e7          	jalr	1440(ra) # 21530 <usleep@plt>
   35f98:	f40406e3          	beqz	s0,35ee4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3028>
   35f9c:	16e4c783          	lbu	a5,366(s1)
   35fa0:	d7f5                	beqz	a5,35f8c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x30d0>
   35fa2:	b789                	j	35ee4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3028>
   35fa4:	5462                	lw	s0,56(sp)
   35fa6:	50f2                	lw	ra,60(sp)
   35fa8:	54d2                	lw	s1,52(sp)
   35faa:	5b02                	lw	s6,32(sp)
   35fac:	86d6                	mv	a3,s5
   35fae:	8652                	mv	a2,s4
   35fb0:	5a92                	lw	s5,36(sp)
   35fb2:	5a22                	lw	s4,40(sp)
   35fb4:	85ce                	mv	a1,s3
   35fb6:	854a                	mv	a0,s2
   35fb8:	59b2                	lw	s3,44(sp)
   35fba:	5942                	lw	s2,48(sp)
   35fbc:	4701                	li	a4,0
   35fbe:	6121                	addi	sp,sp,64
   35fc0:	a99ff06f          	j	35a58 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2b9c>
   35fc4:	0028                	addi	a0,sp,8
   35fc6:	4785                	li	a5,1
   35fc8:	4cf40c23          	sb	a5,1240(s0)
   35fcc:	fffec097          	auipc	ra,0xfffec
   35fd0:	c14080e7          	jalr	-1004(ra) # 21be0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   35fd4:	4622                	lw	a2,8(sp)
   35fd6:	86d2                	mv	a3,s4
   35fd8:	000d2597          	auipc	a1,0xd2
   35fdc:	b5058593          	addi	a1,a1,-1200 # 107b28 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa26c8> ; DATA 'recv carplay spspps:%s len:%d\n'
   35fe0:	000d1517          	auipc	a0,0xd1
   35fe4:	1b450513          	addi	a0,a0,436 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   35fe8:	fffec097          	auipc	ra,0xfffec
   35fec:	d18080e7          	jalr	-744(ra) # 21d00 <MLOGD@plt>
   35ff0:	4522                	lw	a0,8(sp)
   35ff2:	081c                	addi	a5,sp,16
   35ff4:	eef506e3          	beq	a0,a5,35ee0 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3024>
   35ff8:	fffeb097          	auipc	ra,0xfffeb
   35ffc:	818080e7          	jalr	-2024(ra) # 20810 <operator delete(void*)@plt>
   36000:	ee1ff06f          	j	35ee0 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3024>
   36004:	85aa                	mv	a1,a0
   36006:	8652                	mv	a2,s4
   36008:	00098513          	mv	a0,s3
   3600c:	fffea097          	auipc	ra,0xfffea
   36010:	894080e7          	jalr	-1900(ra) # 1f8a0 <memcmp@plt>
   36014:	ed31                	bnez	a0,36070 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x31b4>
   36016:	000d2617          	auipc	a2,0xd2
   3601a:	b3260613          	addi	a2,a2,-1230 # 107b48 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa26e8> ; DATA 'recvCarPlayVideoFrame'
   3601e:	000d2597          	auipc	a1,0xd2
   36022:	b4258593          	addi	a1,a1,-1214 # 107b60 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2700> ; DATA '%s is same spspps not close video stream!'
   36026:	000d1517          	auipc	a0,0xd1
   3602a:	16e50513          	addi	a0,a0,366 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   3602e:	94ca                	add	s1,s1,s2
   36030:	fffec097          	auipc	ra,0xfffec
   36034:	cd0080e7          	jalr	-816(ra) # 21d00 <MLOGD@plt>
   36038:	16d4c783          	lbu	a5,365(s1)
   3603c:	ee0788e3          	beqz	a5,35f2c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3070>
   36040:	000b0513          	mv	a0,s6
   36044:	fffea097          	auipc	ra,0xfffea
   36048:	bbc080e7          	jalr	-1092(ra) # 1fc00 <MMutex::unlock()@plt>
   3604c:	e99ff06f          	j	35ee4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3028>
   36050:	78004a2b          	.insn	4, 0x78004a2b
   36054:	734180ef          	jal	4e788 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x7a0>
   36058:	ec0504e3          	beqz	a0,35f20 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3064>
   3605c:	002c                	addi	a1,sp,8
   3605e:	2f00150b          	.insn	4, 0x2f00150b
   36062:	c402                	sw	zero,8(sp)
   36064:	5bd1a0ef          	jal	50e20 <logout(void*, int, char const*, void*)@@Base+0x440>
   36068:	c501                	beqz	a0,36070 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x31b4>
   3606a:	47a2                	lw	a5,8(sp)
   3606c:	f9478ce3          	beq	a5,s4,36004 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3148>
   36070:	6789                	lui	a5,0x2
   36072:	97ca                	add	a5,a5,s2
   36074:	16d7c703          	lbu	a4,365(a5) # 216d <CFArrayCreateCopy@plt-0x1d663>
   36078:	f761                	bnez	a4,36040 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3184>
   3607a:	4705                	li	a4,1
   3607c:	000b0513          	mv	a0,s6
   36080:	0a07a423          	sw	zero,168(a5)
   36084:	16078523          	sb	zero,362(a5)
   36088:	16e78623          	sb	a4,364(a5)
   3608c:	16e78923          	sb	a4,370(a5)
   36090:	fffea097          	auipc	ra,0xfffea
   36094:	b70080e7          	jalr	-1168(ra) # 1fc00 <MMutex::unlock()@plt>
   36098:	1f400593          	li	a1,500
   3609c:	06400693          	li	a3,100
   360a0:	1f400613          	li	a2,500
   360a4:	00100513          	li	a0,1
   360a8:	068180ef          	jal	4e110 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x128>
   360ac:	000f9797          	auipc	a5,0xf9
   360b0:	1a07a783          	lw	a5,416(a5) # 12f24c <gAirPlayModeState@@Base-0x1208> ; DATA ELF relocation: gAirPlayModeState
   360b4:	5462                	lw	s0,56(sp)
   360b6:	50f2                	lw	ra,60(sp)
   360b8:	54d2                	lw	s1,52(sp)
   360ba:	5942                	lw	s2,48(sp)
   360bc:	59b2                	lw	s3,44(sp)
   360be:	5a22                	lw	s4,40(sp)
   360c0:	5a92                	lw	s5,36(sp)
   360c2:	5b02                	lw	s6,32(sp)
   360c4:	43c8                	lw	a0,4(a5)
   360c6:	4581                	li	a1,0
   360c8:	04010113          	addi	sp,sp,64
   360cc:	36d1806f          	j	4ec38 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xc50>
   360d0:	4722                	lw	a4,8(sp)
   360d2:	081c                	addi	a5,sp,16
   360d4:	842a                	mv	s0,a0
   360d6:	00f70763          	beq	a4,a5,360e4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x3228>
   360da:	853a                	mv	a0,a4
   360dc:	fffea097          	auipc	ra,0xfffea
   360e0:	734080e7          	jalr	1844(ra) # 20810 <operator delete(void*)@plt>
   360e4:	00040513          	mv	a0,s0
   360e8:	fffeb097          	auipc	ra,0xfffeb
   360ec:	c28080e7          	jalr	-984(ra) # 20d10 <_Unwind_Resume@plt>
