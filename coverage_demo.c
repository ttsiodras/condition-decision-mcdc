#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    uint32_t t1 = atoi(argv[1]);
    uint32_t t2 = t1 < 8 && t1 > 2;
    if (t1 < 7 && t1 > 3)
        printf("3<%d<7 was true\n", t1);
    else
        printf("3<%d<7 was false\n", t1);
    return 0;
}
