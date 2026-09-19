
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00035c28 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2d6c>:
   35c28:	7179                	addi	sp,sp,-48
   35c2a:	d422                	sw	s0,40(sp)
   35c2c:	6409                	lui	s0,0x2
   35c2e:	942a                	add	s0,s0,a0
   35c30:	16e44783          	lbu	a5,366(s0) # 216e <CFArrayCreateCopy@plt-0x1d662>
   35c34:	d606                	sw	ra,44(sp)
   35c36:	d226                	sw	s1,36(sp)
   35c38:	d04a                	sw	s2,32(sp)
   35c3a:	ce4e                	sw	s3,28(sp)
   35c3c:	cc52                	sw	s4,24(sp)
   35c3e:	ca56                	sw	s5,20(sp)
   35c40:	c781                	beqz	a5,35c48 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2d8c>
   35c42:	16d44783          	lbu	a5,365(s0)
   35c46:	cb99                	beqz	a5,35c5c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2da0>
   35c48:	50b2                	lw	ra,44(sp)
   35c4a:	5422                	lw	s0,40(sp)
   35c4c:	5492                	lw	s1,36(sp)
   35c4e:	5902                	lw	s2,32(sp)
   35c50:	49f2                	lw	s3,28(sp)
   35c52:	4a62                	lw	s4,24(sp)
   35c54:	4ad2                	lw	s5,20(sp)
   35c56:	6145                	addi	sp,sp,48
   35c58:	00008067          	ret
   35c5c:	00050493          	mv	s1,a0
   35c60:	2f00150b          	.insn	4, 0x2f00150b
   35c64:	5a11a0ef          	jal	50a04 <logout(void*, int, char const*, void*)@@Base+0x24>
   35c68:	06050863          	beqz	a0,35cd8 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2e1c>
   35c6c:	6789                	lui	a5,0x2
   35c6e:	97a6                	add	a5,a5,s1
   35c70:	18c7a703          	lw	a4,396(a5) # 218c <CFArrayCreateCopy@plt-0x1d644>
   35c74:	1907a603          	lw	a2,400(a5)
   35c78:	000e16b7          	lui	a3,0xe1
   35c7c:	02c70733          	mul	a4,a4,a2
   35c80:	08d77a63          	bgeu	a4,a3,35d14 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2e58>
   35c84:	16a7c783          	lbu	a5,362(a5)
   35c88:	c602                	sw	zero,12(sp)
   35c8a:	0060                	addi	s0,sp,12
   35c8c:	1c078063          	beqz	a5,35e4c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2f90>
   35c90:	fffea097          	auipc	ra,0xfffea
   35c94:	550080e7          	jalr	1360(ra) # 201e0 <lockDisplayImage@plt>
   35c98:	6789                	lui	a5,0x2
   35c9a:	97a6                	add	a5,a5,s1
   35c9c:	16c7c703          	lbu	a4,364(a5) # 216c <CFArrayCreateCopy@plt-0x1d664>
   35ca0:	00040693          	mv	a3,s0
   35ca4:	01850613          	addi	a2,a0,24
   35ca8:	02450593          	addi	a1,a0,36
   35cac:	2f00150b          	.insn	4, 0x2f00150b
   35cb0:	0e81b0ef          	jal	50d98 <logout(void*, int, char const*, void*)@@Base+0x3b8>
   35cb4:	00050413          	mv	s0,a0
   35cb8:	fffec097          	auipc	ra,0xfffec
   35cbc:	228080e7          	jalr	552(ra) # 21ee0 <unLockDisplayImage@plt>
   35cc0:	16040e63          	beqz	s0,35e3c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2f80>
   35cc4:	00444683          	lbu	a3,4(s0)
   35cc8:	4632                	lw	a2,12(sp)
   35cca:	4705                	li	a4,1
   35ccc:	8afd                	andi	a3,a3,31
   35cce:	85a2                	mv	a1,s0
   35cd0:	8526                	mv	a0,s1
   35cd2:	3359                	jal	35a58 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2b9c>
   35cd4:	f75ff06f          	j	35c48 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2d8c>
   35cd8:	000d4517          	auipc	a0,0xd4
   35cdc:	34050513          	addi	a0,a0,832 # 10a018 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa4bb8> ; DATA 'sync'
   35ce0:	fffeb097          	auipc	ra,0xfffeb
   35ce4:	430080e7          	jalr	1072(ra) # 21110 <system@plt>
   35ce8:	000d2517          	auipc	a0,0xd2
   35cec:	e1c50513          	addi	a0,a0,-484 # 107b04 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa26a4> ; DATA 'echo 3 > /proc/sys/vm/drop_caches'
   35cf0:	fffeb097          	auipc	ra,0xfffeb
   35cf4:	420080e7          	jalr	1056(ra) # 21110 <system@plt>
   35cf8:	44442703          	lw	a4,1092(s0)
   35cfc:	19442683          	lw	a3,404(s0)
   35d00:	19042603          	lw	a2,400(s0)
   35d04:	18c42583          	lw	a1,396(s0)
   35d08:	2f00150b          	.insn	4, 0x2f00150b
   35d0c:	5011a0ef          	jal	50a0c <logout(void*, int, char const*, void*)@@Base+0x2c>
   35d10:	f5dff06f          	j	35c6c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2db0>
   35d14:	2b80190b          	.insn	4, 0x2b80190b
   35d18:	4c894783          	lbu	a5,1224(s2)
   35d1c:	0ff0000f          	fence
   35d20:	08078463          	beqz	a5,35da8 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2eec>
   35d24:	6789                	lui	a5,0x2
   35d26:	97a6                	add	a5,a5,s1
   35d28:	0e07a783          	lw	a5,224(a5) # 20e0 <CFArrayCreateCopy@plt-0x1d6f0>
   35d2c:	04078063          	beqz	a5,35d6c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2eb0>
   35d30:	a19fc0ef          	jal	32748 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0x688>
   35d34:	4d092783          	lw	a5,1232(s2)
   35d38:	4d492703          	lw	a4,1236(s2)
   35d3c:	40f507b3          	sub	a5,a0,a5
   35d40:	00f53533          	sltu	a0,a0,a5
   35d44:	40e585b3          	sub	a1,a1,a4
   35d48:	00a59663          	bne	a1,a0,35d54 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2e98>
   35d4c:	7cf00713          	li	a4,1999
   35d50:	00f77e63          	bgeu	a4,a5,35d6c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2eb0>
   35d54:	6409                	lui	s0,0x2
   35d56:	9426                	add	s0,s0,s1
   35d58:	0e042503          	lw	a0,224(s0) # 20e0 <CFArrayCreateCopy@plt-0x1d6f0>
   35d5c:	fffeb097          	auipc	ra,0xfffeb
   35d60:	154080e7          	jalr	340(ra) # 20eb0 <free@plt>
   35d64:	0e042023          	sw	zero,224(s0)
   35d68:	0e042223          	sw	zero,228(s0)
   35d6c:	002c                	addi	a1,sp,8
   35d6e:	2f00150b          	.insn	4, 0x2f00150b
   35d72:	6409                	lui	s0,0x2
   35d74:	9426                	add	s0,s0,s1
   35d76:	c402                	sw	zero,8(sp)
   35d78:	0a81b0ef          	jal	50e20 <logout(void*, int, char const*, void*)@@Base+0x440>
   35d7c:	0e042783          	lw	a5,224(s0) # 20e0 <CFArrayCreateCopy@plt-0x1d6f0>
   35d80:	89aa                	mv	s3,a0
   35d82:	cba9                	beqz	a5,35dd4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2f18>
   35d84:	6409                	lui	s0,0x2
   35d86:	9426                	add	s0,s0,s1
   35d88:	16a44703          	lbu	a4,362(s0) # 216a <CFArrayCreateCopy@plt-0x1d666>
   35d8c:	0e070263          	beqz	a4,35e70 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2fb4>
   35d90:	6709                	lui	a4,0x2
   35d92:	9726                	add	a4,a4,s1
   35d94:	0e472603          	lw	a2,228(a4) # 20e4 <CFArrayCreateCopy@plt-0x1d6ec>
   35d98:	4695                	li	a3,5
   35d9a:	4705                	li	a4,1
   35d9c:	85be                	mv	a1,a5
   35d9e:	8526                	mv	a0,s1
   35da0:	cb9ff0ef          	jal	35a58 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2b9c>
   35da4:	ea5ff06f          	j	35c48 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2d8c>
   35da8:	7800150b          	.insn	4, 0x7800150b
   35dac:	fffea097          	auipc	ra,0xfffea
   35db0:	4b4080e7          	jalr	1204(ra) # 20260 <__cxa_guard_acquire@plt>
   35db4:	f60508e3          	beqz	a0,35d24 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2e68>
   35db8:	991fc0ef          	jal	32748 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0x688>
   35dbc:	4ca92823          	sw	a0,1232(s2)
   35dc0:	7800150b          	.insn	4, 0x7800150b
   35dc4:	4cb92a23          	sw	a1,1236(s2)
   35dc8:	fffeb097          	auipc	ra,0xfffeb
   35dcc:	b28080e7          	jalr	-1240(ra) # 208f0 <__cxa_guard_release@plt>
   35dd0:	f55ff06f          	j	35d24 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2e68>
   35dd4:	00012623          	sw	zero,12(sp)
   35dd8:	fffea097          	auipc	ra,0xfffea
   35ddc:	408080e7          	jalr	1032(ra) # 201e0 <lockDisplayImage@plt>
   35de0:	4705                	li	a4,1
   35de2:	01850613          	addi	a2,a0,24
   35de6:	02450593          	addi	a1,a0,36
   35dea:	0074                	addi	a3,sp,12
   35dec:	2f00150b          	.insn	4, 0x2f00150b
   35df0:	7a91a0ef          	jal	50d98 <logout(void*, int, char const*, void*)@@Base+0x3b8>
   35df4:	00050a93          	mv	s5,a0
   35df8:	fffec097          	auipc	ra,0xfffec
   35dfc:	0e8080e7          	jalr	232(ra) # 21ee0 <unLockDisplayImage@plt>
   35e00:	4a32                	lw	s4,12(sp)
   35e02:	8552                	mv	a0,s4
   35e04:	fffec097          	auipc	ra,0xfffec
   35e08:	d7c080e7          	jalr	-644(ra) # 21b80 <malloc@plt>
   35e0c:	0ea42023          	sw	a0,224(s0)
   35e10:	c911                	beqz	a0,35e24 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2f68>
   35e12:	8652                	mv	a2,s4
   35e14:	000a8593          	mv	a1,s5
   35e18:	0f442223          	sw	s4,228(s0)
   35e1c:	fffec097          	auipc	ra,0xfffec
   35e20:	484080e7          	jalr	1156(ra) # 222a0 <memcpy@plt>
   35e24:	925fc0ef          	jal	32748 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0x688>
   35e28:	6789                	lui	a5,0x2
   35e2a:	97a6                	add	a5,a5,s1
   35e2c:	0e07a783          	lw	a5,224(a5) # 20e0 <CFArrayCreateCopy@plt-0x1d6f0>
   35e30:	4ca92823          	sw	a0,1232(s2)
   35e34:	4cb92a23          	sw	a1,1236(s2)
   35e38:	f40796e3          	bnez	a5,35d84 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2ec8>
   35e3c:	1f400593          	li	a1,500
   35e40:	00000513          	li	a0,0
   35e44:	5f5180ef          	jal	4ec38 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xc50>
   35e48:	e01ff06f          	j	35c48 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2d8c>
   35e4c:	00040593          	mv	a1,s0
   35e50:	2f00150b          	.insn	4, 0x2f00150b
   35e54:	7cd1a0ef          	jal	50e20 <logout(void*, int, char const*, void*)@@Base+0x440>
   35e58:	85aa                	mv	a1,a0
   35e5a:	c50d                	beqz	a0,35e84 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2fc8>
   35e5c:	00454683          	lbu	a3,4(a0)
   35e60:	4632                	lw	a2,12(sp)
   35e62:	4705                	li	a4,1
   35e64:	8afd                	andi	a3,a3,31
   35e66:	8526                	mv	a0,s1
   35e68:	bf1ff0ef          	jal	35a58 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2b9c>
   35e6c:	e25ff06f          	j	35c90 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2dd4>
   35e70:	4622                	lw	a2,8(sp)
   35e72:	4705                	li	a4,1
   35e74:	469d                	li	a3,7
   35e76:	85ce                	mv	a1,s3
   35e78:	8526                	mv	a0,s1
   35e7a:	3ef9                	jal	35a58 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2b9c>
   35e7c:	0e042783          	lw	a5,224(s0)
   35e80:	f11ff06f          	j	35d90 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2ed4>
   35e84:	1f400593          	li	a1,500
   35e88:	5b1180ef          	jal	4ec38 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xc50>
   35e8c:	e05ff06f          	j	35c90 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2dd4>
   35e90:	00050413          	mv	s0,a0
   35e94:	7800150b          	.insn	4, 0x7800150b
   35e98:	fffea097          	auipc	ra,0xfffea
   35e9c:	5a8080e7          	jalr	1448(ra) # 20440 <__cxa_guard_abort@plt>
   35ea0:	00040513          	mv	a0,s0
   35ea4:	fffeb097          	auipc	ra,0xfffeb
   35ea8:	e6c080e7          	jalr	-404(ra) # 20d10 <_Unwind_Resume@plt>
   35eac:	d7dff06f          	j	35c28 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2d6c>
