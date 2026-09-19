
firmwares/hw501/131/rootfs/lib/libiAP2Link.so:     file format elf32-littleriscv


Disassembly of section .text:

0000b950 <iAP2LinkQueueSendData@@Base>:
    b950:	348052ef          	jal	t0,10c98 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x38>
    b954:	7179                	addi	sp,sp,-48
    b956:	842a                	mv	s0,a0
    b958:	89ae                	mv	s3,a1
    b95a:	8932                	mv	s2,a2
    b95c:	16050463          	beqz	a0,bac4 <iAP2LinkQueueSendData@@Base+0x174>
    b960:	16058263          	beqz	a1,bac4 <iAP2LinkQueueSendData@@Base+0x174>
    b964:	16060063          	beqz	a2,bac4 <iAP2LinkQueueSendData@@Base+0x174>
    b968:	85b6                	mv	a1,a3
    b96a:	8a36                	mv	s4,a3
    b96c:	8bba                	mv	s7,a4
    b96e:	8c3e                	mv	s8,a5
    b970:	ffffc097          	auipc	ra,0xffffc
    b974:	2e0080e7          	jalr	736(ra) # 7c50 <iAP2LinkGetSessionInfo@plt>
    b978:	84aa                	mv	s1,a0
    b97a:	12050363          	beqz	a0,baa0 <iAP2LinkQueueSendData@@Base+0x150>
    b97e:	8522                	mv	a0,s0
    b980:	ffffc097          	auipc	ra,0xffffc
    b984:	4c0080e7          	jalr	1216(ra) # 7e40 <iAP2LinkGetMaxSendPayloadSize@plt>
    b988:	0014c783          	lbu	a5,1(s1)
    b98c:	0cf407db          	.insn	4, 0x0cf407db
    b990:	0587ab03          	lw	s6,88(a5)
    b994:	000b1a63          	bnez	s6,b9a8 <iAP2LinkQueueSendData@@Base+0x58>
    b998:	4485                	li	s1,1
    b99a:	501c                	lw	a5,32(s0)
    b99c:	8522                	mv	a0,s0
    b99e:	9782                	jalr	a5
    b9a0:	8526                	mv	a0,s1
    b9a2:	6145                	addi	sp,sp,48
    b9a4:	3300506f          	j	10cd4 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x74>
    b9a8:	84ca                	mv	s1,s2
    b9aa:	01257363          	bgeu	a0,s2,b9b0 <iAP2LinkQueueSendData@@Base+0x60>
    b9ae:	84aa                	mv	s1,a0
    b9b0:	8ace                	mv	s5,s3
    b9b2:	4d81                	li	s11,0
    b9b4:	02c10c93          	addi	s9,sp,44
    b9b8:	0ff00d13          	li	s10,255
    b9bc:	41b90833          	sub	a6,s2,s11
    b9c0:	88a6                	mv	a7,s1
    b9c2:	00987363          	bgeu	a6,s1,b9c8 <iAP2LinkQueueSendData@@Base+0x78>
    b9c6:	84c2                	mv	s1,a6
    b9c8:	03044603          	lbu	a2,48(s0)
    b9cc:	02f44583          	lbu	a1,47(s0)
    b9d0:	87d2                	mv	a5,s4
    b9d2:	8726                	mv	a4,s1
    b9d4:	86d6                	mv	a3,s5
    b9d6:	8522                	mv	a0,s0
    b9d8:	ce46                	sw	a7,28(sp)
    b9da:	cc42                	sw	a6,24(sp)
    b9dc:	ffffc097          	auipc	ra,0xffffc
    b9e0:	6a4080e7          	jalr	1700(ra) # 8080 <iAP2PacketCreateACKPacket@plt>
    b9e4:	d62a                	sw	a0,44(sp)
    b9e6:	c151                	beqz	a0,ba6a <iAP2LinkQueueSendData@@Base+0x11a>
    b9e8:	4862                	lw	a6,24(sp)
    b9ea:	48f2                	lw	a7,28(sp)
    b9ec:	0308e963          	bltu	a7,a6,ba1e <iAP2LinkQueueSendData@@Base+0xce>
    b9f0:	01752223          	sw	s7,4(a0)
    b9f4:	01852423          	sw	s8,8(a0)
    b9f8:	855a                	mv	a0,s6
    b9fa:	ffffd097          	auipc	ra,0xffffd
    b9fe:	276080e7          	jalr	630(ra) # 8c70 <iAP2ListArrayGetLastItemIndex@plt>
    ba02:	8666                	mv	a2,s9
    ba04:	85aa                	mv	a1,a0
    ba06:	855a                	mv	a0,s6
    ba08:	ffffd097          	auipc	ra,0xffffd
    ba0c:	8f8080e7          	jalr	-1800(ra) # 8300 <iAP2LinkAddPacketAfter@plt>
    ba10:	01a50c63          	beq	a0,s10,ba28 <iAP2LinkQueueSendData@@Base+0xd8>
    ba14:	9da6                	add	s11,s11,s1
    ba16:	9aa6                	add	s5,s5,s1
    ba18:	fb2de2e3          	bltu	s11,s2,b9bc <iAP2LinkQueueSendData@@Base+0x6c>
    ba1c:	bfb5                	j	b998 <iAP2LinkQueueSendData@@Base+0x48>
    ba1e:	00052223          	sw	zero,4(a0)
    ba22:	00052423          	sw	zero,8(a0)
    ba26:	bfc9                	j	b9f8 <iAP2LinkQueueSendData@@Base+0xa8>
    ba28:	855a                	mv	a0,s6
    ba2a:	ffffd097          	auipc	ra,0xffffd
    ba2e:	ae6080e7          	jalr	-1306(ra) # 8510 <iAP2ListArrayGetCount@plt>
    ba32:	6605                	lui	a2,0x1
    ba34:	86aa                	mv	a3,a0
    ba36:	88a6                	mv	a7,s1
    ba38:	00006517          	auipc	a0,0x6
    ba3c:	4c050513          	addi	a0,a0,1216 # 11ef8 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x1298> ; DATA '%s:%d QueueSendData listCount=%u payload=%p payloadLen=%u data=%p dataLen=%u session=%u\n'
    ba40:	8856                	mv	a6,s5
    ba42:	87ca                	mv	a5,s2
    ba44:	874e                	mv	a4,s3
    ba46:	9d760613          	addi	a2,a2,-1577 # 9d7 <__iAP2BuffPoolInitBuffList@plt-0x7239>
    ba4a:	00006597          	auipc	a1,0x6
    ba4e:	1e258593          	addi	a1,a1,482 # 11c2c <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0xfcc> ; DATA '/workspace/CarLifeProxy_Linux/iAP2Link/iAP2Link/iAP2Link.c'
    ba52:	c052                	sw	s4,0(sp)
    ba54:	ffffc097          	auipc	ra,0xffffc
    ba58:	6fc080e7          	jalr	1788(ra) # 8150 <iAP2LogDbg@plt>
    ba5c:	5532                	lw	a0,44(sp)
    ba5e:	ffffc097          	auipc	ra,0xffffc
    ba62:	2e2080e7          	jalr	738(ra) # 7d40 <iAP2PacketDelete@plt>
    ba66:	4481                	li	s1,0
    ba68:	bf0d                	j	b99a <iAP2LinkQueueSendData@@Base+0x4a>
    ba6a:	855a                	mv	a0,s6
    ba6c:	ffffd097          	auipc	ra,0xffffd
    ba70:	aa4080e7          	jalr	-1372(ra) # 8510 <iAP2ListArrayGetCount@plt>
    ba74:	6605                	lui	a2,0x1
    ba76:	86aa                	mv	a3,a0
    ba78:	88a6                	mv	a7,s1
    ba7a:	8856                	mv	a6,s5
    ba7c:	87ca                	mv	a5,s2
    ba7e:	874e                	mv	a4,s3
    ba80:	9e260613          	addi	a2,a2,-1566 # 9e2 <__iAP2BuffPoolInitBuffList@plt-0x722e>
    ba84:	00006597          	auipc	a1,0x6
    ba88:	1a858593          	addi	a1,a1,424 # 11c2c <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0xfcc> ; DATA '/workspace/CarLifeProxy_Linux/iAP2Link/iAP2Link/iAP2Link.c'
    ba8c:	00006517          	auipc	a0,0x6
    ba90:	4c850513          	addi	a0,a0,1224 # 11f54 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x12f4> ; DATA '%s:%d QueueSendData Ran out of Send Packets! listCount=%u payload=%p payloadLen=%u data=%p dataLen=%u session=%u\n'
    ba94:	c052                	sw	s4,0(sp)
    ba96:	ffffc097          	auipc	ra,0xffffc
    ba9a:	76a080e7          	jalr	1898(ra) # 8200 <iAP2LogError@plt>
    ba9e:	b7e1                	j	ba66 <iAP2LinkQueueSendData@@Base+0x116>
    baa0:	6605                	lui	a2,0x1
    baa2:	86d2                	mv	a3,s4
    baa4:	9ec60613          	addi	a2,a2,-1556 # 9ec <__iAP2BuffPoolInitBuffList@plt-0x7224>
    baa8:	00006597          	auipc	a1,0x6
    baac:	18458593          	addi	a1,a1,388 # 11c2c <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0xfcc> ; DATA '/workspace/CarLifeProxy_Linux/iAP2Link/iAP2Link/iAP2Link.c'
    bab0:	00006517          	auipc	a0,0x6
    bab4:	42c50513          	addi	a0,a0,1068 # 11edc <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x127c> ; DATA '%s:%d Invalid session(%u)!\n'
    bab8:	ffffc097          	auipc	ra,0xffffc
    babc:	748080e7          	jalr	1864(ra) # 8200 <iAP2LogError@plt>
    bac0:	4481                	li	s1,0
    bac2:	bdf9                	j	b9a0 <iAP2LinkQueueSendData@@Base+0x50>
    bac4:	6605                	lui	a2,0x1
    bac6:	87ca                	mv	a5,s2
    bac8:	874e                	mv	a4,s3
    baca:	86a2                	mv	a3,s0
    bacc:	9f160613          	addi	a2,a2,-1551 # 9f1 <__iAP2BuffPoolInitBuffList@plt-0x721f>
    bad0:	00006597          	auipc	a1,0x6
    bad4:	15c58593          	addi	a1,a1,348 # 11c2c <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0xfcc> ; DATA '/workspace/CarLifeProxy_Linux/iAP2Link/iAP2Link/iAP2Link.c'
    bad8:	00006517          	auipc	a0,0x6
    badc:	4f050513          	addi	a0,a0,1264 # 11fc8 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x1368> ; DATA '%s:%d NULL link(%p) or payload(%p) or no payload (len=%u)!\n'
    bae0:	ffffc097          	auipc	ra,0xffffc
    bae4:	720080e7          	jalr	1824(ra) # 8200 <iAP2LogError@plt>
    bae8:	bfe1                	j	bac0 <iAP2LinkQueueSendData@@Base+0x170>
