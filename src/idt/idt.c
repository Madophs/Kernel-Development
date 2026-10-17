#include "idt.h"
#include "../config.h"
#include "../kernel.h"
#include "../memory/memory.h"

struct idt_desc idt_descriptors[MDSOS_TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;

extern void idt_load(struct idtr_desc* desc);

void int_zero() {
    print("Division by zero\n");
}

void idt_set(int int_idx, void* address)
{
    idt_descriptors[int_idx].offset_1 = (uint32_t)(address) & 0x0000ffff;
    idt_descriptors[int_idx].selector = KERNEL_CODE_SELECTOR;
    idt_descriptors[int_idx].zero = 0x0;
    idt_descriptors[int_idx].type_attr = 0xEE; // Interrupt gate, Ring 3, P = 1
    idt_descriptors[int_idx].offset_2 = (uint32_t)address >> 0x10;
}

void idt_init()
{
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t) idt_descriptors;
    idt_set(0, int_zero);

    idt_load(&idtr_descriptor);
}
