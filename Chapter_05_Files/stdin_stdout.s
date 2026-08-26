# PURPOSE: Read from STDIN, convert to uppercase, write to STDOUT
#          (Like a filter!)
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_EXIT, 1
.equ STDIN, 0
.equ STDOUT, 1
.equ LINUX_SYSCALL, 0x80
.equ END_OF_FILE, 0

.section .bss
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text
.globl _start             # FIX 1: Change main to _start
_start:

read_loop_begin:
    # Read from STDIN
    movl $SYS_READ, %eax
    movl $STDIN, %ebx          
    movl $BUFFER_DATA, %ecx    
    movl $BUFFER_SIZE, %edx    
    int $LINUX_SYSCALL

    cmpl $END_OF_FILE, %eax    
    jle end_loop

    # Convert to uppercase
    pushl %eax            # FIX 2: Push length first (goes to 12(%ebp))
    pushl $BUFFER_DATA    # Push address second (goes to 8(%ebp))
    call convert_to_upper
    
    # FIX 3: Clean up the stack and prepare for SYS_WRITE
    addl $4, %esp         # Remove BUFFER_DATA from the stack
    popl %edx             # Pop the length directly into %edx for writing!

    # Write to STDOUT
    movl $SYS_WRITE, %eax
    movl $STDOUT, %ebx         
    movl $BUFFER_DATA, %ecx
    int $LINUX_SYSCALL

    jmp read_loop_begin

end_loop:
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

# --- Your convert_to_upper function remains completely unchanged ---
convert_to_upper:
    pushl %ebp
    movl %esp, %ebp
    .equ LOWERCASE_A, 'a'
    .equ LOWERCASE_Z, 'z'
    .equ UPPER_CONVERSION, 'A' - 'a'
    movl 8(%ebp), %eax
    movl 12(%ebp), %ebx
    movl $0, %edi
    cmpl $0, %ebx
    je end_convert_loop
convert_loop:
    movb (%eax, %edi, 1), %cl
    cmpb $LOWERCASE_A, %cl
    jl next_byte
    cmpb $LOWERCASE_Z, %cl
    jg next_byte
    addb $UPPER_CONVERSION, %cl
    movb %cl, (%eax, %edi, 1)
next_byte:
    incl %edi
    cmpl %edi, %ebx
    jne convert_loop
end_convert_loop:
    movl %ebp, %esp
    popl %ebp
    ret