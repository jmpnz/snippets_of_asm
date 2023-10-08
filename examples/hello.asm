; hello world
section .data
    msg db "Hello, World !", 0
section .bss ; empty
section .text
    global main

main:
    mov rax, 1 ; syscall number for write
    mov rdi, 1 ; file descriptor number for stdout
    mov rsi, msg ; string to display in this case static
    mov rdx, 14; length of the string
    syscall ; trap to OS
    mov rax, 60 ; syscall number for exit
    mov rdi, 0 ; arg to exit (exit code)
    syscall ; trap to OS
