#include "../include/upu.h"

/**
 * u_plic_init - Initialize the PLIC thresholds
 */
void u_plic_init(void) {
  PLIC->THRESHOLD = 0;
  PLIC->ENABLE = 0; // Disable all initially
}

/**
 * u_plic_enable_source - Enable a specific interrupt ID
 */
void u_plic_enable_source(uint32_t id) {
  PLIC->ENABLE |= (1 << id);
  PLIC->PRIO[id] = 1; // Default priority 1
}

/**
 * u_plic_get_claim - Claim the highest priority pending interrupt
 */
uint32_t u_plic_get_claim(void) {
  // Note: In RISC-V PLIC, claim is usually at Context Offset (0x201004)
  // For this simple v1 SoC, we'll read PENDING for now.
  return PLIC->PENDING;
}
