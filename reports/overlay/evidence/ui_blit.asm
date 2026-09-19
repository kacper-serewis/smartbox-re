
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0005943c <void std::vector<HIDDevInfos*, std::allocator<HIDDevInfos*> >::_M_realloc_insert<HIDDevInfos* const&>(__gnu_cxx::__normal_iterator<HIDDevInfos**, std::vector<HIDDevInfos*, std::allocator<HIDDevInfos*> > >, HIDDevInfos* const&)@@Base+0x124>:
   5943c:	d4a20007          	.insn	4, 0xd4a20007
   59440:	d686                	sw	ra,108(sp)
   59442:	d2a6                	sw	s1,100(sp)
   59444:	d0ca                	sw	s2,96(sp)
   59446:	cece                	sw	s3,92(sp)
   59448:	ccd2                	sw	s4,88(sp)
   5944a:	cad6                	sw	s5,84(sp)
   5944c:	842a                	mv	s0,a0
   5944e:	c799                	beqz	a5,5945c <void std::vector<HIDDevInfos*, std::allocator<HIDDevInfos*> >::_M_realloc_insert<HIDDevInfos* const&>(__gnu_cxx::__normal_iterator<HIDDevInfos**, std::vector<HIDDevInfos*, std::allocator<HIDDevInfos*> > >, HIDDevInfos* const&)@@Base+0x144>
   59450:	4710190b          	.insn	4, 0x4710190b
   59454:	00092783          	lw	a5,0(s2)
   59458:	02c78063          	beq	a5,a2,59478 <void std::vector<HIDDevInfos*, std::allocator<HIDDevInfos*> >::_M_realloc_insert<HIDDevInfos* const&>(__gnu_cxx::__normal_iterator<HIDDevInfos**, std::vector<HIDDevInfos*, std::allocator<HIDDevInfos*> > >, HIDDevInfos* const&)@@Base+0x160>
   5945c:	8522                	mv	a0,s0
   5945e:	5426                	lw	s0,104(sp)
   59460:	50b6                	lw	ra,108(sp)
   59462:	5496                	lw	s1,100(sp)
   59464:	5906                	lw	s2,96(sp)
   59466:	49f6                	lw	s3,92(sp)
   59468:	4a66                	lw	s4,88(sp)
   5946a:	4ad6                	lw	s5,84(sp)
   5946c:	07010113          	addi	sp,sp,112
   59470:	fffc7317          	auipc	t1,0xfffc7
   59474:	5a030067          	jr	1440(t1) # 20a10 <lv_disp_flush_ready@plt>
   59478:	00059883          	lh	a7,0(a1)
   5947c:	00259703          	lh	a4,2(a1)
   59480:	00459a03          	lh	s4,4(a1)
   59484:	00659983          	lh	s3,6(a1)
   59488:	000d6a97          	auipc	s5,0xd6
   5948c:	e00aaa83          	lw	s5,-512(s5) # 12f288 <dispay_buffer_img1@@Base-0x15ac> ; DATA ELF relocation: dispay_buffer_img1
   59490:	000aa503          	lw	a0,0(s5)
   59494:	00058493          	mv	s1,a1
   59498:	411a0a33          	sub	s4,s4,a7
   5949c:	40e989b3          	sub	s3,s3,a4
   594a0:	fffc9097          	auipc	ra,0xfffc9
   594a4:	920080e7          	jalr	-1760(ra) # 21dc0 <flushG2DImage@plt>
   594a8:	000aa583          	lw	a1,0(s5)
   594ac:	03400613          	li	a2,52
   594b0:	05a1                	addi	a1,a1,8
   594b2:	0868                	addi	a0,sp,28
   594b4:	fffc9097          	auipc	ra,0xfffc9
   594b8:	dec080e7          	jalr	-532(ra) # 222a0 <memcpy@plt>
   594bc:	00049703          	lh	a4,0(s1)
   594c0:	00249803          	lh	a6,2(s1)
   594c4:	00492683          	lw	a3,4(s2)
   594c8:	00892783          	lw	a5,8(s2)
   594cc:	0a05                	addi	s4,s4,1
   594ce:	0985                	addi	s3,s3,1
   594d0:	9836                	add	a6,a6,a3
   594d2:	97ba                	add	a5,a5,a4
   594d4:	88d2                	mv	a7,s4
   594d6:	874e                	mv	a4,s3
   594d8:	86d2                	mv	a3,s4
   594da:	4601                	li	a2,0
   594dc:	4581                	li	a1,0
   594de:	0848                	addi	a0,sp,20
   594e0:	ca52                	sw	s4,20(sp)
   594e2:	cc4e                	sw	s3,24(sp)
   594e4:	01312023          	sw	s3,0(sp)
   594e8:	fffc7097          	auipc	ra,0xfffc7
   594ec:	ff8080e7          	jalr	-8(ra) # 204e0 <bltImgToDisplay@plt>
   594f0:	f6dff06f          	j	5945c <void std::vector<HIDDevInfos*, std::allocator<HIDDevInfos*> >::_M_realloc_insert<HIDDevInfos* const&>(__gnu_cxx::__normal_iterator<HIDDevInfos**, std::vector<HIDDevInfos*, std::allocator<HIDDevInfos*> > >, HIDDevInfos* const&)@@Base+0x144>
   594f4:	1141                	addi	sp,sp,-16
   594f6:	87b2                	mv	a5,a2
   594f8:	c422                	sw	s0,8(sp)
   594fa:	4710140b          	.insn	4, 0x4710140b
   594fe:	c408                	sw	a0,8(s0)
   59500:	c04c                	sw	a1,4(s0)
   59502:	853e                	mv	a0,a5
   59504:	462d                	li	a2,11
   59506:	85b6                	mv	a1,a3
   59508:	c45c                	sw	a5,12(s0)
   5950a:	c606                	sw	ra,12(sp)
   5950c:	c226                	sw	s1,4(sp)
   5950e:	c814                	sw	a3,16(s0)
   59510:	fffc8097          	auipc	ra,0xfffc8
   59514:	430080e7          	jalr	1072(ra) # 21940 <createG2DImage@plt>
   59518:	000d6797          	auipc	a5,0xd6
   5951c:	d707a783          	lw	a5,-656(a5) # 12f288 <dispay_buffer_img1@@Base-0x15ac> ; DATA ELF relocation: dispay_buffer_img1
   59520:	c388                	sw	a0,0(a5)
   59522:	cd39                	beqz	a0,59580 <void std::vector<HIDDevInfos*, std::allocator<HIDDevInfos*> >::_M_realloc_insert<HIDDevInfos* const&>(__gnu_cxx::__normal_iterator<HIDDevInfos**, std::vector<HIDDevInfos*, std::allocator<HIDDevInfos*> > >, HIDDevInfos* const&)@@Base+0x268>
   59524:	454c                	lw	a1,12(a0)
   59526:	c00c                	sw	a1,0(s0)
   59528:	4954                	lw	a3,20(a0)
   5952a:	4850148b          	.insn	4, 0x4850148b
   5952e:	8526                	mv	a0,s1
   59530:	00000613          	li	a2,0
   59534:	fffc8097          	auipc	ra,0xfffc8
   59538:	e6c080e7          	jalr	-404(ra) # 213a0 <lv_disp_draw_buf_init@plt>
   5953c:	4a10150b          	.insn	4, 0x4a10150b
   59540:	fffc7097          	auipc	ra,0xfffc7
   59544:	e80080e7          	jalr	-384(ra) # 203c0 <lv_disp_drv_init@plt>
   59548:	445c                	lw	a5,12(s0)
   5954a:	4038                	lw	a4,64(s0)
