
.section .text
.global main



main:
    # Prepare jump to super mode
    li t1, 1
    slli t1, t1, 11   #mpp_mask
    csrs mstatus, t1
    
    la t4, supervisor       #load address of user-space code
    csrrw zero, mepc, t4    #set mepc to user code
    
    la t5, page_fault_handler
    csrw mtvec, t5
   
    mret

supervisor:
################## Setting up page tables ##############
    # Set value in PTE2 (Initial Mapping)
    li a0,0x81000000
    li a1, 0x82000
    slli a1, a1, 0xa
    ori a1, a1, 0x01 # | - | - | - |V
    sd a1, 16(a0)

    # To set V.A 0x0 -> P.A 0x0
    li a1, 0x82001
    slli a1, a1, 0xa
    ori a1, a1, 0x01 # | - | - | - |V
    sd a1, 0(a0)

    # Set value in PTE1 (Initial Mapping)
    li a0,0x82000000
    li a1, 0x83000
    slli a1, a1, 0xa
    ori a1, a1, 0x01 # | - | - | - |V
    sd a1, 0(a0)

    # Set Frame number in PTE0 (Initial Mapping)
    li a0,0x83000000
    li a1, 0x80000
    slli a1, a1, 0xa
    ori a1, a1, 0xef # D | A | G | - | X | W | R |V
    sd a1, 0(a0)

    li a1, 0x80001
    slli a1, a1, 0xa
    ori a1, a1, 0xef # D | A | G | - | X | W | R |V
    sd a1, 8(a0)

    # Set value in PTE1 (Code Mapping)
    li a0,0x82001000
    li a1, 0x83001
    slli a1, a1, 0xa
    ori a1, a1, 0x01 # | - | - | - |V
    sd a1, 0(a0)
 
    # Set value in PTE0 (Code Mapping)
    li a0,0x83001000
    li a1, 0x80001
    slli a1, a1, 0xa
    ori a1, a1, 0xfb # D | A | G | U | X | - | R |V
    sd a1, 0(a0)

    # Data Mapping
    li a1, 0x80002
    slli a1, a1, 0xa
    ori a1, a1, 0xf7 # D | A | G | U | - | W | R |V
    sd a1, 8(a0)
    

####################################################################

    # Prepare jump to user mode
    li t1, 0
    slli t1, t1, 8   #spp_mask
    csrs sstatus, t1

    # Configure satp
    la t1, satp_config 
    ld t2, 0(t1)
    sfence.vma zero, zero
    csrrw zero, satp, t2
    sfence.vma zero, zero

    li t4, 0       # load VA address of user-space code
    csrrw zero, sepc, t4    # set sepc to user code
    
    sret



###################################################################
##################### ADD CODE ONLY HERE  #########################
###################################################################
.align 4
page_fault_handler:

csrr t0,mtval
#t2 contains VPN[0]
srli t0,t0,12
addi t2,t0,0
andi t2,t2,0x1FF
slli t2,t2,3
#t3 contains VPN[1]
srli t0,t0,9
addi t3,t0,0
andi t3,t3,0x1FF
slli t3,t3,3

# since until virtual address 0x400000 is taken care there cant be invalid L2 page entry
# but L1 page table entry can be invalid

    li t0,0x82001000
    add t0,t0,t3

    ld t4,0(t0)
    andi t4,t4,0x1
    li t5,0x1
    beq t4,t5,L1_valid

    # here L1 page table entry is not valid
    # create new L0 page table
        la a0,next_page
        ld a1,0(a0)
        addi a2,a1,1
        sd a2,0(a0)
        addi t4,a1,0
        #t4 contains L0 page table address
        slli a1,a1,10
        ori a1,a1,0x01
        sd a1,0(t0)
        j L1_isvalid

    L1_valid:
        ld t4,0(t0)
        srli t4,t4,10
        # andi t4,t4,0xfffffffffff
        # here t4 contains the L0 page table address
    L1_isvalid:

# here
# suppose L1 page entry is not valid we created L0 page table,put its address to t4 and modified the Li page entry
# L1 page is valid simply get L0 page table address and is put to t4
# finally t4 contains the address L0 page table
csrr a0,mcause
li a1,12
beq a0,a1,instruction_fault

#since its page fault we definitely create new instruction page or map data page
data_fault:
    addi t0,t4,0
    slli t0,t0,12
    add t0,t0,t2
    #t0 contains the address of L0 entry
    #mapping L0 entry
    li a0,0x80002
    slli a0,a0,10
    addi a0,a0,0xf7
    sd a0,0(t0)

    j exit

instruction_fault:
        addi t0,t4,0
        slli t0,t0,12
        add t0,t0,t2
        # t0 contains the address of L0 entry
        # mapping L0 entry
        la a0,next_page
        ld a1,0(a0)
        addi a2,a1,1
        sd a2,0(a0)

        addi a0,a1,0
        slli a1,a1,10
        ori a1, a1, 0xfb
        sd a1,0(t0)

        slli t0,a0,12
        li t1,0x80001000
        li t2,0x80002000

        loop:
            beq t1,t2,loop_end
            ld a1,0(t1)
            sd a1,0(t0)
            addi t0,t0,8
            addi t1,t1,8
            j loop
        loop_end:

exit:
    mret

###################################################################
###################################################################

.align 12
user_code:
    la t1,var_count
    lw t2, 0(t1)
    addi t2, t2, 1
    sw t2, 0(t1)

    la t5, code_jump_position
    lw t3, 0(t5)
    li t4, 0x2000
    add t3, t3, t4
    sw t3, 0(t5)
    
    jalr x0, t3


.data
.align 12
var_count:  .word  0
code_jump_position: .word 0x0000
next_page:.word 0x80003


.align 8
# Value to set in satp
satp_config: .dword 0x8000000000081000

