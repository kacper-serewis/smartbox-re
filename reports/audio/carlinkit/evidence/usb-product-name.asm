; ARM ELF virtual addresses; mode=ARM; static analysis only
00052038: 07402de9   push     {r0, r1, r2, lr}
0005203c: 04208de2   add      r2, sp, #4
00052040: 58009fe5   ldr      r0, [pc, #0x58] ; [0x520a0]=0x23823d '/tmp/car_usb_product'
00052044: 0d10a0e1   mov      r1, sp
00052048: 0030a0e3   mov      r3, #0
0005204c: 00308de5   str      r3, [sp]
00052050: 04308de5   str      r3, [sp, #4]
00052054: 3fb900eb   bl       #0x80558
00052058: 00209de5   ldr      r2, [sp]
0005205c: 000052e3   cmp      r2, #0
00052060: 0200000a   beq      #0x52070
00052064: 04309de5   ldr      r3, [sp, #4]
00052068: 000053e3   cmp      r3, #0
0005206c: 0400001a   bne      #0x52084
00052070: 00009de5   ldr      r0, [sp]
00052074: 000050e3   cmp      r0, #0
00052078: 0500000a   beq      #0x52094
0005207c: c31dffeb   bl       #0x19790
00052080: 030000ea   b        #0x52094
00052084: 18009fe5   ldr      r0, [pc, #0x18] ; [0x520a4]=0x2a3eec
00052088: 3f10a0e3   mov      r1, #0x3f
0005208c: cafdffeb   bl       #0x517bc
00052090: f6ffffea   b        #0x52070
00052094: 08009fe5   ldr      r0, [pc, #8] ; [0x520a4]=0x2a3eec
00052098: 0cd08de2   add      sp, sp, #0xc
0005209c: 04f09de4   pop      {pc}
