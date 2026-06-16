.section .text
.global main

main:
	# Write code here to jump to supervisor mode 
	li t0,0x800
	csrs mstatus,t0
	la t0,supervisor
	csrw mepc,t0
	mret

supervisor:
################ Initialize your page tables here ################
	#setting L3 pagetable entry
	la t0,L3
	la t1,L2
	srli t1,t1,12
	slli t1,t1,10
	addi t1,t1,1
	#addi t1,t1,0xC0
	sd t1,0(t0)

	#setting L2 pagetable enty
	la t0,L2
	la t1,L1
	srli t1,t1,12
	slli t1,t1,10
	addi t1,t1,1
	#addi t1,t1,0xC0
	sd t1,0(t0)


	#for virtual address 0x00009b000000 VPN[3] is 0 so L3 pagetable entry matches with that done for usercode and data section
	#setting L2 pagetable entry for page containing machine and supervisor code
	la t0,L2
	addi t0,t0,0x10
	la t1,L1_prime
	srli t1,t1,12
	slli t1,t1,10
	addi t1,t1,1
	#addi t1,t1,0xC0
	sd t1,0(t0)

	#setting L1 pagetable entry
	la t0,L1
	la t1,L0
	srli t1,t1,12
	slli t1,t1,10
	addi t1,t1,1
	#addi t1,t1,0xC0
	sd t1,0(t0)

	#setting L1 pagetable entry for page containing machine and supervisor code
	la t0,L1_prime
	addi t1,x0,0xd8
	slli t1,t1,3
	add t0,t0,t1
	la t1,L0_prime
	srli t1,t1,12
	slli t1,t1,10
	addi t1,t1,1
	#addi t1,t1,0xC0
	sd t1,0(t0)

	#setting leaf page table entry for user code page
	la t0,L0
	li t1,0x9b001
	slli t1,t1,10
	addi t1,t1,0x1b
	addi t1,t1,0xC0
	sd t1,0(t0)

	#setting leaf page table entry for data section page
	la t0,L0
	li t1,0x9b002
	slli t1,t1,10
	addi t1,t1,0x17
	addi t1,t1,0xC0
	sd t1,8(t0)

	#setting leaf page table entry for machine and supervisor code
	la t0,L0_prime
	li t1,0x9b000
	slli t1,t1,10
	addi t1,t1,0xb
	addi t1,t1,0xC0
	sd t1,0(t0)


	#setting satp
	la t0,L3
	srli t0,t0,12
	li t2,9
	slli t2,t2,60
	add t2,t2,t0
	la t1,satp_config
	sd t2,0(t1)

####################################################################

	# Prepare a jump to user mode
	csrw sstatus,x0

################ DO NOT MODIFY THESE INSTRUCTIONS ################
	la t1, satp_config # load satp val
	ld t2, 0(t1)
	sfence.vma zero, zero
	csrrw zero, satp, t2
	sfence.vma zero, zero
	li t4, 0
	csrrw zero, sepc, t4
	sret
#################################################################### 

.align 12
user_code:
# Write user code here that does the following:
    # 1. Initialize four variables var1 , var2 , var3 , var4 in the data section with values 1 , 2 , 3 , 4.
	la t0,var1
	li t1,1
	sd t1,0(t0)

	la t0,var2
	li t1,2
	sd t1,0(t0)

	la t0,var3
	li t1,3
	sd t1,0(t0)

	la t0,var4
	li t1,4
	sd t1,0(t0)
	
    # 2. The user_code must load these variables into t1 , t2 , t3 , t4 registers (for reading during debug mode) and then loop back to itself.
	j user_code
# Don't forget to align the data section and user_code propely. For assembly directive usage, use the last reference given.


.section .data 
.align 12
var1:.dword 0
var2:.dword 0
var3:.dword 0
var4:.dword 0

satp_config: .dword 0
# Set appropriate value for satp here.
.align 12
L3:.space 4096
L2:.space 4096
L1:.space 4096
L0:.space 4096
L1_prime:.space 4096
L0_prime:.space 4096

