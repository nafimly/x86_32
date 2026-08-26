# edi: store the index of the current item
# ebx: store the maximum value found so far
# eax: store the current item being compared

.section .data
data_items:
    .long 3, 12, 5, 35, 2, 53, 89, 64, 13, 18, 22, 6, 7, 23, 102, 0

.section .text
.globl _start

_start:
    movl $0, %edi

    movl data_items(,%edi,4), %eax
    movl %eax, %ebx

iter:
    cmpl $0, %eax
    je done

    incl %edi
    movl data_items(,%edi,4), %eax

    cmpl %ebx, %eax
    jle iter

    movl %eax, %ebx
    jmp iter

done:
    movl $1, %eax
    int $0x80
