# 🛠️ UPU Developer Guide: Compatibility & Build Stack

This document outlines how to write code for the UPU architecture and the technical challenges/validation steps required for physical fabrication.

---

## 🏗️ 1. The UPU Software Stack
To maintain the "Silicon Stem Cell" philosophy, UPU uses a unified software stack.

### Unified HAL (Hardware Abstraction Layer)
All accelerators (GPU, TPU, NPU) are memory-mapped. To write compatible code, you must use the `upu_hal.h` primitives.

**Example: Dispatching a Tensor Op to Infinity TPU**
```c
#include <upu_hal.h>

void compute_attention_mask() {
    // 1. Map data to HBM3/L3 space
    void* data_ptr = upu_malloc(SIZE_1MB);

    // 2. Configure TPU Systolic Array (1024x1024)
    tpu_config_t config = { .mode = BF16, .stride = 1 };

    // 3. Dispatch Packet through Hyper-NoC
    // Revolutionary: The NoC handles the routing, not the CPU.
    upu_dispatch_tpu(data_ptr, &config);
}
```

---

## 🔬 2. Fabrication Validation (GDSII Workflow)
How do we know UPU can be fabricated at 7nm or 2nm?

### A. DRC/LVS (Design Rule Check / Layout vs Schematic)
*   **Edge (130nm):** Use `OpenLane`. Run `make physical` to generate the GDSII file and verify it against the Sky130 PDK.
*   **HPC (7nm/2nm):** Use the `contracts/` directory. These Python/SystemVerilog contracts enforce "Physical Feasibility Rules" even before synthesis.

### B. Thermal & Power Modeling
The **Hyper-NoC** at 2GHz creates massive heat signatures. Use:
```bash
python scripts/hyperion_thermal_model.py --node 2nm --clk 2.0GHz
```
If the simulation reports >120°C, you must enable **Backside Power Delivery (BSPDN)** in the RTL config.

---

## ⚠️ 3. Hardware Bottlenecks & Known Challenges

### 1. The Dark Silicon Problem
In the v2 "Ultra" (N7/N3), we cannot power all cores (CPU, GPU, TPU, NPU) at 100% simultaneously without melting the die.
*   **Solution:** Integrated "Power-Gating" in the Hyper-NoC. The NoC dynamically disables unused clusters.

### 2. Clock Domain Crossing (CDC)
The Hyper-NoC runs at 2GHz, but the peripherals (UART, GPIO) run at 50MHz.
*   **Problem:** Metastability at the interface.
*   **Solution:** We use **Async FIFO CDC Bridges** located in `rtl/bus/async_bridge.sv`.

### 3. Chiplet Interconnect Latency
In v3 "Hyperion", moving data between chiplets via **UCIe** introduces latency.
*   **Problem:** Stalls in the TPU pipe.
*   **Solution:** "Latency Hiding" using the shared 32MB L3 Cache as a buffer.

---

## 🛠️ 4. Building the Stack
To build a production binary for UPU:
1.  **Cross-Compile:** Use the RISC-V LLVM toolchain.
2.  **Link:** Link against `libupu_hal.a`.
3.  **Simulate:** Run on `tb/virtual_soc_sim.py` to check timing accuracy.
4.  **Synthesize:** Run `./scripts/tape_out_workflow_ultra.sh`.
