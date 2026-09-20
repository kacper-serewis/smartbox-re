
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00051f10 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x39c>:
   51f10:	14d05863          	blez	a3,52060 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x4ec>
   51f14:	7139                	addi	sp,sp,-64
   51f16:	72c1                	lui	t0,0xffff0
   51f18:	dc22                	sw	s0,56(sp)
   51f1a:	02c1                	addi	t0,t0,16 # ffff0010 <AOAProxy::sReaderBuffer@@Base+0xffebf71c>
   51f1c:	7441                	lui	s0,0xffff0
   51f1e:	6741                	lui	a4,0x10
   51f20:	da26                	sw	s1,52(sp)
   51f22:	d84a                	sw	s2,48(sp)
   51f24:	d64e                	sw	s3,44(sp)
   51f26:	d452                	sw	s4,40(sp)
   51f28:	d256                	sw	s5,36(sp)
   51f2a:	d05a                	sw	s6,32(sp)
   51f2c:	ce5e                	sw	s7,28(sp)
   51f2e:	cc62                	sw	s8,24(sp)
   51f30:	ca66                	sw	s9,20(sp)
   51f32:	9722                	add	a4,a4,s0
   51f34:	de06                	sw	ra,60(sp)
   51f36:	9116                	add	sp,sp,t0
   51f38:	00270433          	add	s0,a4,sp
   51f3c:	6ac1                	lui	s5,0x10
   51f3e:	6a11                	lui	s4,0x4
   51f40:	8bae                	mv	s7,a1
   51f42:	8b2a                	mv	s6,a0
   51f44:	84b2                	mv	s1,a2
   51f46:	0ad6095b          	.insn	4, 0x0ad6095b
   51f4a:	00440c93          	addi	s9,s0,4 # ffff0004 <AOAProxy::sReaderBuffer@@Base+0xffebf710>
   51f4e:	1aed                	addi	s5,s5,-5 # fffb <CFArrayCreateCopy@plt-0xf7d5>
   51f50:	040a0a13          	addi	s4,s4,64 # 4040 <CFArrayCreateCopy@plt-0x1b790>
   51f54:	1ae00c13          	li	s8,430
   51f58:	00640993          	addi	s3,s0,6
   51f5c:	01c0006f          	j	51f78 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x404>
   51f60:	0a17d05b          	.insn	4, 0x0a17d05b
   51f64:	0c47d65b          	.insn	4, 0x0c47d65b
   51f68:	0e57d05b          	.insn	4, 0x0e57d05b
   51f6c:	0a67d65b          	.insn	4, 0x0a67d65b
   51f70:	00248493          	addi	s1,s1,2
   51f74:	06990463          	beq	s2,s1,51fdc <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x468>
   51f78:	8656                	mv	a2,s5
   51f7a:	4581                	li	a1,0
   51f7c:	000c8513          	mv	a0,s9
   51f80:	00042023          	sw	zero,0(s0)
   51f84:	fffd0097          	auipc	ra,0xfffd0
   51f88:	08c080e7          	jalr	140(ra) # 22010 <memset@plt>
   51f8c:	0004d783          	lhu	a5,0(s1)
   51f90:	01441023          	sh	s4,0(s0)
   51f94:	01841223          	sh	s8,4(s0)
   51f98:	f7e1                	bnez	a5,51f60 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x3ec>
   51f9a:	864e                	mv	a2,s3
   51f9c:	3e800593          	li	a1,1000
   51fa0:	00000513          	li	a0,0
   51fa4:	fffd0097          	auipc	ra,0xfffd0
   51fa8:	d1c080e7          	jalr	-740(ra) # 21cc0 <makeU16Param(unsigned short, unsigned short, unsigned char*)@plt>
   51fac:	00a98633          	add	a2,s3,a0
   51fb0:	8e01                	sub	a2,a2,s0
   51fb2:	3c8627db          	.insn	4, 0x3c8627db
   51fb6:	00861813          	slli	a6,a2,0x8
   51fba:	00f86833          	or	a6,a6,a5
   51fbe:	4701                	li	a4,0
   51fc0:	4781                	li	a5,0
   51fc2:	86de                	mv	a3,s7
   51fc4:	85a2                	mv	a1,s0
   51fc6:	855a                	mv	a0,s6
   51fc8:	00248493          	addi	s1,s1,2
   51fcc:	01041123          	sh	a6,2(s0)
   51fd0:	fffcf097          	auipc	ra,0xfffcf
   51fd4:	f10080e7          	jalr	-240(ra) # 20ee0 <iAP2LinkQueueSendData@plt>
   51fd8:	fa9910e3          	bne	s2,s1,51f78 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x404>
   51fdc:	62c1                	lui	t0,0x10
   51fde:	12c1                	addi	t0,t0,-16 # fff0 <CFArrayCreateCopy@plt-0xf7e0>
   51fe0:	9116                	add	sp,sp,t0
   51fe2:	50f2                	lw	ra,60(sp)
   51fe4:	5462                	lw	s0,56(sp)
   51fe6:	54d2                	lw	s1,52(sp)
   51fe8:	5942                	lw	s2,48(sp)
   51fea:	59b2                	lw	s3,44(sp)
   51fec:	5a22                	lw	s4,40(sp)
   51fee:	5a92                	lw	s5,36(sp)
   51ff0:	5b02                	lw	s6,32(sp)
   51ff2:	4bf2                	lw	s7,28(sp)
   51ff4:	4c62                	lw	s8,24(sp)
   51ff6:	4cd2                	lw	s9,20(sp)
   51ff8:	4505                	li	a0,1
   51ffa:	6121                	addi	sp,sp,64
   51ffc:	00008067          	ret
   52000:	864e                	mv	a2,s3
   52002:	4585                	li	a1,1
   52004:	00100513          	li	a0,1
   52008:	fffcf097          	auipc	ra,0xfffcf
   5200c:	1d8080e7          	jalr	472(ra) # 211e0 <makeU8Param(unsigned short, unsigned char, unsigned char*)@plt>
   52010:	00a98633          	add	a2,s3,a0
   52014:	f9dff06f          	j	51fb0 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x43c>
   52018:	864e                	mv	a2,s3
   5201a:	05000593          	li	a1,80
   5201e:	4519                	li	a0,6
   52020:	fffd0097          	auipc	ra,0xfffd0
   52024:	ca0080e7          	jalr	-864(ra) # 21cc0 <makeU16Param(unsigned short, unsigned short, unsigned char*)@plt>
   52028:	00a98633          	add	a2,s3,a0
   5202c:	f85ff06f          	j	51fb0 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x43c>
   52030:	864e                	mv	a2,s3
   52032:	4585                	li	a1,1
   52034:	00400513          	li	a0,4
   52038:	fffcf097          	auipc	ra,0xfffcf
   5203c:	1a8080e7          	jalr	424(ra) # 211e0 <makeU8Param(unsigned short, unsigned char, unsigned char*)@plt>
   52040:	00a98633          	add	a2,s3,a0
   52044:	f6dff06f          	j	51fb0 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x43c>
   52048:	864e                	mv	a2,s3
   5204a:	4585                	li	a1,1
   5204c:	00500513          	li	a0,5
   52050:	fffcf097          	auipc	ra,0xfffcf
   52054:	190080e7          	jalr	400(ra) # 211e0 <makeU8Param(unsigned short, unsigned char, unsigned char*)@plt>
   52058:	00a98633          	add	a2,s3,a0
   5205c:	f55ff06f          	j	51fb0 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x43c>
   52060:	4505                	li	a0,1
   52062:	8082                	ret
   52064:	7179                	addi	sp,sp,-48
   52066:	cc52                	sw	s4,24(sp)
   52068:	6a41                	lui	s4,0x10
   5206a:	72c1                	lui	t0,0xffff0
   5206c:	d226                	sw	s1,36(sp)
   5206e:	010a0713          	addi	a4,s4,16 # 10010 <CFArrayCreateCopy@plt-0xf7c0>
   52072:	74c1                	lui	s1,0xffff0
   52074:	d606                	sw	ra,44(sp)
   52076:	d422                	sw	s0,40(sp)
   52078:	d04a                	sw	s2,32(sp)
   5207a:	ce4e                	sw	s3,28(sp)
   5207c:	9726                	add	a4,a4,s1
   5207e:	9116                	add	sp,sp,t0
   52080:	00270433          	add	s0,a4,sp
   52084:	6641                	lui	a2,0x10
   52086:	166d                	addi	a2,a2,-5 # fffb <CFArrayCreateCopy@plt-0xf7d5>
   52088:	892a                	mv	s2,a0
   5208a:	89ae                	mv	s3,a1
   5208c:	00440513          	addi	a0,s0,4
   52090:	00000593          	li	a1,0
   52094:	00042023          	sw	zero,0(s0)
   52098:	fffd0097          	auipc	ra,0xfffd0
   5209c:	f78080e7          	jalr	-136(ra) # 22010 <memset@plt>
   520a0:	6791                	lui	a5,0x4
   520a2:	04078793          	addi	a5,a5,64 # 4040 <CFArrayCreateCopy@plt-0x1b790>
   520a6:	00f41023          	sh	a5,0(s0)
   520aa:	6785                	lui	a5,0x1
   520ac:	94e78793          	addi	a5,a5,-1714 # 94e <CFArrayCreateCopy@plt-0x1ee82>
   520b0:	000b2517          	auipc	a0,0xb2
   520b4:	24c50513          	addi	a0,a0,588 # 1042fc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9ee9c> ; DATA 'PROXY_DEVICE_NAME'
   520b8:	00f41223          	sh	a5,4(s0)
   520bc:	fe041a23          	sh	zero,-12(s0)
   520c0:	fffce097          	auipc	ra,0xfffce
   520c4:	a90080e7          	jalr	-1392(ra) # 1fb50 <getenv@plt>
   520c8:	fea42c23          	sw	a0,-8(s0)
   520cc:	000b2517          	auipc	a0,0xb2
   520d0:	23050513          	addi	a0,a0,560 # 1042fc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9ee9c> ; DATA 'PROXY_DEVICE_NAME'
   520d4:	fffce097          	auipc	ra,0xfffce
   520d8:	a7c080e7          	jalr	-1412(ra) # 1fb50 <getenv@plt>
   520dc:	fffcf097          	auipc	ra,0xfffcf
   520e0:	334080e7          	jalr	820(ra) # 21410 <strlen@plt>
   520e4:	ff448593          	addi	a1,s1,-12 # fffefff4 <AOAProxy::sReaderBuffer@@Base+0xffebf700>
   520e8:	010a0693          	addi	a3,s4,16
   520ec:	96ae                	add	a3,a3,a1
   520ee:	00150793          	addi	a5,a0,1
   520f2:	002685b3          	add	a1,a3,sp
   520f6:	00640513          	addi	a0,s0,6
   520fa:	fef42e23          	sw	a5,-4(s0)
   520fe:	3cad                	jal	51b78 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x4>
   52100:	40850633          	sub	a2,a0,s0
   52104:	3c8627db          	.insn	4, 0x3c8627db
   52108:	00861813          	slli	a6,a2,0x8
   5210c:	00f86833          	or	a6,a6,a5
   52110:	86ce                	mv	a3,s3
   52112:	85a2                	mv	a1,s0
   52114:	854a                	mv	a0,s2
   52116:	4781                	li	a5,0
   52118:	00000713          	li	a4,0
   5211c:	01041123          	sh	a6,2(s0)
   52120:	fffcf097          	auipc	ra,0xfffcf
   52124:	dc0080e7          	jalr	-576(ra) # 20ee0 <iAP2LinkQueueSendData@plt>
   52128:	62c1                	lui	t0,0x10
   5212a:	9116                	add	sp,sp,t0
   5212c:	50b2                	lw	ra,44(sp)
   5212e:	5422                	lw	s0,40(sp)
   52130:	5492                	lw	s1,36(sp)
   52132:	5902                	lw	s2,32(sp)
   52134:	49f2                	lw	s3,28(sp)
   52136:	4a62                	lw	s4,24(sp)
   52138:	6145                	addi	sp,sp,48
   5213a:	8082                	ret
   5213c:	7179                	addi	sp,sp,-48
   5213e:	cc52                	sw	s4,24(sp)
   52140:	6a41                	lui	s4,0x10
   52142:	72c1                	lui	t0,0xffff0
   52144:	d226                	sw	s1,36(sp)
   52146:	010a0713          	addi	a4,s4,16 # 10010 <CFArrayCreateCopy@plt-0xf7c0>
   5214a:	74c1                	lui	s1,0xffff0
   5214c:	d606                	sw	ra,44(sp)
   5214e:	d422                	sw	s0,40(sp)
   52150:	d04a                	sw	s2,32(sp)
   52152:	ce4e                	sw	s3,28(sp)
   52154:	9726                	add	a4,a4,s1
   52156:	9116                	add	sp,sp,t0
   52158:	00270433          	add	s0,a4,sp
   5215c:	6641                	lui	a2,0x10
   5215e:	166d                	addi	a2,a2,-5 # fffb <CFArrayCreateCopy@plt-0xf7d5>
   52160:	892a                	mv	s2,a0
   52162:	89ae                	mv	s3,a1
   52164:	00440513          	addi	a0,s0,4
   52168:	00000593          	li	a1,0
   5216c:	00042023          	sw	zero,0(s0)
   52170:	fffd0097          	auipc	ra,0xfffd0
   52174:	ea0080e7          	jalr	-352(ra) # 22010 <memset@plt>
   52178:	6791                	lui	a5,0x4
   5217a:	04078793          	addi	a5,a5,64 # 4040 <CFArrayCreateCopy@plt-0x1b790>
   5217e:	00f41023          	sh	a5,0(s0)
   52182:	6785                	lui	a5,0x1
   52184:	ff448593          	addi	a1,s1,-12 # fffefff4 <AOAProxy::sReaderBuffer@@Base+0xffebf700>
   52188:	010a0693          	addi	a3,s4,16
   5218c:	c4e78793          	addi	a5,a5,-946 # c4e <CFArrayCreateCopy@plt-0x1eb82>
