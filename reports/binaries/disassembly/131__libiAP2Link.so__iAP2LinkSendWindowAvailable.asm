
firmwares/hw501/131/rootfs/lib/libiAP2Link.so:     file format elf32-littleriscv


Disassembly of section .text:

0000a8b6 <iAP2LinkSendWindowAvailable@@Base>:
    a8b6:	5d5c                	lw	a5,60(a0)
    a8b8:	8b99                	andi	a5,a5,6
    a8ba:	0267e75b          	.insn	4, 0x0267e75b
    a8be:	40a062ef          	jal	t0,10cc8 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x68>
    a8c2:	0bf54783          	lbu	a5,191(a0)
    a8c6:	842a                	mv	s0,a0
    a8c8:	4505                	li	a0,1
    a8ca:	cf89                	beqz	a5,a8e4 <iAP2LinkSendWindowAvailable@@Base+0x2e>
    a8cc:	02f44583          	lbu	a1,47(s0)
    a8d0:	02e44503          	lbu	a0,46(s0)
    a8d4:	ffffe097          	auipc	ra,0xffffe
    a8d8:	fbc080e7          	jalr	-68(ra) # 8890 <iAP2PacketCalcSeqGap@plt>
    a8dc:	0c744783          	lbu	a5,199(s0)
    a8e0:	00f53533          	sltu	a0,a0,a5
    a8e4:	4080606f          	j	10cec <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x8c>
    a8e8:	4505                	li	a0,1
    a8ea:	8082                	ret
