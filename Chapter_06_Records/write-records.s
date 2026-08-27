.include "linux.s"
.include "record-def.s"

.section .data


record1:
    .ascii "Clara\0"
    .rept (RECORD_LASTNAME - RECORD_FIRSTNAME - 6)
        .byte 0
    .endr

    .ascii "Lovelace\0"
    .rept (RECORD_ADDRESS - RECORD_LASTNAME - 9)
        .byte 0
    .endr

    .ascii "London\0"
    .rept (RECORD_AGE - RECORD_ADDRESS - 7)
        .byte 0
    .endr   

    .long 19

record2:
    .ascii "Yuji\0"
    .rept (RECORD_LASTNAME - RECORD_FIRSTNAME - 5)
        .byte 0
    .endr

    .ascii "Itadori\0"
    .rept (RECORD_ADDRESS - RECORD_LASTNAME - 8)
        .byte 0
    .endr

    .ascii "London\0"
    .rept (RECORD_AGE - RECORD_ADDRESS - 7)
        .byte 0
    .endr   

    .long 15


file_name:
    .ascii "records.dat\0"

.equ ST_FILE_DESCRIPTOR, -4

.section .text
.globl _start
_start:
    movl %esp, %ebp
    subl $4, %ebp

    movl $SYS_OPEN, %eax
    movl $file_name, %ebx
    movl $0101, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

    movl %eax, ST_FILE_DESCRIPTOR(%ebp)

    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record1
    call write_record
    addl $8, %esp

    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record2
    call write_record
    addl $8, %esp

    # Close the file descriptor
    movl $SYS_CLOSE, %eax
    movl ST_FILE_DESCRIPTOR(%ebp), %ebx
    int $LINUX_SYSCALL

    # Exit the program
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
    