
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

000294f0 <_SendAirPlayModeStatesToProxy@@Base+0xe80>:
   294f0:	000dd597          	auipc	a1,0xdd
   294f4:	84c58593          	addi	a1,a1,-1972 # 105d3c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa08dc> ; CFSTRING 'setNightMode'
   294f8:	00040513          	mv	a0,s0
   294fc:	ffff7097          	auipc	ra,0xffff7
   29500:	cb4080e7          	jalr	-844(ra) # 201b0 <CFEqual@plt>
   29504:	1c050063          	beqz	a0,296c4 <_SendAirPlayModeStatesToProxy@@Base+0x1054>
   29508:	0870                	addi	a2,sp,28
   2950a:	000dd597          	auipc	a1,0xdd
   2950e:	84a58593          	addi	a1,a1,-1974 # 105d54 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa08f4> ; CFSTRING 'nightMode'
   29512:	854a                	mv	a0,s2
   29514:	ffff6097          	auipc	ra,0xffff6
   29518:	32c080e7          	jalr	812(ra) # 1f840 <CFDictionaryGetInt64@plt>
   2951c:	47f2                	lw	a5,28(sp)
   2951e:	ef99                	bnez	a5,2953c <_SendAirPlayModeStatesToProxy@@Base+0xecc>
   29520:	8d4d                	or	a0,a0,a1
   29522:	3a050f63          	beqz	a0,298e0 <_SendAirPlayModeStatesToProxy@@Base+0x1270>
   29526:	00106797          	auipc	a5,0x106
   2952a:	d067a783          	lw	a5,-762(a5) # 12f22c <kCFLBooleanTrue@Base> ; DATA ELF relocation: kCFLBooleanTrue
   2952e:	4398                	lw	a4,0(a5)
   29530:	00106797          	auipc	a5,0x106
   29534:	bf07a783          	lw	a5,-1040(a5) # 12f120 <gProxyInfos@@Base-0x488> ; DATA ELF relocation: gProxyInfos
   29538:	0ee7a423          	sw	a4,232(a5)
   2953c:	080005b7          	lui	a1,0x8000
   29540:	10058593          	addi	a1,a1,256 # 8000100 <AOAProxy::sReaderBuffer@@Base+0x7ecf80c>
   29544:	00040513          	mv	a0,s0
   29548:	ffff6097          	auipc	ra,0xffff6
   2954c:	488080e7          	jalr	1160(ra) # 1f9d0 <CFStringGetCStringPtr@plt>
   29550:	00106497          	auipc	s1,0x106
   29554:	c0c4a483          	lw	s1,-1012(s1) # 12f15c <gProxyDelegate@@Base-0x428> ; DATA ELF relocation: gProxyDelegate
   29558:	40dc                	lw	a5,4(s1)
   2955a:	8a2a                	mv	s4,a0
   2955c:	9782                	jalr	a5
   2955e:	89aa                	mv	s3,a0
   29560:	2a050c63          	beqz	a0,29818 <_SendAirPlayModeStatesToProxy@@Base+0x11a8>
   29564:	4681                	li	a3,0
   29566:	4601                	li	a2,0
   29568:	00090593          	mv	a1,s2
   2956c:	ffff7097          	auipc	ra,0xffff7
   29570:	e34080e7          	jalr	-460(ra) # 203a0 <AirPlayReceiverSessionSendCommand@plt>
   29574:	449c                	lw	a5,8(s1)
   29576:	854e                	mv	a0,s3
   29578:	9782                	jalr	a5
   2957a:	b7b9                	j	294c8 <_SendAirPlayModeStatesToProxy@@Base+0xe58>
