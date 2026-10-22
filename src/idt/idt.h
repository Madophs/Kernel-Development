#ifndef IDT_H
#define IDT_H

#include <stdint.h>

struct idt_desc
{
    uint16_t offset_1;
    uint16_t selector;  // Selector that's in our GDT
    uint8_t zero;       // Unused, set to 0
    uint8_t type_attr;  // gate type, dpl, and p fields
    uint16_t offset_2;
} __attribute__((packed));

struct idtr_desc
{
    uint16_t limit;     // Size of descriptor table - 1
    uint32_t base;      // IDT base address
} __attribute((packed));

void idt_init();

extern void enable_interrupts();
extern void disable_interrupts();

#endif
