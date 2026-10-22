#ifndef CONFIG_H
#define CONFIG_H

#define KERNEL_CODE_SELECTOR    0x8
#define KERNEL_DATA_SELECTOR    0x10

#define MDSOS_TOTAL_INTERRUPTS  0x100

#define MDSOS_HEAP_SIZE_BYTES   0x400 * 0x400 * 0x64 // 1024B^2 * 100 = 100MB
#define MDSOS_HEAP_BLOCK_SIZE   0x1000 // 4064 bytes
#define MDSOS_HEAP_ADDRESS      0x01000000
// We are no longer on Real Mode ∴ we can use memory sectors from there
// https://wiki.osdev.org/Memory_Map_(x86)#Overview
#define MDSOS_HEAP_TABLE_ADDR   0x00007E00

#endif
