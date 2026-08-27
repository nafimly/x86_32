.include "linux.s"
.include "record-def.s"

.section .data
input_file_name:
    .ascii "test.dat\0"
output_file_name:
    .ascii "testout.dat\0"

# Error messages
no_open_input_msg:
    .ascii "Error: Cannot open input file\0"
no_open_output_msg:
    .ascii "Error: Cannot open output file\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.section .text
.globl _start
_start:
    # Set up stack frame
    movl %esp, %ebp
    subl $8, %esp
    .equ ST_INPUT_DESCRIPTOR, -4
    .equ ST_OUTPUT_DESCRIPTOR, -8

    # --- OPEN INPUT FILE (WITH ERROR CHECKING) ---
    movl $SYS_OPEN, %eax
    movl $input_file_name, %ebx
    movl $0, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

    # Check for error! If negative, jump to error handler
    cmpl $0, %eax
    jl no_input_file
    movl %eax, ST_INPUT_DESCRIPTOR(%ebp)

    # --- OPEN OUTPUT FILE (WITH ERROR CHECKING) ---
    movl $SYS_OPEN, %eax
    movl $output_file_name, %ebx
    movl $0101, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

    # Check for error!
    cmpl $0, %eax
    jl no_output_file
    movl %eax, ST_OUTPUT_DESCRIPTOR(%ebp)

    # --- MAIN LOOP ---
loop_begin:
    pushl ST_INPUT_DESCRIPTOR(%ebp)
    pushl $record_buffer
    call read_record
    addl $8, %esp

    cmpl $RECORD_SIZE, %eax
    jne loop_end

    # Increment age
    incl record_buffer + RECORD_AGE

    # Write record
    pushl ST_OUTPUT_DESCRIPTOR(%ebp)
    pushl $record_buffer
    call write_record
    addl $8, %esp

    jmp loop_begin

loop_end:
    # Close files and exit
    movl $SYS_CLOSE, %eax
    movl ST_OUTPUT_DESCRIPTOR(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_CLOSE, %eax
    movl ST_INPUT_DESCRIPTOR(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

# --- ERROR HANDLERS ---
no_input_file:
    pushl $no_open_input_msg
    pushl $1
    call error_exit

no_output_file:
    pushl $no_open_output_msg
    pushl $2
    call error_exit
