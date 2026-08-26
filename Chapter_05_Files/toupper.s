# PURPOSE: This program converts all lowercase characters 
#          in a file to uppercase.
#
# INPUT:   ./toupper <input_file> <output_file>
# OUTPUT:  Writes the uppercase version to the output file
#
# CONSTANTS
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101   # 0101 in octal: Create, Write-only, Truncate

.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.equ LINUX_SYSCALL, 0x80
.equ END_OF_FILE, 0
.equ NUMBER_ARGUMENTS, 2

.section .bss
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text

# STACK POSITIONS
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0
.equ ST_ARGV_0, 4
.equ ST_ARGV_1, 8
.equ ST_ARGV_2, 12

.globl main
main:
    ### INITIALIZE PROGRAM ###
    movl %esp, %ebp              # Save the initial stack pointer
    subl $ST_SIZE_RESERVE, %esp  # Make room for our file descriptors

open_files:
    ### OPEN INPUT FILE ###
    movl $SYS_OPEN, %eax
    movl ST_ARGV_1(%ebp), %ebx   # Filename is the first argument
    movl $O_RDONLY, %ecx         # Open for reading
    movl $0666, %edx             # Permissions (not used for reading)
    int $LINUX_SYSCALL

    # Save the returned file descriptor (or error) on the stack
    movl %eax, ST_FD_IN(%ebp)

    ### OPEN OUTPUT FILE ###
    movl $SYS_OPEN, %eax
    movl ST_ARGV_2(%ebp), %ebx   # Filename is the second argument
    movl $O_CREAT_WRONLY_TRUNC, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

    # Save the returned file descriptor (or error) on the stack
    movl %eax, ST_FD_OUT(%ebp)

### MAIN LOOP ###
read_loop_begin:
    ### READ A BLOCK FROM THE INPUT FILE ###
    movl $SYS_READ, %eax
    movl ST_FD_IN(%ebp), %ebx    # Read from our input descriptor
    movl $BUFFER_DATA, %ecx      # Read into our buffer
    movl $BUFFER_SIZE, %edx      # Read up to 500 bytes
    int $LINUX_SYSCALL

    # %eax now holds the number of bytes read (or 0, or negative error)
    
    ### EXIT IF WE'VE REACHED THE END ###
    cmpl $END_OF_FILE, %eax      # Check if it's 0
    jle end_loop                 # If <= 0, we are done (or there's an error)

continue_read_loop:
    ### CONVERT THE BLOCK TO UPPER CASE ###
    pushl $BUFFER_DATA           # Address of the buffer (2nd arg)
    pushl %eax                   # Size of the buffer (1st arg)
    call convert_to_upper
    popl %eax                    # Get the size back
    addl $4, %esp                # Restore %esp

    ### WRITE THE BLOCK OUT TO THE OUTPUT FILE ###
    movl %eax, %edx              # Size of the buffer
    movl $SYS_WRITE, %eax
    movl ST_FD_OUT(%ebp), %ebx   # Write to our output descriptor
    movl $BUFFER_DATA, %ecx      # Address of the buffer
    int $LINUX_SYSCALL

    ### CONTINUE THE LOOP ###
    jmp read_loop_begin

end_loop:
    ### CLOSE THE FILES ###
    movl $SYS_CLOSE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_CLOSE, %eax
    movl ST_FD_IN(%ebp), %ebx
    int $LINUX_SYSCALL

    ### EXIT ###
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

# PURPOSE: Function to convert a buffer to uppercase
# INPUT:   The first parameter is the location of the buffer
#          The second parameter is the size of the buffer
# OUTPUT:  None (it modifies the buffer in place)
.type convert_to_upper, @function
convert_to_upper:
    pushl %ebp
    movl %esp, %ebp

    # Constants for the function
    .equ LOWERCASE_A, 'a'
    .equ LOWERCASE_Z, 'z'
    .equ UPPER_CONVERSION, 'A' - 'a'    # This is -32

    # Grab the parameters
    movl 8(%ebp), %eax          # Buffer address
    movl 12(%ebp), %ebx         # Buffer length
    movl $0, %edi               # Current index in buffer

    # Sanity check: If buffer length is 0, leave
    cmpl $0, %ebx
    je end_convert_loop

convert_loop:
    # Grab the current byte
    movb (%eax, %edi, 1), %cl
    
    # Check if it's between 'a' and 'z'
    cmpb $LOWERCASE_A, %cl
    jl next_byte
    cmpb $LOWERCASE_Z, %cl
    jg next_byte

    # It is lowercase! Convert it.
    addb $UPPER_CONVERSION, %cl
    movb %cl, (%eax, %edi, 1)

next_byte:
    incl %edi
    cmpl %edi, %ebx             # Continue unless we've reached the end
    jne convert_loop

end_convert_loop:
    movl %ebp, %esp
    popl %ebp
    ret