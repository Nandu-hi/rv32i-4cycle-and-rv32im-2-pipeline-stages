OUTPUT_ARCH( "riscv" )
ENTRY( _start )

SECTIONS
{
  . = 0x80000000;

  .text : {
    *(.text)           /* Take all .text sections from all files and put them here */
  }

  .data : {
    *(.data)
  }

  .bss : {
    *(.bss)
  }
}

