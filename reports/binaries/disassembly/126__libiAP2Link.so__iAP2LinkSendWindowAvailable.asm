
firmwares/hw501/126/rootfs/lib/libiAP2Link.so:     file format elf32-littleriscv


Disassembly of section .text:

000111e4 <iAP2LinkSendWindowAvailable@@Base>:
   111e4:	7179                	addi	sp,sp,-48
   111e6:	d606                	sw	ra,44(sp)
   111e8:	d422                	sw	s0,40(sp)
   111ea:	1800                	addi	s0,sp,48
   111ec:	fca42e23          	sw	a0,-36(s0)
   111f0:	fe0407a3          	sb	zero,-17(s0)
   111f4:	fdc42783          	lw	a5,-36(s0)
   111f8:	03c7c783          	lbu	a5,60(a5)
   111fc:	8b91                	andi	a5,a5,4
   111fe:	0ff7f793          	zext.b	a5,a5
   11202:	cf9d                	beqz	a5,11240 <iAP2LinkSendWindowAvailable@@Base+0x5c>
   11204:	fdc42783          	lw	a5,-36(s0)
   11208:	03c7c783          	lbu	a5,60(a5)
   1120c:	8b89                	andi	a5,a5,2
   1120e:	0ff7f793          	zext.b	a5,a5
   11212:	c79d                	beqz	a5,11240 <iAP2LinkSendWindowAvailable@@Base+0x5c>
   11214:	fdc42783          	lw	a5,-36(s0)
   11218:	02e7c703          	lbu	a4,46(a5)
   1121c:	fdc42783          	lw	a5,-36(s0)
   11220:	02f7c783          	lbu	a5,47(a5)
   11224:	85be                	mv	a1,a5
   11226:	853a                	mv	a0,a4
   11228:	ffffa097          	auipc	ra,0xffffa
   1122c:	6e8080e7          	jalr	1768(ra) # b910 <iAP2PacketCalcSeqGap@plt>
   11230:	87aa                	mv	a5,a0
   11232:	873e                	mv	a4,a5
   11234:	fdc42783          	lw	a5,-36(s0)
   11238:	0c77c783          	lbu	a5,199(a5)
   1123c:	00f77663          	bgeu	a4,a5,11248 <iAP2LinkSendWindowAvailable@@Base+0x64>
   11240:	00100793          	li	a5,1
   11244:	fef407a3          	sb	a5,-17(s0)
   11248:	fef40783          	lb	a5,-17(s0)
   1124c:	853e                	mv	a0,a5
   1124e:	50b2                	lw	ra,44(sp)
   11250:	5422                	lw	s0,40(sp)
   11252:	6145                	addi	sp,sp,48
   11254:	00008067          	ret
