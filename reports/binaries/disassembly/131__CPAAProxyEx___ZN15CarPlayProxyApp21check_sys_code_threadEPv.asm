
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00031df4 <CarPlayProxyApp::check_sys_code_thread(void*)@@Base>:
   31df4:	1141                	addi	sp,sp,-16
   31df6:	c606                	sw	ra,12(sp)
   31df8:	c422                	sw	s0,8(sp)
   31dfa:	842a                	mv	s0,a0
   31dfc:	490320ef          	jal	6428c <AOAProxy::aoaReadThread(void*)@@Base+0xc3c>
   31e00:	4f0320ef          	jal	642f0 <AOAProxy::aoaReadThread(void*)@@Base+0xca0>
   31e04:	c511                	beqz	a0,31e10 <CarPlayProxyApp::check_sys_code_thread(void*)@@Base+0x1c>
   31e06:	40b2                	lw	ra,12(sp)
   31e08:	4422                	lw	s0,8(sp)
   31e0a:	4501                	li	a0,0
   31e0c:	0141                	addi	sp,sp,16
   31e0e:	8082                	ret
   31e10:	000d5597          	auipc	a1,0xd5
   31e14:	48858593          	addi	a1,a1,1160 # 107298 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1e38> ; DATA 'check system code failed\n'
   31e18:	000d5517          	auipc	a0,0xd5
   31e1c:	37c50513          	addi	a0,a0,892 # 107194 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa1d34> ; DATA 'GalProxy'
   31e20:	ffff0097          	auipc	ra,0xffff0
   31e24:	ee0080e7          	jalr	-288(ra) # 21d00 <MLOGD@plt>
   31e28:	6789                	lui	a5,0x2
   31e2a:	943e                	add	s0,s0,a5
   31e2c:	40b2                	lw	ra,12(sp)
   31e2e:	3a040e23          	sb	zero,956(s0)
   31e32:	4422                	lw	s0,8(sp)
   31e34:	4501                	li	a0,0
   31e36:	0141                	addi	sp,sp,16
   31e38:	00008067          	ret
