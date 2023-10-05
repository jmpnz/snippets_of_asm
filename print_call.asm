section .data

newline_char: db 10 ; '\n'
codes: db '0123456789abcdef' ; hex characters table

section .text
global _start

print_newline:
    mov rax, 1 ; 'write' syscall identifier
    mov rdi, 1 ; stdout file descriptor
    mov rsi, newline_char ; pointer to the data to write
    mov rdx, 1 ; length in bytes of data to write
    syscall
    ret
print_hex:
    mov rax, rdi
    mov rdi, 1
    mov rdx, 1
    mov rcx, 64 ; how far are we shifting rax?
iterate:
    push rax ; Save the initial rax value
    sub rcx, 4
    sar rax, cl ; shift to 60, 56, 52, ... 4, 0
    ; the cl register is the smallest part of rcx
    and rax, 0xf ; clear all bits but the lowest four
    lea rsi, [codes + rax]; take a hexadecimal digit character code
    mov rax, 1 ;
    push rcx ; syscall will break rcx
    syscall ; rax = 1 (31) -- the write identifier,
    pop rcx
    pop rax
    test rcx, rcx ; break out of the loop when rcx = 0
    jnz iterate
    ret
_start:
    mov rdi, 0x1122334455667788
    call print_hex
    call print_newline
    mov rax, 60
    xor rdi, rdi
    syscall
