#include <stdint.h>
#include <stdio.h>
#include "greet.h"

int32_t greet(void)
{
    int32_t ret = 0;

    printf("%s(), L%d: Hello~ Bongjour~ Hola~\n", __func__, __LINE__);

    return ret;
}