#include <stddef.h>
#include <stdint.h>

#include "kernel.h"
#include "idt/idt.h"
#include "memory/heap/kheap.h"

uint16_t *video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

uint16_t terminal_make_char(char c, uint8_t color)
{
    return (color << 8) | c;
}

void terminal_putchar(int x, int y, char c, uint8_t color) {
    video_mem[(x * VGA_WIDTH) + y] = terminal_make_char(c, color);
}

void terminal_write(char c, uint8_t color) {
    if (c == '\n') {
        ++terminal_row;
        terminal_col = 0;
        return;
    }
    terminal_putchar(terminal_row, terminal_col, c, color);
    ++terminal_col;
    if (terminal_col >= VGA_WIDTH) {
        terminal_col = 0;
        ++terminal_row;
    }
}

size_t strlen(const char *str)
{
    size_t len = 0;
    while(str[len]) {
        ++len;
    }
    return len;
}

void print(const char *str) {
    size_t len = strlen(str);
    for (int i = 0; i < len; ++i) {
        terminal_write(str[i], 15);
    }
}

void terminal_initialize()
{
    video_mem = (uint16_t *)(0xB8000);
    terminal_row = 0;
    terminal_col = 0;
    for (int i = 0; i < VGA_HEIGHT; ++i) {
        for (int j = 0; j < VGA_WIDTH; ++j) {
            terminal_putchar(i, j, ' ', 0);
        }
    }
}

void kernel_main()
{
    terminal_initialize();
    print("Hola MdsOS\nNueva linea\n");

    kheap_init();

    // Initialize Interrupt Descriptor Table
    idt_init();

    // Enable system interrupts
    enable_interrupts();
}
