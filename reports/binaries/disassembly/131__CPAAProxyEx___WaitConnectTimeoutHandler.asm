
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

000251bc <_WaitConnectTimeoutHandler@@Base>:
   251bc:	1141                	addi	sp,sp,-16
   251be:	000df597          	auipc	a1,0xdf
   251c2:	32258593          	addi	a1,a1,802 # 1044e0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f080> ; DATA 'Wait for CarPlay connect to proxy ctrl timeout\n'
   251c6:	000df517          	auipc	a0,0xdf
   251ca:	08250513          	addi	a0,a0,130 # 104248 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9ede8> ; DATA 'ProxyServer'
   251ce:	c422                	sw	s0,8(sp)
   251d0:	c606                	sw	ra,12(sp)
   251d2:	0010a417          	auipc	s0,0x10a
   251d6:	05642403          	lw	s0,86(s0) # 12f228 <gProxyCtrlConnected@@Base-0x1e0> ; DATA ELF relocation: gProxyCtrlConnected
   251da:	c226                	sw	s1,4(sp)
   251dc:	ffffd097          	auipc	ra,0xffffd
   251e0:	b24080e7          	jalr	-1244(ra) # 21d00 <MLOGD@plt>
   251e4:	401c                	lw	a5,0(s0)
   251e6:	e799                	bnez	a5,251f4 <_WaitConnectTimeoutHandler@@Base+0x38>
   251e8:	0010a797          	auipc	a5,0x10a
   251ec:	da07a783          	lw	a5,-608(a5) # 12ef88 <gHostNameWithInterfaceNdx@@Base-0x444> ; DATA ELF relocation: gHostNameWithInterfaceNdx
   251f0:	439c                	lw	a5,0(a5)
   251f2:	c3d9                	beqz	a5,25278 <_WaitConnectTimeoutHandler@@Base+0xbc>
   251f4:	0010a797          	auipc	a5,0x10a
   251f8:	dec7a783          	lw	a5,-532(a5) # 12efe0 <gClientReady@@Base-0x42c> ; DATA ELF relocation: gClientReady
   251fc:	439c                	lw	a5,0(a5)
   251fe:	cb8d                	beqz	a5,25230 <_WaitConnectTimeoutHandler@@Base+0x74>
   25200:	401c                	lw	a5,0(s0)
   25202:	e38d                	bnez	a5,25224 <_WaitConnectTimeoutHandler@@Base+0x68>
   25204:	823fa52b          	.insn	4, 0x823fa52b
   25208:	cd11                	beqz	a0,25224 <_WaitConnectTimeoutHandler@@Base+0x68>
   2520a:	4422                	lw	s0,8(sp)
   2520c:	40b2                	lw	ra,12(sp)
   2520e:	4492                	lw	s1,4(sp)
   25210:	00000617          	auipc	a2,0x0
   25214:	a5060613          	addi	a2,a2,-1456 # 24c60 <IAP2LinkStatusChangeNotify@@Base+0x2b0>
   25218:	4581                	li	a1,0
   2521a:	0141                	addi	sp,sp,16
   2521c:	ffffd317          	auipc	t1,0xffffd
   25220:	d4430067          	jr	-700(t1) # 21f60 <dispatch_async_f@plt>
   25224:	40b2                	lw	ra,12(sp)
   25226:	4422                	lw	s0,8(sp)
   25228:	4492                	lw	s1,4(sp)
   2522a:	0141                	addi	sp,sp,16
   2522c:	00008067          	ret
   25230:	821f948b          	.insn	4, 0x821f948b
   25234:	4cc8                	lw	a0,28(s1)
   25236:	d569                	beqz	a0,25200 <_WaitConnectTimeoutHandler@@Base+0x44>
   25238:	ffffb097          	auipc	ra,0xffffb
   2523c:	5f8080e7          	jalr	1528(ra) # 20830 <BonjourBrowser_Stop@plt>
   25240:	000df517          	auipc	a0,0xdf
   25244:	2f450513          	addi	a0,a0,756 # 104534 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f0d4> ; DATA 'carplay_proxy_ifname'
   25248:	ffffb097          	auipc	ra,0xffffb
   2524c:	908080e7          	jalr	-1784(ra) # 1fb50 <getenv@plt>
   25250:	86aa                	mv	a3,a0
   25252:	4cc8                	lw	a0,28(s1)
   25254:	00000713          	li	a4,0
   25258:	080007b7          	lui	a5,0x8000
   2525c:	000df617          	auipc	a2,0xdf
   25260:	0b460613          	addi	a2,a2,180 # 104310 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9eeb0> ; DATA 'local.'
   25264:	000df597          	auipc	a1,0xdf
   25268:	2e858593          	addi	a1,a1,744 # 10454c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f0ec> ; DATA '_airplay._tcp.'
   2526c:	ffffb097          	auipc	ra,0xffffb
   25270:	184080e7          	jalr	388(ra) # 203f0 <BonjourBrowser_Start@plt>
   25274:	f8dff06f          	j	25200 <_WaitConnectTimeoutHandler@@Base+0x44>
   25278:	4422                	lw	s0,8(sp)
   2527a:	40b2                	lw	ra,12(sp)
   2527c:	4492                	lw	s1,4(sp)
   2527e:	000df517          	auipc	a0,0xdf
   25282:	29250513          	addi	a0,a0,658 # 104510 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9f0b0> ; DATA 'killall -9 mdnsd;sleep 0.1;mdnsd &'
   25286:	0141                	addi	sp,sp,16
   25288:	ffffc317          	auipc	t1,0xffffc
   2528c:	e8830067          	jr	-376(t1) # 21110 <system@plt>
