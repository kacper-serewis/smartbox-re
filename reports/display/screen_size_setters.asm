
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0004c2d8 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0xc8c>:
   4c2d8:	420506d3          	fcvt.d.s	fa3,fa0
   4c2dc:	7179                	addi	sp,sp,-48
   4c2de:	86ae                	mv	a3,a1
   4c2e0:	862a                	mv	a2,a0
   4c2e2:	d422                	sw	s0,40(sp)
   4c2e4:	d226                	sw	s1,36(sp)
   4c2e6:	a436                	fsd	fa3,8(sp)
   4c2e8:	47b2                	lw	a5,12(sp)
   4c2ea:	4722                	lw	a4,8(sp)
   4c2ec:	842a                	mv	s0,a0
   4c2ee:	d74d948b          	.insn	4, 0xd74d948b
   4c2f2:	d04a                	sw	s2,32(sp)
   4c2f4:	000be517          	auipc	a0,0xbe
   4c2f8:	4f050513          	addi	a0,a0,1264 # 10a7e4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5384> ; DATA 'CarPlayApp %s %dx%d ratio:%f\n'
   4c2fc:	892e                	mv	s2,a1
   4c2fe:	000be597          	auipc	a1,0xbe
   4c302:	4ce58593          	addi	a1,a1,1230 # 10a7cc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa536c> ; DATA 'set_carplay_screen_size'
   4c306:	ac22                	fsd	fs0,24(sp)
   4c308:	d606                	sw	ra,44(sp)
   4c30a:	20a50453          	fmv.s	fs0,fa0
   4c30e:	c080                	sw	s0,0(s1)
   4c310:	0124a223          	sw	s2,4(s1)
   4c314:	fffd6097          	auipc	ra,0xfffd6
   4c318:	d9c080e7          	jalr	-612(ra) # 220b0 <printf@plt>
   4c31c:	4ff00793          	li	a5,1279
   4c320:	0687de63          	bge	a5,s0,4c39c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0xd50>
   4c324:	0e100793          	li	a5,225
   4c328:	000bf697          	auipc	a3,0xbf
   4c32c:	a346a787          	flw	fa5,-1484(a3) # 10ad5c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa58fc>
   4c330:	00f4a423          	sw	a5,8(s1)
   4c334:	1887f7d3          	fdiv.s	fa5,fa5,fs0
   4c338:	000bd697          	auipc	a3,0xbd
   4c33c:	b346a707          	flw	fa4,-1228(a3) # 108e6c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa3a0c>
   4c340:	00e7f7d3          	fadd.s	fa5,fa5,fa4
   4c344:	c00797d3          	fcvt.w.s	a5,fa5,rtz
   4c348:	0807f25b          	.insn	4, 0x0807f25b
   4c34c:	fff78793          	addi	a5,a5,-1
   4c350:	40000713          	li	a4,1024
   4c354:	c4dc                	sw	a5,12(s1)
   4c356:	02e41b63          	bne	s0,a4,4c38c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0xd40>
   4c35a:	da890913          	addi	s2,s2,-600
   4c35e:	47a1                	li	a5,8
   4c360:	0327e663          	bltu	a5,s2,4c38c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0xd40>
   4c364:	000bf697          	auipc	a3,0xbf
   4c368:	a006a787          	flw	fa5,-1536(a3) # 10ad64 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5904>
   4c36c:	a08787d3          	fle.s	a5,fa5,fs0
   4c370:	cf91                	beqz	a5,4c38c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0xd40>
   4c372:	000bf617          	auipc	a2,0xbf
   4c376:	9f662787          	flw	fa5,-1546(a2) # 10ad68 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5908>
   4c37a:	a0f407d3          	fle.s	a5,fs0,fa5
   4c37e:	c799                	beqz	a5,4c38c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0xd40>
   4c380:	0c400793          	li	a5,196
   4c384:	c49c                	sw	a5,8(s1)
   4c386:	06e00793          	li	a5,110
   4c38a:	c4dc                	sw	a5,12(s1)
   4c38c:	50b2                	lw	ra,44(sp)
   4c38e:	5422                	lw	s0,40(sp)
   4c390:	2462                	fld	fs0,24(sp)
   4c392:	5492                	lw	s1,36(sp)
   4c394:	5902                	lw	s2,32(sp)
   4c396:	6145                	addi	sp,sp,48
   4c398:	00008067          	ret
   4c39c:	3ff00793          	li	a5,1023
   4c3a0:	0287de63          	bge	a5,s0,4c3dc <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0xd90>
   4c3a4:	000bf617          	auipc	a2,0xbf
   4c3a8:	9bc62787          	flw	fa5,-1604(a2) # 10ad60 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5900>
   4c3ac:	1887f7d3          	fdiv.s	fa5,fa5,fs0
   4c3b0:	000bd617          	auipc	a2,0xbd
   4c3b4:	abc62707          	flw	fa4,-1348(a2) # 108e6c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa3a0c>
   4c3b8:	0c400793          	li	a5,196
   4c3bc:	c49c                	sw	a5,8(s1)
   4c3be:	00e7f7d3          	fadd.s	fa5,fa5,fa4
   4c3c2:	c00797d3          	fcvt.w.s	a5,fa5,rtz
   4c3c6:	f807f35b          	.insn	4, 0xf807f35b
   4c3ca:	b759                	j	4c350 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0xd04>
   4c3cc:	50b2                	lw	ra,44(sp)
   4c3ce:	5422                	lw	s0,40(sp)
   4c3d0:	c4dc                	sw	a5,12(s1)
   4c3d2:	2462                	fld	fs0,24(sp)
   4c3d4:	5492                	lw	s1,36(sp)
   4c3d6:	5902                	lw	s2,32(sp)
   4c3d8:	6145                	addi	sp,sp,48
   4c3da:	8082                	ret
   4c3dc:	09a00793          	li	a5,154
   4c3e0:	000bf717          	auipc	a4,0xbf
   4c3e4:	97872787          	flw	fa5,-1672(a4) # 10ad58 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa58f8>
   4c3e8:	c49c                	sw	a5,8(s1)
   4c3ea:	b7a9                	j	4c334 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0xce8>
   4c3ec:	d74d988b          	.insn	4, 0xd74d988b
   4c3f0:	8eaa                	mv	t4,a0
   4c3f2:	8e2e                	mv	t3,a1
   4c3f4:	8332                	mv	t1,a2
   4c3f6:	87b6                	mv	a5,a3
   4c3f8:	883a                	mv	a6,a4
   4c3fa:	86ae                	mv	a3,a1
   4c3fc:	8732                	mv	a4,a2
   4c3fe:	000be597          	auipc	a1,0xbe
   4c402:	40658593          	addi	a1,a1,1030 # 10a804 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa53a4> ; DATA 'set_carplay_screen_size2'
   4c406:	862a                	mv	a2,a0
   4c408:	000be517          	auipc	a0,0xbe
   4c40c:	41850513          	addi	a0,a0,1048 # 10a820 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa53c0> ; DATA 'CarPlayApp %s %dx%d fps:%d mm:%dx%d\n'
   4c410:	01d8a023          	sw	t4,0(a7)
   4c414:	01c8a223          	sw	t3,4(a7)
   4c418:	0068a823          	sw	t1,16(a7)
   4c41c:	00f8a423          	sw	a5,8(a7)
   4c420:	0108a623          	sw	a6,12(a7)
   4c424:	fffd6317          	auipc	t1,0xfffd6
   4c428:	c8c30067          	jr	-884(t1) # 220b0 <printf@plt>
