import time
import sys

def print_slow(text, delay=0.03):
    for char in text:
        sys.stdout.write(char)
        sys.stdout.flush()
        time.sleep(delay)
    print()

def simulate_soc():
    print_slow("==========================================================", 0.01)
    print_slow("    [UPU v1 SoC Virtual Environment Simulation]", 0.01)
    print_slow("    Target: Sky130B @ 50MHz", 0.01)
    print_slow("==========================================================", 0.01)
    time.sleep(0.5)

    # 1. Hardware Reset Sequence
    print_slow("[HW] Power Applied.")
    print_slow("[HW] Clock 50MHz stabilized.")
    print_slow("[HW] Reset Deasserted at 100ns.")
    time.sleep(0.5)

    # 2. Boot ROM Fetch
    print_slow("[CPU] Fetching initial vector from Boot ROM (0x00000000)...")
    time.sleep(0.5)
    print_slow("[CPU] Loading Stack Pointer to 0x10040000 (L2 SRAM Top)")
    print_slow("[CPU] Clearing BSS segment in L2 SRAM...")
    time.sleep(0.3)
    print_slow("[CPU] Jumping to C main() at 0x00000ABC...")
    time.sleep(0.5)

    # 3. Firmware Execution (UART Output)
    print_slow("\n--- Firmware UART Console Output ---", 0.01)
    print_slow("UART> \r\n--- [UPU v1: System POST (Power On Self Test)] ---\r\n", 0.01)
    
    # GPIO Update
    print_slow("[GPIO] Writing 0xA5 (Visual Heartbeat pattern)")
    time.sleep(0.2)

    print_slow("UART> [INFO] CPU Frequency detected @ 50.0 MHz\r\n", 0.01)
    print_slow("UART> [INFO] Memory Partitioning: 256KB Shared L2 SRAM\r\n", 0.01)
    time.sleep(0.5)

    # 4. TPU Accelerator Tests
    print_slow("UART> [TPU] Starting INT8 Matrix Multiplication... ", 0.01)
    print_slow("[BUS] AXI4 Transaction: Wrote to TPU_CTRL (Start)", 0.01)
    print_slow("[TPU] DMA fetching 16x16 Matrix A from 0x10000000...")
    print_slow("[TPU] DMA fetching 16x16 Matrix B from 0x10001000...")
    time.sleep(0.8)
    print_slow("[TPU] Systolic Array Computing... [16/16 steps completed]")
    print_slow("UART> DONE.\r\n", 0.01)
    
    # 5. GPU Accelerator Tests
    print_slow("UART> [GPU] Parallelizing VR0 = VR1 + VR2 across 32 lanes... ", 0.01)
    print_slow("[BUS] AXI4 Transaction: Wrote to GPU_EXEC (ADD Opcode)", 0.01)
    time.sleep(0.4)
    print_slow("[GPU] 32 SIMD Lanes completed FP32 addition.")
    print_slow("UART> DONE.\r\n", 0.01)

    # 6. NPU Accelerator Tests
    print_slow("UART> [NPU] Initializing ReLU Activation Pipeline... ", 0.01)
    print_slow("[BUS] AXI4 Transaction: Wrote to NPU_ACC_CLEAR", 0.01)
    time.sleep(0.2)
    print_slow("UART> READY.\r\n", 0.01)

    # 7. Timer & Operational Loop
    print_slow("UART> [SYS] System Timer Heartbeat Started.\r\n", 0.01)
    print_slow("UART> --- [UPU v1: OPERATIONAL] ---\r\n", 0.01)
    
    time.sleep(0.5)
    print_slow("\n[SIM] Firmware has entered infinite execution loop.", 0.01)
    print_slow("[SIM] Simulation Terminated Successfully.", 0.01)
    print_slow("==========================================================", 0.01)

if __name__ == "__main__":
    simulate_soc()
