
firmwares/hw501/131/rootfs/lib/libCoreUtils.so:     file format elf32-littleriscv


Disassembly of section .text:

00044660 <MFiPlatform_Initialize@@Base>:
   44660:	0005a797          	auipc	a5,0x5a
   44664:	f507a783          	lw	a5,-176(a5) # 9e5b0 <gRemoteCopyCertificate@@Base-0x738> ; DATA ELF relocation: gRemoteCopyCertificate
   44668:	439c                	lw	a5,0(a5)
   4466a:	12079663          	bnez	a5,44796 <MFiPlatform_Initialize@@Base+0x136>
   4466e:	751352ef          	jal	t0,7a5be <s_mp_sub@@Base+0x11b6>
   44672:	0005a417          	auipc	s0,0x5a
   44676:	53a40413          	addi	s0,s0,1338 # 9ebac <gLogUtilsInitializing@@Base+0x13>
   4467a:	501c                	lw	a5,32(s0)
   4467c:	1141                	addi	sp,sp,-16
   4467e:	e3a9                	bnez	a5,446c0 <MFiPlatform_Initialize@@Base+0x60>
   44680:	0003f517          	auipc	a0,0x3f
   44684:	96850513          	addi	a0,a0,-1688 # 82fe8 <kCFLArrayCallBacksNull@@Base+0x6dc8> ; DATA 'mfi_dev_path'
   44688:	fffd3097          	auipc	ra,0xfffd3
   4468c:	c98080e7          	jalr	-872(ra) # 17320 <getenv@plt>
   44690:	85aa                	mv	a1,a0
   44692:	e509                	bnez	a0,4469c <MFiPlatform_Initialize@@Base+0x3c>
   44694:	0003f597          	auipc	a1,0x3f
   44698:	94858593          	addi	a1,a1,-1720 # 82fdc <kCFLArrayCallBacksNull@@Base+0x6dbc> ; DATA '/dev/i2c-0'
   4469c:	0005a517          	auipc	a0,0x5a
   446a0:	54450513          	addi	a0,a0,1348 # 9ebe0 <gLogUtilsInitializing@@Base+0x47>
   446a4:	fffd4097          	auipc	ra,0xfffd4
   446a8:	08c080e7          	jalr	140(ra) # 18730 <strcpy@plt>
   446ac:	fffff797          	auipc	a5,0xfffff
   446b0:	65e78793          	addi	a5,a5,1630 # 43d0a <MFiSAP_Decrypt@@Base+0x23c>
   446b4:	d01c                	sw	a5,32(s0)
   446b6:	fffff797          	auipc	a5,0xfffff
   446ba:	41a78793          	addi	a5,a5,1050 # 43ad0 <MFiSAP_Decrypt@@Base+0x2>
   446be:	d05c                	sw	a5,36(s0)
   446c0:	13442783          	lw	a5,308(s0)
   446c4:	e7a1                	bnez	a5,4470c <MFiPlatform_Initialize@@Base+0xac>
   446c6:	47c1                	li	a5,16
   446c8:	6909                	lui	s2,0x2
   446ca:	c43e                	sw	a5,8(sp)
   446cc:	4481                	li	s1,0
   446ce:	47c5                	li	a5,17
   446d0:	00059a17          	auipc	s4,0x59
   446d4:	d18a0a13          	addi	s4,s4,-744 # 9d3e8 <gLogCategory_LogUtils@@Base+0x40>
   446d8:	0005aa97          	auipc	s5,0x5a
   446dc:	508a8a93          	addi	s5,s5,1288 # 9ebe0 <gLogUtilsInitializing@@Base+0x47>
   446e0:	71090913          	addi	s2,s2,1808 # 2710 <mp_invmod_slow@plt-0x122b0>
   446e4:	c63e                	sw	a5,12(sp)
   446e6:	0024a7db          	.insn	4, 0x0024a7db
   446ea:	01078713          	addi	a4,a5,16
   446ee:	002707b3          	add	a5,a4,sp
   446f2:	ff87a983          	lw	s3,-8(a5)
   446f6:	8556                	mv	a0,s5
   446f8:	85ce                	mv	a1,s3
   446fa:	013a2223          	sw	s3,4(s4)
   446fe:	fffd3097          	auipc	ra,0xfffd3
   44702:	482080e7          	jalr	1154(ra) # 17b80 <MFiPlatform_AutoDetect@plt>
   44706:	e931                	bnez	a0,4475a <MFiPlatform_Initialize@@Base+0xfa>
   44708:	13342a23          	sw	s3,308(s0)
   4470c:	13442603          	lw	a2,308(s0)
   44710:	ce31                	beqz	a2,4476c <MFiPlatform_Initialize@@Base+0x10c>
   44712:	00059697          	auipc	a3,0x59
   44716:	ccc6ad23          	sw	a2,-806(a3) # 9d3ec <gLogCategory_LogUtils@@Base+0x44>
   4471a:	0003f597          	auipc	a1,0x3f
   4471e:	8de58593          	addi	a1,a1,-1826 # 82ff8 <kCFLArrayCallBacksNull@@Base+0x6dd8> ; DATA 'MFiPlatform auto detect mfi address:0x%x dev:%s\n'
   44722:	0005a697          	auipc	a3,0x5a
   44726:	4be68693          	addi	a3,a3,1214 # 9ebe0 <gLogUtilsInitializing@@Base+0x47>
   4472a:	0003e517          	auipc	a0,0x3e
   4472e:	4d250513          	addi	a0,a0,1234 # 82bfc <kCFLArrayCallBacksNull@@Base+0x69dc> ; DATA 'MFiServerPlatformLinux'
   44732:	fffd0097          	auipc	ra,0xfffd0
   44736:	76e080e7          	jalr	1902(ra) # 14ea0 <MLOGD@plt>
   4473a:	0005a597          	auipc	a1,0x5a
   4473e:	4a258593          	addi	a1,a1,1186 # 9ebdc <gLogUtilsInitializing@@Base+0x43>
   44742:	0005a517          	auipc	a0,0x5a
   44746:	49650513          	addi	a0,a0,1174 # 9ebd8 <gLogUtilsInitializing@@Base+0x3f>
   4474a:	fffd2097          	auipc	ra,0xfffd2
   4474e:	df6080e7          	jalr	-522(ra) # 16540 <MFiPlatform_CopyCertificate@plt>
   44752:	4501                	li	a0,0
   44754:	0141                	addi	sp,sp,16
   44756:	69d3506f          	j	7a5f2 <s_mp_sub@@Base+0x11ea>
   4475a:	854a                	mv	a0,s2
   4475c:	0485                	addi	s1,s1,1
   4475e:	fffd2097          	auipc	ra,0xfffd2
   44762:	5d2080e7          	jalr	1490(ra) # 16d30 <usleep@plt>
   44766:	b8a4e05b          	.insn	4, 0xb8a4e05b
   4476a:	b74d                	j	4470c <MFiPlatform_Initialize@@Base+0xac>
   4476c:	0005a617          	auipc	a2,0x5a
   44770:	47460613          	addi	a2,a2,1140 # 9ebe0 <gLogUtilsInitializing@@Base+0x47>
   44774:	0003f597          	auipc	a1,0x3f
   44778:	8b858593          	addi	a1,a1,-1864 # 8302c <kCFLArrayCallBacksNull@@Base+0x6e0c> ; DATA 'MFiPlatform auto detect address on %s failed\n'
   4477c:	0003e517          	auipc	a0,0x3e
   44780:	48050513          	addi	a0,a0,1152 # 82bfc <kCFLArrayCallBacksNull@@Base+0x69dc> ; DATA 'MFiServerPlatformLinux'
   44784:	fffd0097          	auipc	ra,0xfffd0
   44788:	71c080e7          	jalr	1820(ra) # 14ea0 <MLOGD@plt>
   4478c:	541c                	lw	a5,40(s0)
   4478e:	d3f1                	beqz	a5,44752 <MFiPlatform_Initialize@@Base+0xf2>
   44790:	4505                	li	a0,1
   44792:	9782                	jalr	a5
   44794:	bf7d                	j	44752 <MFiPlatform_Initialize@@Base+0xf2>
   44796:	4501                	li	a0,0
   44798:	8082                	ret
