/* RV32E Harvard SoC Linker Script
 * I-mem (code only): 0x00000000 - 0x00003FFF (16 KB)
 * D-mem (data only): 0x00010000 - 0x00013FFF (64 KB)
 */

ENTRY(_start)

MEMORY
{
    IMEM (rx)   : ORIGIN = 0x00000000, LENGTH = 16K
    DMEM (rwx)  : ORIGIN = 0x00004000, LENGTH = 16K
}

/* 16-byte aligned stack at top of D-mem */
__stack_top = (ORIGIN(DMEM) + LENGTH(DMEM)) & ~0xF;

SECTIONS
{
    /* -------- CODE IN I-MEM -------- */
    .text :
    {
        KEEP(*(.init))
        KEEP(*(.vectors*))

        *(.text .text.*)
        /* NO rodata here – code only */
    } > IMEM

    /* -------- ALL INITIALIZED DATA + CONST IN D-MEM -------- */
    /* VMA == LMA, so the loader must pre-init D-mem from ELF/HEX. */
    .data :
    {
        _sdata = .;

        /* standard data */
        *(.data .data.*)
        *(.sdata .sdata.*)

        /* all read-only stuff also in D-mem */
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)

        . = ALIGN(4);
        _edata = .;
    } > DMEM

    /* -------- BSS IN D-MEM -------- */
    .bss (NOLOAD) :
    {
        _sbss = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > DMEM

    /* Optional heap */
    .heap (NOLOAD) :
    {
        __heap_start = .;
    } > DMEM

    /* Drop metadata sections */
    /DISCARD/ :
    {
        *(.comment*)
        *(.riscv.attributes)
    }

    /* Symbols used by startup */
    PROVIDE(__bss_start = _sbss);
    PROVIDE(__bss_end   = _ebss);
}
