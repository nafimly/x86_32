.include "linux.s"

# PURPOSE: This function prints an error message and exits
# INPUT:   Stack: Error Code (8(%ebp)), Address of Error Message (12(%ebp))
# OUTPUT:  Exits the program with status 1

.equ ST_ERROR_CODE, 8
.equ ST_ERROR_MSG, 12

.section .text
.globl error_exit
.type error_exit, @function
error_exit:
    pushl %ebp
    movl %esp, %ebp

    # --- Write out error code ---
    movl ST_ERROR_CODE(%ebp), %ecx  # Load address of the error code string into %ecx
    pushl %ecx
    call count_chars
    popl %ecx
    movl %eax, %edx                 # %edx = length of string
    movl $STDERR, %ebx              # %ebx = file descriptor 2
    movl $SYS_WRITE, %eax
    int $LINUX_SYSCALL

    # --- Write out error message ---
    movl ST_ERROR_MSG(%ebp), %ecx   # Load address of the message into %ecx
    pushl %ecx
    call count_chars
    popl %ecx
    movl %eax, %edx                 # %edx = length of string
    movl $STDERR, %ebx
    movl $SYS_WRITE, %eax
    int $LINUX_SYSCALL

    # Write a newline
    pushl $STDERR
    call write_newline
    addl $4, %esp

    # Exit with status 1
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL
    