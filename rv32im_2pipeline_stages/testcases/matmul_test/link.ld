/* RV32E Harvard SoC Linker Script (NO HEAP)
 *
 * I-mem (code only): 0x00000000 - 0x00003FFF (16 KB)
 * D-mem (data only): 0x00004000 - 0x00007FFF (16 KB)
 */

ENTRY(_start)

MEMORY
{
    IMEM (rx)   : ORIGIN = 0x00000000, LENGTH = 16K
    DMEM (rwx)  : ORIGIN = 0x00004000, LENGTH = 16K
}

/* 16-byte aligned stack at top of D-mEM */
__stack_top = (ORIGIN(DMEM) + LENGTH(DMEM)) & ~0xF;

SECTIONS
{
    /* ---------- CODE (I-MEM ONLY) ---------- */
    .text :
    {
        KEEP(*(.init))
        KEEP(*(.vectors*))
        *(.text .text.*)
        /* NO rodata here — code only */
    } > IMEM

    /* ---------- DATA + CONST (D-MEM) ---------- */
    /* VMA == LMA: loader must pre-initialize DMEM */
    .data :
    {
        _sdata = .;

        *(.data .data.*)
        *(.sdata .sdata.*)

        /* All constants explicitly in DMEM */
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)

        . = ALIGN(4);
        _edata = .;
    } > DMEM

    /* ---------- BSS (D-MEM) ---------- */
    .bss (NOLOAD) :
    {
        _sbss = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > DMEM

    /* ---------- NO HEAP ---------- */
    /* malloc/new are forbidden on this system */

    /* ---------- DISCARD ---------- */
    /DISCARD/ :
    {
        *(.comment*)
        *(.riscv.attributes)
    }

    /* ---------- Symbols for startup ---------- */
    PROVIDE(__bss_start = _sbss);
    PROVIDE(__bss_end   = _ebss);
}
