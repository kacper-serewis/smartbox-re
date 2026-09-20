
/var/folders/wb/38qjft055l18_4qj_94p15cc0000gn/T/smartbox-sony-eft9p193/baseline/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0004d41a <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x1dce>:
   4d41a:	6325                	lui	t1,0x9
   4d41c:	80030313          	addi	t1,t1,-2048 # 8800 <CFArrayCreateCopy@plt-0x16fd0>
   4d420:	4381                	li	t2,0
   4d422:	881a                	mv	a6,t1
   4d424:	4e01                	li	t3,0
   4d426:	4e81                	li	t4,0
   4d428:	889e                	mv	a7,t2
   4d42a:	4701                	li	a4,0
   4d42c:	4781                	li	a5,0
   4d42e:	000bd697          	auipc	a3,0xbd
   4d432:	6f268693          	addi	a3,a3,1778 # 10ab20 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa56c0> ; DATA 'Media'
   4d436:	06400613          	li	a2,100
   4d43a:	000bd597          	auipc	a1,0xbd
   4d43e:	67258593          	addi	a1,a1,1650 # 10aaac <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa564c> ; DATA 'SetAudioFormats streamType:%u audioType:%s  inputFormats:0x%llx outputFormats:0x%llx\n'
   4d442:	000bd517          	auipc	a0,0xbd
   4d446:	6c250513          	addi	a0,a0,1730 # 10ab04 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa56a4> ; DATA 'CarPlayApp'
   4d44a:	d072                	sw	t3,32(sp)
   4d44c:	d276                	sw	t4,36(sp)
   4d44e:	d41a                	sw	t1,40(sp)
   4d450:	02712623          	sw	t2,44(sp)
   4d454:	fffd5097          	auipc	ra,0xfffd5
   4d458:	8ac080e7          	jalr	-1876(ra) # 21d00 <MLOGD@plt>
   4d45c:	57a2                	lw	a5,40(sp)
   4d45e:	5832                	lw	a6,44(sp)
   4d460:	5682                	lw	a3,32(sp)
   4d462:	5712                	lw	a4,36(sp)
   4d464:	000be617          	auipc	a2,0xbe
   4d468:	a5860613          	addi	a2,a2,-1448 # 10aebc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5a5c>
   4d46c:	06400593          	li	a1,100
   4d470:	000a0513          	mv	a0,s4
   4d474:	fffd3097          	auipc	ra,0xfffd3
   4d478:	37c080e7          	jalr	892(ra) # 207f0 <AirPlayInfoArrayAddAudioFormat@plt>
