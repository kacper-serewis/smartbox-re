
/var/folders/wb/38qjft055l18_4qj_94p15cc0000gn/T/smartbox-sony-eft9p193/hook.bin:     file format binary


Disassembly of section .data:

0012b860 <.data>:
  12b860:	fc010113          	addi	sp,sp,-64
  12b864:	00112023          	sw	ra,0(sp)
  12b868:	00512223          	sw	t0,4(sp)
  12b86c:	00612423          	sw	t1,8(sp)
  12b870:	00712623          	sw	t2,12(sp)
  12b874:	00a12823          	sw	a0,16(sp)
  12b878:	00b12a23          	sw	a1,20(sp)
  12b87c:	00c12c23          	sw	a2,24(sp)
  12b880:	00d12e23          	sw	a3,28(sp)
  12b884:	02e12023          	sw	a4,32(sp)
  12b888:	02f12223          	sw	a5,36(sp)
  12b88c:	03012423          	sw	a6,40(sp)
  12b890:	03112623          	sw	a7,44(sp)
  12b894:	03c12823          	sw	t3,48(sp)
  12b898:	03d12a23          	sw	t4,52(sp)
  12b89c:	03e12c23          	sw	t5,56(sp)
  12b8a0:	03f12e23          	sw	t6,60(sp)
  12b8a4:	ffff82b7          	lui	t0,0xffff8
  12b8a8:	fff28293          	addi	t0,t0,-1 # 0xffff7fff
  12b8ac:	00001537          	lui	a0,0x1
  12b8b0:	80050513          	addi	a0,a0,-2048 # 0x800
  12b8b4:	0104a583          	lw	a1,16(s1)
  12b8b8:	0055f5b3          	and	a1,a1,t0
  12b8bc:	00a5e5b3          	or	a1,a1,a0
  12b8c0:	00b4a823          	sw	a1,16(s1)
  12b8c4:	0304a583          	lw	a1,48(s1)
  12b8c8:	0055f5b3          	and	a1,a1,t0
  12b8cc:	00a5e5b3          	or	a1,a1,a0
  12b8d0:	02b4a823          	sw	a1,48(s1)
  12b8d4:	0012c537          	lui	a0,0x12c
  12b8d8:	94850513          	addi	a0,a0,-1720 # 0x12b948
  12b8dc:	0012c5b7          	lui	a1,0x12c
  12b8e0:	95258593          	addi	a1,a1,-1710 # 0x12b952
  12b8e4:	0104a603          	lw	a2,16(s1)
  12b8e8:	0304a683          	lw	a3,48(s1)
  12b8ec:	000222b7          	lui	t0,0x22
  12b8f0:	d0028293          	addi	t0,t0,-768 # 0x21d00
  12b8f4:	000280e7          	jalr	t0
  12b8f8:	00012083          	lw	ra,0(sp)
  12b8fc:	00412283          	lw	t0,4(sp)
  12b900:	00812303          	lw	t1,8(sp)
  12b904:	00c12383          	lw	t2,12(sp)
  12b908:	01012503          	lw	a0,16(sp)
  12b90c:	01412583          	lw	a1,20(sp)
  12b910:	01812603          	lw	a2,24(sp)
  12b914:	01c12683          	lw	a3,28(sp)
  12b918:	02012703          	lw	a4,32(sp)
  12b91c:	02412783          	lw	a5,36(sp)
  12b920:	02812803          	lw	a6,40(sp)
  12b924:	02c12883          	lw	a7,44(sp)
  12b928:	03012e03          	lw	t3,48(sp)
  12b92c:	03412e83          	lw	t4,52(sp)
  12b930:	03812f03          	lw	t5,56(sp)
  12b934:	03c12f83          	lw	t6,60(sp)
  12b938:	04010113          	addi	sp,sp,64
  12b93c:	0001f2b7          	lui	t0,0x1f
  12b940:	7d028293          	addi	t0,t0,2000 # 0x1f7d0
  12b944:	00028067          	jr	t0
