%include "print.asm"

section .data

datum1: dq 0x1122334455667788
datum2: db 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88

section .text

_start:
    mov rdi, [datum1]
    call print_hex
    call print_newline

    mov rdi, [datum2]
    call print_hex
    call print_newline

    mov rax, 60
    xor rdi, rdi
    syscall

