; ARM ELF virtual addresses; mode=ARM; static analysis only
000411f0: d82045e1   ldrd     r2, r3, [r5, #-8]
000411f4: 0030a0e3   mov      r3, #0
000411f8: 022902e2   and      r2, r2, #0x8000
000411fc: 033092e1   orrs     r3, r2, r3
00041200: 0100000a   beq      #0x4120c
00041204: 80019fe5   ldr      r0, [pc, #0x180] ; [0x4138c]=0x22b56c 'touch /tmp/use_48K_audio'
00041208: d662ffeb   bl       #0x19d68 ; system
0004120c: d82045e1   ldrd     r2, r3, [r5, #-8]
00041210: 78019fe5   ldr      r0, [pc, #0x178] ; [0x41390]=0x22b585 '/tmp/main_audio_format'
00041214: 78119fe5   ldr      r1, [pc, #0x178] ; [0x41394]=0x224f4d 'wb'
00041218: f022cde1   strd     r2, r3, [sp, #0x20]
0004121c: 8262ffeb   bl       #0x19c2c ; fopen
00041220: 005050e2   subs     r5, r0, #0
00041224: 0600000a   beq      #0x41244
00041228: 20008de2   add      r0, sp, #0x20
0004122c: 0110a0e3   mov      r1, #1
00041230: 0820a0e3   mov      r2, #8
00041234: 0530a0e1   mov      r3, r5
00041238: 1e64ffeb   bl       #0x1a2b8 ; fwrite
0004123c: 0500a0e1   mov      r0, r5
00041240: 6164ffeb   bl       #0x1a3cc ; fclose
00041244: d020c4e1   ldrd     r2, r3, [r4]
00041248: 48019fe5   ldr      r0, [pc, #0x148] ; [0x41398]=0x22b59c '/tmp/alt_audio_format'
0004124c: 40119fe5   ldr      r1, [pc, #0x140] ; [0x41394]=0x224f4d 'wb'
00041250: f822cde1   strd     r2, r3, [sp, #0x28]
00041254: 7462ffeb   bl       #0x19c2c ; fopen
00041258: 004050e2   subs     r4, r0, #0
0004125c: 3700000a   beq      #0x41340
