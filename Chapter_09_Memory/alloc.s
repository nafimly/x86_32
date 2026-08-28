.section .data

# points to the beginning of the memory we are managing
heap_begin:
    .long 0
# points to one location past the memory we are managing
current_break:
    .long 0

# Size of space for memory region header
.equ HEADER_SIZE, 8
# Location of the "available" flag in the header
.equ HDR_AVAIL_OFFSET, 0
# Location of the size field in the header
.equ HDR_SIZE_OFFSET, 4

# Constant
.equ UNAVAILABLE, 0    
.equ AVAILABLE, 1      
.equ SYS_BRK, 45       
.equ LINUX_SYSCALL, 0x80


.section .text
.globl allocate_init
.type allocate_init, @function
allocate_init:
    pushl %ebp            
    movl %esp, %ebp

    # If the brk system call is called with 0 in %ebx, it returns the last valid usable address
    movl $SYS_BRK, %eax   
    movl $0, %ebx
    int $LINUX_SYSCALL

    incl %eax             
    movl %eax, current_break 
    movl %eax, heap_begin 

    movl %ebp, %esp       
    popl %ebp
    ret



.globl allocate
.type allocate, @function
# Stack position of the memory size to allocate
.equ ST_MEM_SIZE, 8
allocate:
    pushl %ebp            
    movl %esp, %ebp
    movl ST_MEM_SIZE(%ebp), %ecx  
    movl heap_begin, %eax 
    movl current_break, %ebx 

alloc_loop_begin:
    cmpl %ebx, %eax       
    je move_break

    movl HDR_SIZE_OFFSET(%eax), %edx

    cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    je next_location

    cmpl %edx, %ecx
    jle allocate_here

next_location:
    addl $HEADER_SIZE, %eax
    addl %edx, %eax
    jmp alloc_loop_begin  

allocate_here:
    # leftover = old_size - (requested_size + HEADER_SIZE)
    movl %edx, %edi         
    subl %ecx, %edi        
    subl $HEADER_SIZE, %edi 
    

    cmpl $HEADER_SIZE, %edi
    jl no_split

    # Mark the first part as UNAVAILABLE
    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    
    # Set the size of the first part to the requested size
    movl %ecx, HDR_SIZE_OFFSET(%eax)

    leal HEADER_SIZE(%eax), %esi   # %esi = start of data
    addl %ecx, %esi                # %esi = start of leftover data
    subl $HEADER_SIZE, %esi        

    movl $AVAILABLE, HDR_AVAIL_OFFSET(%esi)
    movl %edi, HDR_SIZE_OFFSET(%esi)
    
    jmp return_block

no_split:
    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    
return_block:
    addl $HEADER_SIZE, %eax
    movl %ebp, %esp
    popl %ebp
    ret

move_break:
    addl $HEADER_SIZE, %ebx   
    addl %ecx, %ebx           

    pushl %eax             
    pushl %ecx
    pushl %ebx

    movl $SYS_BRK, %eax       
    int $LINUX_SYSCALL

    cmpl $0, %eax             
    je error

    popl %ebx                 
    popl %ecx
    popl %eax

    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    movl %ecx, HDR_SIZE_OFFSET(%eax)
    addl $HEADER_SIZE, %eax

    movl %ebx, current_break  

    movl %ebp, %esp           
    popl %ebp
    ret

error:
    movl $0, %eax             
    movl %ebp, %esp
    popl %ebp
    ret


.globl deallocate
.type deallocate, @function
.equ ST_MEMORY_SEG, 4
deallocate:
    movl ST_MEMORY_SEG(%esp), %eax
    subl $HEADER_SIZE, %eax
    movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)
    ret