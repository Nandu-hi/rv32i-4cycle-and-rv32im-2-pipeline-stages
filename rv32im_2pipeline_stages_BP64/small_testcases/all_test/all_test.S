.section .text
.global _start
_start:

  # --- ADDI: x1 = x0 + 5
  addi x1, x0, 5
  addi x2, x1, -5
  beq x2, x0, pass_addi
  j fail
pass_addi:

  # --- ANDI / ORI / XORI
  addi x3, x0, 0x0F
  andi x4, x3, 0xF0   # Should be 0
  beq x4, x0, pass_andi
  j fail
pass_andi:

  ori  x5, x3, 0xF0   # 0xFF
  li x6, 0xFF
  bne x5, x6, fail

  xori x7, x5, 0xFF   # 0x00
  beq x7, x0, pass_xori
  j fail
pass_xori:

  # --- SLTI / SLTIU
  addi x8, x0, 1
  slti x9, x8, 2       # x9 = 1
  bne x9, x8, fail

  sltiu x10, x0, 1     # x10 = 1
  bne x10, x8, fail

  # --- SLLI / SRLI / SRAI
  slli x11, x8, 3      # x11 = 1 << 3 = 8
  srli x12, x11, 2     # x12 = 2
  li x13, 2
  bne x12, x13, fail

  srai x14, x11, 2     # Arithmetic right shift (positive stays same)
  bne x14, x13, fail

  # --- Register Arithmetic: ADD, SUB, AND, OR, XOR
  add  x1, x8, x8      # x1 = 2
  sub  x2, x1, x8      # x2 = 1
  bne  x2, x8, fail

  xor  x3, x1, x2      # x3 = 3
  li   x4, 3
  bne  x3, x4, fail

  and  x5, x1, x4      # x5 = 2
  li   x6, 2
  bne  x5, x6, fail

  or   x7, x1, x2      # x7 = 3
  bne  x7, x4, fail

  # --- SLT / SLTU
  slt  x8, x2, x1      # 1 < 2 → x8 = 1
  bne  x8, x2, fail

  sltu x9, x2, x1      # unsigned: 1 < 2 → x9 = 1
  bne  x9, x2, fail

  # --- Branch: BEQ / BNE / BLT / BGE / BLTU / BGEU
  li x10, 10
  li x11, 10
  beq x10, x11, pass_beq
  j fail
pass_beq:

  bne x10, x0, pass_bne
  j fail
pass_bne:

  li x12, 5
  blt x12, x10, pass_blt
  j fail
pass_blt:

  bge x10, x12, pass_bge
  j fail
pass_bge:

  bltu x12, x10, pass_bltu
  j fail
pass_bltu:

  bgeu x10, x12, pass_bgeu
  j fail
pass_bgeu:

  # --- JAL
  jal x1, jal_target
  j fail         # Should not execute
jal_target:
  li x2, 0
  addi x2, x1, -4
  beq x2, x0, fail  # x1 should be PC+4
  j pass_jal
pass_jal:

  # --- JALR (Corrected)
  auipc x3, 0           # PC
  addi  x3, x3, 16      # Offset to label_jalr
  jalr  x4, 0(x3)       # Jump to label_jalr
  j fail
label_jalr:
  li x5, 0
  addi x5, x4, -4
  beq x5, x0, fail
  j pass_jalr
pass_jalr:

  # --- LUI / AUIPC
  lui x6, 0x12345
  auipc x7, 0x0         # Don't validate address, just test usage
  nop

  # --- Memory: SB/LB, SH/LH, SW/LW
  li x1, 0x4000          # base address in memory range 0x000 – 0x3000
  li x2, 0x7F
  sb x2, 0(x1)
  lb x3, 0(x1)
  andi x3, x3, 0xFF
  bne x3, x2, fail

  li x4, 0x1234
  sh x4, 2(x1)
  lh x5, 2(x1)
  andi x5, x5, -1
  bne x5, x4, fail

  li x6, 0xDEAD
  sw x6, 4(x1)
  lw x7, 4(x1)
  bne x7, x6, fail

  # --- Loop to Self
  j done

fail:
  li x0, 0              # trap or infinite loop on fail
  j fail

done:
  j done
