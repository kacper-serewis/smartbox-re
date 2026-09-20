; ARM ELF virtual addresses; mode=ARM; static analysis only
00040cd0: f04f2de9   push     {r4, r5, r6, r7, r8, sb, sl, fp, lr}
00040cd4: 008051e2   subs     r8, r1, #0
00040cd8: 4cd04de2   sub      sp, sp, #0x4c
00040cdc: 0040a0e1   mov      r4, r0
00040ce0: 0890a001   moveq    sb, r8
00040ce4: 0200000a   beq      #0x40cf4
00040ce8: 0800a0e1   mov      r0, r8
00040cec: ad6100eb   bl       #0x593a8
00040cf0: 0090a0e1   mov      sb, r0
00040cf4: 4c069fe5   ldr      r0, [pc, #0x64c] ; [0x41348]=0x2a2538
00040cf8: 003090e5   ldr      r3, [r0]
00040cfc: 320053e3   cmp      r3, #0x32
00040d00: 050000ca   bgt      #0x40d1c
00040d04: 010073e3   cmn      r3, #1
00040d08: 5c01001a   bne      #0x41280
00040d0c: 3210a0e3   mov      r1, #0x32
00040d10: 54f800eb   bl       #0x7ee68
00040d14: 000050e3   cmp      r0, #0
00040d18: 5801001a   bne      #0x41280
00040d1c: 0050a0e3   mov      r5, #0
00040d20: 090055e1   cmp      r5, sb
00040d24: 870000aa   bge      #0x40f48
00040d28: 0510a0e1   mov      r1, r5
00040d2c: 0800a0e1   mov      r0, r8
00040d30: aa6100eb   bl       #0x593e0
00040d34: 0020a0e3   mov      r2, #0
00040d38: 0c169fe5   ldr      r1, [pc, #0x60c] ; [0x4134c]=0x22ae80
00040d3c: 1c008de5   str      r0, [sp, #0x1c]
00040d40: 189a00eb   bl       #0x675a8
00040d44: 0020a0e3   mov      r2, #0
00040d48: 0060a0e1   mov      r6, r0
00040d4c: 0170a0e1   mov      r7, r1
00040d50: 1c009de5   ldr      r0, [sp, #0x1c]
00040d54: f4159fe5   ldr      r1, [pc, #0x5f4] ; [0x41350]=0x22afe0
00040d58: 129a00eb   bl       #0x675a8
00040d5c: 0020a0e3   mov      r2, #0
00040d60: f001cde1   strd     r0, r1, [sp, #0x10]
00040d64: 1c009de5   ldr      r0, [sp, #0x1c]
00040d68: e4159fe5   ldr      r1, [pc, #0x5e4] ; [0x41354]=0x22affa
00040d6c: 0d9a00eb   bl       #0x675a8
00040d70: 020059e3   cmp      sb, #2
00040d74: 00a0a0e1   mov      sl, r0
00040d78: 01b0a0e1   mov      fp, r1
00040d7c: 400000da   ble      #0x40e84
00040d80: 0010a0e3   mov      r1, #0
00040d84: 2020a0e3   mov      r2, #0x20
00040d88: 28008de2   add      r0, sp, #0x28
00040d8c: 6b63ffeb   bl       #0x19b40
00040d90: 0030a0e3   mov      r3, #0
00040d94: 1c009de5   ldr      r0, [sp, #0x1c]
00040d98: 28208de2   add      r2, sp, #0x28
00040d9c: 00308de5   str      r3, [sp]
00040da0: 1f30a0e3   mov      r3, #0x1f
00040da4: ac159fe5   ldr      r1, [pc, #0x5ac] ; [0x41358]=0x22af4e
00040da8: 7e9800eb   bl       #0x66fa8
00040dac: 000057e3   cmp      r7, #0
00040db0: 64005603   cmpeq    r6, #0x64
00040db4: 1d00001a   bne      #0x40e30
00040db8: 28008de2   add      r0, sp, #0x28
00040dbc: 98159fe5   ldr      r1, [pc, #0x598] ; [0x4135c]=0x22b357 'speechRecognition'
00040dc0: b465ffeb   bl       #0x1a498 ; strcmp
00040dc4: 000050e3   cmp      r0, #0
00040dc8: d001cd01   ldrdeq   r0, r1, [sp, #0x10]
00040dcc: 973e8402   addeq    r3, r4, #0x970
00040dd0: f8004301   strdeq   r0, r1, [r3, #-8]
00040dd4: 3300000a   beq      #0x40ea8
00040dd8: 28008de2   add      r0, sp, #0x28
00040ddc: 7c159fe5   ldr      r1, [pc, #0x57c] ; [0x41360]=0x22b34d 'telephony'
00040de0: ac65ffeb   bl       #0x1a498 ; strcmp
00040de4: 000050e3   cmp      r0, #0
00040de8: d001cd01   ldrdeq   r0, r1, [sp, #0x10]
00040dec: 963e8402   addeq    r3, r4, #0x960
00040df0: f000c301   strdeq   r0, r1, [r3]
00040df4: 2b00000a   beq      #0x40ea8
00040df8: 28008de2   add      r0, sp, #0x28
00040dfc: 60159fe5   ldr      r1, [pc, #0x560] ; [0x41364]=0x22b369 'alert'
00040e00: a465ffeb   bl       #0x1a498 ; strcmp
00040e04: 000050e3   cmp      r0, #0
00040e08: 953e8402   addeq    r3, r4, #0x950
00040e0c: f0a0c301   strdeq   sl, fp, [r3]
00040e10: 2400000a   beq      #0x40ea8
00040e14: 28008de2   add      r0, sp, #0x28
00040e18: 48159fe5   ldr      r1, [pc, #0x548] ; [0x41368]=0x22b36f 'media'
00040e1c: 9d65ffeb   bl       #0x1a498 ; strcmp
00040e20: 000050e3   cmp      r0, #0
00040e24: 963e8402   addeq    r3, r4, #0x960
00040e28: f8a04301   strdeq   sl, fp, [r3, #-8]
00040e2c: 1d0000ea   b        #0x40ea8
00040e30: 000057e3   cmp      r7, #0
00040e34: 65005603   cmpeq    r6, #0x65
00040e38: 1400001a   bne      #0x40e90
00040e3c: 28008de2   add      r0, sp, #0x28
00040e40: 24159fe5   ldr      r1, [pc, #0x524] ; [0x4136c]=0x22b383 'default'
00040e44: 9365ffeb   bl       #0x1a498 ; strcmp
00040e48: 000050e3   cmp      r0, #0
00040e4c: 2300001a   bne      #0x40ee0
00040e50: f0049fe5   ldr      r0, [pc, #0x4f0] ; [0x41348]=0x2a2538
00040e54: 003090e5   ldr      r3, [r0]
00040e58: 0a0053e3   cmp      r3, #0xa
00040e5c: 050000ca   bgt      #0x40e78
00040e60: 010073e3   cmn      r3, #1
00040e64: 0c01001a   bne      #0x4129c
00040e68: 0a10a0e3   mov      r1, #0xa
00040e6c: fdf700eb   bl       #0x7ee68
00040e70: 000050e3   cmp      r0, #0
00040e74: 0801001a   bne      #0x4129c
00040e78: 493d84e2   add      r3, r4, #0x1240
00040e7c: f0a3c3e1   strd     sl, fp, [r3, #0x30]
00040e80: 2e0000ea   b        #0x40f40
00040e84: 000057e3   cmp      r7, #0
00040e88: 65005603   cmpeq    r6, #0x65
00040e8c: 1300000a   beq      #0x40ee0
00040e90: 000057e3   cmp      r7, #0
00040e94: 66005603   cmpeq    r6, #0x66
00040e98: 1d00000a   beq      #0x40f14
00040e9c: 000057e3   cmp      r7, #0
00040ea0: 64005603   cmpeq    r6, #0x64
00040ea4: 2500001a   bne      #0x40f40
00040ea8: 251d84e2   add      r1, r4, #0x940
00040eac: d061cde1   ldrd     r6, r7, [sp, #0x10]
00040eb0: d020c1e1   ldrd     r2, r3, [r1]
00040eb4: 026086e1   orr      r6, r6, r2
00040eb8: 037087e1   orr      r7, r7, r3
00040ebc: 0620a0e1   mov      r2, r6
00040ec0: 0730a0e1   mov      r3, r7
00040ec4: f020c1e1   strd     r2, r3, [r1]
00040ec8: 951e84e2   add      r1, r4, #0x950
00040ecc: d82041e1   ldrd     r2, r3, [r1, #-8]
00040ed0: 0a2082e1   orr      r2, r2, sl
00040ed4: 0b3083e1   orr      r3, r3, fp
00040ed8: f82041e1   strd     r2, r3, [r1, #-8]
00040edc: 170000ea   b        #0x40f40
00040ee0: 491d84e2   add      r1, r4, #0x1240
00040ee4: d061cde1   ldrd     r6, r7, [sp, #0x10]
00040ee8: d822c1e1   ldrd     r2, r3, [r1, #0x28]
00040eec: 026086e1   orr      r6, r6, r2
00040ef0: 037087e1   orr      r7, r7, r3
00040ef4: 0620a0e1   mov      r2, r6
00040ef8: 0730a0e1   mov      r3, r7
00040efc: f822c1e1   strd     r2, r3, [r1, #0x28]
00040f00: d023c1e1   ldrd     r2, r3, [r1, #0x30]
00040f04: 0a2082e1   orr      r2, r2, sl
00040f08: 0b3083e1   orr      r3, r3, fp
00040f0c: f023c1e1   strd     r2, r3, [r1, #0x30]
00040f10: 0a0000ea   b        #0x40f40
00040f14: d821c4e1   ldrd     r2, r3, [r4, #0x18]
00040f18: d001cde1   ldrd     r0, r1, [sp, #0x10]
00040f1c: 020080e1   orr      r0, r0, r2
00040f20: 031081e1   orr      r1, r1, r3
00040f24: 0020a0e1   mov      r2, r0
00040f28: 0130a0e1   mov      r3, r1
00040f2c: f821c4e1   strd     r2, r3, [r4, #0x18]
00040f30: d022c4e1   ldrd     r2, r3, [r4, #0x20]
00040f34: 0a2082e1   orr      r2, r2, sl
00040f38: 0b3083e1   orr      r3, r3, fp
00040f3c: f022c4e1   strd     r2, r3, [r4, #0x20]
00040f40: 015085e2   add      r5, r5, #1
00040f44: 75ffffea   b        #0x40d20
00040f48: 978e84e2   add      r8, r4, #0x970
00040f4c: 966e84e2   add      r6, r4, #0x960
00040f50: 955e84e2   add      r5, r4, #0x950
00040f54: ec739fe5   ldr      r7, [pc, #0x3ec] ; [0x41348]=0x2a2538
00040f58: d82048e1   ldrd     r2, r3, [r8, #-8]
00040f5c: 033092e1   orrs     r3, r2, r3
00040f60: 253d8402   addeq    r3, r4, #0x940
00040f64: d020c301   ldrdeq   r2, r3, [r3]
00040f68: f8204801   strdeq   r2, r3, [r8, #-8]
00040f6c: d020c6e1   ldrd     r2, r3, [r6]
00040f70: 033092e1   orrs     r3, r2, r3
00040f74: 253d8402   addeq    r3, r4, #0x940
00040f78: d020c301   ldrdeq   r2, r3, [r3]
00040f7c: f020c601   strdeq   r2, r3, [r6]
00040f80: d82046e1   ldrd     r2, r3, [r6, #-8]
00040f84: 033092e1   orrs     r3, r2, r3
00040f88: d8204501   ldrdeq   r2, r3, [r5, #-8]
00040f8c: f8204601   strdeq   r2, r3, [r6, #-8]
00040f90: d020c5e1   ldrd     r2, r3, [r5]
00040f94: 033092e1   orrs     r3, r2, r3
00040f98: d8204501   ldrdeq   r2, r3, [r5, #-8]
00040f9c: f020c501   strdeq   r2, r3, [r5]
00040fa0: d82046e1   ldrd     r2, r3, [r6, #-8]
00040fa4: 0030a0e3   mov      r3, #0
00040fa8: 222b02e2   and      r2, r2, #0x8800
00040fac: f82046e1   strd     r2, r3, [r6, #-8]
00040fb0: d020c5e1   ldrd     r2, r3, [r5]
00040fb4: 0030a0e3   mov      r3, #0
00040fb8: 222b02e2   and      r2, r2, #0x8800
00040fbc: 031092e1   orrs     r1, r2, r3
00040fc0: f020c511   strdne   r2, r3, [r5]
00040fc4: d82048e1   ldrd     r2, r3, [r8, #-8]
00040fc8: 0030a0e3   mov      r3, #0
00040fcc: 402002e2   and      r2, r2, #0x40
00040fd0: 033092e1   orrs     r3, r2, r3
00040fd4: 0e00000a   beq      #0x41014
00040fd8: 003097e5   ldr      r3, [r7]
00040fdc: 0a0053e3   cmp      r3, #0xa
00040fe0: 060000ca   bgt      #0x41000
00040fe4: 010073e3   cmn      r3, #1
00040fe8: b200001a   bne      #0x412b8
00040fec: 0700a0e1   mov      r0, r7
00040ff0: 0a10a0e3   mov      r1, #0xa
00040ff4: 9bf700eb   bl       #0x7ee68
00040ff8: 000050e3   cmp      r0, #0
00040ffc: ad00001a   bne      #0x412b8
00041000: 68039fe5   ldr      r0, [pc, #0x368] ; [0x41370]=0x22b523 'touch /tmp/siri_use_24K_audio'
00041004: 5763ffeb   bl       #0x19d68 ; system
00041008: 4020a0e3   mov      r2, #0x40
0004100c: 0030a0e3   mov      r3, #0
00041010: f82048e1   strd     r2, r3, [r8, #-8]
00041014: d020c6e1   ldrd     r2, r3, [r6]
00041018: 0010a0e3   mov      r1, #0
0004101c: 0030a0e3   mov      r3, #0
00041020: 400002e2   and      r0, r2, #0x40
00041024: 102002e2   and      r2, r2, #0x10
00041028: 011090e1   orrs     r1, r0, r1
0004102c: 0600000a   beq      #0x4104c
00041030: 031092e1   orrs     r1, r2, r3
00041034: 0400001a   bne      #0x4104c
00041038: d8f2ffeb   bl       #0x3dba0
0004103c: 4020a0e3   mov      r2, #0x40
00041040: 0030a0e3   mov      r3, #0
00041044: f020c6e1   strd     r2, r3, [r6]
00041048: 100000ea   b        #0x41090
0004104c: 033092e1   orrs     r3, r2, r3
00041050: 0e00000a   beq      #0x41090
00041054: f74300eb   bl       #0x52038
00041058: 14139fe5   ldr      r1, [pc, #0x314] ; [0x41374]=0x22b541 'DIPO'
0004105c: 0d65ffeb   bl       #0x1a498 ; strcmp
00041060: 000050e3   cmp      r0, #0
00041064: f3ffff0a   beq      #0x41038
00041068: 124300eb   bl       #0x51cb8
0004106c: 04139fe5   ldr      r1, [pc, #0x304] ; [0x41378]=0x22b546 'MYOPEL'
00041070: 0865ffeb   bl       #0x1a498 ; strcmp
00041074: 000050e3   cmp      r0, #0
00041078: eeffff0a   beq      #0x41038
0004107c: 0d4300eb   bl       #0x51cb8
00041080: f4129fe5   ldr      r1, [pc, #0x2f4] ; [0x4137c]=0x22b54d '1726111252'
00041084: 0365ffeb   bl       #0x1a498 ; strcmp
00041088: 000050e3   cmp      r0, #0
0004108c: e9ffff0a   beq      #0x41038
