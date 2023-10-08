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
    mov rbx, 1 ; loop counter start at 1
    mov rax, 0 ; sum in rax
jloop:
    add rax, rbx ; increment rax by rbx content
    inc rbx ; increment loop counter
    cmp rbx, [number] ; test if we reached number
    jle jloop ; if not reached goback to jloop
    ; if reached
    mov rdi, fmt ;setup printf args
    mov rsi, [number];
    mov rdx, rax;
    mov rax, 0
    call printf
    mov rsp, rbp
    pop rbp
    ret
