#include "../include/upu.h"

/**
 * u_gpio_out - Write to 8-bit output port
 */
void u_gpio_out(uint8_t value) { GPIO->DATA = value; }

/**
 * u_gpio_mask - Configure which pins are enabled
 */
void u_gpio_mask(uint8_t mask) { GPIO->MASK = mask; }

/**
 * u_gpio_toggle - XOR bits on the output port
 */
void u_gpio_toggle(uint8_t value) { GPIO->DATA ^= value; }
