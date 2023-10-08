extern printf
section .data
    first	db	"A",0
    second	db	"B",0
    third	db	"C",0
    fourth	db	"D",0
    fifth	db	"E",0
    sixth	db	"F",0
    seventh	db	"G",0
    eighth  db      "H",0
    ninth   db      "I",0
    tenth   db      "J",0
    fmt1	db	"The string is: %s%s%s%s%s%s%s%s%s%s",10,0
    fmt2    db	"PI = %f",10,0
    pi   dq      3.14

section .bss
section .text
    global main
main:
    push rbp
    mov rbp, rsp; for correct debugging
    sub rsp, 8

    push tenth  ; now start pushing in
    push ninth  ; reverse order
    push eighth
    push seventh
    push sixth

    mov r9, fifth
    mov r8, fourth
    mov rcx, third
    mov rdx, second
    mov rsi, first  ; the correct registers
    mov rdi,fmt1

    mov rax, 0
    call printf
    add rsp, 48
    movsd xmm0,[pi] ; print a float
    mov rax, 1
    mov rdi, fmt2
    call printf
    leave
    ret
