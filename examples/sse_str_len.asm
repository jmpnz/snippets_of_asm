extern printf
section .data
    str1 db "The quick brown fox jumps over the lazy dog", 10, 0
    fmt1 db "String: %s", 10, 0
    fmt2 db "String length: %d", 10,0
section .bss
section .text
    global main
main:
    push rbp
    mov rbp, rsp
    mov rdi, fmt1
    mov rsi, str1
    xor rax, rax
    ; print the initial string.
    call printf
    ; prepare call to pstrlen function
    mov rdi, str1
    call pstrlen
    mov rdi, fmt2
    mov rsi, rax ; return value of `call pstrlen`
    xor rax, rax
    call printf
    leave
    ret
pstrlen:
    push rbp
    mov rbp, rsp
    mov rax, -16
    pxor xmm0, xmm0
.not_found:
    add rax, 16
    pcmpistri xmm0, [rdi + rax], 00001000b
    jnz .not_found
    add rax, rcx
    inc rax
    leave
    ret
