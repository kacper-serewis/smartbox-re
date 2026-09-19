
firmwares/hw501/128/rootfs/lib/libCoreUtils.so:     file format elf32-littleriscv


Disassembly of section .text:

00044660 <MFiPlatform_Initialize@@Base>:
   44660:	74f352ef          	jal	t0,7a5ae <s_mp_sub@@Base+0x11b8>
   44664:	0005a417          	auipc	s0,0x5a
   44668:	54840413          	addi	s0,s0,1352 # 9ebac <gLogUtilsInitializing@@Base+0x13>
   4466c:	501c                	lw	a5,32(s0)
   4466e:	1141                	addi	sp,sp,-16
   44670:	e3a9                	bnez	a5,446b2 <MFiPlatform_Initialize@@Base+0x52>
   44672:	0003f517          	auipc	a0,0x3f
   44676:	96650513          	addi	a0,a0,-1690 # 82fd8 <kCFLArrayCallBacksNull@@Base+0x6dc8> ; DATA 'mfi_dev_path'
   4467a:	fffd3097          	auipc	ra,0xfffd3
   4467e:	ca6080e7          	jalr	-858(ra) # 17320 <getenv@plt>
   44682:	85aa                	mv	a1,a0
   44684:	e509                	bnez	a0,4468e <MFiPlatform_Initialize@@Base+0x2e>
   44686:	0003f597          	auipc	a1,0x3f
   4468a:	94658593          	addi	a1,a1,-1722 # 82fcc <kCFLArrayCallBacksNull@@Base+0x6dbc> ; DATA '/dev/i2c-0'
   4468e:	0005a517          	auipc	a0,0x5a
   44692:	55250513          	addi	a0,a0,1362 # 9ebe0 <gLogUtilsInitializing@@Base+0x47>
   44696:	fffd4097          	auipc	ra,0xfffd4
   4469a:	09a080e7          	jalr	154(ra) # 18730 <strcpy@plt>
   4469e:	fffff797          	auipc	a5,0xfffff
   446a2:	66c78793          	addi	a5,a5,1644 # 43d0a <MFiSAP_Decrypt@@Base+0x23c>
   446a6:	d01c                	sw	a5,32(s0)
   446a8:	fffff797          	auipc	a5,0xfffff
   446ac:	42878793          	addi	a5,a5,1064 # 43ad0 <MFiSAP_Decrypt@@Base+0x2>
   446b0:	d05c                	sw	a5,36(s0)
   446b2:	13442783          	lw	a5,308(s0)
   446b6:	e7a1                	bnez	a5,446fe <MFiPlatform_Initialize@@Base+0x9e>
   446b8:	47c1                	li	a5,16
   446ba:	6909                	lui	s2,0x2
   446bc:	c43e                	sw	a5,8(sp)
   446be:	4481                	li	s1,0
   446c0:	47c5                	li	a5,17
   446c2:	00059a17          	auipc	s4,0x59
   446c6:	d26a0a13          	addi	s4,s4,-730 # 9d3e8 <gLogCategory_LogUtils@@Base+0x40>
   446ca:	0005aa97          	auipc	s5,0x5a
   446ce:	516a8a93          	addi	s5,s5,1302 # 9ebe0 <gLogUtilsInitializing@@Base+0x47>
   446d2:	71090913          	addi	s2,s2,1808 # 2710 <mp_invmod_slow@plt-0x122b0>
   446d6:	c63e                	sw	a5,12(sp)
   446d8:	0024a7db          	.insn	4, 0x0024a7db
   446dc:	01078713          	addi	a4,a5,16
   446e0:	002707b3          	add	a5,a4,sp
   446e4:	ff87a983          	lw	s3,-8(a5)
   446e8:	8556                	mv	a0,s5
   446ea:	85ce                	mv	a1,s3
   446ec:	013a2223          	sw	s3,4(s4)
   446f0:	fffd3097          	auipc	ra,0xfffd3
   446f4:	490080e7          	jalr	1168(ra) # 17b80 <MFiPlatform_AutoDetect@plt>
   446f8:	e931                	bnez	a0,4474c <MFiPlatform_Initialize@@Base+0xec>
   446fa:	13342a23          	sw	s3,308(s0)
   446fe:	13442603          	lw	a2,308(s0)
   44702:	ce31                	beqz	a2,4475e <MFiPlatform_Initialize@@Base+0xfe>
   44704:	00059697          	auipc	a3,0x59
   44708:	cec6a423          	sw	a2,-792(a3) # 9d3ec <gLogCategory_LogUtils@@Base+0x44>
   4470c:	0003f597          	auipc	a1,0x3f
   44710:	8dc58593          	addi	a1,a1,-1828 # 82fe8 <kCFLArrayCallBacksNull@@Base+0x6dd8> ; DATA 'MFiPlatform auto detect mfi address:0x%x dev:%s\n'
   44714:	0005a697          	auipc	a3,0x5a
   44718:	4cc68693          	addi	a3,a3,1228 # 9ebe0 <gLogUtilsInitializing@@Base+0x47>
   4471c:	0003e517          	auipc	a0,0x3e
   44720:	4d050513          	addi	a0,a0,1232 # 82bec <kCFLArrayCallBacksNull@@Base+0x69dc> ; DATA 'MFiServerPlatformLinux'
   44724:	fffd0097          	auipc	ra,0xfffd0
   44728:	77c080e7          	jalr	1916(ra) # 14ea0 <MLOGD@plt>
   4472c:	0005a597          	auipc	a1,0x5a
   44730:	4b058593          	addi	a1,a1,1200 # 9ebdc <gLogUtilsInitializing@@Base+0x43>
   44734:	0005a517          	auipc	a0,0x5a
   44738:	4a450513          	addi	a0,a0,1188 # 9ebd8 <gLogUtilsInitializing@@Base+0x3f>
   4473c:	fffd2097          	auipc	ra,0xfffd2
   44740:	e04080e7          	jalr	-508(ra) # 16540 <MFiPlatform_CopyCertificate@plt>
   44744:	4501                	li	a0,0
   44746:	0141                	addi	sp,sp,16
   44748:	69b3506f          	j	7a5e2 <s_mp_sub@@Base+0x11ec>
   4474c:	854a                	mv	a0,s2
   4474e:	0485                	addi	s1,s1,1
   44750:	fffd2097          	auipc	ra,0xfffd2
   44754:	5e0080e7          	jalr	1504(ra) # 16d30 <usleep@plt>
   44758:	b8a4e05b          	.insn	4, 0xb8a4e05b
   4475c:	b74d                	j	446fe <MFiPlatform_Initialize@@Base+0x9e>
   4475e:	0005a617          	auipc	a2,0x5a
   44762:	48260613          	addi	a2,a2,1154 # 9ebe0 <gLogUtilsInitializing@@Base+0x47>
   44766:	0003f597          	auipc	a1,0x3f
   4476a:	8b658593          	addi	a1,a1,-1866 # 8301c <kCFLArrayCallBacksNull@@Base+0x6e0c> ; DATA 'MFiPlatform auto detect address on %s failed\n'
   4476e:	0003e517          	auipc	a0,0x3e
   44772:	47e50513          	addi	a0,a0,1150 # 82bec <kCFLArrayCallBacksNull@@Base+0x69dc> ; DATA 'MFiServerPlatformLinux'
   44776:	fffd0097          	auipc	ra,0xfffd0
   4477a:	72a080e7          	jalr	1834(ra) # 14ea0 <MLOGD@plt>
   4477e:	541c                	lw	a5,40(s0)
   44780:	d3f1                	beqz	a5,44744 <MFiPlatform_Initialize@@Base+0xe4>
   44782:	4505                	li	a0,1
   44784:	9782                	jalr	a5
   44786:	bf7d                	j	44744 <MFiPlatform_Initialize@@Base+0xe4>
