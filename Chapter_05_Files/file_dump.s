# PURPOSE: Demonstrate .bss by opening a file, reading 100 bytes,
#          and writing them to STDOUT.
#
# INPUT:   ./file_dump <filename>
# OUTPUT:  Prints the first 100 bytes of the file.

.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

.equ O_RDONLY, 0
.equ STDOUT, 1
.equ LINUX_SYSCALL, 0x80

# ------- THE .BSS SECTION -------
.section .bss
.equ BUFFER_SIZE, 100
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .data
filename:
    .ascii "test_input.txt\0"

.section .text
.globl _start
_start:
    # 1. OPEN THE FILE (HARDCODED)
    movl $SYS_OPEN, %eax
    movl $filename, %ebx       # Use the label directly
    movl $O_RDONLY, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

    cmpl $0, %eax
    jl error_exit

    movl %eax, %ebx

    # 2. READ 100 BYTES
    movl $SYS_READ, %eax
    movl $BUFFER_DATA, %ecx
    movl $BUFFER_SIZE, %edx
    int $LINUX_SYSCALL

    movl %eax, %edx

    # 3. WRITE
    movl $SYS_WRITE, %eax
    movl $STDOUT, %ebx
    movl $BUFFER_DATA, %ecx
    int $LINUX_SYSCALL

    # 4. CLOSE
    movl $SYS_CLOSE, %eax
    int $LINUX_SYSCALL

    # 5. EXIT
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

error_exit:
    movl $SYS_EXIT, %eax
    movl $1, %ebx
    int $LINUX_SYSCALL