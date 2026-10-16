ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; https://wiki.osdev.org/FAT
jmp short boot_init
nop

db "MSWIN4.1"
times 0x19 db 0

boot_init:
; Set text segment at 0x7c0 (start)
jmp 0:start

start:
    cli ; Clear interrupts during set up
    mov ax, 0
    mov ds, ax ; data segment
    mov es, ax ; extra segment
    mov ss, ax ; stack segment
    mov sp, 0x7c00
    sti ; Enable interrupts

.PM_start:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or al, 1        ; Set Protected Mode bit in cr0 (Control Register 0)
    mov cr0, eax
    ;jmp CODE_SEG:is_A20_on
    jmp $

; gdt offset 0x0
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0
; gdt offset 0x8
gdt_code:
    dw 0xffff   ; Segment limit first 0-15 bits
    dw 0        ; Base first 0-15 bits
    db 0        ; Base 16-23 bits
    db 0x9a     ; Access byte
    db 11001111b; Lower bits (Limit) upper bits (Flags)
    db 0        ; Base
; gdt offset 0x10
gdt_data:       ; DS, SS, ES, FS, GS
    dw 0xffff   ; Segment limit first 0-15 bits
    dw 0        ; Base first 0-15 bits
    db 0        ; Base 16-23 bits
    db 0x92     ; Access byte
    db 11001111b; Lower bits (Limit) upper bits (Flags)
    db 0        ; Base
gdt_end:

; GDTR
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

[BITS 32]

load32:
    mov eax, 1
    mov ecx, 0x64       ; Sectors to read
    mov edi, 0x0100000   ; Destination buffer 1Mb
    call ata_lba_read
    jmp CODE_SEG:0x0100000

; https://wiki.osdev.org/ATA_PIO_Mode#28_bit_PIO
ata_lba_read:
    mov ebx, eax        ; Backup the LBA (Logical Block Addressing)
    ; Send the highest 8 bits of the LBA to hard disk controller
    shr eax, 24
    or eax, 0xe0 ; Select the master drive
    mov dx, 0x1f6
    out dx, al
    ; Finished ending the highest 8 bits of the LBA

    ; Send the total sectors to read
    mov eax, ecx
    mov dx, 0x1f2
    out dx, al
    ; Finish sending the total sectors to read

    ; Send more bits of the LBA
    mov eax, ebx        ; Restore the backup LBA
    mov dx, 0x1f3
    out dx, al
    ; Finished sending more bits of the LBA

    ; Send more bits of the LBA
    mov dx, 0x1f4
    mov eax, ebx        ; Restore the backup LBA
    shr eax, 8
    out dx, al
    ; Finished sending more bits of the LBA

    ; Send uppper 16 bits of the LBA
    mov dx, 0x1f5
    mov eax, ebx
    shr eax, 16
    out dx, al
    ; Finished sending upper 16 bits of the LBA

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; Read all sectors into memory
.next_sector:
    push ecx

; Wait for IRQ or poll
.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    ; We need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1f0
    rep insw
    pop ecx
    loop .next_sector
    ; End of reading sectors into memory
    ret

times 510-($ - $$) db 0
dw 0xAA55
