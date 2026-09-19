
firmwares/hw501/126/rootfs/lib/libCoreUtils.so:     file format elf32-littleriscv


Disassembly of section .text:

00051f0c <MFiPlatform_Initialize@@Base>:
   51f0c:	7179                	addi	sp,sp,-48
   51f0e:	cc52                	sw	s4,24(sp)
   51f10:	00073a17          	auipc	s4,0x73
   51f14:	c28a0a13          	addi	s4,s4,-984 # c4b38 <gDispatchMainQueueScheduleHookFunc@@Base+0x4>
   51f18:	020a2783          	lw	a5,32(s4)
   51f1c:	d606                	sw	ra,44(sp)
   51f1e:	d422                	sw	s0,40(sp)
   51f20:	d226                	sw	s1,36(sp)
   51f22:	d04a                	sw	s2,32(sp)
   51f24:	ce4e                	sw	s3,28(sp)
   51f26:	ca56                	sw	s5,20(sp)
   51f28:	0e078e63          	beqz	a5,52024 <MFiPlatform_Initialize@@Base+0x118>
   51f2c:	19ca2403          	lw	s0,412(s4)
   51f30:	00071917          	auipc	s2,0x71
   51f34:	40090913          	addi	s2,s2,1024 # c3330 <gLogCategory_DebugServicesAssert@@Base+0x40>
   51f38:	e841                	bnez	s0,51fc8 <MFiPlatform_Initialize@@Base+0xbc>
   51f3a:	47c1                	li	a5,16
   51f3c:	6989                	lui	s3,0x2
   51f3e:	c43e                	sw	a5,8(sp)
   51f40:	47c5                	li	a5,17
   51f42:	4441                	li	s0,16
   51f44:	4481                	li	s1,0
   51f46:	00071917          	auipc	s2,0x71
   51f4a:	3ea90913          	addi	s2,s2,1002 # c3330 <gLogCategory_DebugServicesAssert@@Base+0x40>
   51f4e:	00073a97          	auipc	s5,0x73
   51f52:	c1ea8a93          	addi	s5,s5,-994 # c4b6c <gDispatchMainQueueScheduleHookFunc@@Base+0x38>
   51f56:	71098993          	addi	s3,s3,1808 # 2710 <mp_invmod_slow@plt-0x12270>
   51f5a:	c63e                	sw	a5,12(sp)
   51f5c:	0080006f          	j	51f64 <MFiPlatform_Initialize@@Base+0x58>
   51f60:	ff87a403          	lw	s0,-8(a5)
   51f64:	85a2                	mv	a1,s0
   51f66:	8556                	mv	a0,s5
   51f68:	00148493          	addi	s1,s1,1
   51f6c:	00892223          	sw	s0,4(s2)
   51f70:	fffc6097          	auipc	ra,0xfffc6
   51f74:	bc0080e7          	jalr	-1088(ra) # 17b30 <MFiPlatform_AutoDetect@plt>
   51f78:	c155                	beqz	a0,5201c <MFiPlatform_Initialize@@Base+0x110>
   51f7a:	854e                	mv	a0,s3
   51f7c:	fffc5097          	auipc	ra,0xfffc5
   51f80:	d64080e7          	jalr	-668(ra) # 16ce0 <usleep@plt>
   51f84:	0024a7db          	.insn	4, 0x0024a7db
   51f88:	01078713          	addi	a4,a5,16
   51f8c:	002707b3          	add	a5,a4,sp
   51f90:	bca4e85b          	.insn	4, 0xbca4e85b
   51f94:	19ca2403          	lw	s0,412(s4)
   51f98:	02041863          	bnez	s0,51fc8 <MFiPlatform_Initialize@@Base+0xbc>
   51f9c:	00073617          	auipc	a2,0x73
   51fa0:	bd060613          	addi	a2,a2,-1072 # c4b6c <gDispatchMainQueueScheduleHookFunc@@Base+0x38>
   51fa4:	00057597          	auipc	a1,0x57
   51fa8:	e7458593          	addi	a1,a1,-396 # a8e18 <mp_reduce@@Base+0xb578> ; DATA 'MFiPlatform auto detect address on %s failed\n'
   51fac:	00056517          	auipc	a0,0x56
   51fb0:	2e050513          	addi	a0,a0,736 # a828c <mp_reduce@@Base+0xa9ec> ; DATA 'MFiServerPlatformLinux'
   51fb4:	fffc3097          	auipc	ra,0xfffc3
   51fb8:	e9c080e7          	jalr	-356(ra) # 14e50 <MLOGD@plt>
   51fbc:	028a2783          	lw	a5,40(s4)
   51fc0:	c7a1                	beqz	a5,52008 <MFiPlatform_Initialize@@Base+0xfc>
   51fc2:	4505                	li	a0,1
   51fc4:	9782                	jalr	a5
   51fc6:	a089                	j	52008 <MFiPlatform_Initialize@@Base+0xfc>
   51fc8:	00057597          	auipc	a1,0x57
   51fcc:	e1c58593          	addi	a1,a1,-484 # a8de4 <mp_reduce@@Base+0xb544> ; DATA 'MFiPlatform auto detect mfi address:0x%x dev:%s\n'
   51fd0:	00073697          	auipc	a3,0x73
   51fd4:	b9c68693          	addi	a3,a3,-1124 # c4b6c <gDispatchMainQueueScheduleHookFunc@@Base+0x38>
   51fd8:	00040613          	mv	a2,s0
   51fdc:	00056517          	auipc	a0,0x56
   51fe0:	2b050513          	addi	a0,a0,688 # a828c <mp_reduce@@Base+0xa9ec> ; DATA 'MFiServerPlatformLinux'
   51fe4:	00892223          	sw	s0,4(s2)
   51fe8:	fffc3097          	auipc	ra,0xfffc3
   51fec:	e68080e7          	jalr	-408(ra) # 14e50 <MLOGD@plt>
   51ff0:	00073597          	auipc	a1,0x73
   51ff4:	b7858593          	addi	a1,a1,-1160 # c4b68 <gDispatchMainQueueScheduleHookFunc@@Base+0x34>
   51ff8:	00073517          	auipc	a0,0x73
   51ffc:	b6c50513          	addi	a0,a0,-1172 # c4b64 <gDispatchMainQueueScheduleHookFunc@@Base+0x30>
   52000:	fffc4097          	auipc	ra,0xfffc4
   52004:	4f0080e7          	jalr	1264(ra) # 164f0 <MFiPlatform_CopyCertificate@plt>
   52008:	50b2                	lw	ra,44(sp)
   5200a:	5422                	lw	s0,40(sp)
   5200c:	5492                	lw	s1,36(sp)
   5200e:	5902                	lw	s2,32(sp)
   52010:	49f2                	lw	s3,28(sp)
   52012:	4a62                	lw	s4,24(sp)
   52014:	4ad2                	lw	s5,20(sp)
   52016:	4501                	li	a0,0
   52018:	6145                	addi	sp,sp,48
   5201a:	8082                	ret
   5201c:	188a2e23          	sw	s0,412(s4)
   52020:	f79ff06f          	j	51f98 <MFiPlatform_Initialize@@Base+0x8c>
   52024:	00057517          	auipc	a0,0x57
   52028:	db050513          	addi	a0,a0,-592 # a8dd4 <mp_reduce@@Base+0xb534> ; DATA 'mfi_dev_path'
   5202c:	fffc5097          	auipc	ra,0xfffc5
   52030:	2a4080e7          	jalr	676(ra) # 172d0 <getenv@plt>
   52034:	00050593          	mv	a1,a0
   52038:	02050863          	beqz	a0,52068 <MFiPlatform_Initialize@@Base+0x15c>
   5203c:	00073517          	auipc	a0,0x73
   52040:	b3050513          	addi	a0,a0,-1232 # c4b6c <gDispatchMainQueueScheduleHookFunc@@Base+0x38>
   52044:	fffc6097          	auipc	ra,0xfffc6
   52048:	69c080e7          	jalr	1692(ra) # 186e0 <strcpy@plt>
   5204c:	ffff9797          	auipc	a5,0xffff9
   52050:	a8c78793          	addi	a5,a5,-1396 # 4aad8 <HTTPHeader_Parse@@Base+0x58c>
   52054:	02fa2023          	sw	a5,32(s4)
   52058:	fffff797          	auipc	a5,0xfffff
   5205c:	29c78793          	addi	a5,a5,668 # 512f4 <MFiSAP_Decrypt@@Base+0x20>
   52060:	02fa2223          	sw	a5,36(s4)
   52064:	ec9ff06f          	j	51f2c <MFiPlatform_Initialize@@Base+0x20>
   52068:	00057597          	auipc	a1,0x57
   5206c:	d6058593          	addi	a1,a1,-672 # a8dc8 <mp_reduce@@Base+0xb528> ; DATA '/dev/i2c-0'
   52070:	fcdff06f          	j	5203c <MFiPlatform_Initialize@@Base+0x130>
