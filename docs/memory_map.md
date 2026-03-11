# UPU v1 SoC Memory Map

The UPU (Unified Processing Unit) v1 uses a unified 32-bit address space (0x00000000 to 0xFFFFFFFF) mapped via a 64-bit AXI4 interconnect.

| Range Start | Range End | Size | Target Module | Description |
| :--- | :--- | :--- | :--- | :--- |
| **0x0000 0000** | 0x0000 0FFF | 4 KB | **Boot ROM** | Hardware boot vector, crt0 code. |
| **0x1000 0000** | 0x1003 FFFF | 256 KB | **L2 Shared SRAM** | Shared Instruction/Data memory. |
| **0x3000 0000** | 0x3000 0FFF | 4 KB | **TPU Core** | Systolic Array (16x16 INT8) Control. |
| **0x3000 1000** | 0x3000 1FFF | 4 KB | **NPU Core** | Neural MAC (Saturated) Control. |
| **0x3000 2000** | 0x3000 2FFF | 4 KB | **GPU Core** | Vector SIMD (32x32-bit) Control. |
| **0x3000 3000** | 0x3000 3FFF | 4 KB | **PU Core** | Secondary Auxiliary Scalar Unit. |
| **0x4000 0000** | 0x4000 0FFF | 4 KB | **PLIC** | Intterupt Controller (8 sources). |
| **0x5000 0000** | 0x5000 03FF | 1 KB | **UART** | Serial Interface (AXI-Lite). |
| **0x5001 0000** | 0x5001 03FF | 1 KB | **Timer** | Global SoC System Timer. |
| **0x5002 0000** | 0x5002 03FF | 1 KB | **GPIO** | General Purpose I/O (8-bit). |

---

## Peripheral Register Details

### TPU (0x3000 0000)
- `0x00`: **CTRL** (R/W) 
  - `[0]` Start (Write only)
  - `[1]` Busy (Read only)
  - `[2]` Done / Clear (R/W)
- `0x04`: **NORTH_SRC** (R/W) - Memory base for A matrix.
- `0x08`: **WEST_SRC** (R/W) - Memory base for B matrix.
- `0x0C`: **COUNT** (R/W) - Total steps (usually 16).

### GPU (0x3000 2000)
- `0x00`: **EXEC** (W) 
  - `[0]` Trigger execution.
  - `[3:1]` Opcode (0=ADD, 1=SUB, 2=AND, 3=OR, 5=MAX).
- `0x04`: **DEST_ID** (R/W) - VRF register index (0-31).
- `0x08`: **SRC_A_ID** (R/W) - First operand VRF index.
- `0x0C`: **SRC_B_ID** (R/W) - Second operand VRF index.

### PLIC (0x4000 0000)
- `0x000-0x01C`: **PRIO[0-7]** (R/W) - Source priorities.
- `0x400`: **PENDING** (R) - Bitmask of active interrupt requests.
- `0x800`: **ENABLE** (R/W) - Mask to enable/disable sources.
- `0xC00`: **THRESHOLD** (R/W) - Global interrupt threshold level.

---

## Interrupt Assignment Table
| Source ID | Core/Peripheral | Description |
| :---: | :--- | :--- |
| **0** | TPU | Matrix Multiplication Complete. |
| **1** | NPU | Activation Pipeline Complete. |
| **2** | GPU | Vector Operation Complete. |
| **3** | PU | Auxiliary Unit Done. |
| **4** | DMA | Spare (L2 Memory DMA Done). |
| **5** | UART | RX Data Ready / TX Buffer Empty. |
| **6** | Timer | System Tick / Compare Match. |
| **7** | GPIO | Input Pin State Changed. |
