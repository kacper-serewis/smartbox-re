
firmwares/hw501/128/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00031808 <CarPlayProxyApp::check_sys_code_thread(void*)@@Base>:
   31808:	1141                	addi	sp,sp,-16
   3180a:	c606                	sw	ra,12(sp)
   3180c:	c422                	sw	s0,8(sp)
   3180e:	842a                	mv	s0,a0
   31810:	555300ef          	jal	62564 <AOAProxy::aoaReadThread(void*)@@Base+0xc3c>
   31814:	5b5300ef          	jal	625c8 <AOAProxy::aoaReadThread(void*)@@Base+0xca0>
   31818:	e511                	bnez	a0,31824 <CarPlayProxyApp::check_sys_code_thread(void*)@@Base+0x1c>
   3181a:	6789                	lui	a5,0x2
   3181c:	00f40433          	add	s0,s0,a5
   31820:	3a040e23          	sb	zero,956(s0)
   31824:	40b2                	lw	ra,12(sp)
   31826:	4422                	lw	s0,8(sp)
   31828:	4501                	li	a0,0
   3182a:	0141                	addi	sp,sp,16
   3182c:	00008067          	ret
