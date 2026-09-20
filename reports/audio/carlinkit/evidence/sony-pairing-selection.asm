; ARM ELF virtual addresses; mode=ARM; static analysis only
00039e18: d821c5e1   ldrd     r2, r3, [r5, #0x18]
00039e1c: 0020a0e3   mov      r2, #0
00039e20: 20408de5   str      r4, [sp, #0x20]
00039e24: 403003e2   and      r3, r3, #0x40
00039e28: 033092e1   orrs     r3, r2, r3
00039e2c: 6d00000a   beq      #0x39fe8
00039e30: 806000eb   bl       #0x52038
00039e34: 68129fe5   ldr      r1, [pc, #0x268] ; [0x3a0a4]=0x22a3cd 'SONY CAR AUDIO'
00039e38: 7c80ffeb   bl       #0x1a030 ; strstr
00039e3c: 000050e3   cmp      r0, #0
00039e40: 0400001a   bne      #0x39e58
00039e44: 7b6000eb   bl       #0x52038
00039e48: 58129fe5   ldr      r1, [pc, #0x258] ; [0x3a0a8]=0x22a3dc 'USB4931'
00039e4c: 7780ffeb   bl       #0x1a030 ; strstr
00039e50: 000050e3   cmp      r0, #0
00039e54: 6300000a   beq      #0x39fe8
00039e58: 0500a0e1   mov      r0, r5
00039e5c: 0010a0e3   mov      r1, #0
00039e60: 26fdffeb   bl       #0x39300
