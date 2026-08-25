# fibonacci_recursive_full.s
# Compile: gcc -m32 -o fibonacci fibonacci_recursive_full.s
# Run: ./fibonacci

.section .data
    prompt:     .asciz "Enter a number: "
    result_msg: .asciz "Fibonacci(%d) = %d\n"
    format_in:  .asciz "%d"
    
.section .bss
    .lcomm input_num, 4
    
.section .text
    .globl main
    
main:
    # Print prompt
    movl $4, %eax              # sys_write
    movl $1, %ebx              # stdout
    leal prompt, %ecx          # message pointer
    movl $16, %edx             # message length
    int $0x80
    
    # Read input using scanf (simpler)
    pushl $input_num           # argument: pointer to input_num
    pushl $format_in           # argument: "%d"
    call scanf
    addl $8, %esp              # clean stack
    
    # Save input
    movl input_num, %ebx
    
    # Check for negative input (error handling)
    cmpl $0, %ebx
    jl .negative_input
    
    # Call fibonacci function
    pushl input_num            # push argument
    call fibonacci             # call function
    addl $4, %esp              # clean stack
    
    # Print result
    pushl %eax                 # push result (second arg)
    pushl %ebx                 # push input (first arg)
    pushl $result_msg          # push format string
    call printf
    addl $12, %esp             # clean stack
    
    # Exit
    jmp .exit

.negative_input:
    # Handle negative input - just use absolute value for simplicity
    negl %ebx
    movl %ebx, input_num
    
    # Call fibonacci
    pushl input_num
    call fibonacci
    addl $4, %esp
    
    # Print result
    pushl %eax
    pushl %ebx
    pushl $result_msg
    call printf
    addl $12, %esp

.exit:
    movl $1, %eax              # sys_exit
    xorl %ebx, %ebx            # return 0
    int $0x80

# Function: fibonacci
# Input: parameter on stack (n)
# Output: return value in %eax
.type fibonacci, @function
fibonacci:
    # Prologue
    pushl %ebp
    movl %esp, %ebp
    
    # Get n from stack
    movl 8(%ebp), %eax
    
    # Base case: if n <= 1, return n
    cmpl $1, %eax
    jle .base_case
    
    # Recursive case: fib(n-1) + fib(n-2)
    
    # Calculate fib(n-1)
    movl %eax, %ecx            # save n
    decl %eax                  # n-1
    pushl %eax                 # push n-1
    call fibonacci
    addl $4, %esp              # clean stack
    movl %eax, %edx            # save fib(n-1)
    
    # Calculate fib(n-2)
    movl %ecx, %eax            # restore n
    subl $2, %eax              # n-2
    pushl %eax                 # push n-2
    call fibonacci
    addl $4, %esp              # clean stack
    
    # Add the two results
    addl %edx, %eax
    
    # Epilogue and return
    jmp .done
    
.base_case:
    # For n <= 1, just return n (already in eax)
    
.done:
    movl %ebp, %esp
    popl %ebp
    ret

# External functions
.extern printf
.extern scanf
