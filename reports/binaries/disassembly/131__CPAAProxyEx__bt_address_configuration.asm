
firmwares/hw501/131/rootfs/bin/CPAAProxyEx:     file format elf32-littleriscv


Disassembly of section .text:

0003eecc <void std::vector<int, std::allocator<int> >::emplace_back<int>(int&&)@@Base+0x1ffc>:
   3eecc:	000ca517          	auipc	a0,0xca
   3eed0:	28c50513          	addi	a0,a0,652 # 109158 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa3cf8> ; DATA 'PROXY_USE_CHIPID_TO_BTADDRESS'
   3eed4:	fffe1097          	auipc	ra,0xfffe1
   3eed8:	c7c080e7          	jalr	-900(ra) # 1fb50 <getenv@plt>
   3eedc:	c511                	beqz	a0,3eee8 <void std::vector<int, std::allocator<int> >::emplace_back<int>(int&&)@@Base+0x2018>
   3eede:	45b2                	lw	a1,12(sp)
   3eee0:	00500793          	li	a5,5
   3eee4:	10b7ee63          	bltu	a5,a1,3f000 <void std::vector<int, std::allocator<int> >::emplace_back<int>(int&&)@@Base+0x2130>
   3eee8:	01744783          	lbu	a5,23(s0)
   3eeec:	000c9617          	auipc	a2,0xc9
   3eef0:	38060613          	addi	a2,a2,896 # 10826c <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa2e0c>
   3eef4:	00079663          	bnez	a5,3ef00 <void std::vector<int, std::allocator<int> >::emplace_back<int>(int&&)@@Base+0x2030>
   3eef8:	000ca617          	auipc	a2,0xca
   3eefc:	13860613          	addi	a2,a2,312 # 109030 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa3bd0> ; DATA ' > /tmp/logs/bt.log'
   3ef00:	0084                	addi	s1,sp,64
   3ef02:	000ca597          	auipc	a1,0xca
   3ef06:	2c258593          	addi	a1,a1,706 # 1091c4 <BoxActivation::httpResponse(MSNMG::mg_connection*, int, void*, void*)@@Base+0xa3d64> ; DATA 'blueware /etc/bluetooth/blueware.properties %s &'
   3ef0a:	8526                	mv	a0,s1
   3ef0c:	fffe3097          	auipc	ra,0xfffe3
