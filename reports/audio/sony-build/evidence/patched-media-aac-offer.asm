
/var/folders/wb/38qjft055l18_4qj_94p15cc0000gn/T/smartbox-sony-eft9p193/tree/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0004d5f6 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x1faa>:
   4d5f6:	4781                	li	a5,0
   4d5f8:	4701                	li	a4,0
   4d5fa:	d23e                	sw	a5,36(sp)
   4d5fc:	02e12023          	sw	a4,32(sp)
   4d600:	8b9e50ef          	jal	32eb8 <lv_event_switchto_apmode(_lv_event_t*)@@Base+0xdf8>
   4d604:	00400537          	lui	a0,0x400
   4d608:	41f55893          	srai	a7,a0,0x1f
   4d60c:	011567b3          	or	a5,a0,a7
   4d610:	d42a                	sw	a0,40(sp)
   4d612:	d646                	sw	a7,44(sp)
   4d614:	882a                	mv	a6,a0
   4d616:	e38d                	bnez	a5,4d638 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x1fec>
   4d618:	5818                	lw	a4,48(s0)
   4d61a:	585c                	lw	a5,52(s0)
   4d61c:	8fd9                	or	a5,a5,a4
   4d61e:	e399                	bnez	a5,4d624 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x1fd8>
   4d620:	01042703          	lw	a4,16(s0)
   4d624:	26f7785b          	.insn	4, 0x26f7785b
   4d628:	00800737          	lui	a4,0x800
   4d62c:	4781                	li	a5,0
   4d62e:	00800837          	lui	a6,0x800
   4d632:	4881                	li	a7,0
   4d634:	d43a                	sw	a4,40(sp)
   4d636:	d63e                	sw	a5,44(sp)
   4d638:	5702                	lw	a4,32(sp)
   4d63a:	5792                	lw	a5,36(sp)
   4d63c:	000bd697          	auipc	a3,0xbd
   4d640:	4e468693          	addi	a3,a3,1252 # 10ab20 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa56c0> ; DATA 'Media'
   4d644:	06600613          	li	a2,102
   4d648:	000bd597          	auipc	a1,0xbd
   4d64c:	46458593          	addi	a1,a1,1124 # 10aaac <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa564c> ; DATA 'SetAudioFormats streamType:%u audioType:%s  inputFormats:0x%llx outputFormats:0x%llx\n'
   4d650:	000bd517          	auipc	a0,0xbd
   4d654:	4b450513          	addi	a0,a0,1204 # 10ab04 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa56a4> ; DATA 'CarPlayApp'
   4d658:	fffd4097          	auipc	ra,0xfffd4
   4d65c:	6a8080e7          	jalr	1704(ra) # 21d00 <MLOGD@plt>
   4d660:	57a2                	lw	a5,40(sp)
   4d662:	5832                	lw	a6,44(sp)
   4d664:	5682                	lw	a3,32(sp)
   4d666:	5712                	lw	a4,36(sp)
   4d668:	000be617          	auipc	a2,0xbe
   4d66c:	85460613          	addi	a2,a2,-1964 # 10aebc <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5a5c>
   4d670:	06600593          	li	a1,102
   4d674:	000a0513          	mv	a0,s4
   4d678:	fffd3097          	auipc	ra,0xfffd3
   4d67c:	178080e7          	jalr	376(ra) # 207f0 <AirPlayInfoArrayAddAudioFormat@plt>
