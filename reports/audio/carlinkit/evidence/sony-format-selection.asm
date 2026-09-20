; ARM ELF virtual addresses; mode=ARM; static analysis only
00041090: 084300eb   bl       #0x51cb8
00041094: e4129fe5   ldr      r1, [pc, #0x2e4] ; [0x41380]=0x22b558 'MISTRA'
00041098: e463ffeb   bl       #0x1a030 ; strstr
0004109c: 008050e2   subs     r8, r0, #0
000410a0: dc029f15   ldrne    r0, [pc, #0x2dc] ; [0x41384]=0x22b55f 'MediaQuality'
000410a4: 0010a013   movne    r1, #0
000410a8: 0c00001a   bne      #0x410e0
000410ac: e14300eb   bl       #0x52038
000410b0: d0129fe5   ldr      r1, [pc, #0x2d0] ; [0x41388]=0x22a3cd 'SONY CAR AUDIO'
000410b4: dd63ffeb   bl       #0x1a030 ; strstr
000410b8: 000050e3   cmp      r0, #0
000410bc: 0800000a   beq      #0x410e4
000410c0: d82045e1   ldrd     r2, r3, [r5, #-8]
000410c4: 0810a0e1   mov      r1, r8
000410c8: b4029fe5   ldr      r0, [pc, #0x2b4] ; [0x41384]=0x22b55f 'MediaQuality'
000410cc: 022b82e3   orr      r2, r2, #0x800
000410d0: f82045e1   strd     r2, r3, [r5, #-8]
000410d4: d82046e1   ldrd     r2, r3, [r6, #-8]
000410d8: 022b82e3   orr      r2, r2, #0x800
000410dc: f82046e1   strd     r2, r3, [r6, #-8]
000410e0: fa6507fa   blx      #0x21a8d0
000410e4: d82045e1   ldrd     r2, r3, [r5, #-8]
000410e8: 0030a0e3   mov      r3, #0
000410ec: 000053e3   cmp      r3, #0
000410f0: 222b02e2   and      r2, r2, #0x8800
000410f4: 220b5203   cmpeq    r2, #0x8800
000410f8: 1600001a   bne      #0x41158
000410fc: 003097e5   ldr      r3, [r7]
00041100: 320053e3   cmp      r3, #0x32
00041104: 060000ca   bgt      #0x41124
00041108: 010073e3   cmn      r3, #1
0004110c: 6f00001a   bne      #0x412d0
00041110: 30029fe5   ldr      r0, [pc, #0x230] ; [0x41348]=0x2a2538
00041114: 3210a0e3   mov      r1, #0x32
00041118: 52f700eb   bl       #0x7ee68
0004111c: 000050e3   cmp      r0, #0
00041120: 6a00001a   bne      #0x412d0
00041124: 58029fe5   ldr      r0, [pc, #0x258] ; [0x41384]=0x22b55f 'MediaQuality'
00041128: a16507fa   blx      #0x21a7b4
0004112c: d82045e1   ldrd     r2, r3, [r5, #-8]
00041130: 000050e3   cmp      r0, #0
00041134: 0229c203   biceq    r2, r2, #0x8000
00041138: 022bc213   bicne    r2, r2, #0x800
0004113c: f8204501   strdeq   r2, r3, [r5, #-8]
00041140: f8204511   strdne   r2, r3, [r5, #-8]
00041144: d8204601   ldrdeq   r2, r3, [r6, #-8]
00041148: d8204611   ldrdne   r2, r3, [r6, #-8]
0004114c: 0229c203   biceq    r2, r2, #0x8000
00041150: 022bc213   bicne    r2, r2, #0x800
00041154: f82046e1   strd     r2, r3, [r6, #-8]
