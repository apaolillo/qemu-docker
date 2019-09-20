#include "uart.h"

int main()
{
    uart_init();

    char* message = "Hello, UARTX!\n\r";

    for (unsigned i = 0; i < 8; ++i) {
        message[11u] = '1' + i;

        uart_print(i, message);
    }

    return 0;
}
