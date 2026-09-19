
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/lib/libDecEncLib.so:     file format elf32-littleriscv


Disassembly of section .text:

00003878 <bltImgToDisplay@@Base>:
    3878:	7159                	addi	sp,sp,-112
    387a:	d686                	sw	ra,108(sp)
    387c:	d4a2                	sw	s0,104(sp)
    387e:	1880                	addi	s0,sp,112
    3880:	faa42e23          	sw	a0,-68(s0)
    3884:	fab42c23          	sw	a1,-72(s0)
    3888:	fac42a23          	sw	a2,-76(s0)
    388c:	fad42823          	sw	a3,-80(s0)
    3890:	fae42623          	sw	a4,-84(s0)
    3894:	faf42423          	sw	a5,-88(s0)
    3898:	fb042223          	sw	a6,-92(s0)
    389c:	fb142023          	sw	a7,-96(s0)
    38a0:	57fd                	li	a5,-1
    38a2:	fef42623          	sw	a5,-20(s0)
    38a6:	00014517          	auipc	a0,0x14
    38aa:	80652503          	lw	a0,-2042(a0) # 170ac <gDisplayMutex@@Base-0x18> ; DATA ELF relocation: gDisplayMutex
    38ae:	00000097          	auipc	ra,0x0
    38b2:	912080e7          	jalr	-1774(ra) # 31c0 <pthread_mutex_lock@plt>
    38b6:	00013797          	auipc	a5,0x13
    38ba:	7e67a783          	lw	a5,2022(a5) # 1709c <gDisplayImage@@Base-0x20> ; DATA ELF relocation: gDisplayImage
    38be:	439c                	lw	a5,0(a5)
    38c0:	18078863          	beqz	a5,3a50 <bltImgToDisplay@@Base+0x1d8>
    38c4:	fbc42783          	lw	a5,-68(s0)
    38c8:	18078463          	beqz	a5,3a50 <bltImgToDisplay@@Base+0x1d8>
    38cc:	fbc42783          	lw	a5,-68(s0)
    38d0:	4798                	lw	a4,8(a5)
    38d2:	47a9                	li	a5,10
    38d4:	00f70863          	beq	a4,a5,38e4 <bltImgToDisplay@@Base+0x6c>
    38d8:	fbc42783          	lw	a5,-68(s0)
    38dc:	4798                	lw	a4,8(a5)
    38de:	47ad                	li	a5,11
    38e0:	16f71863          	bne	a4,a5,3a50 <bltImgToDisplay@@Base+0x1d8>
    38e4:	00013797          	auipc	a5,0x13
    38e8:	7b87a783          	lw	a5,1976(a5) # 1709c <gDisplayImage@@Base-0x20> ; DATA ELF relocation: gDisplayImage
    38ec:	439c                	lw	a5,0(a5)
    38ee:	4798                	lw	a4,8(a5)
    38f0:	02a00793          	li	a5,42
    38f4:	14f71e63          	bne	a4,a5,3a50 <bltImgToDisplay@@Base+0x1d8>
    38f8:	fb042703          	lw	a4,-80(s0)
    38fc:	fa042783          	lw	a5,-96(s0)
    3900:	00e7d663          	bge	a5,a4,390c <bltImgToDisplay@@Base+0x94>
    3904:	fa042783          	lw	a5,-96(s0)
    3908:	0080006f          	j	3910 <bltImgToDisplay@@Base+0x98>
    390c:	fb042783          	lw	a5,-80(s0)
    3910:	fef42423          	sw	a5,-24(s0)
    3914:	fac42703          	lw	a4,-84(s0)
    3918:	401c                	lw	a5,0(s0)
    391a:	00e7d563          	bge	a5,a4,3924 <bltImgToDisplay@@Base+0xac>
    391e:	401c                	lw	a5,0(s0)
    3920:	0080006f          	j	3928 <bltImgToDisplay@@Base+0xb0>
    3924:	fac42783          	lw	a5,-84(s0)
    3928:	fef42223          	sw	a5,-28(s0)
    392c:	fbc42783          	lw	a5,-68(s0)
    3930:	439c                	lw	a5,0(a5)
    3932:	0786                	slli	a5,a5,0x1
    3934:	07bd                	addi	a5,a5,15
    3936:	9bc1                	andi	a5,a5,-16
    3938:	fef42023          	sw	a5,-32(s0)
    393c:	00013797          	auipc	a5,0x13
    3940:	7607a783          	lw	a5,1888(a5) # 1709c <gDisplayImage@@Base-0x20> ; DATA ELF relocation: gDisplayImage
    3944:	439c                	lw	a5,0(a5)
    3946:	439c                	lw	a5,0(a5)
    3948:	079d                	addi	a5,a5,7
    394a:	9be1                	andi	a5,a5,-8
    394c:	07a2                	slli	a5,a5,0x8
    394e:	87a1                	srai	a5,a5,0x8
    3950:	fcf42e23          	sw	a5,-36(s0)
    3954:	00013797          	auipc	a5,0x13
    3958:	7487a783          	lw	a5,1864(a5) # 1709c <gDisplayImage@@Base-0x20> ; DATA ELF relocation: gDisplayImage
    395c:	439c                	lw	a5,0(a5)
    395e:	439c                	lw	a5,0(a5)
    3960:	079d                	addi	a5,a5,7
    3962:	9be1                	andi	a5,a5,-8
    3964:	079e                	slli	a5,a5,0x7
    3966:	87a1                	srai	a5,a5,0x8
    3968:	fcf42c23          	sw	a5,-40(s0)
    396c:	fbc42783          	lw	a5,-68(s0)
    3970:	47d8                	lw	a4,12(a5)
    3972:	fe042683          	lw	a3,-32(s0)
    3976:	fb442783          	lw	a5,-76(s0)
    397a:	02f687b3          	mul	a5,a3,a5
    397e:	86be                	mv	a3,a5
    3980:	fb842783          	lw	a5,-72(s0)
    3984:	0786                	slli	a5,a5,0x1
    3986:	97b6                	add	a5,a5,a3
    3988:	97ba                	add	a5,a5,a4
    398a:	fcf42a23          	sw	a5,-44(s0)
    398e:	00013797          	auipc	a5,0x13
    3992:	70e7a783          	lw	a5,1806(a5) # 1709c <gDisplayImage@@Base-0x20> ; DATA ELF relocation: gDisplayImage
    3996:	439c                	lw	a5,0(a5)
    3998:	53d8                	lw	a4,36(a5)
    399a:	fdc42683          	lw	a3,-36(s0)
    399e:	fa442783          	lw	a5,-92(s0)
    39a2:	02f687b3          	mul	a5,a3,a5
    39a6:	86be                	mv	a3,a5
    39a8:	fa842783          	lw	a5,-88(s0)
    39ac:	97b6                	add	a5,a5,a3
    39ae:	97ba                	add	a5,a5,a4
    39b0:	fcf42823          	sw	a5,-48(s0)
    39b4:	fa442783          	lw	a5,-92(s0)
    39b8:	4017d713          	srai	a4,a5,0x1
    39bc:	fd842783          	lw	a5,-40(s0)
    39c0:	02f70733          	mul	a4,a4,a5
    39c4:	fa842783          	lw	a5,-88(s0)
    39c8:	8785                	srai	a5,a5,0x1
    39ca:	97ba                	add	a5,a5,a4
    39cc:	fcf42623          	sw	a5,-52(s0)
    39d0:	00013797          	auipc	a5,0x13
    39d4:	6cc7a783          	lw	a5,1740(a5) # 1709c <gDisplayImage@@Base-0x20> ; DATA ELF relocation: gDisplayImage
    39d8:	439c                	lw	a5,0(a5)
    39da:	5798                	lw	a4,40(a5)
    39dc:	fcc42783          	lw	a5,-52(s0)
    39e0:	97ba                	add	a5,a5,a4
    39e2:	fcf42423          	sw	a5,-56(s0)
    39e6:	00013797          	auipc	a5,0x13
    39ea:	6b67a783          	lw	a5,1718(a5) # 1709c <gDisplayImage@@Base-0x20> ; DATA ELF relocation: gDisplayImage
    39ee:	439c                	lw	a5,0(a5)
    39f0:	57d8                	lw	a4,44(a5)
    39f2:	fcc42783          	lw	a5,-52(s0)
    39f6:	97ba                	add	a5,a5,a4
    39f8:	fcf42223          	sw	a5,-60(s0)
    39fc:	fe442783          	lw	a5,-28(s0)
    3a00:	c23e                	sw	a5,4(sp)
    3a02:	fe842783          	lw	a5,-24(s0)
    3a06:	c03e                	sw	a5,0(sp)
    3a08:	fd842883          	lw	a7,-40(s0)
    3a0c:	fc442803          	lw	a6,-60(s0)
    3a10:	fd842783          	lw	a5,-40(s0)
    3a14:	fc842703          	lw	a4,-56(s0)
    3a18:	fdc42683          	lw	a3,-36(s0)
    3a1c:	fd042603          	lw	a2,-48(s0)
    3a20:	fe042583          	lw	a1,-32(s0)
    3a24:	fd442503          	lw	a0,-44(s0)
    3a28:	fffff097          	auipc	ra,0xfffff
    3a2c:	7b8080e7          	jalr	1976(ra) # 31e0 <RGB565ToI420(unsigned char const*, int, unsigned char*, int, unsigned char*, int, unsigned char*, int, int, int)@plt>
    3a30:	00013797          	auipc	a5,0x13
    3a34:	6707a783          	lw	a5,1648(a5) # 170a0 <gDisplaySyncCallBack@@Base-0x20> ; DATA ELF relocation: gDisplaySyncCallBack
    3a38:	4398                	lw	a4,0(a5)
    3a3a:	00013797          	auipc	a5,0x13
    3a3e:	6627a783          	lw	a5,1634(a5) # 1709c <gDisplayImage@@Base-0x20> ; DATA ELF relocation: gDisplayImage
    3a42:	439c                	lw	a5,0(a5)
    3a44:	853e                	mv	a0,a5
    3a46:	9702                	jalr	a4
    3a48:	fe042623          	sw	zero,-20(s0)
    3a4c:	0080006f          	j	3a54 <bltImgToDisplay@@Base+0x1dc>
    3a50:	00000013          	nop
    3a54:	00013517          	auipc	a0,0x13
    3a58:	65852503          	lw	a0,1624(a0) # 170ac <gDisplayMutex@@Base-0x18> ; DATA ELF relocation: gDisplayMutex
    3a5c:	00000097          	auipc	ra,0x0
    3a60:	8f4080e7          	jalr	-1804(ra) # 3350 <pthread_mutex_unlock@plt>
    3a64:	fec42783          	lw	a5,-20(s0)
    3a68:	853e                	mv	a0,a5
    3a6a:	50b6                	lw	ra,108(sp)
    3a6c:	5426                	lw	s0,104(sp)
    3a6e:	6165                	addi	sp,sp,112
    3a70:	00008067          	ret
