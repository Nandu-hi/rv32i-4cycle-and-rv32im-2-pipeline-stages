// simualation of privilege modes
.section .text
.global main
main:
//mstatus
li t0,0
slli t1,t0,12
add t2,t1,x0

slli t1,t0,11
add t2,t2,t1

slli t1,t0,7
add t2,t2,t1

slli t1,t0,3
add t2,t2,t1
csrrs x0,mstatus,t2

//mepc
la t1,ucode
csrrw x0,mepc,t1
//mtvec
la t1,mtrap_handler
csrrw x0,mtvec,t1
//stvec
la t1,strap_handler
csrrw x0,stvec,t1
//medeleg
li t1,1
slli t1,t1,8
csrrw x0,medeleg,t1

# Configure CSR registers (medeleg, mstatus, mepc, mtvec, stvec)
# Execute mret to initiate downward transition to User code
mret


.align 4
mtrap_handler:
# Process traps originating from the strap_handler
mul a1,a1,a2
# Perform the multiplication operation
li a0,0
# Flip a0 to 0

la t1,strap_handler
csrrw x0,mepc,t1
# Set mepc back to strap_handler and execute mret
mret

scode:

    li t0,0
    slli t1,t0,12
    add t2,t1,x0

    slli t1,t0,11
    add t2,t2,t1

    slli t1,t0,7
    add t2,t2,t1

    slli t1,t0,3
    add t2,t2,t1
    csrrs x0,sstatus,t2

    la t1,ucode1
    csrrw x0,sepc,t1
# Execute sret to initiate transition to User mode after setting the CSRs
    sret

.align 4
strap_handler:
# The Dispatcher
# Check if a0 == 0 or a0 == 1
    beq a0,x0,cond
    ecall
    cond:
        j scode
# If a0 == 0: jump to scode (to setup S to U transition)
# If a0 == 1: execute ecall to jump up to mtrap_handler
ucode:
# Note: Handle initial variable loading here if using a single User block
li a0,0
li a1,1
li a2,1
ecall

ucode1:
# Perform the addition operation
add a1,a1,a2
# Flip a0 to 1
li a0,1

# The ecall should invoke the supervisor’s trap handler
ecall