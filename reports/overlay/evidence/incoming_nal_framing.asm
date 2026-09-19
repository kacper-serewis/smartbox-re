
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/lib/libCarLifeStub.so:     file format elf32-littleriscv


Disassembly of section .text:

00001ed8 <ScreenStreamProcessData@@Base>:
    1ed8:	16f002ef          	jal	t0,2846 <ScreenStreamProcessData@@Base+0x96e>
    1edc:	1141                	addi	sp,sp,-16
    1ede:	84ae                	mv	s1,a1
    1ee0:	8932                	mv	s2,a2
    1ee2:	8a42                	mv	s4,a6
    1ee4:	8b46                	mv	s6,a7
    1ee6:	fffff097          	auipc	ra,0xfffff
    1eea:	31a080e7          	jalr	794(ra) # 1200 <ScreenStreamGetContext@plt>
    1eee:	01054783          	lbu	a5,16(a0)
    1ef2:	89aa                	mv	s3,a0
    1ef4:	e38d                	bnez	a5,1f16 <ScreenStreamProcessData@@Base+0x3e>
    1ef6:	450c                	lw	a1,8(a0)
    1ef8:	16058f63          	beqz	a1,2076 <ScreenStreamProcessData@@Base+0x19e>
    1efc:	00002797          	auipc	a5,0x2
    1f00:	2507a783          	lw	a5,592(a5) # 414c <screenVideoProcessCallback@@Base-0x20> ; DATA ELF relocation: screenVideoProcessCallback
    1f04:	439c                	lw	a5,0(a5)
    1f06:	c789                	beqz	a5,1f10 <ScreenStreamProcessData@@Base+0x38>
    1f08:	4550                	lw	a2,12(a0)
    1f0a:	4685                	li	a3,1
    1f0c:	4509                	li	a0,2
    1f0e:	9782                	jalr	a5
    1f10:	4785                	li	a5,1
    1f12:	00f98823          	sb	a5,16(s3)
    1f16:	0149a783          	lw	a5,20(s3)
    1f1a:	0647ea5b          	.insn	4, 0x0647ea5b
    1f1e:	01248bb3          	add	s7,s1,s2
    1f22:	8aa6                	mv	s5,s1
    1f24:	00410d13          	addi	s10,sp,4
    1f28:	00c10c93          	addi	s9,sp,12
    1f2c:	00810c13          	addi	s8,sp,8
    1f30:	01000db7          	lui	s11,0x1000
    1f34:	c226                	sw	s1,4(sp)
    1f36:	0149a603          	lw	a2,20(s3)
    1f3a:	4512                	lw	a0,4(sp)
    1f3c:	87ea                	mv	a5,s10
    1f3e:	8766                	mv	a4,s9
    1f40:	86e2                	mv	a3,s8
    1f42:	85de                	mv	a1,s7
    1f44:	fffff097          	auipc	ra,0xfffff
    1f48:	2dc080e7          	jalr	732(ra) # 1220 <H264GetNextNALUnit@plt>
    1f4c:	842a                	mv	s0,a0
    1f4e:	cd05                	beqz	a0,1f86 <ScreenStreamProcessData@@Base+0xae>
    1f50:	77f9                	lui	a5,0xffffe
    1f52:	5a078793          	addi	a5,a5,1440 # ffffe5a0 <screenVideoProcessCallback@@Base+0xffffa434>
    1f56:	0af51663          	bne	a0,a5,2002 <ScreenStreamProcessData@@Base+0x12a>
    1f5a:	00002797          	auipc	a5,0x2
    1f5e:	1f27a783          	lw	a5,498(a5) # 414c <screenVideoProcessCallback@@Base-0x20> ; DATA ELF relocation: screenVideoProcessCallback
    1f62:	439c                	lw	a5,0(a5)
    1f64:	c791                	beqz	a5,1f70 <ScreenStreamProcessData@@Base+0x98>
    1f66:	4681                	li	a3,0
    1f68:	864a                	mv	a2,s2
    1f6a:	85a6                	mv	a1,s1
    1f6c:	4509                	li	a0,2
    1f6e:	9782                	jalr	a5
    1f70:	4401                	li	s0,0
    1f72:	000a0563          	beqz	s4,1f7c <ScreenStreamProcessData@@Base+0xa4>
    1f76:	855a                	mv	a0,s6
    1f78:	9a02                	jalr	s4
    1f7a:	e451                	bnez	s0,2006 <ScreenStreamProcessData@@Base+0x12e>
    1f7c:	4401                	li	s0,0
    1f7e:	8522                	mv	a0,s0
    1f80:	0141                	addi	sp,sp,16
    1f82:	1010006f          	j	2882 <ScreenStreamProcessData@@Base+0x9aa>
    1f86:	01baa023          	sw	s11,0(s5)
    1f8a:	4a92                	lw	s5,4(sp)
    1f8c:	b76d                	j	1f36 <ScreenStreamProcessData@@Base+0x5e>
    1f8e:	00390513          	addi	a0,s2,3
    1f92:	050a                	slli	a0,a0,0x2
    1f94:	fffff097          	auipc	ra,0xfffff
    1f98:	2dc080e7          	jalr	732(ra) # 1270 <malloc@plt>
    1f9c:	8aaa                	mv	s5,a0
    1f9e:	c165                	beqz	a0,207e <ScreenStreamProcessData@@Base+0x1a6>
    1fa0:	9926                	add	s2,s2,s1
    1fa2:	c226                	sw	s1,4(sp)
    1fa4:	00c50d93          	addi	s11,a0,12
    1fa8:	4481                	li	s1,0
    1faa:	00410c93          	addi	s9,sp,4
    1fae:	00c10c13          	addi	s8,sp,12
    1fb2:	00810b93          	addi	s7,sp,8
    1fb6:	01000d37          	lui	s10,0x1000
    1fba:	0149a603          	lw	a2,20(s3)
    1fbe:	4512                	lw	a0,4(sp)
    1fc0:	87e6                	mv	a5,s9
    1fc2:	8762                	mv	a4,s8
    1fc4:	86de                	mv	a3,s7
    1fc6:	85ca                	mv	a1,s2
    1fc8:	fffff097          	auipc	ra,0xfffff
    1fcc:	258080e7          	jalr	600(ra) # 1220 <H264GetNextNALUnit@plt>
    1fd0:	842a                	mv	s0,a0
    1fd2:	c935                	beqz	a0,2046 <ScreenStreamProcessData@@Base+0x16e>
    1fd4:	77f9                	lui	a5,0xffffe
    1fd6:	5a078793          	addi	a5,a5,1440 # ffffe5a0 <screenVideoProcessCallback@@Base+0xffffa434>
    1fda:	00f51e63          	bne	a0,a5,1ff6 <ScreenStreamProcessData@@Base+0x11e>
    1fde:	00002797          	auipc	a5,0x2
    1fe2:	16e7a783          	lw	a5,366(a5) # 414c <screenVideoProcessCallback@@Base-0x20> ; DATA ELF relocation: screenVideoProcessCallback
    1fe6:	439c                	lw	a5,0(a5)
    1fe8:	4401                	li	s0,0
    1fea:	c791                	beqz	a5,1ff6 <ScreenStreamProcessData@@Base+0x11e>
    1fec:	4681                	li	a3,0
    1fee:	8626                	mv	a2,s1
    1ff0:	85ee                	mv	a1,s11
    1ff2:	4509                	li	a0,2
    1ff4:	9782                	jalr	a5
    1ff6:	8556                	mv	a0,s5
    1ff8:	fffff097          	auipc	ra,0xfffff
    1ffc:	218080e7          	jalr	536(ra) # 1210 <free@plt>
    2000:	d825                	beqz	s0,1f70 <ScreenStreamProcessData@@Base+0x98>
    2002:	f60a1ae3          	bnez	s4,1f76 <ScreenStreamProcessData@@Base+0x9e>
    2006:	00002517          	auipc	a0,0x2
    200a:	13252503          	lw	a0,306(a0) # 4138 <gLogCategory_ScreenStream@@Base+0xf0> ; DATA ELF relocation: gLogCategory_ScreenStream
    200e:	411c                	lw	a5,0(a0)
    2010:	05a00713          	li	a4,90
    2014:	f6f745e3          	blt	a4,a5,1f7e <ScreenStreamProcessData@@Base+0xa6>
    2018:	577d                	li	a4,-1
    201a:	04e78663          	beq	a5,a4,2066 <ScreenStreamProcessData@@Base+0x18e>
    201e:	8722                	mv	a4,s0
    2020:	00001697          	auipc	a3,0x1
    2024:	a6068693          	addi	a3,a3,-1440 # 2a80 <ScreenStreamProcessData@@Base+0xba8> ; DATA '### Screen stream process data failed: %#m\n'
    2028:	05a00613          	li	a2,90
    202c:	00001597          	auipc	a1,0x1
    2030:	ad058593          	addi	a1,a1,-1328 # 2afc <ScreenStreamProcessData@@Base+0xc24> ; DATA 'ScreenStreamProcessData'
    2034:	00002517          	auipc	a0,0x2
    2038:	10452503          	lw	a0,260(a0) # 4138 <gLogCategory_ScreenStream@@Base+0xf0> ; DATA ELF relocation: gLogCategory_ScreenStream
    203c:	fffff097          	auipc	ra,0xfffff
    2040:	254080e7          	jalr	596(ra) # 1290 <LogPrintF@plt>
    2044:	bf2d                	j	1f7e <ScreenStreamProcessData@@Base+0xa6>
    2046:	4432                	lw	s0,12(sp)
    2048:	009d87b3          	add	a5,s11,s1
    204c:	45a2                	lw	a1,8(sp)
    204e:	0491                	addi	s1,s1,4
    2050:	009d8533          	add	a0,s11,s1
    2054:	8622                	mv	a2,s0
    2056:	01a7a023          	sw	s10,0(a5)
    205a:	94a2                	add	s1,s1,s0
    205c:	fffff097          	auipc	ra,0xfffff
    2060:	2b4080e7          	jalr	692(ra) # 1310 <memcpy@plt>
    2064:	bf99                	j	1fba <ScreenStreamProcessData@@Base+0xe2>
    2066:	05a00593          	li	a1,90
    206a:	fffff097          	auipc	ra,0xfffff
    206e:	1f6080e7          	jalr	502(ra) # 1260 <_LogCategory_Initialize@plt>
    2072:	d511                	beqz	a0,1f7e <ScreenStreamProcessData@@Base+0xa6>
    2074:	b76d                	j	201e <ScreenStreamProcessData@@Base+0x146>
    2076:	7479                	lui	s0,0xffffe
    2078:	5a740413          	addi	s0,s0,1447 # ffffe5a7 <screenVideoProcessCallback@@Base+0xffffa43b>
    207c:	b759                	j	2002 <ScreenStreamProcessData@@Base+0x12a>
    207e:	7479                	lui	s0,0xffffe
    2080:	5b840413          	addi	s0,s0,1464 # ffffe5b8 <screenVideoProcessCallback@@Base+0xffffa44c>
    2084:	bfbd                	j	2002 <ScreenStreamProcessData@@Base+0x12a>
