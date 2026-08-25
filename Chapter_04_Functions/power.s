.section .data

.section .text

.globl main
main:
    # 2^3 = 8
    pushl $2
    pushl $3
    call power
    addl $8, %esp

    pushl %eax

    # 5^2 = 25
    pushl $5
    pushl $2
    call power
    addl $8, %esp

    popl %ebx

    # add the two results together
    addl %ebx, %eax
    movl $1, %eax
    int $0x80

.type power, @function
power:
    pushl %ebp
    movl %esp, %ebp     
    subl $4, %esp       # store local variable

    movl 8(%ebp), %ebx
    movl 12(%ebp), %ecx
    movl %ebx, -4(%ebp) # store first exponent in local variable 

power_loop:
    cmpl $1, %ecx
    je end_power

    movl -4(%ebp), %eax
    imull %ebx, %eax    
    movl %eax, -4(%ebp) 

    decl %ecx
    jmp power_loop

end_power:
    movl -4(%ebp), %eax
    movl %ebp, %esp
    popl %ebp
    ret
