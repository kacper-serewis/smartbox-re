
firmwares/hw501/128/rootfs/lib/libiAP2Link.so:     file format elf32-littleriscv


Disassembly of section .text:

0000a946 <iAP2LinkSendWindowAvailable@@Base>:
    a946:	5d5c                	lw	a5,60(a0)
    a948:	8b99                	andi	a5,a5,6
    a94a:	0267e35b          	.insn	4, 0x0267e35b
    a94e:	394062ef          	jal	t0,10ce2 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x68>
    a952:	842a                	mv	s0,a0
    a954:	02f54583          	lbu	a1,47(a0)
    a958:	02e54503          	lbu	a0,46(a0)
    a95c:	ffffe097          	auipc	ra,0xffffe
    a960:	fc4080e7          	jalr	-60(ra) # 8920 <iAP2PacketCalcSeqGap@plt>
    a964:	0c744783          	lbu	a5,199(s0)
    a968:	00f53533          	sltu	a0,a0,a5
    a96c:	39a0606f          	j	10d06 <USBIAP2Session::iAP2LinkSendDetectCB(iAP2Link_st*, signed char)@@Base+0x8c>
    a970:	4505                	li	a0,1
    a972:	8082                	ret
