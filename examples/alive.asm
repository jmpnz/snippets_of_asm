section .data
    msg1 db "Hello, World!",10,0 ; string with new line
    msg1Len equ $-msg1-1 ; len(msg1) - 1
    msg2 db "Alice and Kicking!", 10, 0; string with new line
    msg2Len equ $-msg2-1 ; len(msg2) - 1
    radius dq 357
    pi dq 3.14
section .bss
section .text
    global main
main:
    push rbp; save rbp
    mov rbp, rsp ; use rsp as frame pointer
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, msg1Len
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, msg2Len
    syscall
    mov rsp, rbp ; restore stack pointer
    pop rbp ; restore frame pointer
    mov rax, 60
    mov rdi, 0
    syscall

