#!/bin/bash
../../../beebasm/beebasm -v -i ../../../Beeb1MHzBusFpga/misc/loader/loader.asm
cat loader.bin MANDEL3.bin > rom.bin
truncate -s 4096 rom.bin
od -An -tx1 -w1 -v rom.bin  | tr -d " " > rom.dat
