#include <stdint.h>

#define UART_BASE 0x40003000
#define UART_THR  (*(volatile uint32_t*)(UART_BASE + 0))

void uart_putc(char c) {
    UART_THR = c;
}

void uart_puts(const char* s) {
    while (*s) uart_putc(*s++);
}

int main() {
    uart_puts("UPU Alive: Running RV64I + Hyper-NoC\r\n");
    while(1);
    return 0;
}
