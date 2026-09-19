
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00050d98 <logout(void*, int, char const*, void*)@@Base+0x3b8>:
   50d98:	87aa                	mv	a5,a0
   50d9a:	4d08                	lw	a0,24(a0)
   50d9c:	c141                	beqz	a0,50e1c <logout(void*, int, char const*, void*)@@Base+0x43c>
   50d9e:	0005a803          	lw	a6,0(a1)
   50da2:	7115                	addi	sp,sp,-224
   50da4:	cf86                	sw	ra,220(sp)
   50da6:	cda2                	sw	s0,216(sp)
   50da8:	00e03733          	snez	a4,a4
   50dac:	4790                	lw	a2,8(a5)
   50dae:	4107a623          	sw	a6,1036(a5)
   50db2:	40e00733          	neg	a4,a4
   50db6:	0045a303          	lw	t1,4(a1)
   50dba:	9b79                	andi	a4,a4,-2
   50dbc:	00160893          	addi	a7,a2,1
   50dc0:	41f65813          	srai	a6,a2,0x1f
   50dc4:	070d                	addi	a4,a4,3
   50dc6:	4067a823          	sw	t1,1040(a5)
   50dca:	458c                	lw	a1,8(a1)
   50dcc:	0117a423          	sw	a7,8(a5)
   50dd0:	3ec7a023          	sw	a2,992(a5)
   50dd4:	3f07a223          	sw	a6,996(a5)
   50dd8:	3ce7a823          	sw	a4,976(a5)
   50ddc:	00058463          	beqz	a1,50de4 <logout(void*, int, char const*, void*)@@Base+0x404>
   50de0:	40b7aa23          	sw	a1,1044(a5)
   50de4:	8436                	mv	s0,a3
   50de6:	0818                	addi	a4,sp,16
   50de8:	3d078693          	addi	a3,a5,976
   50dec:	0070                	addi	a2,sp,12
   50dee:	002c                	addi	a1,sp,8
   50df0:	c402                	sw	zero,8(sp)
   50df2:	c602                	sw	zero,12(sp)
   50df4:	1b5270ef          	jal	787a8 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0x13348>
   50df8:	00a05c63          	blez	a0,50e10 <logout(void*, int, char const*, void*)@@Base+0x430>
   50dfc:	47b2                	lw	a5,12(sp)
   50dfe:	00f05963          	blez	a5,50e10 <logout(void*, int, char const*, void*)@@Base+0x430>
   50e02:	47a2                	lw	a5,8(sp)
   50e04:	c008                	sw	a0,0(s0)
   50e06:	40fe                	lw	ra,220(sp)
   50e08:	446e                	lw	s0,216(sp)
   50e0a:	4f88                	lw	a0,24(a5)
   50e0c:	612d                	addi	sp,sp,224
   50e0e:	8082                	ret
   50e10:	40fe                	lw	ra,220(sp)
   50e12:	446e                	lw	s0,216(sp)
   50e14:	4501                	li	a0,0
   50e16:	612d                	addi	sp,sp,224
   50e18:	00008067          	ret
   50e1c:	00008067          	ret
