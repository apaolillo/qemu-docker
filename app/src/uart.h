
#ifndef DEF_UART_H
#define DEF_UART_H

void uart_init(void);

void uart_send(unsigned uart_id, const char* string, unsigned length);

void uart_print(unsigned uart_id, const char* const message);

#endif /* DEF_UART_H */
