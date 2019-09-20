#!/bin/sh
set -e

NB_CORES=2
MACHINE=mcimx7d-sabre
KERNEL_IMAGE=/u-boot/u-boot-2019.07/u-boot.bin

qemu-system-arm \
    -smp $NB_CORES \
    -nographic \
    -gdb tcp::1234 \
    -kernel $KERNEL_IMAGE \
    -machine $MACHINE \
    -m 2G \
    -serial file:/tmp/uart1.txt \
    -serial file:/tmp/uart2.txt \
    -serial file:/tmp/uart3.txt \
    -serial file:/tmp/uart4.txt \
    -serial file:/tmp/uart5.txt \
    -serial file:/tmp/uart6.txt \
    -serial file:/tmp/uart7.txt \
    $@
