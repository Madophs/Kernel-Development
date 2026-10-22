[BITS 32]

section .asm

global paging_load_directory
global paging_enable

; https://wiki.osdev.org/X86_Paging#Virtual_Address_Spaces
paging_load_directory:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    mov cr3, eax
    pop ebp
    ret

paging_enable:
    push ebp
    mov ebp, esp
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    pop ebp
    ret
