OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    rom (rx)  : ORIGIN = 0x00000000, LENGTH = 4K
    ram (rwx) : ORIGIN = 0x10000000, LENGTH = 256K
}

SECTIONS
{
    .text :
    {
        *(.text.start)
        *(.text .text.*)
    } > rom

    .rodata :
    {
        *(.rodata .rodata.*)
    } > rom

    .data :
    {
        *(.data .data.*)
    } > ram AT > rom

    .bss :
    {
        *(.bss .bss.*)
        *(COMMON)
    } > ram

    _end = .;
}
