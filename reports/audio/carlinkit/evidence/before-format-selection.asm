; ARM ELF virtual addresses; mode=Thumb; static analysis only
00033b3e: 0bf087fe   bl       #0x3f850
00033b42: 5d49       ldr      r1, [pc, #0x174] ; [0x33cb8]=0x1fb564 'MISTRA'
00033b44: e5f7d0ec   blx      #0x194e8 ; strstr
00033b48: 20b1       cbz      r0, #0x33b54
00033b4a: 0021       movs     r1, #0
00033b4c: 5b48       ldr      r0, [pc, #0x16c] ; [0x33cbc]=0x1fb56b 'MediaQuality'
00033b4e: b8f1cbfb   bl       #0x1ec2e8
00033b52: 06e0       b        #0x33b62
00033b54: 0bf07cfe   bl       #0x3f850
00033b58: 5949       ldr      r1, [pc, #0x164] ; [0x33cc0]=0x1fb578 'VOLVO'
00033b5a: e5f7c6ec   blx      #0x194e8 ; strstr
00033b5e: 0028       cmp      r0, #0
00033b60: f3d1       bne      #0x33b4a
00033b62: 04f5de65   add.w    r5, r4, #0x6f0
00033b66: 4a4f       ldr      r7, [pc, #0x128] ; [0x33c90]=0x2686d0
00033b68: d5e90023   ldrd     r2, r3, [r5]
00033b6c: 0023       movs     r3, #0
00033b6e: 002b       cmp      r3, #0
00033b70: 02f40842   and      r2, r2, #0x8800
00033b74: 08bf       it       eq
00033b76: b2f5084f   cmpeq.w  r2, #0x8800
00033b7a: 19d1       bne      #0x33bb0
00033b7c: 3b68       ldr      r3, [r7]
00033b7e: 322b       cmp      r3, #0x32
00033b80: 09dc       bgt      #0x33b96
00033b82: 0133       adds     r3, #1
00033b84: 40f0c180   bne.w    #0x33d0a
00033b88: 3846       mov      r0, r7
00033b8a: 3221       movs     r1, #0x32
00033b8c: 36f0d0eb   blx      #0x6a330
00033b90: 0028       cmp      r0, #0
00033b92: 40f0ba80   bne.w    #0x33d0a
00033b96: 4948       ldr      r0, [pc, #0x124] ; [0x33cbc]=0x1fb56b 'MediaQuality'
00033b98: b8f134fb   bl       #0x1ec204
00033b9c: d5e90023   ldrd     r2, r3, [r5]
00033ba0: 10b9       cbnz     r0, #0x33ba8
00033ba2: 22f40042   bic      r2, r2, #0x8000
00033ba6: 01e0       b        #0x33bac
00033ba8: 22f40062   bic      r2, r2, #0x800
00033bac: c5e90023   strd     r2, r3, [r5]
