#include "../include/upu.h"

/**
 * u_timer_setup - Configure the system timer
 *
 * @param period: Number of 50MHz clk cycles before interrupt
 */
void u_timer_setup(uint32_t period) {
  TIMER_REGS->COMPARE = period;
  TIMER_REGS->COUNTER = 0;
  TIMER_REGS->ENABLE = 1;
}

/**
 * u_timer_stop - Stop the timer
 */
void u_timer_stop(void) { TIMER_REGS->ENABLE = 0; }

/**
 * u_timer_get_ms - Return approximate milliseconds (@ 50MHz)
 */
uint32_t u_timer_get_ms(void) {
  // 50,000,000 / 1000 = 50,000 cycles per ms
  return (TIMER_REGS->COUNTER / 50000);
}
