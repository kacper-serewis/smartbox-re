
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0004dc4c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x2600>:
   4dc4c:	000bd597          	auipc	a1,0xbd
   4dc50:	3c458593          	addi	a1,a1,964 # 10b010 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5bb0>
   4dc54:	00040513          	mv	a0,s0
   4dc58:	fffd2097          	auipc	ra,0xfffd2
   4dc5c:	558080e7          	jalr	1368(ra) # 201b0 <CFEqual@plt>
   4dc60:	cd51                	beqz	a0,4dcfc <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x26b0>
   4dc62:	0c84a503          	lw	a0,200(s1)
   4dc66:	c91d                	beqz	a0,4dc9c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x2650>
   4dc68:	fffd4097          	auipc	ra,0xfffd4
   4dc6c:	858080e7          	jalr	-1960(ra) # 214c0 <CFArrayGetCount@plt>
   4dc70:	02a05663          	blez	a0,4dc9c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x2650>
   4dc74:	0c84a403          	lw	s0,200(s1)
   4dc78:	4481                	li	s1,0
   4dc7a:	a00417e3          	bnez	s0,4d688 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x203c>
   4dc7e:	bc19                	j	4d694 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x2048>
   4dc80:	000bd597          	auipc	a1,0xbd
   4dc84:	ec858593          	addi	a1,a1,-312 # 10ab48 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa56e8> ; DATA 'Set carplay extendedFeatures not handled'
   4dc88:	000c1517          	auipc	a0,0xc1
   4dc8c:	b4050513          	addi	a0,a0,-1216 # 10e7c8 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa9368> ; DATA 'CarPlay'
   4dc90:	fffd4097          	auipc	ra,0xfffd4
   4dc94:	070080e7          	jalr	112(ra) # 21d00 <MLOGD@plt>
   4dc98:	c81ff06f          	j	4d918 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x22cc>
   4dc9c:	d74d940b          	.insn	4, 0xd74d940b
   4dca0:	00c42303          	lw	t1,12(s0)
   4dca4:	00842883          	lw	a7,8(s0)
   4dca8:	00442803          	lw	a6,4(s0)
   4dcac:	401c                	lw	a5,0(s0)
   4dcae:	4818                	lw	a4,16(s0)
   4dcb0:	4681                	li	a3,0
   4dcb2:	4639                	li	a2,14
   4dcb4:	000bd597          	auipc	a1,0xbd
   4dcb8:	37058593          	addi	a1,a1,880 # 10b024 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5bc4>
   4dcbc:	1028                	addi	a0,sp,40
   4dcbe:	c01a                	sw	t1,0(sp)
   4dcc0:	02012423          	sw	zero,40(sp)
   4dcc4:	fffd4097          	auipc	ra,0xfffd4
   4dcc8:	4fc080e7          	jalr	1276(ra) # 221c0 <AirPlayInfoArrayAddScreenDisplay@plt>
   4dccc:	00c42803          	lw	a6,12(s0)
   4dcd0:	441c                	lw	a5,8(s0)
   4dcd2:	4058                	lw	a4,4(s0)
   4dcd4:	00042683          	lw	a3,0(s0)
   4dcd8:	000bd617          	auipc	a2,0xbd
   4dcdc:	f1c60613          	addi	a2,a2,-228 # 10abf4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5794> ; DATA '_getScreenDisplays'
   4dce0:	000bd597          	auipc	a1,0xbd
   4dce4:	f2858593          	addi	a1,a1,-216 # 10ac08 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa57a8> ; DATA '%s size:%dx%d %dmmx%dmm\n'
   4dce8:	000bd517          	auipc	a0,0xbd
   4dcec:	e1c50513          	addi	a0,a0,-484 # 10ab04 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa56a4> ; DATA 'CarPlayApp'
   4dcf0:	fffd4097          	auipc	ra,0xfffd4
   4dcf4:	010080e7          	jalr	16(ra) # 21d00 <MLOGD@plt>
   4dcf8:	5422                	lw	s0,40(sp)
   4dcfa:	bfbd                	j	4dc78 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x262c>
