
firmwares/hw501/126/rootfs/lib/libiAP2Link.so:     file format elf32-littleriscv


Disassembly of section .text:

00010dfc <iAP2LinkQueueSendData@@Base>:
   10dfc:	711d                	addi	sp,sp,-96
   10dfe:	ce86                	sw	ra,92(sp)
   10e00:	cca2                	sw	s0,88(sp)
   10e02:	1080                	addi	s0,sp,96
   10e04:	fca42623          	sw	a0,-52(s0)
   10e08:	fcb42423          	sw	a1,-56(s0)
   10e0c:	fcc42223          	sw	a2,-60(s0)
   10e10:	fae42e23          	sw	a4,-68(s0)
   10e14:	faf42c23          	sw	a5,-72(s0)
   10e18:	87b6                	mv	a5,a3
   10e1a:	fcf401a3          	sb	a5,-61(s0)
   10e1e:	fe0407a3          	sb	zero,-17(s0)
   10e22:	fcc42783          	lw	a5,-52(s0)
   10e26:	20078563          	beqz	a5,11030 <iAP2LinkQueueSendData@@Base+0x234>
   10e2a:	fc842783          	lw	a5,-56(s0)
   10e2e:	20078163          	beqz	a5,11030 <iAP2LinkQueueSendData@@Base+0x234>
   10e32:	fc442783          	lw	a5,-60(s0)
   10e36:	1e078d63          	beqz	a5,11030 <iAP2LinkQueueSendData@@Base+0x234>
   10e3a:	fc344783          	lbu	a5,-61(s0)
   10e3e:	85be                	mv	a1,a5
   10e40:	fcc42503          	lw	a0,-52(s0)
   10e44:	ffffa097          	auipc	ra,0xffffa
   10e48:	dec080e7          	jalr	-532(ra) # ac30 <iAP2LinkGetSessionInfo@plt>
   10e4c:	fca42e23          	sw	a0,-36(s0)
   10e50:	fdc42783          	lw	a5,-36(s0)
   10e54:	1a078a63          	beqz	a5,11008 <iAP2LinkQueueSendData@@Base+0x20c>
   10e58:	fc842783          	lw	a5,-56(s0)
   10e5c:	fef42423          	sw	a5,-24(s0)
   10e60:	fe042223          	sw	zero,-28(s0)
   10e64:	fcc42503          	lw	a0,-52(s0)
   10e68:	ffffa097          	auipc	ra,0xffffa
   10e6c:	fc8080e7          	jalr	-56(ra) # ae30 <iAP2LinkGetMaxSendPayloadSize@plt>
   10e70:	fea42023          	sw	a0,-32(s0)
   10e74:	fdc42783          	lw	a5,-36(s0)
   10e78:	0017c783          	lbu	a5,1(a5)
   10e7c:	fcc42703          	lw	a4,-52(s0)
   10e80:	07d1                	addi	a5,a5,20
   10e82:	078a                	slli	a5,a5,0x2
   10e84:	97ba                	add	a5,a5,a4
   10e86:	479c                	lw	a5,8(a5)
   10e88:	fcf42c23          	sw	a5,-40(s0)
   10e8c:	fe042703          	lw	a4,-32(s0)
   10e90:	fc442783          	lw	a5,-60(s0)
   10e94:	00e7f663          	bgeu	a5,a4,10ea0 <iAP2LinkQueueSendData@@Base+0xa4>
   10e98:	fc442783          	lw	a5,-60(s0)
   10e9c:	fef42023          	sw	a5,-32(s0)
   10ea0:	4785                	li	a5,1
   10ea2:	fef407a3          	sb	a5,-17(s0)
   10ea6:	fd842783          	lw	a5,-40(s0)
   10eaa:	14078763          	beqz	a5,10ff8 <iAP2LinkQueueSendData@@Base+0x1fc>
   10eae:	fc040ba3          	sb	zero,-41(s0)
   10eb2:	aa0d                	j	10fe4 <iAP2LinkQueueSendData@@Base+0x1e8>
   10eb4:	fc442703          	lw	a4,-60(s0)
   10eb8:	fe442783          	lw	a5,-28(s0)
   10ebc:	40f707b3          	sub	a5,a4,a5
   10ec0:	fe042703          	lw	a4,-32(s0)
   10ec4:	00e7fa63          	bgeu	a5,a4,10ed8 <iAP2LinkQueueSendData@@Base+0xdc>
   10ec8:	fc442703          	lw	a4,-60(s0)
   10ecc:	fe442783          	lw	a5,-28(s0)
   10ed0:	40f707b3          	sub	a5,a4,a5
   10ed4:	fef42023          	sw	a5,-32(s0)
   10ed8:	fc442703          	lw	a4,-60(s0)
   10edc:	fe442783          	lw	a5,-28(s0)
   10ee0:	40f707b3          	sub	a5,a4,a5
   10ee4:	fe042703          	lw	a4,-32(s0)
   10ee8:	40f707b3          	sub	a5,a4,a5
   10eec:	0017b793          	seqz	a5,a5
   10ef0:	0ff7f793          	zext.b	a5,a5
   10ef4:	fcf40ba3          	sb	a5,-41(s0)
   10ef8:	fcc42783          	lw	a5,-52(s0)
   10efc:	02f7c583          	lbu	a1,47(a5)
   10f00:	fcc42783          	lw	a5,-52(s0)
   10f04:	0307c603          	lbu	a2,48(a5)
   10f08:	fc344783          	lbu	a5,-61(s0)
   10f0c:	fe042703          	lw	a4,-32(s0)
   10f10:	fe842683          	lw	a3,-24(s0)
   10f14:	fcc42503          	lw	a0,-52(s0)
   10f18:	ffffa097          	auipc	ra,0xffffa
   10f1c:	198080e7          	jalr	408(ra) # b0b0 <iAP2PacketCreateACKPacket@plt>
   10f20:	87aa                	mv	a5,a0
   10f22:	fcf42823          	sw	a5,-48(s0)
   10f26:	fd042783          	lw	a5,-48(s0)
   10f2a:	cbad                	beqz	a5,10f9c <iAP2LinkQueueSendData@@Base+0x1a0>
   10f2c:	fd740783          	lb	a5,-41(s0)
   10f30:	cf81                	beqz	a5,10f48 <iAP2LinkQueueSendData@@Base+0x14c>
   10f32:	fd042783          	lw	a5,-48(s0)
   10f36:	fbc42703          	lw	a4,-68(s0)
   10f3a:	c3d8                	sw	a4,4(a5)
   10f3c:	fd042783          	lw	a5,-48(s0)
   10f40:	fb842703          	lw	a4,-72(s0)
   10f44:	c798                	sw	a4,8(a5)
   10f46:	a809                	j	10f58 <iAP2LinkQueueSendData@@Base+0x15c>
   10f48:	fd042783          	lw	a5,-48(s0)
   10f4c:	0007a223          	sw	zero,4(a5)
   10f50:	fd042783          	lw	a5,-48(s0)
   10f54:	0007a423          	sw	zero,8(a5)
   10f58:	fd842503          	lw	a0,-40(s0)
   10f5c:	ffffb097          	auipc	ra,0xffffb
   10f60:	da4080e7          	jalr	-604(ra) # bd00 <iAP2ListArrayGetLastItemIndex@plt>
   10f64:	87aa                	mv	a5,a0
   10f66:	873e                	mv	a4,a5
   10f68:	fd040793          	addi	a5,s0,-48
   10f6c:	863e                	mv	a2,a5
   10f6e:	85ba                	mv	a1,a4
   10f70:	fd842503          	lw	a0,-40(s0)
   10f74:	ffffa097          	auipc	ra,0xffffa
   10f78:	3dc080e7          	jalr	988(ra) # b350 <iAP2LinkAddPacketAfter@plt>
   10f7c:	fe842703          	lw	a4,-24(s0)
   10f80:	fe042783          	lw	a5,-32(s0)
   10f84:	97ba                	add	a5,a5,a4
   10f86:	fef42423          	sw	a5,-24(s0)
   10f8a:	fe442703          	lw	a4,-28(s0)
   10f8e:	fe042783          	lw	a5,-32(s0)
   10f92:	97ba                	add	a5,a5,a4
   10f94:	fef42223          	sw	a5,-28(s0)
   10f98:	04c0006f          	j	10fe4 <iAP2LinkQueueSendData@@Base+0x1e8>
   10f9c:	fd842503          	lw	a0,-40(s0)
   10fa0:	ffffa097          	auipc	ra,0xffffa
   10fa4:	5c0080e7          	jalr	1472(ra) # b560 <iAP2ListArrayGetCount@plt>
   10fa8:	87aa                	mv	a5,a0
   10faa:	86be                	mv	a3,a5
   10fac:	fc344783          	lbu	a5,-61(s0)
   10fb0:	c03e                	sw	a5,0(sp)
   10fb2:	fe042883          	lw	a7,-32(s0)
   10fb6:	fe842803          	lw	a6,-24(s0)
   10fba:	fc442783          	lw	a5,-60(s0)
   10fbe:	fc842703          	lw	a4,-56(s0)
   10fc2:	6605                	lui	a2,0x1
   10fc4:	9e860613          	addi	a2,a2,-1560 # 9e8 <__iAP2BuffPoolInitBuffList@plt-0xa208>
   10fc8:	0000f597          	auipc	a1,0xf
   10fcc:	55c58593          	addi	a1,a1,1372 # 20524 <kIap2PacketDetectBadData@@Base+0x8> ; DATA '/workspace/CarLifeProxy_Linux/iAP2Link/iAP2Link/iAP2Link.c'
   10fd0:	00010517          	auipc	a0,0x10
   10fd4:	a3850513          	addi	a0,a0,-1480 # 20a08 <kIap2PacketDetectBadData@@Base+0x4ec> ; DATA '%s:%d QueueSendData Ran out of Send Packets! listCount=%u payload=%p payloadLen=%u data=%p dataLen=%u session=%u\n'
   10fd8:	ffffa097          	auipc	ra,0xffffa
   10fdc:	278080e7          	jalr	632(ra) # b250 <iAP2LogError@plt>
   10fe0:	fe0407a3          	sb	zero,-17(s0)
   10fe4:	fef40783          	lb	a5,-17(s0)
   10fe8:	00078863          	beqz	a5,10ff8 <iAP2LinkQueueSendData@@Base+0x1fc>
   10fec:	fe442703          	lw	a4,-28(s0)
   10ff0:	fc442783          	lw	a5,-60(s0)
   10ff4:	ecf760e3          	bltu	a4,a5,10eb4 <iAP2LinkQueueSendData@@Base+0xb8>
   10ff8:	fcc42783          	lw	a5,-52(s0)
   10ffc:	539c                	lw	a5,32(a5)
   10ffe:	fcc42503          	lw	a0,-52(s0)
   11002:	9782                	jalr	a5
   11004:	0580006f          	j	1105c <iAP2LinkQueueSendData@@Base+0x260>
   11008:	fc344783          	lbu	a5,-61(s0)
   1100c:	86be                	mv	a3,a5
   1100e:	6785                	lui	a5,0x1
   11010:	9f378613          	addi	a2,a5,-1549 # 9f3 <__iAP2BuffPoolInitBuffList@plt-0xa1fd>
   11014:	0000f597          	auipc	a1,0xf
   11018:	51058593          	addi	a1,a1,1296 # 20524 <kIap2PacketDetectBadData@@Base+0x8> ; DATA '/workspace/CarLifeProxy_Linux/iAP2Link/iAP2Link/iAP2Link.c'
   1101c:	0000f517          	auipc	a0,0xf
   11020:	6b450513          	addi	a0,a0,1716 # 206d0 <kIap2PacketDetectBadData@@Base+0x1b4> ; DATA '%s:%d Invalid session(%u)!\n'
   11024:	ffffa097          	auipc	ra,0xffffa
   11028:	22c080e7          	jalr	556(ra) # b250 <iAP2LogError@plt>
   1102c:	0300006f          	j	1105c <iAP2LinkQueueSendData@@Base+0x260>
   11030:	fc442783          	lw	a5,-60(s0)
   11034:	fc842703          	lw	a4,-56(s0)
   11038:	fcc42683          	lw	a3,-52(s0)
   1103c:	00001637          	lui	a2,0x1
   11040:	9f960613          	addi	a2,a2,-1543 # 9f9 <__iAP2BuffPoolInitBuffList@plt-0xa1f7>
   11044:	0000f597          	auipc	a1,0xf
   11048:	4e058593          	addi	a1,a1,1248 # 20524 <kIap2PacketDetectBadData@@Base+0x8> ; DATA '/workspace/CarLifeProxy_Linux/iAP2Link/iAP2Link/iAP2Link.c'
   1104c:	00010517          	auipc	a0,0x10
   11050:	a3050513          	addi	a0,a0,-1488 # 20a7c <kIap2PacketDetectBadData@@Base+0x560> ; DATA '%s:%d NULL link(%p) or payload(%p) or no payload (len=%u)!\n'
   11054:	ffffa097          	auipc	ra,0xffffa
   11058:	1fc080e7          	jalr	508(ra) # b250 <iAP2LogError@plt>
   1105c:	fef40783          	lb	a5,-17(s0)
   11060:	853e                	mv	a0,a5
   11062:	40f6                	lw	ra,92(sp)
   11064:	4466                	lw	s0,88(sp)
   11066:	6125                	addi	sp,sp,96
   11068:	00008067          	ret
