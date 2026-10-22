[BITS 32]

global _start

extern kernel_main

CODE_SEG equ 0x8
DATA_SEG equ 0x10

_start:
    pushad
is_A20_on:
    mov edi,0x112345  ;odd megabyte address.
    mov esi,0x012345  ;even megabyte address.
    mov [esi],esi     ;making sure that both addresses contain different values.
    mov [edi],edi     ;(if A20 line is cleared the two pointers would point to the address 0x012345 that would contain 0x112345 (edi))
    cmpsd             ;compare addresses to see if the're equivalent.
    popad
    jne main          ;if not equivalent , A20 line is set.

fast_A20_gate:
    in al, 0x92
    or al, 2
    out 0x92, al

main:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; Remap the master PIC (Programable Interrupt Controller)
    mov al, 00010001b
    out 0x20, al ; Tell master PIC

    mov al, 0x20 ; Interrupt 0x20 is where master ISR should start
    out 0x21, al

    mov al, 00000001b
    out 0x21, al
    ; End remap of the master PIC

    call kernel_main
.sub_main:
    hlt
    jmp .sub_main

times 512-($ - $$) db 0
