# PURPOSE: Program to compute factorial using recursion
#          This program will compute 4! (4 * 3 * 2 * 1 = 24)
#
# INPUT:   None
# OUTPUT:  Returns 24 as the exit status code
#
# NOTES:   The parameter must be 1 or greater

.section .text

.globl main
main:
    # Push the argument for factorial
    pushl $4
    call factorial
    addl $4, %esp       # Clean up the stack parameter

    # The result is now in %eax.
    # Move it to %ebx for the exit syscall
    movl %eax, %ebx

    # Exit!
    movl $1, %eax
    int $0x80

# PURPOSE: Function to compute the factorial of a number
# INPUT:   First argument - the number
# OUTPUT:  Returns the result in %eax
.type factorial, @function
factorial:
    # Standard prologue
    pushl %ebp
    movl %esp, %ebp

    # Move the argument (8(%ebp)) into %eax
    movl 8(%ebp), %eax
    
    # Check the base case: if the number is 1, we are done
    cmpl $1, %eax
    je end_factorial

    # Otherwise, we need to recurse.
    # First, decrease the number by 1
    decl %eax

    # Push the new number onto the stack as the new argument
    pushl %eax
    call factorial      # Recursive call!

    # Move the argument (the original number) back into %ebx
    movl 8(%ebp), %ebx
    imull %ebx, %eax    # %eax = (n-1)! * n

end_factorial:
    # Standard epilogue
    movl %ebp, %esp
    popl %ebp
    ret
