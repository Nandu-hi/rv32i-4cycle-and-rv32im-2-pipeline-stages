MEMORY {
  BRAM (rxw) : ORIGIN = 0x00000000, LENGTH = 0x3200  /* 12.5 KB */
}

_estack = ORIGIN(BRAM) + LENGTH(BRAM);    /* 0x3200 */
_stack_size = 0x200;                      /* 512 bytes stack */
_stack_bottom = _estack - _stack_size;    /* 0x3000 */

ENTRY(_start)

SECTIONS {
.text : {
    *(.text._start)     /* early startup */
    *(.text*)           /* application code */
  } > BRAM
  
  .rodata : {
    *(.rodata*)
  } > BRAM

  .data : {
    *(.data*)
  } > BRAM

  .bss : {
    *(.bss*)
    *(COMMON)
  } > BRAM

  /* Stack is not used in .stack section, but we define its symbols */
}

