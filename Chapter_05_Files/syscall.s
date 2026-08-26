.section .data
.section .text

.globl main
main:
    movl $19, %eax
    int $0x80

    