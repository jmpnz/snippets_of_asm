; What is my CPU capable of ?
extern printf
section .data
    fmt_no_sse db "This cpu doesn't supports SSE", 10, 0
    fmt_sse42 db "This cpu supports SSE 4.2", 10, 0
    fmt_sse41 db "This cpu supports SSE 4.1", 10, 0
    fmt_sse3 db "This cpu supports SSE 3.0", 10, 0
    fmt_sse2 db "This cpu supports SSE 2.0", 10, 0
    fmt_sse db "This cpu supports SSE", 10, 0
    fmt_avx db "This cpu supports AVX", 10, 0
    fmt_avx2 db "This cpu supports AVX2", 10, 0
    fmt_avx512 db "This cpu supports AVX512", 10, 0
    fmt_no_avx512 db "This cpu doesn't support AVX512", 10, 0

section .bss
section .text
    global main
main:
    push rbp
    mov rbp, rsp
    call cpu_sse
    leave
    ret
; check for sse support
cpu_sse:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    xor r12, r12
    mov eax, 1 ; request CPU features
    cpuid ; cpu returns the feature information in rax, rbx, rcx and rdx
    ; test for SSE
    test edx, 200000h ; test bit 25
    jz sse2 ; sse available check for sse2
    mov r12, 1
    mov rdi, fmt_sse
    push rax
    push rcx
    push rdx
    mov rax, 0
    call printf
    pop rdx
    pop rcx
    pop rax
sse2:
    test edx, 400000h ; test bit 26 for sse2
    jz sse3 ; sse 2 available check for sse3
    mov r12, 1
    mov rdi, fmt_sse2
    push rax
    push rcx ; modified by printf
    push rdx
    mov rax, 0
    call printf
    pop rdx
    pop rcx
    pop rax
sse3:
    test ecx, 9h ; test bit 0 (SSE 3)
    jz sse41 ; sse3 available check for sse4
    mov r12, 1
    mov rdi, fmt_sse3
    push rax
    push rcx
    push rdx
    mov rax, 0
    call printf
    pop rdx
    pop rcx
    pop rax
sse41:
    test ecx, 80000h ; test bit 19 sse 4.1
    jz sse42 ; sse 4.1 available check for sse 4.2
    mov r12, 1
    mov rdi, fmt_sse41
    push rax
    push rcx
    push rdx
    mov rax, 0
    call printf
    pop rdx
    pop rcx
    pop rax
sse42:
    test ecx, 10000h ; test bit 20 sse 4.2
    jz avx
    mov r12, 1
    mov rdi, fmt_sse42
    push rax
    push rcx
    push rdx
    mov rax, 0
    call printf
    pop rdx
    pop rcx
    pop rax
avx:
    test ecx, 1000000h ; test bit 28 for avx
    jz avx2
    mov r12, 1
    mov rdi, fmt_avx
    push rax
    push rcx
    push rdx
    mov rax, 0
    call printf
    pop rdx
    pop rcx
    pop rax
avx2:
    test ecx, 1 << 5 ; test bit 5 of eax for avx2
    jz avx512
    mov r12, 1
    mov rdi, fmt_avx2
    push rax
    push rcx
    push rdx
    mov rax, 0
    call printf
    pop rdx
    pop rcx
    pop rax
avx512:
    test ebx, 1 << 16
    jz no_avx
    mov r12, 1
    mov rdi, fmt_avx512
    push rax
    push rcx
    push rdx
    mov rax, 0
    call printf
    pop rdx
    pop rcx
    pop rax
cleanup:
    cmp r12, 1
    je sse_ok
    mov rdi, fmt_no_sse
    xor rax, rax
    call printf
    jmp exit
no_avx:
    mov rdi, fmt_no_avx512
    push rax
    push rcx
    push rdx
    mov rax, 0
    call printf
    pop rdx
    pop rcx
    pop rax
sse_ok:
    mov rax, r12
exit:
    leave
    ret
