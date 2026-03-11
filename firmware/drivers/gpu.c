#include "../include/upu.h"

/**
 * u_gpu_vector_add - Parallel SIMD vectorized operation
 *
 * @param dest_id: Target vector register (VR0-31)
 * @param src_a: Source register A
 * @param src_b: Source register B
 * @param op: Opcode (GPU_OP_ADD, GPU_OP_MAX, etc.)
 */
void u_gpu_vector_op(uint32_t dest_id, uint32_t src_a, uint32_t src_b,
                     uint32_t op) {
  // 1. Set the register IDs
  GPU->DEST_ID = dest_id;
  GPU->SRC_A_ID = src_a;
  GPU->SRC_B_ID = src_b;

  // 2. Trigger the execution with the specified operation
  // [0]: Start bit, [3:1]: Opcode
  GPU->EXEC = (0x1 | (op << 1));

  // 3. Wait for the operation to complete via PLIC or polling
  // (Note: GPU core raises an IRQ upon completion)
}

/**
 * u_gpu_get_done_status - Check if last vector operation finished
 */
uint32_t u_gpu_get_done_status(void) {
  // Check if the GPU_DONE interrupt bit is set in the PLIC (Source 2)
  return (PLIC->PENDING & (1 << 2));
}
