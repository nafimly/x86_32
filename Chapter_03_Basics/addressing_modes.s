.section .data
clar:
    .long 43

.section .text
.globl _start

_start:
    # 1. direct addressing mode
    movl clar, %eax
    movl %eax, %ebx


    # 2.base pointer addressing mode
    leal clar, %ecx
    movl 0(%ecx), %eax
    cmpl %eax, %ebx
    jne fail

    # 3. success
    movl $1, %eax        
    movl $0, %ebx       
    int $0x80


fail:
    movl $1, %eax
    movl $1, %ebx
    int $0x80
