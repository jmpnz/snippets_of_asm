; reverse string with stack
extern printf
section .data
    strng db "RADARE2", 0
    strngLen equ $-strng-1 ; string length
    fmt1 db "The original string : %s", 10, 0
    fmt2 db "The reversed string : %s", 10, 0
section .bss
section .text
    global main
main:
    push rbp
    mov rbp, rsp
    ; print the original string
    mov rdi, fmt1
    mov rsi, strng
    mov rax, 0
    call printf
    ; push the string characters into the stack
    xor rax, rax ; clear rax
    mov rbx, strng ; address of strng in rbx
    mov rcx, strngLen ; length in rcx counter
    mov r12, 0 ; use r12 as an index into the string
pushloop:
    mov al, byte [rbx + r12] ; mov strng[0] to al
    push rax ; save rax on the stack
    inc r12 ; increment index
    loop pushloop ; continue loop until we reach end of the string
    ; pop the string in reverse
    mov rbx, strng
    mov rcx, strngLen
    mov r12, 0
poploop:
    pop rax ; pop a char from the stack
    mov byte [rbx + r12], al ; mov char at strng[0]
    inc r12 ; increment index
    loop poploop ; keep on keeping on
    ; print the reversed string
    mov rdi, fmt2
    mov rsi, strng
    mov rax, 0
    call printf
    mov rsp, rbp
    pop rbp
    ret

