#include "../include/upu.h"

/**
 * u_uart_putc - Output a single character via UART
 */
void u_uart_putc(char c) {
  // 1. Wait for the transmit buffer to be empty
  while (!(UART->LSR & UART_TX_EMPTY)) {
    // Simple polling
  }

  // 2. Load the character into the THR (Transmit Holding Register)
  UART->RBR_THR = (uint32_t)c;
}

/**
 * u_uart_puts - Output a null-terminated string via UART
 */
void u_uart_puts(const char *s) {
  while (*s) {
    u_uart_putc(*s++);
  }
}

/**
 * u_uart_getc - Read a single character from UART (blocking)
 */
char u_uart_getc(void) {
  // 1. Wait for data to be ready
  while (!(UART->LSR & UART_RX_READY)) {
    // Simple polling
  }

  // 2. Return the character from RBR (Receive Buffer Register)
  return (char)(UART->RBR_THR & 0xFF);
}
