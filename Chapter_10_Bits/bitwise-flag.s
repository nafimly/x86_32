.include "linux.s"

# Define the flags
.equ FLAG_DOG, 1       # 0b00001
.equ FLAG_CAT, 2       # 0b00010
.equ FLAG_BIRD, 4      # 0b00100
.equ FLAG_FISH, 8      # 0b01000
.equ FLAG_HAMSTER, 16  # 0b10000

.section .data
has_bird_msg:
    .ascii "Has a bird!\n\0"
no_bird_msg:
    .ascii "No bird.\n\0"

.section .text
.globl _start
_start:
    # Let's say this person has a dog and a bird.
    # We use OR to combine the flags.
    movl $0, %ebx
    orl $FLAG_DOG, %ebx
    orl $FLAG_BIRD, %ebx
    # %ebx is now 5

    # Now, let's check if they have a bird.
    # We do this by ANDing with the FLAG_BIRD mask.
    movl %ebx, %eax
    andl $FLAG_BIRD, %eax

    # The result is either 0 (False) or 4 (True).
    # Let's check if it's zero.
    cmpl $0, %eax
    je no_bird

has_bird:
    # Write "Has a bird!" to the screen
    pushl $has_bird_msg
    call count_chars
    addl $4, %esp

    movl %eax, %edx
    movl $SYS_WRITE, %eax
    movl $STDOUT, %ebx
    movl $has_bird_msg, %ecx
    int $LINUX_SYSCALL

    jmp exit_program

no_bird:
    # Write "No bird." to the screen
    pushl $no_bird_msg
    call count_chars
    addl $4, %esp

    movl %eax, %edx
    movl $SYS_WRITE, %eax
    movl $STDOUT, %ebx
    movl $no_bird_msg, %ecx
    int $LINUX_SYSCALL

exit_program:
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL