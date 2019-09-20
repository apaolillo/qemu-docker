/*
 * This code must be at the beginning of the executable.
 * Indeed, if:
 *  1. the ELF file is converted into binary
 *  2. this the binary that is loaded by the boot loader (U-Boot/QEMU)
 *  3. there is no way to provide the entry point address to the boot loader
 * The bootloader will probably assume that the entry point is the first
 * instruction of the binary.
 */
.section .boot.text.start, "ax"

/*
 * Disable interrupts and jumps to C startup code.
 */
.global start
start:
    cpsid   i, #0x13                /* Switch to kernel mode and disable interrupts. */
    ldr     sp, =_boot_stack_top    /* Load kernel stack start. */
    bl      main                    /* Call main function. */
idle:
    b       idle                    /* Loop forever when the program is over. */
