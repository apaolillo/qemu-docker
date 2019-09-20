#include <stdint-gcc.h>

#define NB_UART 8
#define UART1_BASE_ADDRESS 0x30860000
#define UART2_BASE_ADDRESS 0x30890000
#define UART3_BASE_ADDRESS 0x30880000
#define UART4_BASE_ADDRESS 0x30A60000
#define UART5_BASE_ADDRESS 0x30A70000
#define UART6_BASE_ADDRESS 0x30A80000
#define UART7_BASE_ADDRESS 0x30A90000

#define UART_UCR1_UARTEN (1u << 0)
#define UART_UCR2_SRST (1u << 0)
#define UART_UCR2_RXEN (1u << 1)
#define UART_UCR2_TXEN (1u << 2)
#define UART_UCR2_WS (1u << 5)
#define UART_UCR2_IRTS (1u << 14)
#define UART_UTS_TXFULL (1u << 4)

typedef struct {
    volatile uint32_t receiver;
    uint32_t reserved[15];
    volatile uint32_t transmitter;
    uint32_t reserved2[15];
    volatile uint32_t control1;
    volatile uint32_t control2;
    volatile uint32_t control3;
    volatile uint32_t control4;
    volatile uint32_t fifoControl;
    volatile uint32_t status1;
    volatile uint32_t status2;
    volatile uint32_t escapeCharacter;
    volatile uint32_t escapeTimer;
    volatile uint32_t brmIncremental;
    volatile uint32_t brmModulator;
    volatile uint32_t baudRateCount;
    volatile uint32_t oneMilliSecond;
    volatile uint32_t test;
    volatile uint32_t rs485ModeControl;
} ImxUartRegisters;

typedef enum
{
    UART1 = 0x0u,
    UART2 = 0x1u,
    UART3 = 0x2u,
    UART4 = 0x3u,
    UART5 = 0x4u,
    UART6 = 0x5u,
    UART7 = 0x6u,
} UartLineId_e;

static ImxUartRegisters * uartLines[NB_UART] = {
    (ImxUartRegisters *) UART1_BASE_ADDRESS,
    (ImxUartRegisters *) UART2_BASE_ADDRESS,
    (ImxUartRegisters *) UART3_BASE_ADDRESS,
    (ImxUartRegisters *) UART4_BASE_ADDRESS,
    (ImxUartRegisters *) UART5_BASE_ADDRESS,
    (ImxUartRegisters *) UART6_BASE_ADDRESS,
    (ImxUartRegisters *) UART7_BASE_ADDRESS,
};

static void imx_uart_init(ImxUartRegisters* uartPtr)
{
    uartPtr->control1 = 0x0;
    uartPtr->control2 = 0x0; /* Reset the UART device. */

    /* Waits for the reset to complete. */
    while (!(uartPtr->control2 & UART_UCR2_SRST))
        ;

    uartPtr->control3 = 0x784u;
    uartPtr->control4 = 0x8000u;
    uartPtr->escapeCharacter = 0x002Bu;
    uartPtr->escapeTimer = 0x0u;
    uartPtr->test = 0x0u;
    uartPtr->fifoControl = 0x200u;
    uartPtr->brmIncremental = 0xFu;

    uartPtr->brmModulator = 0x15Bu;

    uartPtr->control2 = UART_UCR2_SRST | UART_UCR2_RXEN | UART_UCR2_TXEN
                        | UART_UCR2_WS | UART_UCR2_IRTS;
    uartPtr->control1 = UART_UCR1_UARTEN;
}

static void imx_uart_sendbyte(ImxUartRegisters* uartPtr, uint8_t byte)
{
    while (uartPtr->test & UART_UTS_TXFULL);

    uartPtr->transmitter = (uint32_t) byte;
}

void uart_init(void)
{
    imx_uart_init(uartLines[UART1]);
    imx_uart_init(uartLines[UART2]);
    imx_uart_init(uartLines[UART3]);
    imx_uart_init(uartLines[UART4]);
    imx_uart_init(uartLines[UART5]);
    imx_uart_init(uartLines[UART6]);
    imx_uart_init(uartLines[UART7]);
}

void uart_send(unsigned uart_id, const char* string, unsigned length)
{
    if (uart_id >= NB_UART)
        return;

    const char* charToSend = string;

    for (unsigned i = length; i != 0u; --i) {
        imx_uart_sendbyte(uartLines[uart_id],
                          *charToSend);
        ++charToSend;
    }
}

void uart_print(unsigned uart_id, const char* const message)
{
    if (uart_id >= NB_UART)
        return;

    const char* msgPtr = message;
    while (*msgPtr) {
        imx_uart_sendbyte(uartLines[uart_id],
                          *msgPtr);
        msgPtr++;
    }
}
