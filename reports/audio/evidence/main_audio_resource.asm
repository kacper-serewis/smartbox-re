
CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0004e098 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0xb0>:
   4e098:	7179                	addi	sp,sp,-48
   4e09a:	d422                	sw	s0,40(sp)
   4e09c:	d226                	sw	s1,36(sp)
   4e09e:	0490140b          	.insn	4, 0x0490140b
   4e0a2:	84aa                	mv	s1,a0
   4e0a4:	02112623          	sw	ra,44(sp)
   4e0a8:	b19fd0ef          	jal	4bbc0 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x574>
   4e0ac:	581c                	lw	a5,48(s0)
   4e0ae:	cfa9                	beqz	a5,4e108 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x120>
   4e0b0:	00048693          	mv	a3,s1
   4e0b4:	000bd617          	auipc	a2,0xbd
   4e0b8:	bd460613          	addi	a2,a2,-1068 # 10ac88 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5828> ; DATA 'sendMainAudioModes'
   4e0bc:	000bd597          	auipc	a1,0xbd
   4e0c0:	be058593          	addi	a1,a1,-1056 # 10ac9c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa583c> ; DATA '%s AirPlayTransferType:%u\n'
   4e0c4:	000bd517          	auipc	a0,0xbd
   4e0c8:	a4050513          	addi	a0,a0,-1472 # 10ab04 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa56a4> ; DATA 'CarPlayApp'
   4e0cc:	fffd4097          	auipc	ra,0xfffd4
   4e0d0:	c34080e7          	jalr	-972(ra) # 21d00 <MLOGD@plt>
   4e0d4:	5808                	lw	a0,48(s0)
   4e0d6:	4881                	li	a7,0
   4e0d8:	4801                	li	a6,0
   4e0da:	06400793          	li	a5,100
   4e0de:	06400713          	li	a4,100
   4e0e2:	06400693          	li	a3,100
   4e0e6:	8626                	mv	a2,s1
   4e0e8:	4589                	li	a1,2
   4e0ea:	c002                	sw	zero,0(sp)
   4e0ec:	fffd4097          	auipc	ra,0xfffd4
   4e0f0:	124080e7          	jalr	292(ra) # 22210 <AirPlayReceiverSessionChangeResourceMode@plt>
   4e0f4:	00a12e23          	sw	a0,28(sp)
   4e0f8:	ad9fd0ef          	jal	4bbd0 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x584>
   4e0fc:	50b2                	lw	ra,44(sp)
   4e0fe:	5422                	lw	s0,40(sp)
   4e100:	4572                	lw	a0,28(sp)
   4e102:	5492                	lw	s1,36(sp)
   4e104:	6145                	addi	sp,sp,48
   4e106:	8082                	ret
   4e108:	7579                	lui	a0,0xffffe
   4e10a:	5d450513          	addi	a0,a0,1492 # ffffe5d4 <AOAProxy::sReaderBuffer@@Base+0xffecdce0>
   4e10e:	b7dd                	j	4e0f4 <getAirPlayRecvSessionModeState(AirPlayReceiverSessionPrivate*)@@Base+0x10c>
