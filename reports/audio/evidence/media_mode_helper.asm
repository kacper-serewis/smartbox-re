
CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00034f8c <CarPlayProxyApp::HWTestThread(void*)@@Base+0x20d0>:
   34f8c:	6789                	lui	a5,0x2
   34f8e:	953e                	add	a0,a0,a5
   34f90:	3d452503          	lw	a0,980(a0)
   34f94:	0015585b          	.insn	4, 0x0015585b
   34f98:	1579                	addi	a0,a0,-2
   34f9a:	00153513          	seqz	a0,a0
   34f9e:	055a                	slli	a0,a0,0x16
   34fa0:	00008067          	ret
