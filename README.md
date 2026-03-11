# 🚀 UPU: Unified Processing Unit
### *The Stem Cell of Silicon Architecture*

[![Status](https://img.shields.io/badge/Status-100%25%20Complete-brightgreen)](https://github.com/Santhoshnadella/UPU)
[![Node](https://img.shields.io/badge/Node-130nm%20%E2%86%92%202nm-blue)](docs/research_paper.md)
[![License](https://img.shields.io/badge/License-MIT-orange)](LICENSE)

---

## 🧬 The Analogy: The Stem Cell
Think of the **UPU (Unified Processing Unit)** as the **Stem Cell of Silicon Architecture**. 

In biology, a stem cell is a blank slate containing the genetic blueprint to become anything—a simple skin cell or a complex neuron. It adapts based on its environment. 

**UPU works the same way:**
*   **At the Edge (v1):** It acts like a fundamental cell, sipping milliwatts of power to handle IoT tasks in Skywater 130nm.
*   **In the Workstation (v2 Ultra):** It differentiates into a specialized muscle, driving AAA gaming and massive LLMs on 7nm/3nm nodes.
*   **In the Datacenter (v3 Hyperion):** It evolves into a complex 3D-stacked neural network, utilizing 2nm GAA chiplets and backside power delivery to define the future of HPC.

**One RTL codebase. Infinite differentiation.**

---

## 🌍 The Three Eras of UPU

### 🟢 Phase 1: UPU v1 (Edge & IoT)
*   **Target:** Low-power embedded AI.
*   **Node:** Skywater 130nm Open-Source PDK.
*   **Architecture:** 64-bit AXI4 Crossbar.
*   **Cores:** RV64I CPU + 16x16 TPU + 32-lane GPU + Echo NPU.
*   **Status:** Silicon-Ready.

### 🔵 Phase 2: UPU v2 "Ultra" (The Superchip)
*   **Target:** HPC Workstations & AAA Gaming.
*   **Node:** 7nm FinFET / 3nm GAA.
*   **Architecture:** Multi-Terabit **Hyper-NoC** (Packet-switched).
*   **Cores:** Titan GPU (Ray-tracing) + Infinity TPU (Text-to-Video).
*   **Status:** RTL Verified.

### 🟣 Phase 3: UPU v3 "Hyperion" (The Chiplet Frontier)
*   **Target:** Next-Gen HPC & Massive AI Training.
*   **Node:** 2nm GAA (Gat-All-Around).
*   **Architecture:** 3D-Stacked Chiplets with **UCIe** D2D Interconnects.
*   **Features:** Backside Power Delivery (BSPDN), HBM3 Integration.
*   **Status:** Final Spec & TCG Layout.

---

## 🛠️ Repository Structure

```tree
├── rtl/               # Hardware Definition (SystemVerilog)
│   ├── cores/         # Titan GPU, Infinity TPU, Echo NPU, CPU
│   ├── bus/           # Hyper-NoC & UCIe Bridge logic
│   └── v3_hyperion/   # Chiplet-specific hub & compute nodes
├── docs/              # Specifications & Research Papers
├── firmware/          # Low-level HAL & Bare-metal drivers
├── scripts/           # Synthesis & Tape-out automation (OpenLane/TCL)
└── visual_sim/        # Interactive Silcon Dashboards & Transistor Sims
```

---

## 🕹️ Interactive Simulations
We don't just write code; we visualize the silicon.
*   [**Visual UPU Transistor-Exact Sim**](docs/visual_upu_transistor_exact.html): A 1:1 functional replication of the "Visual 6502" for the UPU architecture.
*   [**UPU Floorplan Viewer**](docs/upu_v2_floorplan.html): Interactive layout of the Ultra SoC.
*   [**Silicon Dashboard**](docs/upu_universal_dashboard.html): Real-time metrics and roadmap visualization.

---

## ⚡ Quick Start (Synthesis)

### For Edge (v1):
```bash
make firmware && make physical
```

### For HPC (v2/v3):
```bash
./scripts/tape_out_workflow_ultra.sh
```

---

## 🤝 Roadmap & Future
The UPU project is now **100% RTL Complete**. The next frontier is physical tape-out through open-source MPW programs and industrial GAA fabrication runs.

**"The hardware is the body; the architecture is the DNA. UPU is the first living silicon."**

---

Created by **Santhosh Nadella**.
