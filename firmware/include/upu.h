#ifndef UPU_H
#define UPU_H

#include <stdint.h>

/**
 * UPU (Unified Processing Unit) v1 Memory Map
 */
#define UPU_L2_SRAM_BASE 0x10000000
#define UPU_CPU_CSR_BASE 0x20000000
#define UPU_TPU_REGS_BASE 0x30000000
#define UPU_NPU_REGS_BASE 0x30001000
#define UPU_GPU_REGS_BASE 0x30002000
#define UPU_PU_REGS_BASE 0x30003000
#define UPU_PLIC_REGS_BASE 0x40000000
#define UPU_UART_REGS_BASE 0x50000000
#define UPU_TIMR_REGS_BASE 0x50010000
#define UPU_GPIO_REGS_BASE 0x50020000

/**
 * Core Structures
 */
typedef struct {
  volatile uint32_t CTRL;      // 0x00: [0] Start, [1] Busy, [2] Done
  volatile uint32_t NORTH_SRC; // 0x04: Memory address
  volatile uint32_t WEST_SRC;  // 0x08: Memory address
  volatile uint32_t COUNT;     // 0x0C: Step count
} TPU_Type;

typedef struct {
  volatile uint32_t ACC_CLEAR; // 0x00: Reset accumulators
} NPU_Type;

typedef struct {
  volatile uint32_t EXEC;     // 0x00: Trigger (Opcode [3:1])
  volatile uint32_t DEST_ID;  // 0x04
  volatile uint32_t SRC_A_ID; // 0x08
  volatile uint32_t SRC_B_ID; // 0x0C
} GPU_Type;

typedef struct {
  volatile uint32_t EXEC;   // 0x00: Trigger (Opcode [2:1])
  volatile uint32_t REG[4]; // 0x04-0x10
} PU_Type;

typedef struct {
  volatile uint32_t PRIO[8]; // 0x00
  uint32_t _pad0[248];
  volatile uint32_t PENDING; // 0x400
  uint32_t _pad1[255];
  volatile uint32_t ENABLE; // 0x800
  uint32_t _pad2[255];
  volatile uint32_t THRESHOLD; // 0xC00
} PLIC_Type;

typedef struct {
  volatile uint32_t RBR_THR; // 0x00
  uint32_t _pad0[4];
  volatile uint32_t LSR; // 0x14
} UART_Type;

typedef struct {
  volatile uint32_t ENABLE;  // 0x00
  volatile uint32_t COMPARE; // 0x04
  volatile uint32_t COUNTER; // 0x08
} TIMER_Type;

typedef struct {
  volatile uint32_t DATA; // 0x00
  volatile uint32_t MASK; // 0x04
} GPIO_Type;

// SoC Peripheral Proxies
#define TPU ((TPU_Type *)UPU_TPU_REGS_BASE)
#define NPU ((NPU_Type *)UPU_NPU_REGS_BASE)
#define GPU ((GPU_Type *)UPU_GPU_REGS_BASE)
#define PU ((PU_Type *)UPU_PU_REGS_BASE)
#define PLIC ((PLIC_Type *)UPU_PLIC_REGS_BASE)
#define UART ((UART_Type *)UPU_UART_REGS_BASE)
#define TIMER_REGS ((TIMER_Type *)UPU_TIMR_REGS_BASE)
#define GPIO ((GPIO_Type *)UPU_GPIO_REGS_BASE)

// Control Definitions
#define TPU_START (1 << 0)
#define TPU_BUSY (1 << 1)
#define TPU_DONE (1 << 2)

#define GPU_START (1 << 0)
#define GPU_ADD (0x0 << 1)
#define GPU_MAX (0x5 << 1)

#define UART_TX_EMPTY (1 << 1)
#define UART_RX_READY (1 << 0)

#endif // UPU_H
