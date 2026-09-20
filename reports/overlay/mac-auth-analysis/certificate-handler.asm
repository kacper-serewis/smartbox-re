
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00051c8c <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x118>:
   51c8c:	715d                	addi	sp,sp,-80
   51c8e:	da56                	sw	s5,52(sp)
   51c90:	6ac1                	lui	s5,0x10
   51c92:	c2a6                	sw	s1,68(sp)
   51c94:	72c1                	lui	t0,0xffff0
   51c96:	74c1                	lui	s1,0xffff0
   51c98:	030a8713          	addi	a4,s5,48 # 10030 <CFArrayCreateCopy@plt-0xf7a0>
   51c9c:	9726                	add	a4,a4,s1
   51c9e:	c4a2                	sw	s0,72(sp)
   51ca0:	c0ca                	sw	s2,64(sp)
   51ca2:	de4e                	sw	s3,60(sp)
   51ca4:	dc52                	sw	s4,56(sp)
   51ca6:	c686                	sw	ra,76(sp)
   51ca8:	9116                	add	sp,sp,t0
   51caa:	00270433          	add	s0,a4,sp
   51cae:	8a32                	mv	s4,a2
   51cb0:	6641                	lui	a2,0x10
   51cb2:	166d                	addi	a2,a2,-5 # fffb <CFArrayCreateCopy@plt-0xf7d5>
   51cb4:	892a                	mv	s2,a0
   51cb6:	89ae                	mv	s3,a1
   51cb8:	00440513          	addi	a0,s0,4
   51cbc:	00000593          	li	a1,0
   51cc0:	00042023          	sw	zero,0(s0)
   51cc4:	fffd0097          	auipc	ra,0xfffd0
   51cc8:	34c080e7          	jalr	844(ra) # 22010 <memset@plt>
   51ccc:	000ba797          	auipc	a5,0xba
   51cd0:	b3478793          	addi	a5,a5,-1228 # 10b800 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa63a0>
   51cd4:	0007a303          	lw	t1,0(a5)
   51cd8:	0047a883          	lw	a7,4(a5)
   51cdc:	0087a803          	lw	a6,8(a5)
   51ce0:	47c8                	lw	a0,12(a5)
   51ce2:	4b8c                	lw	a1,16(a5)
   51ce4:	4bd0                	lw	a2,20(a5)
   51ce6:	4f94                	lw	a3,24(a5)
   51ce8:	4fdc                	lw	a5,28(a5)
   51cea:	1481                	addi	s1,s1,-32 # fffeffe0 <AOAProxy::sReaderBuffer@@Base+0xffebf6ec>
   51cec:	030a8713          	addi	a4,s5,48
   51cf0:	fef42e23          	sw	a5,-4(s0)
   51cf4:	6791                	lui	a5,0x4
   51cf6:	9726                	add	a4,a4,s1
   51cf8:	04078793          	addi	a5,a5,64 # 4040 <CFArrayCreateCopy@plt-0x1b790>
   51cfc:	002704b3          	add	s1,a4,sp
   51d00:	00f41023          	sh	a5,0(s0)
   51d04:	2aa00793          	li	a5,682
   51d08:	00f41223          	sh	a5,4(s0)
   51d0c:	28000713          	li	a4,640
   51d10:	fe642023          	sw	t1,-32(s0)
   51d14:	ff142223          	sw	a7,-28(s0)
   51d18:	ff042423          	sw	a6,-24(s0)
   51d1c:	fea42623          	sw	a0,-20(s0)
   51d20:	feb42823          	sw	a1,-16(s0)
   51d24:	fec42a23          	sw	a2,-12(s0)
   51d28:	fed42c23          	sw	a3,-8(s0)
   51d2c:	fc041a23          	sh	zero,-44(s0)
   51d30:	fc942c23          	sw	s1,-40(s0)
   51d34:	01400793          	li	a5,20
   51d38:	01474463          	blt	a4,s4,51d40 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x1cc>
   51d3c:	02000793          	li	a5,32
   51d40:	64c1                	lui	s1,0x10
   51d42:	75c1                	lui	a1,0xffff0
   51d44:	03048693          	addi	a3,s1,48 # 10030 <CFArrayCreateCopy@plt-0xf7a0>
   51d48:	96ae                	add	a3,a3,a1
   51d4a:	00268433          	add	s0,a3,sp
   51d4e:	fd458593          	addi	a1,a1,-44 # fffeffd4 <AOAProxy::sReaderBuffer@@Base+0xffebf6e0>
   51d52:	03048693          	addi	a3,s1,48
   51d56:	96ae                	add	a3,a3,a1
   51d58:	002685b3          	add	a1,a3,sp
   51d5c:	00640513          	addi	a0,s0,6
   51d60:	fcf42e23          	sw	a5,-36(s0)
   51d64:	e15ff0ef          	jal	51b78 <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0x4>
   51d68:	40850633          	sub	a2,a0,s0
   51d6c:	3c8627db          	.insn	4, 0x3c8627db
   51d70:	00861813          	slli	a6,a2,0x8
   51d74:	00f86833          	or	a6,a6,a5
   51d78:	86ce                	mv	a3,s3
   51d7a:	85a2                	mv	a1,s0
   51d7c:	854a                	mv	a0,s2
   51d7e:	000dd797          	auipc	a5,0xdd
   51d82:	34e7a783          	lw	a5,846(a5) # 12f0cc <_iAP2LinkDataSentAuthResponseCB_t(iAP2Link_st*, void*)@@Base+0xdd558> ; DATA ELF relocation: _Z33_iAP2LinkDataSentAuthResponseCB_tP11iAP2Link_stPv
   51d86:	4701                	li	a4,0
   51d88:	01041123          	sh	a6,2(s0)
   51d8c:	fffcf097          	auipc	ra,0xfffcf
   51d90:	154080e7          	jalr	340(ra) # 20ee0 <iAP2LinkQueueSendData@plt>
   51d94:	62c1                	lui	t0,0x10
   51d96:	9116                	add	sp,sp,t0
   51d98:	40b6                	lw	ra,76(sp)
   51d9a:	4426                	lw	s0,72(sp)
   51d9c:	4496                	lw	s1,68(sp)
   51d9e:	4906                	lw	s2,64(sp)
   51da0:	59f2                	lw	s3,60(sp)
   51da2:	5a62                	lw	s4,56(sp)
   51da4:	5ad2                	lw	s5,52(sp)
   51da6:	6161                	addi	sp,sp,80
   51da8:	00008067          	ret
   51dac:	7179                	addi	sp,sp,-48
   51dae:	72c1                	lui	t0,0xffff0
   51db0:	d422                	sw	s0,40(sp)
   51db2:	02c1                	addi	t0,t0,16 # ffff0010 <AOAProxy::sReaderBuffer@@Base+0xffebf71c>
   51db4:	7441                	lui	s0,0xffff0
   51db6:	67c1                	lui	a5,0x10
   51db8:	d606                	sw	ra,44(sp)
   51dba:	d226                	sw	s1,36(sp)
   51dbc:	d04a                	sw	s2,32(sp)
   51dbe:	ce4e                	sw	s3,28(sp)
   51dc0:	97a2                	add	a5,a5,s0
   51dc2:	9116                	add	sp,sp,t0
   51dc4:	00278433          	add	s0,a5,sp
   51dc8:	84b2                	mv	s1,a2
   51dca:	6641                	lui	a2,0x10
   51dcc:	892a                	mv	s2,a0
   51dce:	89ae                	mv	s3,a1
   51dd0:	166d                	addi	a2,a2,-5 # fffb <CFArrayCreateCopy@plt-0xf7d5>
   51dd2:	4581                	li	a1,0
   51dd4:	00440513          	addi	a0,s0,4 # ffff0004 <AOAProxy::sReaderBuffer@@Base+0xffebf710>
   51dd8:	00042023          	sw	zero,0(s0)
   51ddc:	fffd0097          	auipc	ra,0xfffd0
   51de0:	234080e7          	jalr	564(ra) # 22010 <memset@plt>
   51de4:	00903833          	snez	a6,s1
   51de8:	0811                	addi	a6,a6,4
   51dea:	010402a3          	sb	a6,5(s0)
   51dee:	6891                	lui	a7,0x4
   51df0:	786d                	lui	a6,0xffffb
   51df2:	86ce                	mv	a3,s3
   51df4:	85a2                	mv	a1,s0
   51df6:	854a                	mv	a0,s2
   51df8:	04088893          	addi	a7,a7,64 # 4040 <CFArrayCreateCopy@plt-0x1b790>
   51dfc:	a0680813          	addi	a6,a6,-1530 # ffffaa06 <AOAProxy::sReaderBuffer@@Base+0xffeca112>
   51e00:	4781                	li	a5,0
   51e02:	4701                	li	a4,0
   51e04:	00600613          	li	a2,6
   51e08:	01141023          	sh	a7,0(s0)
   51e0c:	010411a3          	sh	a6,3(s0)
   51e10:	fffcf097          	auipc	ra,0xfffcf
   51e14:	0d0080e7          	jalr	208(ra) # 20ee0 <iAP2LinkQueueSendData@plt>
   51e18:	62c1                	lui	t0,0x10
   51e1a:	12c1                	addi	t0,t0,-16 # fff0 <CFArrayCreateCopy@plt-0xf7e0>
   51e1c:	9116                	add	sp,sp,t0
   51e1e:	50b2                	lw	ra,44(sp)
   51e20:	5422                	lw	s0,40(sp)
   51e22:	5492                	lw	s1,36(sp)
   51e24:	5902                	lw	s2,32(sp)
   51e26:	49f2                	lw	s3,28(sp)
   51e28:	6145                	addi	sp,sp,48
   51e2a:	8082                	ret
