.section .text
.global _start
_start:

# ==============================================================================
# SECTION 1: I-TYPE ALU OPERATIONS (Immediate)
# Testing all funct3 variations: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
# ==============================================================================

# -----------------------------------------------------
# 1.1 ADDI (funct3 = 000)
# -----------------------------------------------------
  # Test 1: Simple Addition
  addi x1, x0, 10       # x1 = 10
  li   x2, 10
  bne  x1, x2, fail

  # Test 2: Negative Immediate (Sign Extension)
  addi x1, x0, -10      # x1 = -10
  li   x2, -10
  bne  x1, x2, fail

  # Test 3: Zero Register Read-Only Check
  addi x0, x0, 123      # Try to write to x0
  bne  x0, x0, fail     # x0 must remain 0

# -----------------------------------------------------
# 1.2 SLTI (funct3 = 010) - Set Less Than Immediate (Signed)
# -----------------------------------------------------
  # Test 1: -10 < 0 (True)
  li   x1, -10
  slti x2, x1, 0        # x2 should be 1
  li   x3, 1
  bne  x2, x3, fail

  # Test 2: 10 < 0 (False)
  li   x1, 10
  slti x2, x1, 0        # x2 should be 0
  bne  x2, x0, fail

# -----------------------------------------------------
# 1.3 SLTIU (funct3 = 011) - Set Less Than Immediate (Unsigned)
# -----------------------------------------------------
  # Test 1: 10 < 20 (True)
  li   x1, 10
  sltiu x2, x1, 20      # x2 should be 1
  li   x3, 1
  bne  x2, x3, fail

  # Test 2: -1 (0xFFFFFFFF) < 1 (False in Unsigned)
  li   x1, -1
  sltiu x2, x1, 1       # x2 should be 0 because 0xFFFFFFFF > 1
  bne  x2, x0, fail

# -----------------------------------------------------
# 1.4 XORI (funct3 = 100) - XOR Immediate
# -----------------------------------------------------
  li   x1, 0xFFFFFFFF
  xori x2, x1, -1       # 0xFFFFFFFF ^ 0xFFFFFFFF = 0
  bne  x2, x0, fail

# -----------------------------------------------------
# 1.5 ORI (funct3 = 110) - OR Immediate
# -----------------------------------------------------
  li   x1, 0xF0F0F0F0
  ori  x2, x1, 0x0F0    # result should be 0xF0F0F0F0 | 0x000000F0 -> 0xF0F0F0F0
  li   x3, 0xF0F0F0F0
  bne  x2, x3, fail

  # ORI with negative immediate (-1)
  ori  x2, x0, -1       # x2 = 0 | 0xFFFFFFFF
  li   x3, -1
  bne  x2, x3, fail

# -----------------------------------------------------
# 1.6 ANDI (funct3 = 111) - AND Immediate
# -----------------------------------------------------
  li   x1, 0xABCDEF00
  andi x2, x1, 0x00F    # 0xABCDEF00 & 0x0000000F = 0
  bne  x2, x0, fail

  andi x2, x1, -1       # 0xABCDEF00 & 0xFFFFFFFF = 0xABCDEF00
  bne  x2, x1, fail

# -----------------------------------------------------
# 1.7 SLLI (funct3 = 001) - Shift Left Logical Immediate
# -----------------------------------------------------
  li   x1, 1
  slli x2, x1, 4        # 1 << 4 = 16
  li   x3, 16
  bne  x2, x3, fail

# -----------------------------------------------------
# 1.8 SRLI (funct3 = 101) - Shift Right Logical Immediate
# -----------------------------------------------------
  li   x1, -1           # 0xFFFFFFFF
  srli x2, x1, 31       # 0xFFFFFFFF >> 31 (Logical) = 1
  li   x3, 1
  bne  x2, x3, fail

# -----------------------------------------------------
# 1.9 SRAI (funct3 = 101, funct7 bit 30=1) - Shift Right Arithmetic Immediate
# -----------------------------------------------------
  li   x1, -2           # 0xFFFFFFFE
  srai x2, x1, 1        # 0xFFFFFFFE >> 1 (Arithmetic) = 0xFFFFFFFF (-1)
  li   x3, -1
  bne  x2, x3, fail


# ==============================================================================
# SECTION 2: R-TYPE ALU OPERATIONS (Register-Register)
# Testing all funct3 variations: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
# ==============================================================================

# -----------------------------------------------------
# 2.1 ADD (funct3 = 000, funct7 = 00)
# -----------------------------------------------------
  li   x1, 100
  li   x2, -50
  add  x3, x1, x2       # 100 + (-50) = 50
  li   x4, 50
  bne  x3, x4, fail

# -----------------------------------------------------
# 2.2 SUB (funct3 = 000, funct7 = 20)
# -----------------------------------------------------
  li   x1, 10
  li   x2, 20
  sub  x3, x1, x2       # 10 - 20 = -10
  li   x4, -10
  bne  x3, x4, fail

# -----------------------------------------------------
# 2.3 SLL (funct3 = 001) - Shift Left Logical
# -----------------------------------------------------
  li   x1, 1
  li   x2, 5
  sll  x3, x1, x2       # 1 << 5 = 32
  li   x4, 32
  bne  x3, x4, fail

# -----------------------------------------------------
# 2.4 SLT (funct3 = 010) - Set Less Than (Signed)
# -----------------------------------------------------
  li   x1, -5
  li   x2, 5
  slt  x3, x1, x2       # -5 < 5 -> 1
  li   x4, 1
  bne  x3, x4, fail

  slt  x3, x2, x1       # 5 < -5 -> 0
  bne  x3, x0, fail

# -----------------------------------------------------
# 2.5 SLTU (funct3 = 011) - Set Less Than (Unsigned)
# -----------------------------------------------------
  li   x1, -1           # Max Unsigned (0xFFFFFFFF)
  li   x2, 1
  sltu x3, x1, x2       # Max < 1 -> False (0)
  bne  x3, x0, fail

  sltu x3, x2, x1       # 1 < Max -> True (1)
  li   x4, 1
  bne  x3, x4, fail

# -----------------------------------------------------
# 2.6 XOR (funct3 = 100)
# -----------------------------------------------------
  li   x1, 0xAAAAAAAA
  li   x2, 0x55555555
  xor  x3, x1, x2       # AA.. ^ 55.. = FF..
  li   x4, -1           # 0xFFFFFFFF
  bne  x3, x4, fail

# -----------------------------------------------------
# 2.7 SRL (funct3 = 101, funct7 = 00) - Shift Right Logical
# -----------------------------------------------------
  li   x1, 0x80000000
  li   x2, 31
  srl  x3, x1, x2       # 0x80... >> 31 (Logical) = 1
  li   x4, 1
  bne  x3, x4, fail

# -----------------------------------------------------
# 2.8 SRA (funct3 = 101, funct7 = 20) - Shift Right Arithmetic
# -----------------------------------------------------
  li   x1, 0x80000000
  li   x2, 31
  sra  x3, x1, x2       # 0x80... >> 31 (Arithmetic) = 0xFFFFFFFF (-1)
  li   x4, -1
  bne  x3, x4, fail

# -----------------------------------------------------
# 2.9 OR (funct3 = 110)
# -----------------------------------------------------
  li   x1, 0x0000FFFF
  li   x2, 0xFFFF0000
  or   x3, x1, x2       # Result: 0xFFFFFFFF
  li   x4, -1
  bne  x3, x4, fail

# -----------------------------------------------------
# 2.10 AND (funct3 = 111)
# -----------------------------------------------------
  li   x1, 0xFF00FF00
  li   x2, 0x00FFFF00
  and  x3, x1, x2       # Result: 0x0000FF00
  li   x4, 0x0000FF00
  bne  x3, x4, fail


# ==============================================================================
# SECTION 3: B-TYPE BRANCH OPERATIONS
# Testing all funct3 variations: BEQ, BNE, BLT, BGE, BLTU, BGEU
# ==============================================================================

# 3.1 BEQ (funct3 = 000)
  li x1, 5
  li x2, 5
  beq x1, x2, pass_beq
  j fail
pass_beq:

# 3.2 BNE (funct3 = 001)
  li x1, 5
  li x2, 6
  bne x1, x2, pass_bne
  j fail
pass_bne:

# 3.3 BLT (funct3 = 100) - Signed <
  li x1, -10
  li x2, 0
  blt x1, x2, pass_blt
  j fail
pass_blt:

# 3.4 BGE (funct3 = 101) - Signed >=
  li x1, 0
  li x2, -10
  bge x1, x2, pass_bge
  j fail
pass_bge:

# 3.5 BLTU (funct3 = 110) - Unsigned <
  li x1, 10
  li x2, -1   # 0xFFFFFFFF
  bltu x1, x2, pass_bltu # 10 < MAX_UINT
  j fail
pass_bltu:

# 3.6 BGEU (funct3 = 111) - Unsigned >=
  li x1, -1   # 0xFFFFFFFF
  li x2, 10
  bgeu x1, x2, pass_bgeu # MAX_UINT >= 10
  j fail
pass_bgeu:


# ==============================================================================
# SECTION 4: LOAD / STORE (S-Type, I-Type)
# Testing funct3: SB, SH, SW, LB, LH, LW, LBU, LHU
# ==============================================================================
# We need a valid memory address. Assuming 0x1000 is available for bare-metal.

  li x10, 0x4000

# 4.1 SW / LW (funct3 = 010)
  li x1, 0xDEADBEEF
  sw x1, 0(x10)
  lw x2, 0(x10)
  bne x1, x2, fail

# 4.2 SH / LH (funct3 = 001)
  li x1, 0x1234
  sh x1, 4(x10)
  lh x2, 4(x10)
  bne x1, x2, fail

  # SH Negative Check
  li x1, -1        # 0xFFFFFFFF
  sh x1, 6(x10)    # Write 0xFFFF
  lh x2, 6(x10)    # Read back (sign extended to 0xFFFFFFFF)
  bne x1, x2, fail

# 4.3 LHU (funct3 = 101)
  lhu x2, 6(x10)   # Read 0xFFFF, zero extend to 0x0000FFFF
  li  x3, 0xFFFF
  bne x2, x3, fail

# 4.4 SB / LB (funct3 = 000)
  li x1, 0x7F
  sb x1, 8(x10)
  lb x2, 8(x10)
  bne x1, x2, fail

  # SB Negative Check
  li x1, -1        # 0xFFFFFFFF
  sb x1, 9(x10)    # Write 0xFF
  lb x2, 9(x10)    # Read back (sign extended to 0xFFFFFFFF)
  bne x1, x2, fail

# 4.5 LBU (funct3 = 100)
  lbu x2, 9(x10)   # Read 0xFF, zero extend to 0x000000FF
  li  x3, 0xFF
  bne x2, x3, fail


# ==============================================================================
# SECTION 5: JUMPS (J-Type / I-Type)
# ==============================================================================

# 5.1 JAL (Jump and Link)
  jal x1, jal_target
  j fail
jal_target:
  # x1 should contain PC+4.
  # Since we are here, JAL worked.

# 5.2 JALR (Jump and Link Register)
  la x2, jalr_dest
  jalr x0, 0(x2)
  j fail
jalr_dest:
  # JALR worked.


# ==============================================================================
# SECTION 6: U-TYPE INSTRUCTIONS (LUI / AUIPC)
# ==============================================================================

# 6.1 LUI (Load Upper Immediate)
  # LUI loads the 20-bit immediate into bits 31:12 of the destination register
  # and clears the bottom 12 bits.
  lui x1, 0x12345       # x1 should become 0x12345000
  li  x2, 0x12345000
  bne x1, x2, fail

  # LUI boundary check (all 1s)
  lui x1, 0xFFFFF       # x1 should become 0xFFFFF000
  li  x2, 0xFFFFF000
  bne x1, x2, fail

  # LUI zero check
  lui x1, 0             # x1 should become 0x00000000
  bne x1, x0, fail

# 6.2 AUIPC (Add Upper Immediate to PC)
  # AUIPC adds the 20-bit upper immediate to the PC of the AUIPC instruction.
  # We test this by calculating the address of a label.
  
  # Step 1: Get PC via AUIPC
  auipc x1, 0           # x1 = PC of this instruction + 0
  
  # Step 2: Use JAL to get PC+4 into x2 to verify x1 is correct
  jal x2, verify_auipc
  j fail # Should not be reached

verify_auipc:
  # x2 now holds the address of 'verify_auipc' (which is AUIPC_ADDR + 4)
  addi x2, x2, -8       # Adjust x2 to point back to the AUIPC instruction
  bne  x1, x2, fail     # AUIPC result (x1) should match calculated PC (x2)

  # Complex AUIPC Check: Load a target address relative to PC
  # We want to load the address of 'pass' label using AUIPC + ADDI manually
  # This tests if AUIPC handles the upper 20 bits correctly.
  
  # Note: Since we don't know the absolute address of 'pass' at assembly time without
  # linker relaxation potentially optimizing it, we stick to the self-relative check above
  # which is the most robust bare-metal test.

# ==============================================================================
# FINAL SUCCESS TRAP
# ==============================================================================
pass:
  j pass

# ==============================================================================
# FAILURE TRAP
# ==============================================================================
fail:
  j fail