    .section .init
    .globl _start
    .option norvc        /* avoid compressed if your core doesn't support it */

_start:
    /* -------------------------------------------------
     * Set up stack pointer
     * ------------------------------------------------- */
    la      sp, __stack_top

    /* -------------------------------------------------
     * Clear .bss
     * ------------------------------------------------- */
    la      t0, __bss_start
    la      t1, __bss_end

bss_clear_loop:
    bgeu    t0, t1, bss_clear_done
    sw      zero, 0(t0)
    addi    t0, t0, 4
    j       bss_clear_loop

bss_clear_done:

    /* -------------------------------------------------
     * Call main()
     * ------------------------------------------------- */
    call    main

    /* -------------------------------------------------
     * If main returns, trap forever
     * ------------------------------------------------- */
hang:
    j       hang

