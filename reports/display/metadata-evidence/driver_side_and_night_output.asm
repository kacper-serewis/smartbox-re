
/Users/kacperserewis/Documents/dev/smartbox-re/firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0004d870 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x2224>:
   4d870:	000bd597          	auipc	a1,0xbd
   4d874:	6bc58593          	addi	a1,a1,1724 # 10af2c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5acc> ; CFSTRING 'rightHandDrive'
   4d878:	00040513          	mv	a0,s0
   4d87c:	fffd3097          	auipc	ra,0xfffd3
   4d880:	934080e7          	jalr	-1740(ra) # 201b0 <CFEqual@plt>
   4d884:	c505                	beqz	a0,4d8ac <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x2260>
   4d886:	0e44a403          	lw	s0,228(s1)
   4d88a:	f84d                	bnez	s0,4d83c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x21f0>
   4d88c:	74f9                	lui	s1,0xffffe
   4d88e:	5c648493          	addi	s1,s1,1478 # ffffe5c6 <AOAProxy::sReaderBuffer@@Base+0xffecdcd2>
   4d892:	b509                	j	4d694 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x2048>
   4d894:	00400737          	lui	a4,0x400
   4d898:	4781                	li	a5,0
   4d89a:	00400837          	lui	a6,0x400
   4d89e:	4881                	li	a7,0
   4d8a0:	d43a                	sw	a4,40(sp)
   4d8a2:	d63e                	sw	a5,44(sp)
   4d8a4:	d95ff06f          	j	4d638 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x1fec>
   4d8a8:	4472                	lw	s0,28(sp)
   4d8aa:	b3ed                	j	4d694 <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x2048>
   4d8ac:	000bd597          	auipc	a1,0xbd
   4d8b0:	69858593          	addi	a1,a1,1688 # 10af44 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa5ae4> ; CFSTRING 'nightMode'
   4d8b4:	00040513          	mv	a0,s0
   4d8b8:	fffd3097          	auipc	ra,0xfffd3
   4d8bc:	8f8080e7          	jalr	-1800(ra) # 201b0 <CFEqual@plt>
   4d8c0:	c511                	beqz	a0,4d8cc <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x2280>
   4d8c2:	0e84a403          	lw	s0,232(s1)
   4d8c6:	f83d                	bnez	s0,4d83c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x21f0>
   4d8c8:	fc5ff06f          	j	4d88c <CarPlayControlClientEventCallback(CarPlayControlClient const*, unsigned int, void*, void*)@@Base+0x2240>
