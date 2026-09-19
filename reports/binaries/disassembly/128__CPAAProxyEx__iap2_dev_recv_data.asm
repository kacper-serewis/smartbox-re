
firmwares/hw501/128/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0002ff70 <iap2_dev_recv_data@@Base>:
   2ff70:	515c                	lw	a5,36(a0)
   2ff72:	7131                	addi	sp,sp,-192
   2ff74:	db26                	sw	s1,180(sp)
   2ff76:	4784                	lw	s1,8(a5)
   2ff78:	d94a                	sw	s2,176(sp)
   2ff7a:	df06                	sw	ra,188(sp)
   2ff7c:	dd22                	sw	s0,184(sp)
   2ff7e:	d74e                	sw	s3,172(sp)
   2ff80:	d552                	sw	s4,168(sp)
   2ff82:	d356                	sw	s5,164(sp)
   2ff84:	d15a                	sw	s6,160(sp)
   2ff86:	cf5e                	sw	s7,156(sp)
   2ff88:	0744c783          	lbu	a5,116(s1)
   2ff8c:	72fd                	lui	t0,0xfffff
   2ff8e:	9116                	add	sp,sp,t0
   2ff90:	00068913          	mv	s2,a3
   2ff94:	04d78a63          	beq	a5,a3,2ffe8 <iap2_dev_recv_data@@Base+0x78>
   2ff98:	0754c783          	lbu	a5,117(s1)
   2ff9c:	02d78263          	beq	a5,a3,2ffc0 <iap2_dev_recv_data@@Base+0x50>
   2ffa0:	00100513          	li	a0,1
   2ffa4:	6285                	lui	t0,0x1
   2ffa6:	9116                	add	sp,sp,t0
   2ffa8:	50fa                	lw	ra,188(sp)
   2ffaa:	546a                	lw	s0,184(sp)
   2ffac:	54da                	lw	s1,180(sp)
   2ffae:	594a                	lw	s2,176(sp)
   2ffb0:	59ba                	lw	s3,172(sp)
   2ffb2:	5a2a                	lw	s4,168(sp)
   2ffb4:	5a9a                	lw	s5,164(sp)
   2ffb6:	5b0a                	lw	s6,160(sp)
   2ffb8:	4bfa                	lw	s7,156(sp)
   2ffba:	6129                	addi	sp,sp,192
   2ffbc:	00008067          	ret
   2ffc0:	000fa797          	auipc	a5,0xfa
   2ffc4:	1507a783          	lw	a5,336(a5) # 12a110 <gOverCarplayLink@@Base-0xc98> ; DATA ELF relocation: gOverCarplayLink
   2ffc8:	4388                	lw	a0,0(a5)
   2ffca:	d979                	beqz	a0,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   2ffcc:	000fa797          	auipc	a5,0xfa
   2ffd0:	09c7a783          	lw	a5,156(a5) # 12a068 <gOverCarPlayBufferSession@@Base-0xd3c> ; DATA ELF relocation: gOverCarPlayBufferSession
   2ffd4:	0007c683          	lbu	a3,0(a5)
   2ffd8:	4701                	li	a4,0
   2ffda:	4781                	li	a5,0
   2ffdc:	ffff1097          	auipc	ra,0xffff1
   2ffe0:	d34080e7          	jalr	-716(ra) # 20d10 <iAP2LinkQueueSendData@plt>
   2ffe4:	fbdff06f          	j	2ffa0 <iap2_dev_recv_data@@Base+0x30>
   2ffe8:	0045d403          	lhu	s0,4(a1)
   2ffec:	0005c783          	lbu	a5,0(a1)
   2fff0:	3c84275b          	.insn	4, 0x3c84275b
   2fff4:	20f4245b          	.insn	4, 0x20f4245b
   2fff8:	8aaa                	mv	s5,a0
   2fffa:	89ae                	mv	s3,a1
   2fffc:	8a32                	mv	s4,a2
   2fffe:	8c59                	or	s0,s0,a4
   30000:	4607d85b          	.insn	4, 0x4607d85b
   30004:	0b44d783          	lhu	a5,180(s1)
   30008:	cbd1                	beqz	a5,3009c <iap2_dev_recv_data@@Base+0x12c>
   3000a:	0b64d703          	lhu	a4,182(s1)
   3000e:	014786b3          	add	a3,a5,s4
   30012:	f8d767e3          	bltu	a4,a3,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30016:	0b04a503          	lw	a0,176(s1)
   3001a:	8652                	mv	a2,s4
   3001c:	85ce                	mv	a1,s3
   3001e:	953e                	add	a0,a0,a5
   30020:	ffff2097          	auipc	ra,0xffff2
   30024:	060080e7          	jalr	96(ra) # 22080 <memcpy@plt>
   30028:	0b44d703          	lhu	a4,180(s1)
   3002c:	0b64d783          	lhu	a5,182(s1)
   30030:	9752                	add	a4,a4,s4
   30032:	0b84d603          	lhu	a2,184(s1)
   30036:	3c07275b          	.insn	4, 0x3c07275b
   3003a:	86d2                	mv	a3,s4
   3003c:	000d3597          	auipc	a1,0xd3
   30040:	65858593          	addi	a1,a1,1624 # 103694 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0190> ; DATA 'recv buffer msg id = %04x datalen=%d recvlen:%d msglen=%d\n'
   30044:	000d3517          	auipc	a0,0xd3
   30048:	e1050513          	addi	a0,a0,-496 # 102e54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f950> ; DATA 'ProxyIAP2'
   3004c:	0ae49a23          	sh	a4,180(s1)
   30050:	ffff2097          	auipc	ra,0xffff2
   30054:	ac0080e7          	jalr	-1344(ra) # 21b10 <MLOGD@plt>
   30058:	0b64d783          	lhu	a5,182(s1)
   3005c:	0b44da03          	lhu	s4,180(s1)
   30060:	f4fa10e3          	bne	s4,a5,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30064:	0b04a983          	lw	s3,176(s1)
   30068:	0b84d403          	lhu	s0,184(s1)
   3006c:	0280006f          	j	30094 <iap2_dev_recv_data@@Base+0x124>
   30070:	0015c783          	lbu	a5,1(a1)
   30074:	f807e85b          	.insn	4, 0xf807e85b
   30078:	00500793          	li	a5,5
   3007c:	f8c7f4e3          	bgeu	a5,a2,30004 <iap2_dev_recv_data@@Base+0x94>
   30080:	0025d783          	lhu	a5,2(a1)
   30084:	3c87ab5b          	.insn	4, 0x3c87ab5b
   30088:	20f7a7db          	.insn	4, 0x20f7a7db
   3008c:	0167eb33          	or	s6,a5,s6
   30090:	7d666863          	bltu	a2,s6,30860 <iap2_dev_recv_data@@Base+0x8f0>
   30094:	0a04aa23          	sw	zero,180(s1)
   30098:	0a049c23          	sh	zero,184(s1)
   3009c:	67c1                	lui	a5,0x10
   3009e:	17ed                	addi	a5,a5,-5 # fffb <CFArrayCreateCopy@plt-0xf615>
   300a0:	0ef41263          	bne	s0,a5,30184 <iap2_dev_recv_data@@Base+0x214>
   300a4:	8652                	mv	a2,s4
   300a6:	85ce                	mv	a1,s3
   300a8:	00040513          	mv	a0,s0
   300ac:	dfcfe0ef          	jal	2e6a8 <_HandleProxyEventConnectionClose@@Base+0x3f24>
   300b0:	7b7d                	lui	s6,0xfffff
   300b2:	f26b0793          	addi	a5,s6,-218 # ffffef26 <AOAProxy::sReaderBuffer@@Base+0xffed3682>
   300b6:	97a2                	add	a5,a5,s0
   300b8:	3c07a7db          	.insn	4, 0x3c07a7db
   300bc:	470d                	li	a4,3
   300be:	14f77b63          	bgeu	a4,a5,30214 <iap2_dev_recv_data@@Base+0x2a4>
   300c2:	77ed                	lui	a5,0xffffb
   300c4:	40078793          	addi	a5,a5,1024 # ffffb400 <AOAProxy::sReaderBuffer@@Base+0xffecfb5c>
   300c8:	97a2                	add	a5,a5,s0
   300ca:	3c07a7db          	.insn	4, 0x3c07a7db
   300ce:	46a5                	li	a3,9
   300d0:	2cf6e663          	bltu	a3,a5,3039c <iap2_dev_recv_data@@Base+0x42c>
   300d4:	000fa497          	auipc	s1,0xfa
   300d8:	03c4a483          	lw	s1,60(s1) # 12a110 <gOverCarplayLink@@Base-0xc98> ; DATA ELF relocation: gOverCarplayLink
   300dc:	409c                	lw	a5,0(s1)
   300de:	2a078363          	beqz	a5,30384 <iap2_dev_recv_data@@Base+0x414>
   300e2:	6b85                	lui	s7,0x1
   300e4:	080b8613          	addi	a2,s7,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   300e8:	965a                	add	a2,a2,s6
   300ea:	080c                	addi	a1,sp,16
   300ec:	00b60433          	add	s0,a2,a1
   300f0:	00440513          	addi	a0,s0,4
   300f4:	7fc00613          	li	a2,2044
   300f8:	00000593          	li	a1,0
   300fc:	00042023          	sw	zero,0(s0)
   30100:	ffff2097          	auipc	ra,0xffff2
   30104:	d10080e7          	jalr	-752(ra) # 21e10 <memset@plt>
   30108:	fc0b0693          	addi	a3,s6,-64
   3010c:	080b8593          	addi	a1,s7,128
   30110:	95b6                	add	a1,a1,a3
   30112:	0814                	addi	a3,sp,16
   30114:	000fa797          	auipc	a5,0xfa
   30118:	1487a783          	lw	a5,328(a5) # 12a25c <gMediaUniqueId@@Base-0xab4> ; DATA ELF relocation: gMediaUniqueId
   3011c:	fa8b0613          	addi	a2,s6,-88
   30120:	96ae                	add	a3,a3,a1
   30122:	080b8593          	addi	a1,s7,128
   30126:	0007a803          	lw	a6,0(a5)
   3012a:	95b2                	add	a1,a1,a2
   3012c:	4f9c                	lw	a5,24(a5)
   3012e:	000d3897          	auipc	a7,0xd3
   30132:	39a88893          	addi	a7,a7,922 # 1034c8 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9ffc4> ; DATA 'E9746442-B1A7-4E38-95CE-D1274F5E4A1A-MPB-14.4'
   30136:	0810                	addi	a2,sp,16
   30138:	962e                	add	a2,a2,a1
   3013a:	fb142423          	sw	a7,-88(s0)
   3013e:	8722                	mv	a4,s0
   30140:	000d3897          	auipc	a7,0xd3
   30144:	3b888893          	addi	a7,a7,952 # 1034f8 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9fff4> ; DATA 'E9746442-B1A7-4E38-95CE-D1274F5E4A1A-4954524C-14.4'
   30148:	85d2                	mv	a1,s4
   3014a:	854e                	mv	a0,s3
   3014c:	fb142623          	sw	a7,-84(s0)
   30150:	fd042023          	sw	a6,-64(s0)
   30154:	fcf42223          	sw	a5,-60(s0)
   30158:	2e0220ef          	jal	52438 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x1eb4>
   3015c:	862a                	mv	a2,a0
   3015e:	4505                	li	a0,1
   30160:	e40602e3          	beqz	a2,2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30164:	000fa797          	auipc	a5,0xfa
   30168:	ed87a783          	lw	a5,-296(a5) # 12a03c <gOverCarPlayCtrlSession@@Base-0xd69> ; DATA ELF relocation: gOverCarPlayCtrlSession
   3016c:	0007c683          	lbu	a3,0(a5)
   30170:	4088                	lw	a0,0(s1)
   30172:	4781                	li	a5,0
   30174:	4701                	li	a4,0
   30176:	85a2                	mv	a1,s0
   30178:	ffff1097          	auipc	ra,0xffff1
   3017c:	b98080e7          	jalr	-1128(ra) # 20d10 <iAP2LinkQueueSendData@plt>
   30180:	e25ff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30184:	874a                	mv	a4,s2
   30186:	86d2                	mv	a3,s4
   30188:	00040613          	mv	a2,s0
   3018c:	000d3597          	auipc	a1,0xd3
   30190:	54458593          	addi	a1,a1,1348 # 1036d0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa01cc> ; DATA 'recv msg id = %04x datalen=%d session=%d\n'
   30194:	000d3517          	auipc	a0,0xd3
   30198:	cc050513          	addi	a0,a0,-832 # 102e54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f950> ; DATA 'ProxyIAP2'
   3019c:	ffff2097          	auipc	ra,0xffff2
   301a0:	974080e7          	jalr	-1676(ra) # 21b10 <MLOGD@plt>
   301a4:	8652                	mv	a2,s4
   301a6:	85ce                	mv	a1,s3
   301a8:	00040513          	mv	a0,s0
   301ac:	cfcfe0ef          	jal	2e6a8 <_HandleProxyEventConnectionClose@@Base+0x3f24>
   301b0:	7771                	lui	a4,0xffffc
   301b2:	eac70793          	addi	a5,a4,-340 # ffffbeac <AOAProxy::sReaderBuffer@@Base+0xffed0608>
   301b6:	97a2                	add	a5,a5,s0
   301b8:	3c07a7db          	.insn	4, 0x3c07a7db
   301bc:	46c1                	li	a3,16
   301be:	04f6e363          	bltu	a3,a5,30204 <iap2_dev_recv_data@@Base+0x294>
   301c2:	000fa797          	auipc	a5,0xfa
   301c6:	f4e7a783          	lw	a5,-178(a5) # 12a110 <gOverCarplayLink@@Base-0xc98> ; DATA ELF relocation: gOverCarplayLink
   301ca:	4388                	lw	a0,0(a5)
   301cc:	04050c63          	beqz	a0,30224 <iap2_dev_recv_data@@Base+0x2b4>
   301d0:	000fa797          	auipc	a5,0xfa
   301d4:	e6c7a783          	lw	a5,-404(a5) # 12a03c <gOverCarPlayCtrlSession@@Base-0xd69> ; DATA ELF relocation: gOverCarPlayCtrlSession
   301d8:	0007c683          	lbu	a3,0(a5)
   301dc:	6285                	lui	t0,0x1
   301de:	9116                	add	sp,sp,t0
   301e0:	50fa                	lw	ra,188(sp)
   301e2:	546a                	lw	s0,184(sp)
   301e4:	54da                	lw	s1,180(sp)
   301e6:	594a                	lw	s2,176(sp)
   301e8:	5a9a                	lw	s5,164(sp)
   301ea:	5b0a                	lw	s6,160(sp)
   301ec:	4bfa                	lw	s7,156(sp)
   301ee:	8652                	mv	a2,s4
   301f0:	85ce                	mv	a1,s3
   301f2:	5a2a                	lw	s4,168(sp)
   301f4:	59ba                	lw	s3,172(sp)
   301f6:	4781                	li	a5,0
   301f8:	4701                	li	a4,0
   301fa:	6129                	addi	sp,sp,192
   301fc:	ffff1317          	auipc	t1,0xffff1
   30200:	b1430067          	jr	-1260(t1) # 20d10 <iAP2LinkQueueSendData@plt>
   30204:	e9070793          	addi	a5,a4,-368
   30208:	97a2                	add	a5,a5,s0
   3020a:	3c07a7db          	.insn	4, 0x3c07a7db
   3020e:	4709                	li	a4,2
   30210:	eaf760e3          	bltu	a4,a5,300b0 <iap2_dev_recv_data@@Base+0x140>
   30214:	000fa797          	auipc	a5,0xfa
   30218:	efc7a783          	lw	a5,-260(a5) # 12a110 <gOverCarplayLink@@Base-0xc98> ; DATA ELF relocation: gOverCarplayLink
   3021c:	4388                	lw	a0,0(a5)
   3021e:	f94d                	bnez	a0,301d0 <iap2_dev_recv_data@@Base+0x260>
   30220:	d81ff06f          	j	2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30224:	6791                	lui	a5,0x4
   30226:	15478713          	addi	a4,a5,340 # 4154 <CFArrayCreateCopy@plt-0x1b4bc>
   3022a:	70e40763          	beq	s0,a4,30938 <iap2_dev_recv_data@@Base+0x9c8>
   3022e:	15778793          	addi	a5,a5,343
   30232:	00f41963          	bne	s0,a5,30244 <iap2_dev_recv_data@@Base+0x2d4>
   30236:	85ca                	mv	a1,s2
   30238:	000a8513          	mv	a0,s5
   3023c:	268210ef          	jal	514a4 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0xf20>
   30240:	4505                	li	a0,1
   30242:	b38d                	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30244:	6789                	lui	a5,0x2
   30246:	d0178793          	addi	a5,a5,-767 # 1d01 <CFArrayCreateCopy@plt-0x1d90f>
   3024a:	d4f41be3          	bne	s0,a5,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   3024e:	50e8                	lw	a0,100(s1)
   30250:	00050a63          	beqz	a0,30264 <iap2_dev_recv_data@@Base+0x2f4>
   30254:	ffff1097          	auipc	ra,0xffff1
   30258:	a8c080e7          	jalr	-1396(ra) # 20ce0 <free@plt>
   3025c:	0604a223          	sw	zero,100(s1)
   30260:	0604a423          	sw	zero,104(s1)
   30264:	54e8                	lw	a0,108(s1)
   30266:	c909                	beqz	a0,30278 <iap2_dev_recv_data@@Base+0x308>
   30268:	ffff1097          	auipc	ra,0xffff1
   3026c:	a78080e7          	jalr	-1416(ra) # 20ce0 <free@plt>
   30270:	0604a623          	sw	zero,108(s1)
   30274:	0604a823          	sw	zero,112(s1)
   30278:	0bc4a503          	lw	a0,188(s1)
   3027c:	00050863          	beqz	a0,3028c <iap2_dev_recv_data@@Base+0x31c>
   30280:	ffff1097          	auipc	ra,0xffff1
   30284:	a60080e7          	jalr	-1440(ra) # 20ce0 <free@plt>
   30288:	0a04ae23          	sw	zero,188(s1)
   3028c:	0804a503          	lw	a0,128(s1)
   30290:	00050863          	beqz	a0,302a0 <iap2_dev_recv_data@@Base+0x330>
   30294:	ffff1097          	auipc	ra,0xffff1
   30298:	a4c080e7          	jalr	-1460(ra) # 20ce0 <free@plt>
   3029c:	0804a023          	sw	zero,128(s1)
   302a0:	08448313          	addi	t1,s1,132
   302a4:	0bc48593          	addi	a1,s1,188
   302a8:	08048893          	addi	a7,s1,128
   302ac:	07e48813          	addi	a6,s1,126
   302b0:	07048793          	addi	a5,s1,112
   302b4:	06c48713          	addi	a4,s1,108
   302b8:	06848693          	addi	a3,s1,104
   302bc:	06448613          	addi	a2,s1,100
   302c0:	854e                	mv	a0,s3
   302c2:	c01a                	sw	t1,0(sp)
   302c4:	179220ef          	jal	52c3c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x26b8>
   302c8:	0804a583          	lw	a1,128(s1)
   302cc:	08058ee3          	beqz	a1,30b68 <iap2_dev_recv_data@@Base+0xbf8>
   302d0:	6605                	lui	a2,0x1
   302d2:	747d                	lui	s0,0xfffff
   302d4:	08060693          	addi	a3,a2,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   302d8:	96a2                	add	a3,a3,s0
   302da:	0810                	addi	a2,sp,16
   302dc:	00c68433          	add	s0,a3,a2
   302e0:	0844d603          	lhu	a2,132(s1)
   302e4:	00040513          	mv	a0,s0
   302e8:	ffff1097          	auipc	ra,0xffff1
   302ec:	708080e7          	jalr	1800(ra) # 219f0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   302f0:	0844d683          	lhu	a3,132(s1)
   302f4:	00042603          	lw	a2,0(s0) # fffff000 <AOAProxy::sReaderBuffer@@Base+0xffed375c>
   302f8:	000d3597          	auipc	a1,0xd3
   302fc:	46858593          	addi	a1,a1,1128 # 103760 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa025c> ; DATA 'recv loc info:%s len:%d\n'
   30300:	000d3517          	auipc	a0,0xd3
   30304:	b5450513          	addi	a0,a0,-1196 # 102e54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f950> ; DATA 'ProxyIAP2'
   30308:	ffff2097          	auipc	ra,0xffff2
   3030c:	808080e7          	jalr	-2040(ra) # 21b10 <MLOGD@plt>
   30310:	6585                	lui	a1,0x1
   30312:	77fd                	lui	a5,0xfffff
   30314:	08058613          	addi	a2,a1,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30318:	963e                	add	a2,a2,a5
   3031a:	080c                	addi	a1,sp,16
   3031c:	00b607b3          	add	a5,a2,a1
   30320:	4388                	lw	a0,0(a5)
   30322:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffed3764>
   30324:	00f50663          	beq	a0,a5,30330 <iap2_dev_recv_data@@Base+0x3c0>
   30328:	ffff0097          	auipc	ra,0xffff0
   3032c:	318080e7          	jalr	792(ra) # 20640 <operator delete(void*)@plt>
   30330:	0804a783          	lw	a5,128(s1)
   30334:	cb91                	beqz	a5,30348 <iap2_dev_recv_data@@Base+0x3d8>
   30336:	faf00713          	li	a4,-81
   3033a:	00e78223          	sb	a4,4(a5)
   3033e:	0804a783          	lw	a5,128(s1)
   30342:	5769                	li	a4,-6
   30344:	00e782a3          	sb	a4,5(a5)
   30348:	0c44a783          	lw	a5,196(s1)
   3034c:	c791                	beqz	a5,30358 <iap2_dev_recv_data@@Base+0x3e8>
   3034e:	0c84a503          	lw	a0,200(s1)
   30352:	45a1                	li	a1,8
   30354:	000780e7          	jalr	a5
   30358:	85ca                	mv	a1,s2
   3035a:	8556                	mv	a0,s5
   3035c:	550200ef          	jal	508ac <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x328>
   30360:	0764c783          	lbu	a5,118(s1)
   30364:	0027e45b          	.insn	4, 0x0027e45b
   30368:	7e40006f          	j	30b4c <iap2_dev_recv_data@@Base+0xbdc>
   3036c:	58b4                	lw	a3,112(s1)
   3036e:	54f0                	lw	a2,108(s1)
   30370:	85ca                	mv	a1,s2
   30372:	8556                	mv	a0,s5
   30374:	718230ef          	jal	53a8c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x3508>
   30378:	0bc4a503          	lw	a0,188(s1)
   3037c:	b6dfe0ef          	jal	2eee8 <_HandleProxyEventConnectionClose@@Base+0x4764>
   30380:	4505                	li	a0,1
   30382:	b10d                	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30384:	6795                	lui	a5,0x5
   30386:	c0078793          	addi	a5,a5,-1024 # 4c00 <CFArrayCreateCopy@plt-0x1aa10>
   3038a:	c0f41be3          	bne	s0,a5,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   3038e:	85ca                	mv	a1,s2
   30390:	000a8513          	mv	a0,s5
   30394:	535210ef          	jal	520c8 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x1b44>
   30398:	4505                	li	a0,1
   3039a:	b129                	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   3039c:	77ed                	lui	a5,0xffffb
   3039e:	97a2                	add	a5,a5,s0
   303a0:	3c07a7db          	.insn	4, 0x3c07a7db
   303a4:	04f76c63          	bltu	a4,a5,303fc <iap2_dev_recv_data@@Base+0x48c>
   303a8:	000fa797          	auipc	a5,0xfa
   303ac:	d687a783          	lw	a5,-664(a5) # 12a110 <gOverCarplayLink@@Base-0xc98> ; DATA ELF relocation: gOverCarplayLink
   303b0:	0007a503          	lw	a0,0(a5)
   303b4:	e0051ee3          	bnez	a0,301d0 <iap2_dev_recv_data@@Base+0x260>
   303b8:	6795                	lui	a5,0x5
   303ba:	fcf415e3          	bne	s0,a5,30384 <iap2_dev_recv_data@@Base+0x414>
   303be:	6585                	lui	a1,0x1
   303c0:	747d                	lui	s0,0xfffff
   303c2:	08058613          	addi	a2,a1,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   303c6:	9622                	add	a2,a2,s0
   303c8:	080c                	addi	a1,sp,16
   303ca:	00b60433          	add	s0,a2,a1
   303ce:	8522                	mv	a0,s0
   303d0:	06000613          	li	a2,96
   303d4:	00000593          	li	a1,0
   303d8:	ffff2097          	auipc	ra,0xffff2
   303dc:	a38080e7          	jalr	-1480(ra) # 21e10 <memset@plt>
   303e0:	8622                	mv	a2,s0
   303e2:	85d2                	mv	a1,s4
   303e4:	00098513          	mv	a0,s3
   303e8:	254210ef          	jal	5163c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x10b8>
   303ec:	8622                	mv	a2,s0
   303ee:	85ca                	mv	a1,s2
   303f0:	000a8513          	mv	a0,s5
   303f4:	550210ef          	jal	51944 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x13c0>
   303f8:	4505                	li	a0,1
   303fa:	b66d                	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   303fc:	6bc1                	lui	s7,0x10
   303fe:	ffbb8793          	addi	a5,s7,-5 # fffb <CFArrayCreateCopy@plt-0xf615>
   30402:	68f40763          	beq	s0,a5,30a90 <iap2_dev_recv_data@@Base+0xb20>
   30406:	ff0b8793          	addi	a5,s7,-16
   3040a:	68f40363          	beq	s0,a5,30a90 <iap2_dev_recv_data@@Base+0xb20>
   3040e:	6795                	lui	a5,0x5
   30410:	70378713          	addi	a4,a5,1795 # 5703 <CFArrayCreateCopy@plt-0x19f0d>
   30414:	4ae40263          	beq	s0,a4,308b8 <iap2_dev_recv_data@@Base+0x948>
   30418:	40877e63          	bgeu	a4,s0,30834 <iap2_dev_recv_data@@Base+0x8c4>
   3041c:	67ad                	lui	a5,0xb
   3041e:	a0378713          	addi	a4,a5,-1533 # aa03 <CFArrayCreateCopy@plt-0x14c0d>
   30422:	4ae40363          	beq	s0,a4,308c8 <iap2_dev_recv_data@@Base+0x958>
   30426:	02877d63          	bgeu	a4,s0,30460 <iap2_dev_recv_data@@Base+0x4f0>
   3042a:	e0078793          	addi	a5,a5,-512
   3042e:	4cf40d63          	beq	s0,a5,30908 <iap2_dev_recv_data@@Base+0x998>
   30432:	67ad                	lui	a5,0xb
   30434:	e0378713          	addi	a4,a5,-509 # ae03 <CFArrayCreateCopy@plt-0x1480d>
   30438:	06e41e63          	bne	s0,a4,304b4 <iap2_dev_recv_data@@Base+0x544>
   3043c:	0a848783          	lb	a5,168(s1)
   30440:	b60790e3          	bnez	a5,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30444:	0a44a683          	lw	a3,164(s1)
   30448:	0a04a603          	lw	a2,160(s1)
   3044c:	4785                	li	a5,1
   3044e:	85ca                	mv	a1,s2
   30450:	000a8513          	mv	a0,s5
   30454:	0af48423          	sb	a5,168(s1)
   30458:	4c8200ef          	jal	50920 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x39c>
   3045c:	4505                	li	a0,1
   3045e:	b699                	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30460:	679d                	lui	a5,0x7
   30462:	80278793          	addi	a5,a5,-2046 # 6802 <CFArrayCreateCopy@plt-0x18e0e>
   30466:	5af40763          	beq	s0,a5,30a14 <iap2_dev_recv_data@@Base+0xaa4>
   3046a:	67ad                	lui	a5,0xb
   3046c:	a0178793          	addi	a5,a5,-1535 # aa01 <CFArrayCreateCopy@plt-0x14c0f>
   30470:	0cf41c63          	bne	s0,a5,30548 <iap2_dev_recv_data@@Base+0x5d8>
   30474:	0029d783          	lhu	a5,2(s3)
   30478:	000d3597          	auipc	a1,0xd3
   3047c:	29c58593          	addi	a1,a1,668 # 103714 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0210> ; DATA 'recv authentication certificate len:%d'
   30480:	00879613          	slli	a2,a5,0x8
   30484:	3c87a7db          	.insn	4, 0x3c87a7db
   30488:	8e5d                	or	a2,a2,a5
   3048a:	1659                	addi	a2,a2,-10
   3048c:	3c06265b          	.insn	4, 0x3c06265b
   30490:	000d3517          	auipc	a0,0xd3
   30494:	9c450513          	addi	a0,a0,-1596 # 102e54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f950> ; DATA 'ProxyIAP2'
   30498:	00c12e23          	sw	a2,28(sp)
   3049c:	ffff1097          	auipc	ra,0xffff1
   304a0:	674080e7          	jalr	1652(ra) # 21b10 <MLOGD@plt>
   304a4:	4672                	lw	a2,28(sp)
   304a6:	85ca                	mv	a1,s2
   304a8:	000a8513          	mv	a0,s5
   304ac:	1f0200ef          	jal	5069c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x118>
   304b0:	4505                	li	a0,1
   304b2:	bccd                	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   304b4:	a0678793          	addi	a5,a5,-1530
   304b8:	aef414e3          	bne	s0,a5,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   304bc:	6685                	lui	a3,0x1
   304be:	747d                	lui	s0,0xfffff
   304c0:	08068613          	addi	a2,a3,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   304c4:	9622                	add	a2,a2,s0
   304c6:	0818                	addi	a4,sp,16
   304c8:	fc040593          	addi	a1,s0,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffed371c>
   304cc:	00e60433          	add	s0,a2,a4
   304d0:	08068613          	addi	a2,a3,128
   304d4:	962e                	add	a2,a2,a1
   304d6:	00e605b3          	add	a1,a2,a4
   304da:	854e                	mv	a0,s3
   304dc:	fc041023          	sh	zero,-64(s0)
   304e0:	3b8230ef          	jal	53898 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x3314>
   304e4:	6a050663          	beqz	a0,30b90 <iap2_dev_recv_data@@Base+0xc20>
   304e8:	fc045603          	lhu	a2,-64(s0)
   304ec:	85aa                	mv	a1,a0
   304ee:	8522                	mv	a0,s0
   304f0:	ffff1097          	auipc	ra,0xffff1
   304f4:	500080e7          	jalr	1280(ra) # 219f0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   304f8:	fc045683          	lhu	a3,-64(s0)
   304fc:	00042603          	lw	a2,0(s0)
   30500:	000d3597          	auipc	a1,0xd3
   30504:	23c58593          	addi	a1,a1,572 # 10373c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0238> ; DATA 'recv mfi serial number:%s len:%d\n'
   30508:	000d3517          	auipc	a0,0xd3
   3050c:	94c50513          	addi	a0,a0,-1716 # 102e54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f950> ; DATA 'ProxyIAP2'
   30510:	ffff1097          	auipc	ra,0xffff1
   30514:	600080e7          	jalr	1536(ra) # 21b10 <MLOGD@plt>
   30518:	6585                	lui	a1,0x1
   3051a:	77fd                	lui	a5,0xfffff
   3051c:	08058593          	addi	a1,a1,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30520:	95be                	add	a1,a1,a5
   30522:	0814                	addi	a3,sp,16
   30524:	00d587b3          	add	a5,a1,a3
   30528:	4388                	lw	a0,0(a5)
   3052a:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffed3764>
   3052c:	00f50663          	beq	a0,a5,30538 <iap2_dev_recv_data@@Base+0x5c8>
   30530:	ffff0097          	auipc	ra,0xffff0
   30534:	110080e7          	jalr	272(ra) # 20640 <operator delete(void*)@plt>
   30538:	4601                	li	a2,0
   3053a:	85ca                	mv	a1,s2
   3053c:	000a8513          	mv	a0,s5
   30540:	1f9210ef          	jal	51f38 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x19b4>
   30544:	4505                	li	a0,1
   30546:	bcb9                	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30548:	679d                	lui	a5,0x7
   3054a:	80078793          	addi	a5,a5,-2048 # 6800 <CFArrayCreateCopy@plt-0x18e10>
   3054e:	a4f419e3          	bne	s0,a5,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30552:	6b85                	lui	s7,0x1
   30554:	797d                	lui	s2,0xfffff
   30556:	080b8593          	addi	a1,s7,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   3055a:	95ca                	add	a1,a1,s2
   3055c:	0814                	addi	a3,sp,16
   3055e:	00d58433          	add	s0,a1,a3
   30562:	6605                	lui	a2,0x1
   30564:	1671                	addi	a2,a2,-4 # ffc <CFArrayCreateCopy@plt-0x1e614>
   30566:	4581                	li	a1,0
   30568:	00440513          	addi	a0,s0,4
   3056c:	fa041023          	sh	zero,-96(s0)
   30570:	fa041123          	sh	zero,-94(s0)
   30574:	fa041223          	sh	zero,-92(s0)
   30578:	f8040fa3          	sb	zero,-97(s0)
   3057c:	00042023          	sw	zero,0(s0)
   30580:	ffff2097          	auipc	ra,0xffff2
   30584:	890080e7          	jalr	-1904(ra) # 21e10 <memset@plt>
   30588:	fa690813          	addi	a6,s2,-90 # ffffefa6 <AOAProxy::sReaderBuffer@@Base+0xffed3702>
   3058c:	080b8513          	addi	a0,s7,128
   30590:	9542                	add	a0,a0,a6
   30592:	081c                	addi	a5,sp,16
   30594:	00f50833          	add	a6,a0,a5
   30598:	f9f90713          	addi	a4,s2,-97
   3059c:	080b8513          	addi	a0,s7,128
   305a0:	953a                	add	a0,a0,a4
   305a2:	0818                	addi	a4,sp,16
   305a4:	972a                	add	a4,a4,a0
   305a6:	fa490693          	addi	a3,s2,-92
   305aa:	080b8513          	addi	a0,s7,128
   305ae:	9536                	add	a0,a0,a3
   305b0:	0814                	addi	a3,sp,16
   305b2:	96aa                	add	a3,a3,a0
   305b4:	fa290613          	addi	a2,s2,-94
   305b8:	080b8513          	addi	a0,s7,128
   305bc:	9532                	add	a0,a0,a2
   305be:	0810                	addi	a2,sp,16
   305c0:	fa090593          	addi	a1,s2,-96
   305c4:	962a                	add	a2,a2,a0
   305c6:	080b8513          	addi	a0,s7,128
   305ca:	952e                	add	a0,a0,a1
   305cc:	080c                	addi	a1,sp,16
   305ce:	87a2                	mv	a5,s0
   305d0:	95aa                	add	a1,a1,a0
   305d2:	854e                	mv	a0,s3
   305d4:	fa041323          	sh	zero,-90(s0)
   305d8:	17d220ef          	jal	52f54 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x29d0>
   305dc:	fa645903          	lhu	s2,-90(s0)
   305e0:	85a2                	mv	a1,s0
   305e2:	864a                	mv	a2,s2
   305e4:	fc040513          	addi	a0,s0,-64
   305e8:	fa045983          	lhu	s3,-96(s0)
   305ec:	fa245a03          	lhu	s4,-94(s0)
   305f0:	fa445a83          	lhu	s5,-92(s0)
   305f4:	f9f44b03          	lbu	s6,-97(s0)
   305f8:	ffff1097          	auipc	ra,0xffff1
   305fc:	3f8080e7          	jalr	1016(ra) # 219f0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   30600:	fc042883          	lw	a7,-64(s0)
   30604:	884a                	mv	a6,s2
   30606:	87da                	mv	a5,s6
   30608:	8756                	mv	a4,s5
   3060a:	86d2                	mv	a3,s4
   3060c:	00098613          	mv	a2,s3
   30610:	000d3597          	auipc	a1,0xd3
   30614:	19c58593          	addi	a1,a1,412 # 1037ac <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa02a8> ; DATA 'parse hid info, id:%d vid:%d pid:%d countrycode:%d reportlen:%d report:%s\n'
   30618:	000d3517          	auipc	a0,0xd3
   3061c:	83c50513          	addi	a0,a0,-1988 # 102e54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f950> ; DATA 'ProxyIAP2'
   30620:	ffff1097          	auipc	ra,0xffff1
   30624:	4f0080e7          	jalr	1264(ra) # 21b10 <MLOGD@plt>
   30628:	fc042503          	lw	a0,-64(s0)
   3062c:	fc840793          	addi	a5,s0,-56
   30630:	00f50663          	beq	a0,a5,3063c <iap2_dev_recv_data@@Base+0x6cc>
   30634:	ffff0097          	auipc	ra,0xffff0
   30638:	00c080e7          	jalr	12(ra) # 20640 <operator delete(void*)@plt>
   3063c:	747d                	lui	s0,0xfffff
   3063e:	6b05                	lui	s6,0x1
   30640:	fc040413          	addi	s0,s0,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffed371c>
   30644:	080b0613          	addi	a2,s6,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30648:	9622                	add	a2,a2,s0
   3064a:	0814                	addi	a3,sp,16
   3064c:	00d60433          	add	s0,a2,a3
   30650:	00040513          	mv	a0,s0
   30654:	000d3597          	auipc	a1,0xd3
   30658:	fdc58593          	addi	a1,a1,-36 # 103630 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa012c> ; DATA 'hid'
   3065c:	ffff1097          	auipc	ra,0xffff1
   30660:	3b4080e7          	jalr	948(ra) # 21a10 <MString::MString(char const*)@plt>
   30664:	00040593          	mv	a1,s0
   30668:	000fa517          	auipc	a0,0xfa
   3066c:	b7052503          	lw	a0,-1168(a0) # 12a1d8 <gHIDDevicesConfig@@Base-0xb68> ; DATA ELF relocation: gHIDDevicesConfig
   30670:	ffff2097          	auipc	ra,0xffff2
   30674:	b90080e7          	jalr	-1136(ra) # 22200 <MIniConfig::beginGroup(MString const&)@plt>
   30678:	77fd                	lui	a5,0xfffff
   3067a:	080b0593          	addi	a1,s6,128
   3067e:	95be                	add	a1,a1,a5
   30680:	01010613          	addi	a2,sp,16
   30684:	00c58733          	add	a4,a1,a2
   30688:	fc072503          	lw	a0,-64(a4)
   3068c:	fc870793          	addi	a5,a4,-56
   30690:	00f50663          	beq	a0,a5,3069c <iap2_dev_recv_data@@Base+0x72c>
   30694:	ffff0097          	auipc	ra,0xffff0
   30698:	fac080e7          	jalr	-84(ra) # 20640 <operator delete(void*)@plt>
   3069c:	747d                	lui	s0,0xfffff
   3069e:	6b85                	lui	s7,0x1
   306a0:	fc040913          	addi	s2,s0,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffed371c>
   306a4:	080b8593          	addi	a1,s7,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   306a8:	0814                	addi	a3,sp,16
   306aa:	95ca                	add	a1,a1,s2
   306ac:	00d58933          	add	s2,a1,a3
   306b0:	00090513          	mv	a0,s2
   306b4:	000d3597          	auipc	a1,0xd3
   306b8:	fa858593          	addi	a1,a1,-88 # 10365c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0158> ; DATA 'report'
   306bc:	ffff1097          	auipc	ra,0xffff1
   306c0:	354080e7          	jalr	852(ra) # 21a10 <MString::MString(char const*)@plt>
   306c4:	080b8613          	addi	a2,s7,128
   306c8:	9622                	add	a2,a2,s0
   306ca:	080c                	addi	a1,sp,16
   306cc:	00b60433          	add	s0,a2,a1
   306d0:	000d4697          	auipc	a3,0xd4
   306d4:	54468693          	addi	a3,a3,1348 # 104c14 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1710>
   306d8:	00090613          	mv	a2,s2
   306dc:	000fa597          	auipc	a1,0xfa
   306e0:	afc5a583          	lw	a1,-1284(a1) # 12a1d8 <gHIDDevicesConfig@@Base-0xb68> ; DATA ELF relocation: gHIDDevicesConfig
   306e4:	fa840513          	addi	a0,s0,-88
   306e8:	ffff1097          	auipc	ra,0xffff1
   306ec:	108080e7          	jalr	264(ra) # 217f0 <MIniConfig::value(MString const&, char const*)@plt>
   306f0:	fc042503          	lw	a0,-64(s0)
   306f4:	fc840793          	addi	a5,s0,-56
   306f8:	00f50663          	beq	a0,a5,30704 <iap2_dev_recv_data@@Base+0x794>
   306fc:	ffff0097          	auipc	ra,0xffff0
   30700:	f44080e7          	jalr	-188(ra) # 20640 <operator delete(void*)@plt>
   30704:	000fa517          	auipc	a0,0xfa
   30708:	ad452503          	lw	a0,-1324(a0) # 12a1d8 <gHIDDevicesConfig@@Base-0xb68> ; DATA ELF relocation: gHIDDevicesConfig
   3070c:	ffff0097          	auipc	ra,0xffff0
   30710:	5b4080e7          	jalr	1460(ra) # 20cc0 <MIniConfig::endGroup()@plt>
   30714:	0ac4a783          	lw	a5,172(s1)
   30718:	cfa5                	beqz	a5,30790 <iap2_dev_recv_data@@Base+0x820>
   3071a:	6405                	lui	s0,0x1
   3071c:	75fd                	lui	a1,0xfffff
   3071e:	08040693          	addi	a3,s0,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30722:	0810                	addi	a2,sp,16
   30724:	00b686b3          	add	a3,a3,a1
   30728:	00c685b3          	add	a1,a3,a2
   3072c:	fa65d603          	lhu	a2,-90(a1) # ffffefa6 <AOAProxy::sReaderBuffer@@Base+0xffed3702>
   30730:	fc058513          	addi	a0,a1,-64
   30734:	ffff1097          	auipc	ra,0xffff1
   30738:	2bc080e7          	jalr	700(ra) # 219f0 <MString::fromHexBytes(unsigned char const*, int)@plt>
   3073c:	77fd                	lui	a5,0xfffff
   3073e:	08040593          	addi	a1,s0,128
   30742:	95be                	add	a1,a1,a5
   30744:	01010693          	addi	a3,sp,16
   30748:	00d587b3          	add	a5,a1,a3
   3074c:	fac7a603          	lw	a2,-84(a5) # ffffefac <AOAProxy::sReaderBuffer@@Base+0xffed3708>
   30750:	fc47a703          	lw	a4,-60(a5)
   30754:	fc07a403          	lw	s0,-64(a5)
   30758:	46e60e63          	beq	a2,a4,30bd4 <iap2_dev_recv_data@@Base+0xc64>
   3075c:	6685                	lui	a3,0x1
   3075e:	77fd                	lui	a5,0xfffff
   30760:	08068693          	addi	a3,a3,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30764:	96be                	add	a3,a3,a5
   30766:	0810                	addi	a2,sp,16
   30768:	00c687b3          	add	a5,a3,a2
   3076c:	fc878793          	addi	a5,a5,-56 # ffffefc8 <AOAProxy::sReaderBuffer@@Base+0xffed3724>
   30770:	00f40863          	beq	s0,a5,30780 <iap2_dev_recv_data@@Base+0x810>
   30774:	00040513          	mv	a0,s0
   30778:	ffff0097          	auipc	ra,0xffff0
   3077c:	ec8080e7          	jalr	-312(ra) # 20640 <operator delete(void*)@plt>
   30780:	0ac4a503          	lw	a0,172(s1)
   30784:	00050663          	beqz	a0,30790 <iap2_dev_recv_data@@Base+0x820>
   30788:	ffff1097          	auipc	ra,0xffff1
   3078c:	178080e7          	jalr	376(ra) # 21900 <CFRelease@plt>
   30790:	6405                	lui	s0,0x1
   30792:	787d                	lui	a6,0xfffff
   30794:	08040613          	addi	a2,s0,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30798:	9642                	add	a2,a2,a6
   3079a:	080c                	addi	a1,sp,16
   3079c:	00b60833          	add	a6,a2,a1
   307a0:	fa085503          	lhu	a0,-96(a6) # ffffefa0 <AOAProxy::sReaderBuffer@@Base+0xffed36fc>
   307a4:	65c1                	lui	a1,0x10
   307a6:	fa685883          	lhu	a7,-90(a6)
   307aa:	f9f84783          	lbu	a5,-97(a6)
   307ae:	fa485703          	lhu	a4,-92(a6)
   307b2:	fa285683          	lhu	a3,-94(a6)
   307b6:	faa58593          	addi	a1,a1,-86 # ffaa <CFArrayCreateCopy@plt-0xf666>
   307ba:	95aa                	add	a1,a1,a0
   307bc:	000d3317          	auipc	t1,0xd3
   307c0:	35430313          	addi	t1,t1,852 # 103b10 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa060c>
   307c4:	0a04a623          	sw	zero,172(s1)
   307c8:	000d4617          	auipc	a2,0xd4
   307cc:	44c60613          	addi	a2,a2,1100 # 104c14 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1710>
   307d0:	0ac48513          	addi	a0,s1,172
   307d4:	00612023          	sw	t1,0(sp)
   307d8:	ffff2097          	auipc	ra,0xffff2
   307dc:	8c8080e7          	jalr	-1848(ra) # 220a0 <AirPlayInfoArrayAddHIDDevice@plt>
   307e0:	77fd                	lui	a5,0xfffff
   307e2:	08040693          	addi	a3,s0,128
   307e6:	96be                	add	a3,a3,a5
   307e8:	01010613          	addi	a2,sp,16
   307ec:	00c687b3          	add	a5,a3,a2
   307f0:	fa67d803          	lhu	a6,-90(a5) # ffffefa6 <AOAProxy::sReaderBuffer@@Base+0xffed3702>
   307f4:	f9f7c703          	lbu	a4,-97(a5)
   307f8:	fa47d683          	lhu	a3,-92(a5)
   307fc:	fa27d603          	lhu	a2,-94(a5)
   30800:	fa07d583          	lhu	a1,-96(a5)
   30804:	0bc4a503          	lw	a0,188(s1)
   30808:	a00ff0ef          	jal	2fa08 <_HandleProxyEventConnectionClose@@Base+0x5284>
   3080c:	6605                	lui	a2,0x1
   3080e:	77fd                	lui	a5,0xfffff
   30810:	08060593          	addi	a1,a2,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30814:	95be                	add	a1,a1,a5
   30816:	0814                	addi	a3,sp,16
   30818:	00d58733          	add	a4,a1,a3
   3081c:	fa872503          	lw	a0,-88(a4)
   30820:	fb070793          	addi	a5,a4,-80
   30824:	f6f50e63          	beq	a0,a5,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30828:	ffff0097          	auipc	ra,0xffff0
   3082c:	e18080e7          	jalr	-488(ra) # 20640 <operator delete(void*)@plt>
   30830:	f70ff06f          	j	2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30834:	6711                	lui	a4,0x4
   30836:	30170713          	addi	a4,a4,769 # 4301 <CFArrayCreateCopy@plt-0x1b30f>
   3083a:	10e40763          	beq	s0,a4,30948 <iap2_dev_recv_data@@Base+0x9d8>
   3083e:	9e8773e3          	bgeu	a4,s0,30224 <iap2_dev_recv_data@@Base+0x2b4>
   30842:	e0378793          	addi	a5,a5,-509 # ffffee03 <AOAProxy::sReaderBuffer@@Base+0xffed355f>
   30846:	b6f419e3          	bne	s0,a5,303b8 <iap2_dev_recv_data@@Base+0x448>
   3084a:	07e4d603          	lhu	a2,126(s1)
   3084e:	85ca                	mv	a1,s2
   30850:	000a8513          	mv	a0,s5
   30854:	094220ef          	jal	528e8 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x2364>
   30858:	00100513          	li	a0,1
   3085c:	f48ff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30860:	0b04a503          	lw	a0,176(s1)
   30864:	000b0593          	mv	a1,s6
   30868:	fffef097          	auipc	ra,0xfffef
   3086c:	2b8080e7          	jalr	696(ra) # 1fb20 <realloc@plt>
   30870:	0aa4a823          	sw	a0,176(s1)
   30874:	3c050263          	beqz	a0,30c38 <iap2_dev_recv_data@@Base+0xcc8>
   30878:	8652                	mv	a2,s4
   3087a:	85ce                	mv	a1,s3
   3087c:	0a849c23          	sh	s0,184(s1)
   30880:	0b649b23          	sh	s6,182(s1)
   30884:	ffff1097          	auipc	ra,0xffff1
   30888:	7fc080e7          	jalr	2044(ra) # 22080 <memcpy@plt>
   3088c:	875a                	mv	a4,s6
   3088e:	86d2                	mv	a3,s4
   30890:	00040613          	mv	a2,s0
   30894:	000d3597          	auipc	a1,0xd3
   30898:	dd058593          	addi	a1,a1,-560 # 103664 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0160> ; DATA 'recv buffer msg id = %04x datalen=%d msglen=%d\n'
   3089c:	000d2517          	auipc	a0,0xd2
   308a0:	5b850513          	addi	a0,a0,1464 # 102e54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f950> ; DATA 'ProxyIAP2'
   308a4:	0b449a23          	sh	s4,180(s1)
   308a8:	ffff1097          	auipc	ra,0xffff1
   308ac:	268080e7          	jalr	616(ra) # 21b10 <MLOGD@plt>
   308b0:	00100513          	li	a0,1
   308b4:	ef0ff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   308b8:	85ca                	mv	a1,s2
   308ba:	8556                	mv	a0,s5
   308bc:	5a8200ef          	jal	50e64 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x8e0>
   308c0:	00100513          	li	a0,1
   308c4:	ee0ff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   308c8:	09e4c783          	lbu	a5,158(s1)
   308cc:	22079663          	bnez	a5,30af8 <iap2_dev_recv_data@@Base+0xb88>
   308d0:	0c44a783          	lw	a5,196(s1)
   308d4:	c791                	beqz	a5,308e0 <iap2_dev_recv_data@@Base+0x970>
   308d6:	0c84a503          	lw	a0,200(s1)
   308da:	45a9                	li	a1,10
   308dc:	000780e7          	jalr	a5
   308e0:	4605                	li	a2,1
   308e2:	85ca                	mv	a1,s2
   308e4:	000a8513          	mv	a0,s5
   308e8:	6d51f0ef          	jal	507bc <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x238>
   308ec:	0764c783          	lbu	a5,118(s1)
   308f0:	3227d05b          	.insn	4, 0x3227d05b
   308f4:	0744c583          	lbu	a1,116(s1)
   308f8:	000a8513          	mv	a0,s5
   308fc:	7411f0ef          	jal	5083c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x2b8>
   30900:	00100513          	li	a0,1
   30904:	ea0ff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30908:	0a04a503          	lw	a0,160(s1)
   3090c:	00050a63          	beqz	a0,30920 <iap2_dev_recv_data@@Base+0x9b0>
   30910:	ffff0097          	auipc	ra,0xffff0
   30914:	3d0080e7          	jalr	976(ra) # 20ce0 <free@plt>
   30918:	0a04a023          	sw	zero,160(s1)
   3091c:	0a04a223          	sw	zero,164(s1)
   30920:	00098513          	mv	a0,s3
   30924:	0a448613          	addi	a2,s1,164
   30928:	0a048593          	addi	a1,s1,160
   3092c:	588220ef          	jal	52eb4 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x2930>
   30930:	00100513          	li	a0,1
   30934:	e70ff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30938:	85ca                	mv	a1,s2
   3093a:	8556                	mv	a0,s5
   3093c:	04d200ef          	jal	51188 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0xc04>
   30940:	00100513          	li	a0,1
   30944:	e60ff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30948:	6a85                	lui	s5,0x1
   3094a:	080a8613          	addi	a2,s5,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   3094e:	965a                	add	a2,a2,s6
   30950:	080c                	addi	a1,sp,16
   30952:	00b60433          	add	s0,a2,a1
   30956:	00440513          	addi	a0,s0,4
   3095a:	07c00613          	li	a2,124
   3095e:	4581                	li	a1,0
   30960:	fc042023          	sw	zero,-64(s0)
   30964:	fc042223          	sw	zero,-60(s0)
   30968:	fc042423          	sw	zero,-56(s0)
   3096c:	fc042623          	sw	zero,-52(s0)
   30970:	fc042823          	sw	zero,-48(s0)
   30974:	fc042a23          	sw	zero,-44(s0)
   30978:	fc042c23          	sw	zero,-40(s0)
   3097c:	fc042e23          	sw	zero,-36(s0)
   30980:	fe042023          	sw	zero,-32(s0)
   30984:	fe042223          	sw	zero,-28(s0)
   30988:	fe042423          	sw	zero,-24(s0)
   3098c:	fe042623          	sw	zero,-20(s0)
   30990:	fe042823          	sw	zero,-16(s0)
   30994:	fe042a23          	sw	zero,-12(s0)
   30998:	fe042c23          	sw	zero,-8(s0)
   3099c:	fe042e23          	sw	zero,-4(s0)
   309a0:	00042023          	sw	zero,0(s0)
   309a4:	ffff1097          	auipc	ra,0xffff1
   309a8:	46c080e7          	jalr	1132(ra) # 21e10 <memset@plt>
   309ac:	fc0b0493          	addi	s1,s6,-64
   309b0:	080a8613          	addi	a2,s5,128
   309b4:	9626                	add	a2,a2,s1
   309b6:	0814                	addi	a3,sp,16
   309b8:	00d604b3          	add	s1,a2,a3
   309bc:	080a8593          	addi	a1,s5,128
   309c0:	fa8b0693          	addi	a3,s6,-88
   309c4:	95b6                	add	a1,a1,a3
   309c6:	0810                	addi	a2,sp,16
   309c8:	00c586b3          	add	a3,a1,a2
   309cc:	854e                	mv	a0,s3
   309ce:	8626                	mv	a2,s1
   309d0:	85d2                	mv	a1,s4
   309d2:	8722                	mv	a4,s0
   309d4:	fa042423          	sw	zero,-88(s0)
   309d8:	725220ef          	jal	538fc <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x3378>
   309dc:	fa842683          	lw	a3,-88(s0)
   309e0:	8626                	mv	a2,s1
   309e2:	8722                	mv	a4,s0
   309e4:	000d3597          	auipc	a1,0xd3
   309e8:	d9858593          	addi	a1,a1,-616 # 10377c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0278> ; DATA 'recv carplay start session ip:%s port:%d pi:%s\n'
   309ec:	000d2517          	auipc	a0,0xd2
   309f0:	46850513          	addi	a0,a0,1128 # 102e54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f950> ; DATA 'ProxyIAP2'
   309f4:	ffff1097          	auipc	ra,0xffff1
   309f8:	11c080e7          	jalr	284(ra) # 21b10 <MLOGD@plt>
   309fc:	fa842603          	lw	a2,-88(s0)
   30a00:	db767063          	bgeu	a2,s7,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30a04:	86a2                	mv	a3,s0
   30a06:	85a6                	mv	a1,s1
   30a08:	00200513          	li	a0,2
   30a0c:	a1df50ef          	jal	26428 <_IAP2LinkStatusChangeCallBack@@Base+0x880>
   30a10:	d90ff06f          	j	2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30a14:	6b05                	lui	s6,0x1
   30a16:	74fd                	lui	s1,0xfffff
   30a18:	080b0593          	addi	a1,s6,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30a1c:	95a6                	add	a1,a1,s1
   30a1e:	0810                	addi	a2,sp,16
   30a20:	00c58433          	add	s0,a1,a2
   30a24:	6605                	lui	a2,0x1
   30a26:	1671                	addi	a2,a2,-4 # ffc <CFArrayCreateCopy@plt-0x1e614>
   30a28:	00000593          	li	a1,0
   30a2c:	00440513          	addi	a0,s0,4
   30a30:	fa041423          	sh	zero,-88(s0)
   30a34:	00042023          	sw	zero,0(s0)
   30a38:	ffff1097          	auipc	ra,0xffff1
   30a3c:	3d8080e7          	jalr	984(ra) # 21e10 <memset@plt>
   30a40:	fc048693          	addi	a3,s1,-64 # ffffefc0 <AOAProxy::sReaderBuffer@@Base+0xffed371c>
   30a44:	fa848593          	addi	a1,s1,-88
   30a48:	080b0613          	addi	a2,s6,128
   30a4c:	080b0713          	addi	a4,s6,128
   30a50:	972e                	add	a4,a4,a1
   30a52:	9636                	add	a2,a2,a3
   30a54:	080c                	addi	a1,sp,16
   30a56:	0814                	addi	a3,sp,16
   30a58:	96b2                	add	a3,a3,a2
   30a5a:	95ba                	add	a1,a1,a4
   30a5c:	8622                	mv	a2,s0
   30a5e:	854e                	mv	a0,s3
   30a60:	000f9917          	auipc	s2,0xf9
   30a64:	6bc92903          	lw	s2,1724(s2) # 12a11c <gProxyDelegate@@Base-0x420> ; DATA ELF relocation: gProxyDelegate
   30a68:	fc041023          	sh	zero,-64(s0)
   30a6c:	4c1220ef          	jal	5372c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x31a8>
   30a70:	00492783          	lw	a5,4(s2)
   30a74:	9782                	jalr	a5
   30a76:	84aa                	mv	s1,a0
   30a78:	d2050463          	beqz	a0,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30a7c:	fc045683          	lhu	a3,-64(s0)
   30a80:	12069c63          	bnez	a3,30bb8 <iap2_dev_recv_data@@Base+0xc48>
   30a84:	00892783          	lw	a5,8(s2)
   30a88:	8526                	mv	a0,s1
   30a8a:	9782                	jalr	a5
   30a8c:	d14ff06f          	j	2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30a90:	000f9417          	auipc	s0,0xf9
   30a94:	68042403          	lw	s0,1664(s0) # 12a110 <gOverCarplayLink@@Base-0xc98> ; DATA ELF relocation: gOverCarplayLink
   30a98:	00042783          	lw	a5,0(s0)
   30a9c:	d0078263          	beqz	a5,2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30aa0:	d10d948b          	.insn	4, 0xd10d948b
   30aa4:	0004c503          	lbu	a0,0(s1)
   30aa8:	0ff00793          	li	a5,255
   30aac:	02f50063          	beq	a0,a5,30acc <iap2_dev_recv_data@@Base+0xb5c>
   30ab0:	0015545b          	.insn	4, 0x0015545b
   30ab4:	cecff06f          	j	2ffa0 <iap2_dev_recv_data@@Base+0x30>
   30ab8:	000f9797          	auipc	a5,0xf9
   30abc:	5847a783          	lw	a5,1412(a5) # 12a03c <gOverCarPlayCtrlSession@@Base-0xd69> ; DATA ELF relocation: gOverCarPlayCtrlSession
   30ac0:	0007c683          	lbu	a3,0(a5)
   30ac4:	00042503          	lw	a0,0(s0)
   30ac8:	f14ff06f          	j	301dc <iap2_dev_recv_data@@Base+0x26c>
   30acc:	000d3517          	auipc	a0,0xd3
   30ad0:	c3050513          	addi	a0,a0,-976 # 1036fc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa01f8> ; DATA 'PROXY_ENABLE_GPS_SYNC'
   30ad4:	fffef097          	auipc	ra,0xfffef
   30ad8:	eac080e7          	jalr	-340(ra) # 1f980 <getenv@plt>
   30adc:	14050463          	beqz	a0,30c24 <iap2_dev_recv_data@@Base+0xcb4>
   30ae0:	4629                	li	a2,10
   30ae2:	4581                	li	a1,0
   30ae4:	ffff1097          	auipc	ra,0xffff1
   30ae8:	fbc080e7          	jalr	-68(ra) # 21aa0 <strtol@plt>
   30aec:	00a03533          	snez	a0,a0
   30af0:	00a48023          	sb	a0,0(s1)
   30af4:	fbdff06f          	j	30ab0 <iap2_dev_recv_data@@Base+0xb40>
   30af8:	0904a503          	lw	a0,144(s1)
   30afc:	00050663          	beqz	a0,30b08 <iap2_dev_recv_data@@Base+0xb98>
   30b00:	ffff0097          	auipc	ra,0xffff0
   30b04:	1e0080e7          	jalr	480(ra) # 20ce0 <free@plt>
   30b08:	0029d783          	lhu	a5,2(s3)
   30b0c:	3c87a75b          	.insn	4, 0x3c87a75b
   30b10:	20f7a45b          	.insn	4, 0x20f7a45b
   30b14:	8c59                	or	s0,s0,a4
   30b16:	1459                	addi	s0,s0,-10
   30b18:	00040513          	mv	a0,s0
   30b1c:	0884aa23          	sw	s0,148(s1)
   30b20:	ffff1097          	auipc	ra,0xffff1
   30b24:	e70080e7          	jalr	-400(ra) # 21990 <malloc@plt>
   30b28:	08a4a823          	sw	a0,144(s1)
   30b2c:	10050263          	beqz	a0,30c30 <iap2_dev_recv_data@@Base+0xcc0>
   30b30:	00040613          	mv	a2,s0
   30b34:	00a98593          	addi	a1,s3,10
   30b38:	ffff1097          	auipc	ra,0xffff1
   30b3c:	548080e7          	jalr	1352(ra) # 22080 <memcpy@plt>
   30b40:	00100513          	li	a0,1
   30b44:	08048f23          	sb	zero,158(s1)
   30b48:	c5cff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30b4c:	0684d583          	lhu	a1,104(s1)
   30b50:	0644a503          	lw	a0,100(s1)
   30b54:	3bc210ef          	jal	51f10 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x198c>
   30b58:	85ca                	mv	a1,s2
   30b5a:	862a                	mv	a2,a0
   30b5c:	000a8513          	mv	a0,s5
   30b60:	3d8210ef          	jal	51f38 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x19b4>
   30b64:	815ff06f          	j	30378 <iap2_dev_recv_data@@Base+0x408>
   30b68:	0844d683          	lhu	a3,132(s1)
   30b6c:	000d4617          	auipc	a2,0xd4
   30b70:	0a860613          	addi	a2,a2,168 # 104c14 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1710>
   30b74:	000d3597          	auipc	a1,0xd3
   30b78:	bec58593          	addi	a1,a1,-1044 # 103760 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa025c> ; DATA 'recv loc info:%s len:%d\n'
   30b7c:	000d2517          	auipc	a0,0xd2
   30b80:	2d850513          	addi	a0,a0,728 # 102e54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f950> ; DATA 'ProxyIAP2'
   30b84:	ffff1097          	auipc	ra,0xffff1
   30b88:	f8c080e7          	jalr	-116(ra) # 21b10 <MLOGD@plt>
   30b8c:	fa4ff06f          	j	30330 <iap2_dev_recv_data@@Base+0x3c0>
   30b90:	fc045683          	lhu	a3,-64(s0)
   30b94:	000d1617          	auipc	a2,0xd1
   30b98:	02460613          	addi	a2,a2,36 # 101bb8 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9e6b4> ; DATA 'null'
   30b9c:	000d3597          	auipc	a1,0xd3
   30ba0:	ba058593          	addi	a1,a1,-1120 # 10373c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa0238> ; DATA 'recv mfi serial number:%s len:%d\n'
   30ba4:	000d2517          	auipc	a0,0xd2
   30ba8:	2b050513          	addi	a0,a0,688 # 102e54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f950> ; DATA 'ProxyIAP2'
   30bac:	ffff1097          	auipc	ra,0xffff1
   30bb0:	f64080e7          	jalr	-156(ra) # 21b10 <MLOGD@plt>
   30bb4:	985ff06f          	j	30538 <iap2_dev_recv_data@@Base+0x5c8>
   30bb8:	fa845583          	lhu	a1,-88(s0)
   30bbc:	67c1                	lui	a5,0x10
   30bbe:	faa78793          	addi	a5,a5,-86 # ffaa <CFArrayCreateCopy@plt-0xf666>
   30bc2:	8622                	mv	a2,s0
   30bc4:	00f585b3          	add	a1,a1,a5
   30bc8:	ffff0097          	auipc	ra,0xffff0
   30bcc:	488080e7          	jalr	1160(ra) # 21050 <AirPlayReceiverSessionSendHIDReport@plt>
   30bd0:	eb5ff06f          	j	30a84 <iap2_dev_recv_data@@Base+0xb14>
   30bd4:	ca11                	beqz	a2,30be8 <iap2_dev_recv_data@@Base+0xc78>
   30bd6:	fa87a503          	lw	a0,-88(a5)
   30bda:	85a2                	mv	a1,s0
   30bdc:	fffef097          	auipc	ra,0xfffef
   30be0:	af4080e7          	jalr	-1292(ra) # 1f6d0 <memcmp@plt>
   30be4:	b6051ce3          	bnez	a0,3075c <iap2_dev_recv_data@@Base+0x7ec>
   30be8:	6685                	lui	a3,0x1
   30bea:	77fd                	lui	a5,0xfffff
   30bec:	08068693          	addi	a3,a3,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30bf0:	96be                	add	a3,a3,a5
   30bf2:	0810                	addi	a2,sp,16
   30bf4:	00c687b3          	add	a5,a3,a2
   30bf8:	fc878793          	addi	a5,a5,-56 # ffffefc8 <AOAProxy::sReaderBuffer@@Base+0xffed3724>
   30bfc:	c0f408e3          	beq	s0,a5,3080c <iap2_dev_recv_data@@Base+0x89c>
   30c00:	00040513          	mv	a0,s0
   30c04:	ffff0097          	auipc	ra,0xffff0
   30c08:	a3c080e7          	jalr	-1476(ra) # 20640 <operator delete(void*)@plt>
   30c0c:	c01ff06f          	j	3080c <iap2_dev_recv_data@@Base+0x89c>
   30c10:	58b4                	lw	a3,112(s1)
   30c12:	54f0                	lw	a2,108(s1)
   30c14:	8556                	mv	a0,s5
   30c16:	85ca                	mv	a1,s2
   30c18:	675220ef          	jal	53a8c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x3508>
   30c1c:	00100513          	li	a0,1
   30c20:	b84ff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30c24:	d00db80b          	.insn	4, 0xd00db80b
   30c28:	00100513          	li	a0,1
   30c2c:	b78ff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30c30:	0804aa23          	sw	zero,148(s1)
   30c34:	f0dff06f          	j	30b40 <iap2_dev_recv_data@@Base+0xbd0>
   30c38:	00000513          	li	a0,0
   30c3c:	b68ff06f          	j	2ffa4 <iap2_dev_recv_data@@Base+0x34>
   30c40:	6685                	lui	a3,0x1
   30c42:	77fd                	lui	a5,0xfffff
   30c44:	08068593          	addi	a1,a3,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30c48:	95be                	add	a1,a1,a5
   30c4a:	0810                	addi	a2,sp,16
   30c4c:	00c58733          	add	a4,a1,a2
   30c50:	87ba                	mv	a5,a4
   30c52:	fc072703          	lw	a4,-64(a4)
   30c56:	fc878793          	addi	a5,a5,-56 # ffffefc8 <AOAProxy::sReaderBuffer@@Base+0xffed3724>
   30c5a:	842a                	mv	s0,a0
   30c5c:	00f70863          	beq	a4,a5,30c6c <iap2_dev_recv_data@@Base+0xcfc>
   30c60:	00070513          	mv	a0,a4
   30c64:	ffff0097          	auipc	ra,0xffff0
   30c68:	9dc080e7          	jalr	-1572(ra) # 20640 <operator delete(void*)@plt>
   30c6c:	00040513          	mv	a0,s0
   30c70:	ffff0097          	auipc	ra,0xffff0
   30c74:	ed0080e7          	jalr	-304(ra) # 20b40 <_Unwind_Resume@plt>
   30c78:	6585                	lui	a1,0x1
   30c7a:	77fd                	lui	a5,0xfffff
   30c7c:	08058613          	addi	a2,a1,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30c80:	963e                	add	a2,a2,a5
   30c82:	0814                	addi	a3,sp,16
   30c84:	00d60733          	add	a4,a2,a3
   30c88:	87ba                	mv	a5,a4
   30c8a:	fa872703          	lw	a4,-88(a4)
   30c8e:	fb078793          	addi	a5,a5,-80 # ffffefb0 <AOAProxy::sReaderBuffer@@Base+0xffed370c>
   30c92:	842a                	mv	s0,a0
   30c94:	fcf716e3          	bne	a4,a5,30c60 <iap2_dev_recv_data@@Base+0xcf0>
   30c98:	fd5ff06f          	j	30c6c <iap2_dev_recv_data@@Base+0xcfc>
   30c9c:	6605                	lui	a2,0x1
   30c9e:	77fd                	lui	a5,0xfffff
   30ca0:	08060693          	addi	a3,a2,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30ca4:	96be                	add	a3,a3,a5
   30ca6:	080c                	addi	a1,sp,16
   30ca8:	00b687b3          	add	a5,a3,a1
   30cac:	4398                	lw	a4,0(a5)
   30cae:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffed3764>
   30cb0:	842a                	mv	s0,a0
   30cb2:	faf717e3          	bne	a4,a5,30c60 <iap2_dev_recv_data@@Base+0xcf0>
   30cb6:	bf5d                	j	30c6c <iap2_dev_recv_data@@Base+0xcfc>
   30cb8:	6605                	lui	a2,0x1
   30cba:	77fd                	lui	a5,0xfffff
   30cbc:	08060613          	addi	a2,a2,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30cc0:	963e                	add	a2,a2,a5
   30cc2:	080c                	addi	a1,sp,16
   30cc4:	00b607b3          	add	a5,a2,a1
   30cc8:	4398                	lw	a4,0(a5)
   30cca:	07a1                	addi	a5,a5,8 # fffff008 <AOAProxy::sReaderBuffer@@Base+0xffed3764>
   30ccc:	842a                	mv	s0,a0
   30cce:	f8f719e3          	bne	a4,a5,30c60 <iap2_dev_recv_data@@Base+0xcf0>
   30cd2:	bf69                	j	30c6c <iap2_dev_recv_data@@Base+0xcfc>
   30cd4:	f6dff06f          	j	30c40 <iap2_dev_recv_data@@Base+0xcd0>
   30cd8:	6605                	lui	a2,0x1
   30cda:	77fd                	lui	a5,0xfffff
   30cdc:	08060593          	addi	a1,a2,128 # 1080 <CFArrayCreateCopy@plt-0x1e590>
   30ce0:	95be                	add	a1,a1,a5
   30ce2:	0814                	addi	a3,sp,16
   30ce4:	00d58733          	add	a4,a1,a3
   30ce8:	f69ff06f          	j	30c50 <iap2_dev_recv_data@@Base+0xce0>
