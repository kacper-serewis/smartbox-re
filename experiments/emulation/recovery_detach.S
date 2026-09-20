/* Linux RV32 helper: setsid(), then execve(argv[1], argv + 1, envp).
 * No libc, persistent writes, signal delivery, or flash operations.
 * Invoked as a background child so it is not already a process-group leader.
 */
.section .text
.global _start
_start:
    lw t0, 0(sp)
    li t1, 2
    blt t0, t1, fail
    li a7, 157 /* setsid */
    ecall
    bltz a0, fail
    lw t0, 0(sp)
    addi t0, t0, 2
    slli t0, t0, 2
    add a2, sp, t0
    addi a1, sp, 8
    lw a0, 0(a1)
    li a7, 221 /* execve */
    ecall
fail:
    li a0, 127
    li a7, 93 /* exit */
    ecall
