
#include "uart.h"
#include <stdint-gcc.h>

#define NB_UART 2
#define UART0_BASE_ADDRESS 0xE0000000
#define UART1_BASE_ADDRESS 0xE0001000

#define UART_CONTROL_TXDIS (1u << 5)
#define UART_CONTROL_TXEN (1u << 4)
#define UART_STATUS_TFUL (1u << 4)
#define UART_STATUS_TEMPTY (1u << 3)
#define UART_STATUS_RFUL (1u << 2)
#define UART_STATUS_REMPTY (1u << 1)

typedef volatile struct {
    uint32_t control;
    uint32_t mode;
    uint32_t interruptEnable;
    uint32_t interruptDisable;
    const uint32_t interruptMask;
    uint32_t channelInterruptStatus;
    uint32_t baudrateGenerator;
    uint32_t receiverTimeout;
    uint32_t receiverFifoTriggerLevel;
    uint32_t modemControl;
    uint32_t modemStatus;
    const uint32_t channelStatus;
    uint32_t fifo;
    uint32_t baudrateDivider;
    uint32_t flowControlDelay;
    const uint32_t reserved[2];
    uint32_t transmitterFifoTriggerLevel;
} ZynqUartRegisters;

typedef enum
{
    UART0 = 0x0u,
    UART1 = 0x1u,
} UartLineId_e;

static ZynqUartRegisters* uartLines[NB_UART] = {
    (ZynqUartRegisters*) UART0_BASE_ADDRESS,
    (ZynqUartRegisters*) UART1_BASE_ADDRESS,
};

static void zynq_uart_init(ZynqUartRegisters* uartPtr)
{
    uartPtr->control &= ~UART_CONTROL_TXDIS;
    uartPtr->control |= UART_CONTROL_TXEN;
}

static void zynq_uart_sendbyte(ZynqUartRegisters* uartPtr, uint8_t byte)
{
    while (uartPtr->channelStatus & UART_STATUS_TFUL);

    uartPtr->fifo = byte;
}

void uart_init(void)
{
    zynq_uart_init(uartLines[UART0]);
    zynq_uart_init(uartLines[UART1]);
}

void uart_send(unsigned uart_id, const char* string, unsigned length)
{
    if (uart_id >= NB_UART)
        return;

    const char* charToSend = string;

    for (unsigned i = length; i != 0u; --i) {
        zynq_uart_sendbyte(uartLines[uart_id],
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
        zynq_uart_sendbyte(uartLines[uart_id],
                           *msgPtr);
        msgPtr++;
    }
}
