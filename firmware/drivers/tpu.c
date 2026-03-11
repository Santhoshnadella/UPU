#include "../include/upu.h"

/**
 * u_tpu_matmul - Matrix multiplication via TPU systolic array
 *
 * @param north_src_addr: Memory address of the first 16x16 matrix (rows)
 * @param west_src_addr: Memory address of the second 16x16 matrix (cols)
 * @param count: Number of systolic steps to run (e.g., 16 for 16x16 grid)
 */
void u_tpu_matmul(uint32_t north_src_addr, uint32_t west_src_addr,
                  uint16_t count) {
  // 1. Configure the TPU source addresses in L2 SRAM
  TPU->NORTH_SRC = north_src_addr;
  TPU->WEST_SRC = west_src_addr;
  TPU->COUNT = (uint32_t)count;

  // 2. Trigger the systolic array computation
  TPU->CTRL = TPU_START;

  // 3. Busy-wait for completion (Done bit)
  while (!(TPU->CTRL & TPU_DONE)) {
    // Simple polling for v1
  }

  // 4. Acknowledge/clear the status (Optional, depends on hardware clearing
  // logic)
}

/**
 * u_tpu_is_busy - Check if the TPU is currently running a systolic operation
 */
uint32_t u_tpu_is_busy(void) { return (TPU->CTRL & TPU_BUSY); }
