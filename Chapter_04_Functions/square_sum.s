.section .data
.section .text

.globl main
main:
    # Call cubic for 2
    pushl $2
    call cubic
    addl $4, %esp
    movl %eax, %ebx

    # Call cubic for 3
    pushl $3
    call cubic
    addl $4, %esp
    addl %eax, %ebx     

    # Call cubic for 4
    pushl $1
    call cubic
    addl $4, %esp
    addl %eax, %ebx     

    # Exit with the result in %ebx
    movl $1, %eax
    int $0x80


.type cubic, @function
cubic:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %eax

    movl %eax, %ebx
    imull %ebx, %eax
    imull %ebx, %eax

    movl %ebp, %esp
    popl %ebp
    ret
