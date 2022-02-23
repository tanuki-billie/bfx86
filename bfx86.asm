; Oh look, it's a brainfuck interpreter / compiler in x86 ASM.
; I didn't write this with much optimization in mind, to be quite honest.

section .data
; Constants, gotta love 'em.
; Call codes
SYS_read        equ       0
SYS_write       equ       1
SYS_open        equ       2
SYS_close       equ       3
SYS_exit        equ      60

; Arguments for syscalls
EXIT_success    equ       0
STDIN           equ       0
STDOUT          equ       1
O_RDONLY        equ 000000q

; Interpreter constants
CELL_COUNT      equ   30000
BUFFER_SIZE     equ  100000

; Character constants
LF              db       10
NULL            equ       0

section .bss

; Uninitialized data.
; This is where we store interpreter cells and file data.
cells           resb  CELL_COUNT
fileBuffer      resb  BUFFER_SIZE

section .text
global _start
_start:
; The first thing we pop off of the stack is argc. We can use this value to see if we need to terminate immediately.
    pop rsi
    cmp rsi, 2
    jne exit

; Okay, we have two arguments. Let's hope that the second one is actually a usable argument
    pop rsi
skipFirstArg:
; Lots of stuff going on here, but step by step:
; Checks if the current byte is zero.
    mov al, byte[rsi]
    test al, al
; Pushes the flags to the stack
    pushf
; Increments our register
    inc rsi
; Pops the flags back into the flags register
    popf
; And loops if our byte is not zero
    jnz skipFirstArg
; At this point, rsi contains the file that needs to be read.

openFile:
    mov rax, SYS_open
    mov rdi, rsi
    mov rsi, O_RDONLY
    syscall

; If negative, the resulting function should have OF as zero and SF as one
; But, we can't use jl since the jump would be too far, so we use jge instead
    push rax
    test rax, rax
    jge readFile
    jmp exit

readFile:
    mov rax, SYS_read
    pop rdi
    lea rsi, byte[fileBuffer]
    mov rdx, BUFFER_SIZE
    syscall

; Again, check for errors
    test rax, rax
    jge interpreterStart
    jmp exit

interpreterStart:
; We did it reddit!
; Move a NULL character at the end so that we don't have to worry about it later
    mov rsi, fileBuffer
    mov byte[rsi + rax], NULL

; Initialize all values in the cells array to zero.
    mov rax, cells
    mov rcx, CELL_COUNT
initializeCells:
    mov byte[rax], 0
    inc rax
    loop initializeCells

; Setup our registers for interpreter action :)
; rdi contains the file text, rsi contains the cell buffer
    xor eax, eax
    lea rdi, byte[fileBuffer]
    lea rsi, byte[cells]

; And now, we can interpret everything character by character
interpreter:
; First, we'll get the character that we intend to use.
    mov al, byte[rdi]

; Before we do anything, we set up rcx as a scratch register.
    xor ecx, ecx

; Move left?
    cmp al, '<'
    je move_left

; Move right
    cmp al, '>'
    je move_right

; Increment current cell?
    cmp al, '+'
    je increment

; Decrement current cell?
    cmp al, '-'
    je decrement

; Output current cell?
    cmp al, '.'
    je output

; Input to current cell
    cmp al, ','
    je input

; Beginning loop
    cmp al, '['
    je loop_left_bracket

; Ending loop
    cmp al, ']'
    je loop_right_bracket

; Unknown character, just go to the end
    jmp interpreter_loop_end

move_left:
    dec rsi
    jmp interpreter_loop_end

move_right:
    inc rsi
    jmp interpreter_loop_end

increment:
    inc byte[rsi]
    jmp interpreter_loop_end

decrement:
    dec byte[rsi]
    jmp interpreter_loop_end

output:
    push rdi
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rdx, 1
    syscall

    pop rdi
    jmp interpreter_loop_end

input:
    mov al, byte[rdi+1]
    test al, al
    jz interpreter_loop_end

    push rdi
    mov rax, SYS_read
    mov rdi, STDIN
    mov rdx, 1
    syscall

    pop rdi
    jmp interpreter_loop_end

loop_left_bracket:
    mov al, byte[rsi]
    test al, al
    jnz interpreter_loop_end

left_bracket_search:
; We want to find the *matching* right bracket. We use rcx as a counter - [ increments, ] decrements
; If we find a ] with the counter equaling zero, that's our matching bracket.
    inc rdi
    mov al, byte[rdi]
    cmp al, '['
    jne left_bracket_search2
    inc rcx
left_bracket_search2:
    cmp al, ']'
    jne left_bracket_search3
; First, if our counter is zero, we're done
    test rcx, rcx
    jz interpreter_loop_end
; Otherwise, decrement
    dec rcx
left_bracket_search3:
; If we're here, just move on
    jmp left_bracket_search

loop_right_bracket:
    mov al, byte[rsi]
    test al, al
    jz interpreter_loop_end

right_bracket_search:
; We want to find the *matching* left bracket. We use rcx as a counter - ] increments, [ decrements
; If we find a [ with the counter equaling zero, that's our matching bracket.
    dec rdi
    mov al, byte[rdi]
    cmp al, ']'
    jne right_bracket_search2
    inc rcx
right_bracket_search2:
    cmp al, '['
    jne right_bracket_search3
; First, if our counter is zero, we're done
    test rcx, rcx
    jz interpreter_loop_end
; Otherwise, decrement
    dec rcx
right_bracket_search3:
; If we're here, just move on
    jmp right_bracket_search

interpreter_loop_end:
    inc rdi
    mov al, byte[rdi]
    test al, al
    jz end_interpreting
    jmp interpreter

end_interpreting:
; Probably want to print a linefeed
    ; mov rax, SYS_write
    ; mov rdi, STDOUT
    ; mov rsi, LF
    ; mov rdx, 1
    ; syscall

; Exit program
exit:
    mov rax, SYS_exit
    mov rdi, EXIT_success
    syscall