#!/bin/bash

APP=$1
OUTDIR=output

if [ -z "$APP" ]; then
  echo "Usage: ./build.sh <filename_without_extension>"
  exit 1
fi

rm -rf $OUTDIR
mkdir -p $OUTDIR

riscv64-unknown-elf-gcc -march=rv32e -mabi=ilp32e \
  -nostdlib -nostartfiles -nodefaultlibs \
  -T link.ld \
  -o $OUTDIR/${APP}.elf ${APP}.c

riscv64-unknown-elf-objdump -D -s $OUTDIR/${APP}.elf > $OUTDIR/${APP}.dump

elf2hex 4 4096 $OUTDIR/${APP}.elf 0 > $OUTDIR/${APP}.hex

awk '{ 
  printf "%s\n", substr($0, 7, 2) >> "'"$OUTDIR"'/bank0.hex";
  printf "%s\n", substr($0, 5, 2) >> "'"$OUTDIR"'/bank1.hex";
  printf "%s\n", substr($0, 3, 2) >> "'"$OUTDIR"'/bank2.hex";
  printf "%s\n", substr($0, 1, 2) >> "'"$OUTDIR"'/bank3.hex";
}' $OUTDIR/${APP}.hex
