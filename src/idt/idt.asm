section .asm

global idt_load
idt_load:
    push ebp
    mov ebp, esp
    ; IDTR address as 1st arg
    mov ebx, [ebp + 8]
    ; load IDTR
    lidt [ebx]
    pop ebp
    ret
