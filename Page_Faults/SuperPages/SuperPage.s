.section .text
.global main

main:
	# Write code here to jump to supervisor mode 
	li t0,0x880;
	csrrw x0,mstatus,t0;

	la t0,supervisor;
	csrrw x0,mepc,t0;
	mret;

supervisor: 
################ Initialize your page tables here ################
	#setting address of L1 in L2

	la t0,L2
	la t1,L1
	srli t1,t1,12
	slli t1,t1,10
	addi t1,t1,1
	sd t1,0(t0)

	la t0,L1;
	li t1,0x401;
	slli t1,t1,19;
	addi t1,t1,0xfb;
	sd t1,0(t0);

	la t0,L1;
	addi t0,t0,8;
	li t1,0x402;
	slli t1,t1,19;
	addi t1,t1,0xf7;
	sd t1,0(t0);


	la t0,L2
	addi t0,t0,16
	la t1,L1_prime
	srli t1,t1,12
	slli t1,t1,10
	addi t1,t1,1
	sd t1,0(t0)

	la t0,L1_prime;
	li t1,0x400;
	slli t1,t1,19;
	addi t1,t1,0xcb;
	sd t1,0(t0);


####################################################################

	# Prepare a jump to user mode
	li t0,0x20;
	csrrw x0,sstatus,t0;

	la t0,user_code;
	csrrw x0,sepc,t0;


################ DO NOT MODIFY THESE INSTRUCTIONS ################
	la t1, satp_config # load satp val

	li t0,8;
	slli t0,t0,60;
	la t2,L2;
	srli t2,t2,12;
	add t0,t0,t2;
	sd t0,0(t1);

	ld t2, 0(t1)
	sfence.vma zero, zero
	csrrw zero, satp, t2
	sfence.vma zero, zero

	li t4, 0
	csrrw zero, sepc, t4
	sret
#################################################################### 
.align 21
user_code:
# Write user code here that does the following:
    # 1. Initialize four variables var1 , var2 , var3 , var4 in the data section with values 1 , 2 , 3 , 4.
    # 2. The user_code must load these variables into t1 , t2 , t3 , t4 registers (for reading during debug mode) and then loop back to itself.
# Don't forget to align the data section and user_code propely. For assembly directive usage, use the last reference given.

ld t1,var1;
ld t2,var2;
ld t3,var3;
ld t4,var4;
j user_code;


.section .data
.align 21
var1:.dword 1
var2:.dword 2
var3:.dword 3
var4:.dword 4

.align 12
L1:.space 4096
L1_prime:.space 4096 
L2:.space 4096

satp_config: .dword  0
# Set appropriate value for satp here.

