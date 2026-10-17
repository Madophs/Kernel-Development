#include "memory.h"

void* memset(void* ptr, int c, size_t size)
{
    unsigned char *c_ptr = ptr;
    while (size--) {
        *c_ptr++ = c;
    }
    return ptr;
}
