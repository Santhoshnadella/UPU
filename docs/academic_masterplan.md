# 🎓 UPU Academic Masterplan: Defense & Study Guide

This document prepares you to explain the **Unified Processing Unit (UPU)** to professors, industry experts, and researchers.

---

## 📚 1. The Study Syllabus
To defend this project, you must be comfortable with these four pillars:

### Pillar A: Computer Architecture (The "Brain")
*   **Study Heterogeneous Computing:** Understand why we move away from "CPU-only" designs. Key term: **Domain-Specific Accelerators (DSA)**.
*   **Study Parallelism:** Know the difference between **SIMD** (Single Instruction Multiple Data - used in our GPU) and **Systolic Arrays** (used in our TPU).
*   **Study Network-on-Chip (NoC):** Understand **Packet-Switching** vs. **Bus Arbiter**. Our "Hyper-NoC" uses packets, which is why it scales to 2nm chiplets.

### Pillar B: Digital VLSI (The "Biology")
*   **Study the Flow:** Be able to list the steps from **RTL (SystemVerilog)** → **Synthesis** → **Place & Route** → **Layout (GDSII)**.
*   **Study PDKs:** Know that a **Process Design Kit** is the "rulebook" given by a foundry (like Skywater or TSMC).
*   **Study DRC/LVS:** Design Rule Checks (ensuring wires aren't too thin) and Layout vs Schematic (ensuring the drawing matches the code).

### Pillar C: Next-Gen Semiconductors (The "Frontier")
*   **Concept of "Nodes":** Explain why 130nm is "Planar" and 2nm is **GAA (Gate-All-Around)**.
*   **Backside Power Delivery (BSPDN):** This is a v3 Hyperion feature. Explain that we move power wires to the *back* of the silicon to save space and reduce heat on the front.

---

## 🎙️ 2. The Speech Script (5-Minute Pitch)

**The Hook:**
"Good morning, Professors. Today I am presenting UPU—the Unified Processing Unit. The central problem in modern computing is the 'Von Neumann Bottleneck'—the slow speed of data moving between the CPU and specialized accelerators. UPU is my solution: a 'Silicon Stem Cell' architecture that scales from 130nm Edge IoT to a 3D-stacked 2nm High-Performance Superchip."

**The Technical Core:**
"At the heart of UPU is not a single core, but the **Hyper-NoC**. Unlike standard AXI busses that suffer from congestion, our Hyper-NoC is a packet-switched vascular system. It connects four specialized engines: 
1. The **Titan GPU** for vector math.
2. The **Infinity TPU** for massive tensor operations.
3. The **Echo NPU** for sparse edge AI.
4. And a **RISC-V CPU** for general control.

What makes this project revolutionary is **Scale-Independent RTL**. The same code I’ve written for 130nm can be differentiated into a GAA-based 2nm chiplet system by simply modifying the physical synthesis constraints."

**The Validation:**
"I have validated this design through a three-stage pipeline: 100% UVM coverage for logic, thermal modeling for 2GHz operation, and a transistor-exact visual simulator that allows for real-time architectural introspection. We are currently 'Tape-Out Ready' for the ISM SCL-180nm and Efabless Sky130 shuttles."

**The Closing:**
"UPU isn't just a chip; it's a blueprint for an indigenous, unified, and open-source semiconductor future. Thank you."

---

## 💻 3. Codebase Walkthrough: How Systems Work Together

When you show your code, follow this flow:

### 1. The Entrance (`rtl/upu_top.sv`)
This is the "skin" of the chip. It takes the Clock and Reset and instantiates the **Hyper-NoC**.
*   **Reference**: Point to where all the cores (CPU, GPU, TPU) connect to the NoC.

### 2. The Traffic Controller (`rtl/bus/hyper_noc.sv`)
This is the most complex part of your project. 
*   **How it works**: When the CPU wants to send data to the TPU, it doesn't "write to a wire." It creates a **Packet**. The NoC looks at the "Address Header" and routes it to the TPU port. This allows the GPU to talk to the Memory *at the same time* without stopping the CPU.

### 3. The Muscles (`rtl/cores/`)
*   **tpu_infinity.sv**: Explain the **Systolic Array**. Data flows like a "wave" through multipliers to compute MatMul (Matrix Multiplication) for AI.
*   **gpu_titan.sv**: Explain **Vector Clusters**. It handles many small numbers (Floating Point) at once for graphics or physics.

### 4. The Bridge (`rtl/bus/ucie_d2d_bridge.sv`)
In the v3 Hyperion, this is how two different silicon dies (chiplets) talk to each other. It uses the **UCIe standard**, which is the USB equivalent for chiplets.

---

## 🔧 4. System Interaction Example (The "Life of a Calculation")
**Question from Professor: "How does an AI model actually run on this?"**
1.  **Instruction Fetch**: The RISC-V CPU fetches an instruction from **ROM**.
2.  **Accelerator Dispatch**: The CPU realizes it’s a "Tensor Operation" and sends a command packet through the **Hyper-NoC**.
3.  **Data Movement**: The NoC pulls weights from the **HBM3 Memory Controller** and pushes them into the **TPU's local SRAM**.
4.  **Execution**: The **TPU Infinity** performs the calculation.
5.  **Completion**: The **PMU (Power Management Unit)** detects the TPU has finished and dials back the voltage to save power (entering ECO_MODE).

---
