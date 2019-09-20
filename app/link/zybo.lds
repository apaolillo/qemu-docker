ENTRY(start)

SMALLPAGE_SIZE = 0x1000;
KB = 0x400;
MB = KB * KB;
IMAGE_BOOT_PHADDR = 0x00100000;

_boot_stack_top = 0x00200000; /* TODO TMP CHECK */

SECTIONS {
    . = IMAGE_BOOT_PHADDR;
    .text : {
            * (vectors)
            * (.text)
            * (.rodata)
    }
    .data : { * (.data); }

/*    . += ALIGN(MB);
    _boot_stack_bottom = .;
    . = . + 4 * SMALLPAGE_SIZE;
    _boot_stack_top = .;*/
}
