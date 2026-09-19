
firmwares/hw501/128/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00024f78 <_WaitConnectTimeoutHandler@@Base>:
   24f78:	1141                	addi	sp,sp,-16
   24f7a:	000dc597          	auipc	a1,0xdc
   24f7e:	04658593          	addi	a1,a1,70 # 100fc0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9dabc> ; DATA 'Wait for CarPlay connect to proxy ctrl timeout\n'
   24f82:	000dc517          	auipc	a0,0xdc
   24f86:	da650513          	addi	a0,a0,-602 # 100d28 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9d824> ; DATA 'ProxyServer'
   24f8a:	c422                	sw	s0,8(sp)
   24f8c:	c606                	sw	ra,12(sp)
   24f8e:	00105417          	auipc	s0,0x105
   24f92:	25a42403          	lw	s0,602(s0) # 12a1e8 <gProxyCtrlConnected@@Base-0x1dc> ; DATA ELF relocation: gProxyCtrlConnected
   24f96:	c226                	sw	s1,4(sp)
   24f98:	ffffd097          	auipc	ra,0xffffd
   24f9c:	b78080e7          	jalr	-1160(ra) # 21b10 <MLOGD@plt>
   24fa0:	401c                	lw	a5,0(s0)
   24fa2:	eb89                	bnez	a5,24fb4 <_WaitConnectTimeoutHandler@@Base+0x3c>
   24fa4:	00105797          	auipc	a5,0x105
   24fa8:	fa47a783          	lw	a5,-92(a5) # 129f48 <gHostNameWithInterfaceNdx@@Base-0x440> ; DATA ELF relocation: gHostNameWithInterfaceNdx
   24fac:	0007a783          	lw	a5,0(a5)
   24fb0:	0e078e63          	beqz	a5,250ac <_WaitConnectTimeoutHandler@@Base+0x134>
   24fb4:	00105797          	auipc	a5,0x105
   24fb8:	fec7a783          	lw	a5,-20(a5) # 129fa0 <gClientReady@@Base-0x428> ; DATA ELF relocation: gClientReady
   24fbc:	439c                	lw	a5,0(a5)
   24fbe:	c3dd                	beqz	a5,25064 <_WaitConnectTimeoutHandler@@Base+0xec>
   24fc0:	401c                	lw	a5,0(s0)
   24fc2:	c799                	beqz	a5,24fd0 <_WaitConnectTimeoutHandler@@Base+0x58>
   24fc4:	40b2                	lw	ra,12(sp)
   24fc6:	4422                	lw	s0,8(sp)
   24fc8:	4492                	lw	s1,4(sp)
   24fca:	0141                	addi	sp,sp,16
   24fcc:	00008067          	ret
   24fd0:	821f940b          	.insn	4, 0x821f940b
   24fd4:	4808                	lw	a0,16(s0)
   24fd6:	cd09                	beqz	a0,24ff0 <_WaitConnectTimeoutHandler@@Base+0x78>
   24fd8:	ffffd097          	auipc	ra,0xffffd
   24fdc:	d38080e7          	jalr	-712(ra) # 21d10 <dispatch_source_cancel@plt>
   24fe0:	01042503          	lw	a0,16(s0)
   24fe4:	ffffb097          	auipc	ra,0xffffb
   24fe8:	e8c080e7          	jalr	-372(ra) # 1fe70 <dispatch_release@plt>
   24fec:	820fc9ab          	.insn	4, 0x820fc9ab
   24ff0:	4408                	lw	a0,8(s0)
   24ff2:	cd09                	beqz	a0,2500c <_WaitConnectTimeoutHandler@@Base+0x94>
   24ff4:	ffffd097          	auipc	ra,0xffffd
   24ff8:	d1c080e7          	jalr	-740(ra) # 21d10 <dispatch_source_cancel@plt>
   24ffc:	00842503          	lw	a0,8(s0)
   25000:	ffffb097          	auipc	ra,0xffffb
   25004:	e70080e7          	jalr	-400(ra) # 1fe70 <dispatch_release@plt>
   25008:	820fc5ab          	.insn	4, 0x820fc5ab
   2500c:	4048                	lw	a0,4(s0)
   2500e:	c91d                	beqz	a0,25044 <_WaitConnectTimeoutHandler@@Base+0xcc>
   25010:	ffffb097          	auipc	ra,0xffffb
   25014:	6a0080e7          	jalr	1696(ra) # 206b0 <DNSServiceRefDeallocate@plt>
   25018:	000dc697          	auipc	a3,0xdc
   2501c:	02468693          	addi	a3,a3,36 # 10103c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9db38> ; DATA 'timeout'
   25020:	000dc617          	auipc	a2,0xdc
   25024:	d1460613          	addi	a2,a2,-748 # 100d34 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9d830> ; DATA '_carplay-ctrl._tcp'
   25028:	000dc597          	auipc	a1,0xdc
   2502c:	01c58593          	addi	a1,a1,28 # 101044 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9db40> ; DATA 'Deregistered Bonjour %s for %s\n'
   25030:	000dc517          	auipc	a0,0xdc
   25034:	cf850513          	addi	a0,a0,-776 # 100d28 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9d824> ; DATA 'ProxyServer'
   25038:	820fc3ab          	.insn	4, 0x820fc3ab
   2503c:	ffffd097          	auipc	ra,0xffffd
   25040:	ad4080e7          	jalr	-1324(ra) # 21b10 <MLOGD@plt>
   25044:	4008                	lw	a0,0(s0)
   25046:	dd3d                	beqz	a0,24fc4 <_WaitConnectTimeoutHandler@@Base+0x4c>
   25048:	4422                	lw	s0,8(sp)
   2504a:	40b2                	lw	ra,12(sp)
   2504c:	4492                	lw	s1,4(sp)
   2504e:	00000617          	auipc	a2,0x0
   25052:	9ce60613          	addi	a2,a2,-1586 # 24a1c <IAP2LinkStatusChangeNotify@@Base+0x2b0>
   25056:	4581                	li	a1,0
   25058:	01010113          	addi	sp,sp,16
   2505c:	ffffd317          	auipc	t1,0xffffd
   25060:	d0430067          	jr	-764(t1) # 21d60 <dispatch_async_f@plt>
   25064:	821f948b          	.insn	4, 0x821f948b
   25068:	4cc8                	lw	a0,28(s1)
   2506a:	d939                	beqz	a0,24fc0 <_WaitConnectTimeoutHandler@@Base+0x48>
   2506c:	ffffb097          	auipc	ra,0xffffb
   25070:	5f4080e7          	jalr	1524(ra) # 20660 <BonjourBrowser_Stop@plt>
   25074:	000dc517          	auipc	a0,0xdc
   25078:	fa050513          	addi	a0,a0,-96 # 101014 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9db10> ; DATA 'carplay_proxy_ifname'
   2507c:	ffffb097          	auipc	ra,0xffffb
   25080:	904080e7          	jalr	-1788(ra) # 1f980 <getenv@plt>
   25084:	86aa                	mv	a3,a0
   25086:	4cc8                	lw	a0,28(s1)
   25088:	00000713          	li	a4,0
   2508c:	080007b7          	lui	a5,0x8000
   25090:	000dc617          	auipc	a2,0xdc
   25094:	d6060613          	addi	a2,a2,-672 # 100df0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9d8ec> ; DATA 'local.'
   25098:	000dc597          	auipc	a1,0xdc
   2509c:	f9458593          	addi	a1,a1,-108 # 10102c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9db28> ; DATA '_airplay._tcp.'
   250a0:	ffffb097          	auipc	ra,0xffffb
   250a4:	180080e7          	jalr	384(ra) # 20220 <BonjourBrowser_Start@plt>
   250a8:	f19ff06f          	j	24fc0 <_WaitConnectTimeoutHandler@@Base+0x48>
   250ac:	4422                	lw	s0,8(sp)
   250ae:	40b2                	lw	ra,12(sp)
   250b0:	4492                	lw	s1,4(sp)
   250b2:	000dc517          	auipc	a0,0xdc
   250b6:	f3e50513          	addi	a0,a0,-194 # 100ff0 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x9daec> ; DATA 'killall -9 mdnsd;sleep 0.1;mdnsd &'
   250ba:	0141                	addi	sp,sp,16
   250bc:	ffffc317          	auipc	t1,0xffffc
   250c0:	e8430067          	jr	-380(t1) # 20f40 <system@plt>
