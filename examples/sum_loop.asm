extern printf
section .data
    number dq 1000000000
    fmt db "The sum from 0 to %ld is %ld", 10, 0 ; format specifier
section .bss
section .text
    global main
main:
    push rbp
    mov rbp, rsp
    mov rcx, [number] ; set loop counter at number (going backwards)
    mov rax, 0 ; sum in rax
bloop:
    add rax, rcx ; increment rax by rcx content
    loop bloop ; loop while decreasing rcx by until rcx = 0
    ; if reached
    mov rdi, fmt ;setup printf args
    mov rsi, [number];
    mov rdx, rax;
    mov rax, 0
    call printf
    mov rsp, rbp
    pop rbp
    ret
