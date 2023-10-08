extern printf
section .data
    number1 dq 9.0
    number2 dq 73.0
    fmt db "The numbers are %f and %f", 10, 0
    fmtfloat db "%s %f", 10, 0
    f_sum db "The float sum of %f and %f is %f", 10, 0
    f_diff db "The float difference of %f and %f is %f", 10, 0
    f_mul db "The float product of %f and %f is %f", 10, 0
    f_div db "The float division of %f and %f is %f", 10, 0
    f_sqrt db "The float sqrt of %f is %f", 10
section .bss
section .text
    global main
main:
    push rbp
    mov rbp, rsp
    ; print the numbers, args are passed in xmm0, xmm1
    movsd xmm0, [number1]
    movsd xmm1, [number2]
    ; args to printf are rdi and xmm0, xmm1
    mov rdi, fmt
    ; signal number float registers we are using
    mov rax, 2
    ; call printf
    call printf
    ; sum the two numbers
    movsd xmm2, [number1] ; store 9 in xmm2
    addsd xmm2, [number2] ; xmm2 = xmm + 73
    movsd xmm0, [number1]
    movsd xmm1, [number2]
    ; f_sum format specifier
    mov rdi, f_sum
    ; 3 float registers are used xmm0, xmm1, xmm2
    mov rax, 3
    call printf
    ; diff the two numbers
    movsd xmm2, [number1]
    subsd xmm2, [number2]
    movsd xmm0, [number1]
    movsd xmm1, [number2]
    mov rdi, f_diff
    mov rax, 3
    call printf
    ; mul the two numbers
    movsd xmm2, [number1]
    mulsd xmm2, [number2]
    movsd xmm0, [number1]
    movsd xmm1, [number2]
    mov rdi, f_mul
    mov rax, 3
    call printf
    ; div the two numbers
    movsd xmm2, [number1]
    divsd xmm2, [number2]
    movsd xmm0, [number1]
    movsd xmm1, [number2]
    mov rdi, f_div
    mov rax, 3
    call printf
    ; sqrt 9
    movsd xmm1, [number1]
    sqrtsd xmm1, [number1]
    movsd xmm0, [number1]
    mov rdi, f_sqrt
    mov rax, 2
    call printf
    ; restore stack and exit
    mov rsp, rbp
    pop rbp
    ret

