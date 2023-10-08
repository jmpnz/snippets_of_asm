extern printf
extern gettimeofday

section .data
    fmt db "Seconds since Jan 1, 1970: %ld", 10, 0h
section .bss
    timeval resq 2

section .text
    global main

main:
    push rbp
    mov rbp, rsp

    mov rdi, timeval
    mov rsi, 0
    call gettimeofday
    mov rax, [timeval]
    mov rdi, fmt
    mov rsi, rax
    call printf

    leave
    ret

