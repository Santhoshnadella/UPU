#include "../include/upu.h"

/**
 * u_npu_clear_acc - Reset the NPU accumulators
 */
void u_npu_clear_acc(void) { NPU->ACC_CLEAR = 1; }

/**
 * u_npu_process - Push data through the NPU pipeline
 * Note: NPU is a streaming processor in v1.
 * External DMA or PU usually feeds the 'activation_in' lines.
 */
void u_npu_enable(void) {
  // Currently auto-processing when valid_in is high in RTL.
  // This register can be expanded for mode selection in v2.
}
