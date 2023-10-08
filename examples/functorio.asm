extern printf
section .data
    radius dq 10.0
    pi dq 3.14
    fmt db "The area of the circle is : %.2f", 10, 0
section .bss
section .text
    global main
main:
    push rbp
    mov rbp, rsp
    call area
    mov rdi, fmt
    movsd xmm1, [radius]
    mov rax, 1
    call printf
    leave
    ret

area:
    push rbp
    mov rbp, rsp
    movsd xmm0, [radius]
    mulsd xmm0, [radius] ; square radius
    mulsd xmm0, [pi] ; mul by pi
    leave
    ret
