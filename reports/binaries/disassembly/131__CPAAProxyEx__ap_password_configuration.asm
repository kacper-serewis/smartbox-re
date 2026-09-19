
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

00049890 <std::vector<MString, std::allocator<MString> >::vector(std::vector<MString, std::allocator<MString> > const&)@@Base+0x2100>:
   49890:	000c0517          	auipc	a0,0xc0
   49894:	58450513          	addi	a0,a0,1412 # 109e14 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa49b4> ; DATA 'PROXY_DEVICE_AP_PSK'
   49898:	fffd6097          	auipc	ra,0xfffd6
   4989c:	2b8080e7          	jalr	696(ra) # 1fb50 <getenv@plt>
   498a0:	842a                	mv	s0,a0
   498a2:	862a                	mv	a2,a0
   498a4:	1a050e63          	beqz	a0,49a60 <std::vector<MString, std::allocator<MString> >::vector(std::vector<MString, std::allocator<MString> > const&)@@Base+0x22d0>
   498a8:	000c0597          	auipc	a1,0xc0
   498ac:	58058593          	addi	a1,a1,1408 # 109e28 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa49c8> ; DATA 'get ap psk:%s\n'
   498b0:	000bf517          	auipc	a0,0xbf
   498b4:	69850513          	addi	a0,a0,1688 # 108f48 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa3ae8> ; DATA 'bt'
   498b8:	fffd8097          	auipc	ra,0xfffd8
   498bc:	448080e7          	jalr	1096(ra) # 21d00 <MLOGD@plt>
   498c0:	c811                	beqz	s0,498d4 <std::vector<MString, std::allocator<MString> >::vector(std::vector<MString, std::allocator<MString> > const&)@@Base+0x2144>
   498c2:	8522                	mv	a0,s0
   498c4:	fffd8097          	auipc	ra,0xfffd8
   498c8:	b4c080e7          	jalr	-1204(ra) # 21410 <strlen@plt>
   498cc:	00700793          	li	a5,7
   498d0:	0ea7e063          	bltu	a5,a0,499b0 <std::vector<MString, std::allocator<MString> >::vector(std::vector<MString, std::allocator<MString> > const&)@@Base+0x2220>
   498d4:	3140d0ef          	jal	56be8 <std::vector<HIDDevPair, std::allocator<HIDDevPair> >::_M_erase(__gnu_cxx::__normal_iterator<HIDDevPair*, std::vector<HIDDevPair, std::allocator<HIDDevPair> > >)@@Base+0x6b4>
   498d8:	1800                	addi	s0,sp,48
   498da:	0944aa03          	lw	s4,148(s1)
   498de:	d422                	sw	s0,40(sp)
