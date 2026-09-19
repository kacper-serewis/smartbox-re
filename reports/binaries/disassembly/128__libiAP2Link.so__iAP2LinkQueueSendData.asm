
firmwares/hw501/128/rootfs/lib/libiAP2Link.so:     file format elf32-littleriscv


Disassembly of section .text:

0000b9d8 <iAP2LinkQueueSendData@@Base>:
    b9d8:	2da052ef          	jal	t0,10cb2 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x38>
    b9dc:	7179                	addi	sp,sp,-48
    b9de:	842a                	mv	s0,a0
    b9e0:	89ae                	mv	s3,a1
    b9e2:	8932                	mv	s2,a2
    b9e4:	10050d63          	beqz	a0,bafe <iAP2LinkQueueSendData@@Base+0x126>
    b9e8:	10058b63          	beqz	a1,bafe <iAP2LinkQueueSendData@@Base+0x126>
    b9ec:	10060963          	beqz	a2,bafe <iAP2LinkQueueSendData@@Base+0x126>
    b9f0:	85b6                	mv	a1,a3
    b9f2:	8a36                	mv	s4,a3
    b9f4:	8cba                	mv	s9,a4
    b9f6:	8d3e                	mv	s10,a5
    b9f8:	ffffc097          	auipc	ra,0xffffc
    b9fc:	2c8080e7          	jalr	712(ra) # 7cc0 <iAP2LinkGetSessionInfo@plt>
    ba00:	84aa                	mv	s1,a0
    ba02:	cd61                	beqz	a0,bada <iAP2LinkQueueSendData@@Base+0x102>
    ba04:	8522                	mv	a0,s0
    ba06:	ffffc097          	auipc	ra,0xffffc
    ba0a:	4ba080e7          	jalr	1210(ra) # 7ec0 <iAP2LinkGetMaxSendPayloadSize@plt>
    ba0e:	0014c783          	lbu	a5,1(s1)
    ba12:	0cf407db          	.insn	4, 0x0cf407db
    ba16:	0587ab03          	lw	s6,88(a5)
    ba1a:	000b1a63          	bnez	s6,ba2e <iAP2LinkQueueSendData@@Base+0x56>
    ba1e:	4485                	li	s1,1
    ba20:	501c                	lw	a5,32(s0)
    ba22:	8522                	mv	a0,s0
    ba24:	9782                	jalr	a5
    ba26:	8526                	mv	a0,s1
    ba28:	6145                	addi	sp,sp,48
    ba2a:	2c40506f          	j	10cee <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x74>
    ba2e:	84ca                	mv	s1,s2
    ba30:	01257363          	bgeu	a0,s2,ba36 <iAP2LinkQueueSendData@@Base+0x5e>
    ba34:	84aa                	mv	s1,a0
    ba36:	8ace                	mv	s5,s3
    ba38:	4b81                	li	s7,0
    ba3a:	02c10c13          	addi	s8,sp,44
    ba3e:	41790db3          	sub	s11,s2,s7
    ba42:	8826                	mv	a6,s1
    ba44:	009df363          	bgeu	s11,s1,ba4a <iAP2LinkQueueSendData@@Base+0x72>
    ba48:	84ee                	mv	s1,s11
    ba4a:	03044603          	lbu	a2,48(s0)
    ba4e:	02f44583          	lbu	a1,47(s0)
    ba52:	87d2                	mv	a5,s4
    ba54:	8726                	mv	a4,s1
    ba56:	86d6                	mv	a3,s5
    ba58:	8522                	mv	a0,s0
    ba5a:	ce42                	sw	a6,28(sp)
    ba5c:	ffffc097          	auipc	ra,0xffffc
    ba60:	6a4080e7          	jalr	1700(ra) # 8100 <iAP2PacketCreateACKPacket@plt>
    ba64:	d62a                	sw	a0,44(sp)
    ba66:	cd15                	beqz	a0,baa2 <iAP2LinkQueueSendData@@Base+0xca>
    ba68:	4872                	lw	a6,28(sp)
    ba6a:	03b86763          	bltu	a6,s11,ba98 <iAP2LinkQueueSendData@@Base+0xc0>
    ba6e:	01952223          	sw	s9,4(a0)
    ba72:	01a52423          	sw	s10,8(a0)
    ba76:	855a                	mv	a0,s6
    ba78:	ffffd097          	auipc	ra,0xffffd
    ba7c:	288080e7          	jalr	648(ra) # 8d00 <iAP2ListArrayGetLastItemIndex@plt>
    ba80:	8662                	mv	a2,s8
    ba82:	85aa                	mv	a1,a0
    ba84:	9ba6                	add	s7,s7,s1
    ba86:	855a                	mv	a0,s6
    ba88:	9aa6                	add	s5,s5,s1
    ba8a:	ffffd097          	auipc	ra,0xffffd
    ba8e:	8f6080e7          	jalr	-1802(ra) # 8380 <iAP2LinkAddPacketAfter@plt>
    ba92:	fb2be6e3          	bltu	s7,s2,ba3e <iAP2LinkQueueSendData@@Base+0x66>
    ba96:	b761                	j	ba1e <iAP2LinkQueueSendData@@Base+0x46>
    ba98:	00052223          	sw	zero,4(a0)
    ba9c:	00052423          	sw	zero,8(a0)
    baa0:	bfd9                	j	ba76 <iAP2LinkQueueSendData@@Base+0x9e>
    baa2:	855a                	mv	a0,s6
    baa4:	ffffd097          	auipc	ra,0xffffd
    baa8:	aec080e7          	jalr	-1300(ra) # 8590 <iAP2ListArrayGetCount@plt>
    baac:	6605                	lui	a2,0x1
    baae:	88a6                	mv	a7,s1
    bab0:	86aa                	mv	a3,a0
    bab2:	8856                	mv	a6,s5
    bab4:	87ca                	mv	a5,s2
    bab6:	874e                	mv	a4,s3
    bab8:	9e860613          	addi	a2,a2,-1560 # 9e8 <__iAP2BuffPoolInitBuffList@plt-0x7298>
    babc:	00006597          	auipc	a1,0x6
    bac0:	18c58593          	addi	a1,a1,396 # 11c48 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0xfce> ; DATA '/workspace/CarLifeProxy_Linux/iAP2Link/iAP2Link/iAP2Link.c'
    bac4:	00006517          	auipc	a0,0x6
    bac8:	45050513          	addi	a0,a0,1104 # 11f14 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x129a> ; DATA '%s:%d QueueSendData Ran out of Send Packets! listCount=%u payload=%p payloadLen=%u data=%p dataLen=%u session=%u\n'
    bacc:	c052                	sw	s4,0(sp)
    bace:	4481                	li	s1,0
    bad0:	ffffc097          	auipc	ra,0xffffc
    bad4:	7b0080e7          	jalr	1968(ra) # 8280 <iAP2LogError@plt>
    bad8:	b7a1                	j	ba20 <iAP2LinkQueueSendData@@Base+0x48>
    bada:	6605                	lui	a2,0x1
    badc:	86d2                	mv	a3,s4
    bade:	9f360613          	addi	a2,a2,-1549 # 9f3 <__iAP2BuffPoolInitBuffList@plt-0x728d>
    bae2:	00006597          	auipc	a1,0x6
    bae6:	16658593          	addi	a1,a1,358 # 11c48 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0xfce> ; DATA '/workspace/CarLifeProxy_Linux/iAP2Link/iAP2Link/iAP2Link.c'
    baea:	00006517          	auipc	a0,0x6
    baee:	40e50513          	addi	a0,a0,1038 # 11ef8 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x127e> ; DATA '%s:%d Invalid session(%u)!\n'
    baf2:	ffffc097          	auipc	ra,0xffffc
    baf6:	78e080e7          	jalr	1934(ra) # 8280 <iAP2LogError@plt>
    bafa:	4481                	li	s1,0
    bafc:	b72d                	j	ba26 <iAP2LinkQueueSendData@@Base+0x4e>
    bafe:	6605                	lui	a2,0x1
    bb00:	87ca                	mv	a5,s2
    bb02:	874e                	mv	a4,s3
    bb04:	86a2                	mv	a3,s0
    bb06:	9f960613          	addi	a2,a2,-1543 # 9f9 <__iAP2BuffPoolInitBuffList@plt-0x7287>
    bb0a:	00006597          	auipc	a1,0x6
    bb0e:	13e58593          	addi	a1,a1,318 # 11c48 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0xfce> ; DATA '/workspace/CarLifeProxy_Linux/iAP2Link/iAP2Link/iAP2Link.c'
    bb12:	00006517          	auipc	a0,0x6
    bb16:	47650513          	addi	a0,a0,1142 # 11f88 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x130e> ; DATA '%s:%d NULL link(%p) or payload(%p) or no payload (len=%u)!\n'
    bb1a:	ffffc097          	auipc	ra,0xffffc
    bb1e:	766080e7          	jalr	1894(ra) # 8280 <iAP2LogError@plt>
    bb22:	bfe1                	j	bafa <iAP2LinkQueueSendData@@Base+0x122>
