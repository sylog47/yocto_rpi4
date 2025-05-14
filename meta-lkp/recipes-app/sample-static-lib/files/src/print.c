#include <stdio.h>
#include "print.h"

void print_hello(void)
{
    printf("%s, %d: \n", __func__, __LINE__);
}