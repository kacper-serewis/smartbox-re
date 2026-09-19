
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00035a58 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2b9c>:
   35a58:	1101                	addi	sp,sp,-32
   35a5a:	cc22                	sw	s0,24(sp)
   35a5c:	6409                	lui	s0,0x2
   35a5e:	ca26                	sw	s1,20(sp)
   35a60:	0e840493          	addi	s1,s0,232 # 20e8 <CFArrayCreateCopy@plt-0x1d6e8>
   35a64:	94aa                	add	s1,s1,a0
   35a66:	c84a                	sw	s2,16(sp)
   35a68:	892a                	mv	s2,a0
   35a6a:	8526                	mv	a0,s1
   35a6c:	ce06                	sw	ra,28(sp)
   35a6e:	c64e                	sw	s3,12(sp)
   35a70:	c452                	sw	s4,8(sp)
   35a72:	89b6                	mv	s3,a3
   35a74:	8a3a                	mv	s4,a4
   35a76:	c256                	sw	s5,4(sp)
   35a78:	c05a                	sw	s6,0(sp)
   35a7a:	8aae                	mv	s5,a1
   35a7c:	00060b13          	mv	s6,a2
   35a80:	fffec097          	auipc	ra,0xfffec
   35a84:	8f0080e7          	jalr	-1808(ra) # 21370 <MMutex::lock()@plt>
   35a88:	cc1fc0ef          	jal	32748 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0x688>
   35a8c:	008907b3          	add	a5,s2,s0
   35a90:	16e7c803          	lbu	a6,366(a5)
   35a94:	0ca7a023          	sw	a0,192(a5)
   35a98:	0cb7a223          	sw	a1,196(a5)
   35a9c:	04080463          	beqz	a6,35ae4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c28>
   35aa0:	16d7c783          	lbu	a5,365(a5)
   35aa4:	efb1                	bnez	a5,35b00 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c44>
   35aa6:	6589                	lui	a1,0x2
   35aa8:	95ca                	add	a1,a1,s2
   35aaa:	16a5c783          	lbu	a5,362(a1) # 216a <CFArrayCreateCopy@plt-0x1d666>
   35aae:	e3ad                	bnez	a5,35b10 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c54>
   35ab0:	0a79ee5b          	.insn	4, 0x0a79ee5b
   35ab4:	4445a783          	lw	a5,1092(a1)
   35ab8:	0c27ea5b          	.insn	4, 0x0c27ea5b
   35abc:	2ec0252b          	.insn	4, 0x2ec0252b
   35ac0:	c911                	beqz	a0,35ad4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c18>
   35ac2:	86da                	mv	a3,s6
   35ac4:	8656                	mv	a2,s5
   35ac6:	4589                	li	a1,2
   35ac8:	fffea097          	auipc	ra,0xfffea
   35acc:	378080e7          	jalr	888(ra) # 1fe40 <GalProxy::sendMediaCodecConfig(ServiceType, void*, unsigned int)@plt>
   35ad0:	10051663          	bnez	a0,35bdc <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2d20>
   35ad4:	6789                	lui	a5,0x2
   35ad6:	993e                	add	s2,s2,a5
   35ad8:	00100793          	li	a5,1
   35adc:	16f90523          	sb	a5,362(s2)
   35ae0:	16f90623          	sb	a5,364(s2)
   35ae4:	4462                	lw	s0,24(sp)
   35ae6:	40f2                	lw	ra,28(sp)
   35ae8:	4942                	lw	s2,16(sp)
   35aea:	49b2                	lw	s3,12(sp)
   35aec:	4a22                	lw	s4,8(sp)
   35aee:	4a92                	lw	s5,4(sp)
   35af0:	4b02                	lw	s6,0(sp)
   35af2:	8526                	mv	a0,s1
   35af4:	44d2                	lw	s1,20(sp)
   35af6:	6105                	addi	sp,sp,32
   35af8:	fffea317          	auipc	t1,0xfffea
   35afc:	10830067          	jr	264(t1) # 1fc00 <MMutex::unlock()@plt>
   35b00:	fe0a12e3          	bnez	s4,35ae4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c28>
   35b04:	6589                	lui	a1,0x2
   35b06:	95ca                	add	a1,a1,s2
   35b08:	16a5c783          	lbu	a5,362(a1) # 216a <CFArrayCreateCopy@plt-0x1d666>
   35b0c:	fa0782e3          	beqz	a5,35ab0 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2bf4>
   35b10:	16c5c783          	lbu	a5,364(a1)
   35b14:	cb95                	beqz	a5,35b48 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c8c>
   35b16:	0859ed5b          	.insn	4, 0x0859ed5b
   35b1a:	4445a783          	lw	a5,1092(a1)
   35b1e:	0c27ef5b          	.insn	4, 0x0c27ef5b
   35b22:	2ec0252b          	.insn	4, 0x2ec0252b
   35b26:	c919                	beqz	a0,35b3c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c80>
   35b28:	86da                	mv	a3,s6
   35b2a:	8656                	mv	a2,s5
   35b2c:	00200593          	li	a1,2
   35b30:	fffea097          	auipc	ra,0xfffea
   35b34:	df0080e7          	jalr	-528(ra) # 1f920 <GalProxy::sendMediaDatas(ServiceType, void*, unsigned int)@plt>
   35b38:	0c051863          	bnez	a0,35c08 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2d4c>
   35b3c:	6789                	lui	a5,0x2
   35b3e:	993e                	add	s2,s2,a5
   35b40:	16090623          	sb	zero,364(s2)
   35b44:	fa1ff06f          	j	35ae4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c28>
   35b48:	b879de5b          	.insn	4, 0xb879de5b
   35b4c:	4445a783          	lw	a5,1092(a1)
   35b50:	0827e05b          	.insn	4, 0x0827e05b
   35b54:	2ec0252b          	.insn	4, 0x2ec0252b
   35b58:	d551                	beqz	a0,35ae4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c28>
   35b5a:	86da                	mv	a3,s6
   35b5c:	8656                	mv	a2,s5
   35b5e:	4589                	li	a1,2
   35b60:	fffea097          	auipc	ra,0xfffea
   35b64:	dc0080e7          	jalr	-576(ra) # 1f920 <GalProxy::sendMediaDatas(ServiceType, void*, unsigned int)@plt>
   35b68:	f7dff06f          	j	35ae4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c28>
   35b6c:	00098613          	mv	a2,s3
   35b70:	000d2597          	auipc	a1,0xd2
   35b74:	f0458593          	addi	a1,a1,-252 # 107a74 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2614> ; DATA 'SendProxyScreenFrame wait spspps, skip frameType:%d'
   35b78:	000d1517          	auipc	a0,0xd1
   35b7c:	61c50513          	addi	a0,a0,1564 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   35b80:	fffec097          	auipc	ra,0xfffec
   35b84:	180080e7          	jalr	384(ra) # 21d00 <MLOGD@plt>
   35b88:	f5dff06f          	j	35ae4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c28>
   35b8c:	1885a883          	lw	a7,392(a1)
   35b90:	1845a803          	lw	a6,388(a1)
   35b94:	1805a783          	lw	a5,384(a1)
   35b98:	17c5a703          	lw	a4,380(a1)
   35b9c:	1905a683          	lw	a3,400(a1)
   35ba0:	18c5a603          	lw	a2,396(a1)
   35ba4:	8556                	mv	a0,s5
   35ba6:	85da                	mv	a1,s6
   35ba8:	100190ef          	jal	4eca8 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xcc0>
   35bac:	d505                	beqz	a0,35ad4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c18>
   35bae:	a03d                	j	35bdc <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2d20>
   35bb0:	00098613          	mv	a2,s3
   35bb4:	000d2597          	auipc	a1,0xd2
   35bb8:	f1c58593          	addi	a1,a1,-228 # 107ad0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2670> ; DATA 'SendProxyScreenFrame wait idr, skip frameType:%d'
   35bbc:	000d1517          	auipc	a0,0xd1
   35bc0:	5d850513          	addi	a0,a0,1496 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   35bc4:	fffec097          	auipc	ra,0xfffec
   35bc8:	13c080e7          	jalr	316(ra) # 21d00 <MLOGD@plt>
   35bcc:	f19ff06f          	j	35ae4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c28>
   35bd0:	85da                	mv	a1,s6
   35bd2:	8556                	mv	a0,s5
   35bd4:	2a8190ef          	jal	4ee7c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe94>
   35bd8:	f0dff06f          	j	35ae4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c28>
   35bdc:	00050613          	mv	a2,a0
   35be0:	000d2597          	auipc	a1,0xd2
   35be4:	e6858593          	addi	a1,a1,-408 # 107a48 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa25e8> ; DATA 'send video config frame failed, errno:%d'
   35be8:	000d1517          	auipc	a0,0xd1
   35bec:	5ac50513          	addi	a0,a0,1452 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   35bf0:	fffec097          	auipc	ra,0xfffec
   35bf4:	110080e7          	jalr	272(ra) # 21d00 <MLOGD@plt>
   35bf8:	eedff06f          	j	35ae4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c28>
   35bfc:	85da                	mv	a1,s6
   35bfe:	8556                	mv	a0,s5
   35c00:	27c190ef          	jal	4ee7c <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xe94>
   35c04:	f35ff06f          	j	35b38 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c7c>
   35c08:	00050613          	mv	a2,a0
   35c0c:	000d2597          	auipc	a1,0xd2
   35c10:	e9c58593          	addi	a1,a1,-356 # 107aa8 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2648> ; DATA 'send video key frame failed, errno:%d'
   35c14:	000d1517          	auipc	a0,0xd1
   35c18:	58050513          	addi	a0,a0,1408 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   35c1c:	fffec097          	auipc	ra,0xfffec
   35c20:	0e4080e7          	jalr	228(ra) # 21d00 <MLOGD@plt>
   35c24:	ec1ff06f          	j	35ae4 <CarPlayProxyApp::HWTestThread(void*)@@Base+0x2c28>
