#!/bin/bash

APP=$1
OUTDIR=output

if [ -z "$APP" ]; then
  echo "Usage: ./build.sh <filename_without_extension>"
  exit 1
fi

rm -rf $OUTDIR
mkdir -p $OUTDIR

riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 \
  -nostdlib -nostartfiles -nodefaultlibs \
  -T link.ld \
  -o $OUTDIR/${APP}.elf  start.S ${APP}.c

riscv32-unknown-elf-objdump -D -s $OUTDIR/${APP}.elf > $OUTDIR/${APP}.dump

elf2hex 4 8192 $OUTDIR/${APP}.elf 0 > $OUTDIR/${APP}.hex
head -n 4096 $OUTDIR/${APP}.hex > $OUTDIR/imem.hex
tail -n 4096 $OUTDIR/${APP}.hex > $OUTDIR/dmem.hex
awk '{ 
  printf "%s\n", substr($0, 7, 2) >> "'"$OUTDIR"'/dmem_bank0.hex";
  printf "%s\n", substr($0, 5, 2) >> "'"$OUTDIR"'/dmem_bank1.hex";
  printf "%s\n", substr($0, 3, 2) >> "'"$OUTDIR"'/dmem_bank2.hex";
  printf "%s\n", substr($0, 1, 2) >> "'"$OUTDIR"'/dmem_bank3.hex";
}' $OUTDIR/dmem.hex
