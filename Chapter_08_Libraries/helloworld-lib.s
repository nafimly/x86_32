.include "linux.s"

.section .data
helloworld:
    .ascii "Hello World!\n\0"

.section .text
.globl _start
_start:
    # Push the address of our string onto the stack
    pushl $helloworld
    
    # Call the printf function from libc!
    call printf
    
    # Clean up the stack (1 argument * 4 bytes)
    addl $4, %esp
    
    # Call the exit function from libc
    pushl $0
    call exit
