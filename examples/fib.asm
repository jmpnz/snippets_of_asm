extern printf

section .bss
section .text
    global main

main:
    push rbx
    mov rcx, 100
    or rax, rax
    xor rbx, rbx
    inc rbx
print:
    push rax
    push rcx
    mov rdi, format
    mov rsi, rax
    xor rax, rax

    call printf

    pop rcx
    pop rax

    mov rdx, rax
    mov rax, rbx
    add rbx, rdx
    dec rcx
    jnz print

    pop rbx
    ret

format:
    db "%30ld", 10, 0
