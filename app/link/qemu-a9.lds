ENTRY(start)

/* Cortex-A9 QEMU start RAM */
PHYS_BASE = 0x00000000;

/* Qemu loads the kernel 64K after the start of memory */
PHYS_LOAD = PHYS_BASE + 64K;

_boot_stack_top = PHYS_BASE + 0x00200000; /* TODO TMP CHECK */

SECTIONS
{
    . = PHYS_LOAD;
    .text : {
            * (vectors)
            * (.boot.text.start*)
            * (.text)
            * (.rodata)
    }
    .data : { * (.data); }
}
