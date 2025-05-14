#include "my_static_lib.h"
#include "print.h"
#include "arith.h"

void print_my_static_lib()
{
    printf("%s, %d: \n", __func__, __LINE__);
    print_hello();
    print_arith();
}