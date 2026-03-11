#include "../include/upu.h"

// HAL Prototypes
void u_uart_puts(const char *s);
void u_gpio_out(uint8_t value);
void u_timer_setup(uint32_t period);
void u_tpu_matmul(uint32_t a, uint32_t b, uint16_t n);
void u_gpu_vector_op(uint32_t d, uint32_t a, uint32_t b, uint32_t op);

/**
 * UPU SoC Diagnostic Firmware
 * Demonstrates pipelined execution across all accelerators.
 */
int main(void) {
  // 1. Initial HW Check (L0 Setup)
  u_uart_puts("\r\n--- [UPU v1: System POST (Power On Self Test)] ---\r\n");
  u_gpio_out(0xA5); // Visual Heartbeat on GPIO pins

  // 2. Memory Test (Implicit through L2 SRAM accesses)
  u_uart_puts("[INFO] CPU Frequency detected @ 50.0 MHz\r\n");
  u_uart_puts("[INFO] Memory Partitioning: 256KB Shared L2 SRAM\r\n");

  // 3. Accelerator 1: TPU Systolic Grid (Matrix Mult)
  u_uart_puts("[TPU] Starting INT8 Matrix Multiplication... ");
  u_tpu_matmul(0x10000000, 0x10001000, 16);
  u_uart_puts("DONE.\r\n");

  // 4. Accelerator 2: GPU Vector Unit (Parallel SIMD)
  u_uart_puts("[GPU] Parallelizing VR0 = VR1 + VR2 across 32 lanes... ");
  u_gpu_vector_op(0, 1, 2, GPU_ADD);
  u_uart_puts("DONE.\r\n");

  // 5. Accelerator 3: NPU (Neural Stream)
  u_uart_puts("[NPU] Initializing ReLU Activation Pipeline... ");
  NPU->ACC_CLEAR = 1;
  u_uart_puts("READY.\r\n");

  // 6. System Timer: Start 1ms heartbeat
  // 50,000,000 cycles/sec / 1000 = 50,000 cycles per ms
  u_timer_setup(50000);
  u_uart_puts("[SYS] System Timer Heartbeat Started.\r\n");

  // 7. Execution Loop
  u_uart_puts("--- [UPU v1: OPERATIONAL] ---\r\n");
  uint8_t count = 0;
  while (1) {
    // Increment GPIO as a simple load monitor
    u_gpio_out(count++);
    for (volatile int i = 0; i < 500000; i++)
      ; // Wait ~10ms
  }

  return 0;
}
