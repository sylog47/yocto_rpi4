#include <stdio.h>
#include <unistd.h>

#include "my_static_lib.h"
#include "greet.h"

int main()
{
    int n = 500;
    while (n-- > 0) {
	    printf("[lkp] Hello World! %d\n", n);
    }

    print_arith();
    print_hello();

    greet();

	return 0;
}
