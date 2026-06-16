    .section .text
    .global _start
_start:
    /* Setup base address for OUTPUT (peripheral at 0x0000c000) */
    /* Use explicit lui/addi to avoid pseudo li surprises */
    lui   t0, 0x0000c            /* t0 = 0x00008000 (upper 20 bits) */
    addi  t0, t0, 0x000          /* t0 unchanged, keep explicit */

    /* Data memory base for load/store tests (use 0x00004000) */
    lui   s0, 0x00004            /* s0 = 0x00004000 */

    /* Helper macro: write progress code W into OUTPUT */
    /* We'll use sw xN, 0(t0) where xN contains the code */
    /* Section 1: I-type immediates */
    li   a0, 0x41                /* progress code 0x10 */
    sw   a0, 0(t0)

    /* ---------- 1: ADDI ---------- */
    addi x1, x0, 10
    addi x2, x0, 10
    bne  x1, x2, fail

    addi x1, x0, -10
    addi x2, x0, -10
    bne  x1, x2, fail

    /* test write to x0 should be ignored */
    addi x0, x0, 123      /* should not change x0 */
    bne  x0, x0, fail

    li   a0, 0x42
    sw   a0, 0(t0)

    /* ---------- 1.2 SLTI ---------- */
    li   x1, -10
    slti x2, x1, 0
    li   x3, 1
    bne  x2, x3, fail

    li   a0, 0x43
    sw   a0, 0(t0)

    /* ---------- 1.3 SLTIU ---------- */
    li   x1, 10
    sltiu x2, x1, 20
    li   x3, 1
    bne  x2, x3, fail

    li   x1, -1
    sltiu x2, x1, 1
    bne  x2, x0, fail

    li   a0, 0x44
    sw   a0, 0(t0)

    /* ---------- 1.4 XORI/ORI/ANDI/SLLI/SRLI/SRAI ---------- */
    li   x1, 0xFFFFFFFF
    xori x2, x1, -1
    bne  x2, x0, fail

    li   x1, 0xF0F0F0F0
    ori  x2, x1, 0x000000F0
    li   x3, 0xF0F0F0F0
    bne  x2, x3, fail

    li   x1, 0xABCDEF00
    andi x2, x1, 0x0F
    bne  x2, x0, fail

    li   x1, 1
    slli x2, x1, 4
    li   x3, 16
    bne  x2, x3, fail

    li   x1, -1
    srli x2, x1, 31
    li   x3, 1
    bne  x2, x3, fail

    li   x1, -2
    srai x2, x1, 1
    li   x3, -1
    bne  x2, x3, fail

    li   a0, 0x45
    sw   a0, 0(t0)

    /* ---------- SECTION 2: R-type ---------- */
    li   x1, 100
    li   x2, -50
    add  x3, x1, x2
    li   x4, 50
    bne  x3, x4, fail

    li   x1, 10
    li   x2, 20
    sub  x3, x1, x2
    li   x4, -10
    bne  x3, x4, fail

    li   x1, 1
    li   x2, 5
    sll  x3, x1, x2
    li   x4, 32
    bne  x3, x4, fail

    li   x1, -5
    li   x2, 5
    slt  x3, x1, x2
    li   x4, 1
    bne  x3, x4, fail

    li   x1, -1
    li   x2, 1
    sltu x3, x1, x2
    bne  x3, x0, fail

    li   x1, 0xAAAAAAAA
    li   x2, 0x55555555
    xor  x3, x1, x2
    li   x4, -1
    bne  x3, x4, fail

    li   x1, 0x80000000
    li   x2, 31
    srl  x3, x1, x2
    li   x4, 1
    bne  x3, x4, fail

    li   x1, 0x80000000
    li   x2, 31
    sra  x3, x1, x2
    li   x4, -1
    bne  x3, x4, fail

    li   a0, 0x46
    sw   a0, 0(t0)

    /* ---------- SECTION 3: BRANCH TESTS ---------- */
    li x1, 5
    li x2, 5
    beq x1, x2, pass_beq
    j fail
pass_beq:

    li x1, 5
    li x2, 6
    bne x1, x2, pass_bne
    j fail
pass_bne:

    li x1, -10
    li x2, 0
    blt x1, x2, pass_blt
    j fail
pass_blt:

    li x1, 0
    li x2, -10
    bge x1, x2, pass_bge
    j fail
pass_bge:

    li x1, 10
    li x2, -1
    bltu x1, x2, pass_bltu
    j fail
pass_bltu:

    li x1, -1
    li x2, 10
    bgeu x1, x2, pass_bgeu
    j fail
pass_bgeu:

    li   a0, 0x47
    sw   a0, 0(t0)

    /* ---------- SECTION 4: LOAD/STORE ---------- */
    /* Use s0 (0x00004000) as DMEM base, ensure memory present at that area! */
    /* store a word at s0+0 */
    li   x1, 0xDEADBEEF
    sw   x1, 0(s0)
    lw   x2, 0(s0)
    bne  x1, x2, fail

    /* store half / load half */
    li   x1, 0x1234
    sh   x1, 4(s0)
    lh   x2, 4(s0)
    bne  x1, x2, fail

    li   x1, -1
    sh   x1, 6(s0)
    lh   x2, 6(s0)
    bne  x1, x2, fail

    lhu  x2, 6(s0)
    li   x3, 0xFFFF
    bne  x2, x3, fail

    li   x1, 0x7F
    sb   x1, 8(s0)
    lb   x2, 8(s0)
    bne  x1, x2, fail

    li   x1, -1
    sb   x1, 9(s0)
    lb   x2, 9(s0)
    bne  x1, x2, fail

    lbu  x2, 9(s0)
    li   x3, 0xFF
    bne  x2, x3, fail

    li   a0, 0x48
    sw   a0, 0(t0)

    /* ---------- SECTION 5: JUMPS ---------- */
    /* JAL */
    jal x4, 1f     /* jump forward */
    j fail
1:
    /* if returned here, jal worked (x5 contains ret addr) */

    /* JALR: place label in reg and jump */
    la   x6, 2f
    jalr x0, 0(x6)
    j fail
2:
    li   a0, 0x49
    sw   a0, 0(t0)

    /* ---------- SECTION 6: U-type LUI / AUIPC ---------- */
    /* LUI checks */
    lui x1, 0x12345
    li  x2, 0x12345000
    bne x1, x2, fail

    lui x1, 0xFFFFF
    li  x2, 0xFFFFF000
    bne x1, x2, fail

    auipc x1, 0
    jal x2, 3f
    j fail
3:
    addi x2, x2, -8
    bne x1, x2, fail

    li   a0, 0x50
    sw   a0, 0(t0)

    /* Forwarding probes */
    /* Write reg and read it back immediately */
    addi x7, x0, 5
    add  x8, x7, x0    /* immediate use without NOP - tests forwarding */
    li   x9, 5
    bne  x8, x9, fail_forward

    /* Now probe with NOP inserted (should work even without forwarding) */
    addi x7, x0, 6
    nop
    add  x8, x7, x0
    li   x9, 6
    bne x8, x9, fail_forward

    li   a0, 0x51
    sw   a0, 0(t0)

    /* All tests passed */
    li   a0, 0x52
    sw   a0, 0(t0)
    jal  ra, print_success    /* <--- Add this call here */
    j    .

/* Failure labels write different codes for debugging */
fail_forward:
    li a0, 0x58
    sw  a0, 0(t0)
    j fail_forward

fail:
    li a0, 0x59
    sw  a0, 0(t0)
    j fail

print_success:
    lui   t0, 0x0000C          # Peripheral address 0x0000C000
    # '\n' = 0x0A
    li    t1, 0x0A
    sb    t1, 0(t0)
    # 'T' = 0x54
    li    t1, 0x54
    sb    t1, 0(t0)
    # 'e' = 0x65
    li    t1, 0x65
    sb    t1, 0(t0)
    # 's' = 0x73
    li    t1, 0x73
    sb    t1, 0(t0)
    # 't' = 0x74
    li    t1, 0x74
    sb    t1, 0(t0)
    # ' ' = 0x20
    li    t1, 0x20
    sb    t1, 0(t0)
    # 'P' = 0x50
    li    t1, 0x50
    sb    t1, 0(t0)
    # 'a' = 0x61
    li    t1, 0x61
    sb    t1, 0(t0)
    # 's' = 0x73
    li    t1, 0x73
    sb    t1, 0(t0)
    # 's' = 0x73
    li    t1, 0x73
    sb    t1, 0(t0)
    # 'e' = 0x65
    li    t1, 0x65
    sb    t1, 0(t0)
    # 's' = 0x73
    li    t1, 0x73
    sb    t1, 0(t0)
    # '!' = 0x21
    li    t1, 0x21
    sb    t1, 0(t0)
    # '\n' = 0x0A
    li    t1, 0x0A
    sb    t1, 0(t0)

    ret