// round robin scheduling of processes upon a timer interrupt
.section .text
.global _start
.global ucode_checker
.global ucode_counter
.global get_checker_pc
.global get_counter_pc
.global get_fib_pc
.global ucode_fib
.global _stack_top

_start:
la sp, _machine_stack; # Set the machine stack
call setup_processes;
# Setup the sp register and set mepc based on return values from setup_processes
csrrw x0,mepc,a0;
add sp,a1,x0;
# Setup csr registers for timer interrupts(mtimecmp), trap handling and returning to user mode (mtvec, mstatus, mie)
li t0,0x100;
li t1,0x02004000;
sd t0,0(t1);
li t0,0x0200bff8;
sd x0,0(t0);
la t0,mtrap_handler;
csrrw x0,mtvec,t0;
li t0,0x1880
csrrw x0,mstatus,t0;
li t0,0x80;
csrrw x0,mie,t0;
mret;

increment_timer:
# Increment the mtimecmp value by 0x100 to trigger the next interrupt after some time
    li t0,0x02004000;
    ld t1,0(t0);
    addi t1,t1,0x100;
    sd t1,0(t0);
    ret;

.align 4
mtrap_handler:
# Saving the user mode context in the user stack
addi sp,sp,-248;
sd x1, 0(sp); # Save ra
# x2 skipped as stack pointer will be saved in scheduler in process table
sd x3, 16(sp); # Save gp
sd x4, 24(sp); # Save tp
sd x5, 32(sp); # Save t0
sd x6, 40(sp); # Save t1
sd x7, 48(sp); # Save t2
sd x8, 56(sp); # Save t3
sd x9, 64(sp); # Save t4
sd x10, 72(sp); # Save t5
sd x11, 80(sp); # Save t6
sd x12, 88(sp); # Save t7
sd x13, 96(sp); # Save s0
sd x14, 104(sp); # Save s1
sd x15, 112(sp); # Save s2
sd x16, 120(sp); # Save s3
sd x17, 128(sp); # Save s4
sd x18, 136(sp); # Save s5
sd x19, 144(sp); # Save s6
sd x20, 152(sp); # Save s7
sd x21, 160(sp); # Save s8
sd x22, 168(sp); # Save s9
sd x23, 176(sp); # Save s10
sd x24, 184(sp); # Save s11
sd x25, 192(sp); # Save t3
sd x26, 200(sp); # Save t4
sd x27, 208(sp); # Save t5
sd x28, 216(sp); # Save t6
sd x29, 224(sp); # Save t7
sd x30, 232(sp); # Save s0
sd x31, 240(sp); # Save s1

# Increment the mtimecmp value to trigger next interrupt
call increment_timer;

# Provide arguments to switch_processes
add a1,sp,x0;
csrr a0,mepc;
la sp, _machine_stack;
call switch_processes;
# Set up the sp register and mepc of next process based on return values from switch_processes
csrrw x0,mepc,a0;
add sp,a1,x0;

ld x1, 0(sp); # Restore ra
ld x3, 16(sp); # Restore gp
ld x4, 24(sp); # Restore tp
ld x5, 32(sp); # Restore t0
ld x6, 40(sp); # Restore t1
ld x7, 48(sp); # Restore t2
ld x8, 56(sp); # Restore t3
ld x9, 64(sp); # Restore t4
ld x10, 72(sp); # Restore t5
ld x11, 80(sp); # Restore t6
ld x12, 88(sp); # Restore t7
ld x13, 96(sp); # Restore s0
ld x14, 104(sp); # Restore s1
ld x15, 112(sp); # Restore s2
ld x16, 120(sp); # Restore s3
ld x17, 128(sp); # Restore s4
ld x18, 136(sp); # Restore s5
ld x19, 144(sp); # Restore s6
ld x20, 152(sp); # Restore s7
ld x21, 160(sp); # Restore s8
ld x22, 168(sp); # Restore s9
ld x23, 176(sp); # Restore s10
ld x24, 184(sp); # Restore s11
ld x25, 192(sp); # Restore t3
ld x26, 200(sp); # Restore t4
ld x27, 208(sp); # Restore t5
ld x28, 216(sp); # Restore t6
ld x29, 224(sp); # Restore t7
ld x30, 232(sp); # Restore s0
ld x31, 240(sp); # Restore s1
addi sp,sp,248;
mret;

.align 4
ucode_checker:
li s1, 11;
li s2, 11;
li s3, 11;
li s4, 11;
li s5, 11;
li s6, 11;
li s7, 11;
li s8, 11;
li s9, 11;
li s10, 11;
li s11, 11;
li t0, 11;
li t1, 11;
li t2, 11;
li t3, 11;
li t4, 11;
li t5, 11;
li t6, 11;
li a0, 11;
li a1, 11;
li a2, 11;
li a3, 11;
li a4, 11;
li a5, 11;
li a6, 11;
li a7, 11;
ucode_loop:
bne s1, s2, register_flag;
bne s2, s3, register_flag;
bne s3, s4, register_flag;
bne s4, s5, register_flag;
bne s5, s6, register_flag;
bne s6, s7, register_flag;
bne s7, s8, register_flag;
bne s8, s9, register_flag;
bne s9, s10, register_flag;
bne s10, s11, register_flag;
bne s11, t0, register_flag;
bne t0, t1, register_flag;
bne t1, t2, register_flag;
bne t2, t3, register_flag;
bne t3, t4, register_flag;
bne t4, t5, register_flag;
bne t5, t6, register_flag;
bne t6, a0, register_flag;
bne a0, a1, register_flag;
bne a1, a2, register_flag;
bne a2, a3, register_flag;
bne a3, a4, register_flag;
bne a4, a5, register_flag;
bne a5, a6, register_flag;
bne a6, a7, register_flag;
bne a7, s1, register_flag;
j ucode_loop;
register_flag:
la t0, flag_var;
li t1, 1;
sw t1, 0(t0); # Set flag_var to 1
j ucode_checker;

ucode_counter:
la t0, count_var;
lw t1, 0(t0);
addi t1, t1, 1;
sw t1, 0(t0);
j ucode_counter;

ucode_fib:
li a0, 11;
call fibonacci_helper;
j ucode_fib;

get_checker_pc:
la a0,ucode_checker;
ret;

get_counter_pc:
la a0,ucode_counter;
ret;

get_fib_pc:
la a0,ucode_fib;
ret;

.section .bss
.align 16                # RISC-V stack should be 16-byte aligned
_stack_low:
    .space 4096          # Reserve 4KB for the stack
_stack_top:
    .space 4096          # Reserve another 4KB for the machine stack
_machine_stack:

.align 4
.global count_var
count_var: .word 0
flag_var: .word 0
.align 4
.global fib_array
fib_array: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.align 6
.global process_table
process_table:  
    .space 2048         # Reserve space for 4 process control blocks
.global current_process
current_process:
    .word 0             # Initialize current_process to 0
