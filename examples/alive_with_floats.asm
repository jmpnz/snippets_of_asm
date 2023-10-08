section .data
    msg1 db "Hello, World!",10,0 ; string with new line
    msg1Len equ $-msg1-1 ; len(msg1) - 1
    msg2 db "Alice and Kicking!", 10, 0; string with new line
    msg2Len equ $-msg2-1 ; len(msg2) - 1
    radius dq 357
    pi dq 3.14

    fmtstr db "%s", 10, 0 ; format specifier for strings
    fmtflt db "%lf", 10, 0 ; format specifier for float
    fmtint db "%d", 10, 0; format specifier for integer
section .bss
section .text
extern printf
    global main
main:
    push rbp; save rbp
    mov rbp, rsp ; use rsp as frame pointer
    mov rax, 0
    mov rdi, fmtstr
    mov rsi, msg1
    call printf
    mov rax, 0
    mov rdi, fmtstr
    mov rsi, msg2
    call printf

    mov rax, 0
    mov rdi, fmtint
    mov rsi, [radius]
    call printf

    mov rax, 1 ; 1 xmm register is used
    movq xmm0, [pi]
    mov rdi, fmtflt
    call printf
    mov rsp, rbp
    pop rbp ; restore frame pointer
    ret

