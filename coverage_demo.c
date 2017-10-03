#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    uint32_t a = atoi(argv[1]);
    uint32_t b = atoi(argv[2]);
    uint32_t x = atoi(argv[3]);
    if (a > 1 && b == 0) { 
        puts("Decision 1 was true");
    } else {
        puts("Decision 1 was false");
    } 
    if (a == 2 || x > 1) { 
        puts("Decision 2 was true");
    } else {
        puts("Decision 2 was false");
    } 
    return 0;
}
