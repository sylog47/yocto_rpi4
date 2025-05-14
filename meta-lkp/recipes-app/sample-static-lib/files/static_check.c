#include <stdio.h>

#include "my_static_lib.h"

int main()
{
    printf("%s, %d: \n", __func__, __LINE__);
    // print_my_static_lib();

    print_hello();
    print_arith();

    return 0;
}