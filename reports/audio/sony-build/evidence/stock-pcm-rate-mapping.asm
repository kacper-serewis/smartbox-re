
/var/folders/wb/38qjft055l18_4qj_94p15cc0000gn/T/smartbox-sony-eft9p193/baseline/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0002375c <IAP2LinkStatusChangeNotify@@Base-0x1254>:
   2375c:	67b1                	lui	a5,0xc
   2375e:	b8078793          	addi	a5,a5,-1152 # bb80 <CFArrayCreateCopy@plt-0x13c50>
   23762:	0af50763          	beq	a0,a5,23810 <lv_obj_set_style_pad_left@plt+0x1340>
   23766:	67ad                	lui	a5,0xb
   23768:	c4478793          	addi	a5,a5,-956 # ac44 <CFArrayCreateCopy@plt-0x14b8c>
   2376c:	00f51c63          	bne	a0,a5,23784 <lv_obj_set_style_pad_left@plt+0x12b4>
   23770:	0d05d85b          	.insn	4, 0x0d05d85b
   23774:	4701                	li	a4,0
   23776:	4781                	li	a5,0
   23778:	0f85d05b          	.insn	4, 0x0f85d05b
   2377c:	853a                	mv	a0,a4
   2377e:	85be                	mv	a1,a5
   23780:	00008067          	ret
   23784:	67a1                	lui	a5,0x8
   23786:	d0078793          	addi	a5,a5,-768 # 7d00 <CFArrayCreateCopy@plt-0x17ad0>
   2378a:	00f51f63          	bne	a0,a5,237a8 <lv_obj_set_style_pad_left@plt+0x12d8>
   2378e:	4701                	li	a4,0
   23790:	4781                	li	a5,0
   23792:	bf05e55b          	.insn	4, 0xbf05e55b
   23796:	0e16595b          	.insn	4, 0x0e16595b
   2379a:	be26615b          	.insn	4, 0xbe26615b
   2379e:	20000713          	li	a4,512
   237a2:	4781                	li	a5,0
   237a4:	fd9ff06f          	j	2377c <lv_obj_set_style_pad_left@plt+0x12ac>
   237a8:	6799                	lui	a5,0x6
   237aa:	dc078793          	addi	a5,a5,-576 # 5dc0 <CFArrayCreateCopy@plt-0x19a10>
   237ae:	00f51f63          	bne	a0,a5,237cc <lv_obj_set_style_pad_left@plt+0x12fc>
   237b2:	4701                	li	a4,0
   237b4:	4781                	li	a5,0
   237b6:	bd05e35b          	.insn	4, 0xbd05e35b
   237ba:	0c165b5b          	.insn	4, 0x0c165b5b
   237be:	ba266f5b          	.insn	4, 0xba266f5b
   237c2:	08000713          	li	a4,128
   237c6:	4781                	li	a5,0
   237c8:	fb5ff06f          	j	2377c <lv_obj_set_style_pad_left@plt+0x12ac>
   237cc:	6791                	lui	a5,0x4
   237ce:	e8078793          	addi	a5,a5,-384 # 3e80 <CFArrayCreateCopy@plt-0x1b950>
   237d2:	00f51f63          	bne	a0,a5,237f0 <lv_obj_set_style_pad_left@plt+0x1320>
   237d6:	4701                	li	a4,0
   237d8:	4781                	li	a5,0
   237da:	bb05e15b          	.insn	4, 0xbb05e15b
   237de:	0a165d5b          	.insn	4, 0x0a165d5b
   237e2:	b8266d5b          	.insn	4, 0xb8266d5b
   237e6:	02000713          	li	a4,32
   237ea:	4781                	li	a5,0
   237ec:	f91ff06f          	j	2377c <lv_obj_set_style_pad_left@plt+0x12ac>
   237f0:	6789                	lui	a5,0x2
   237f2:	f4078793          	addi	a5,a5,-192 # 1f40 <CFArrayCreateCopy@plt-0x1d890>
   237f6:	4701                	li	a4,0
   237f8:	0af51663          	bne	a0,a5,238a4 <lv_obj_set_style_pad_left@plt+0x13d4>
   237fc:	4781                	li	a5,0
   237fe:	b705ef5b          	.insn	4, 0xb705ef5b
   23802:	08165f5b          	.insn	4, 0x08165f5b
   23806:	b6266b5b          	.insn	4, 0xb6266b5b
   2380a:	4721                	li	a4,8
   2380c:	4781                	li	a5,0
   2380e:	b7bd                	j	2377c <lv_obj_set_style_pad_left@plt+0x12ac>
   23810:	0105de5b          	.insn	4, 0x0105de5b
   23814:	4701                	li	a4,0
   23816:	4781                	li	a5,0
   23818:	b785e25b          	.insn	4, 0xb785e25b
   2381c:	04165a5b          	.insn	4, 0x04165a5b
   23820:	b4266e5b          	.insn	4, 0xb4266e5b
   23824:	00020737          	lui	a4,0x20
   23828:	4781                	li	a5,0
   2382a:	bf89                	j	2377c <lv_obj_set_style_pad_left@plt+0x12ac>
   2382c:	02165e5b          	.insn	4, 0x02165e5b
   23830:	4701                	li	a4,0
   23832:	4781                	li	a5,0
   23834:	b426645b          	.insn	4, 0xb426645b
   23838:	6721                	lui	a4,0x8
   2383a:	4781                	li	a5,0
   2383c:	f41ff06f          	j	2377c <lv_obj_set_style_pad_left@plt+0x12ac>
   23840:	02165c5b          	.insn	4, 0x02165c5b
   23844:	4701                	li	a4,0
   23846:	4781                	li	a5,0
   23848:	b2266a5b          	.insn	4, 0xb2266a5b
   2384c:	6705                	lui	a4,0x1
   2384e:	80070713          	addi	a4,a4,-2048 # 800 <CFArrayCreateCopy@plt-0x1efd0>
   23852:	4781                	li	a5,0
   23854:	f29ff06f          	j	2377c <lv_obj_set_style_pad_left@plt+0x12ac>
