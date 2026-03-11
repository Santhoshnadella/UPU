# 🚀 UPU: Unified Processing Unit
### *The Stem Cell of Silicon Architecture*

[![Status](https://img.shields.io/badge/Status-100%25%20RTL%20Complete-brightgreen)](https://github.com/Santhoshnadella/UPU)
[![Milestone](https://img.shields.io/badge/Next%20Step-Physical%20Tape--Out-blueviolet)](docs/implementation_plan.md)
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

## 💡 Why UPU is Revolutionary

The Unified Processing Unit isn't just another chip; it is a **paradigm shift** in computer architecture. 

### 1. The Death of the "Processor Silo"
Traditional systems treat the CPU, GPU, and TPU as separate islands that talk to each other over slow, congested bridges. This is the **Von Neumann Bottleneck**. 
*   **The UPU Revolution:** UPU replaces these bridges with the **Hyper-NoC (Network-on-Chip)**—a high-speed, packet-switched vascular system. Data doesn't "travel" between processors; it flows through a unified compute fabric, making it the first architecture designed for the era of **Massive Parallelism**.

### 2. Software-Defined Hardware
Until now, scaling from an IoT sensor to a Supercluster required complete hardware redesigns.
*   **The UPU Revolution:** Because UPU is a **Silicon Stem Cell**, the same low-level HAL (Hardware Abstraction Layer) works across all versions. A developer can write code for a v1 Edge device and, with zero structural changes, deploy it to a 2nm v3 Hyperion superchip.

### 3. Open-Source High-End Silicon
High-performance silicon (7nm, 3nm, 2nm) has historically been locked behind billion-dollar corporate vaults.
*   **The UPU Revolution:** By mapping industrial-grade architectures (GAA, Backside Power, UCIe) into an open-source RTL framework, UPU democratizes the bleeding edge of semiconductor technology.

---

## 🏗️ How This Was Possible: The Engineering Stack

This project was realized through a multi-layered synthesis of modern EDA (Electronic Design Automation):
1.  **SystemVerilog & Hardware Contracts:** Utilizing strict architectural validation to ensure every gate behaves as intended before a single atom of silicon is moved.
2.  **OpenLane & LibreLane:** Leveraging cutting-edge open-source physical design tools to map logic to real-world PDKs (Sky130).
3.  **Cross-Node Modeling:** Simulating the electrical characteristics of GAA (Gate-All-Around) and BSPDN (Backside Power) through advanced thermal and power modeling scripts.
4.  **Visual Verification:** Using custom-built HTML simulators (`Visual UPU`) to debug transistor-level logic with visual intuition rather than just text logs.

---

## 📈 Current Progress & Milestone Tracker

- [x] **v1 RTL (Edge):** 100% Complete & Verified.
- [x] **v2 Ultra RTL (HPC):** 100% Complete (Hyper-NoC Integration Finished).
- [x] **v3 Hyperion Spec:** 100% Defined (UCIe & Chiplet Hubs Implemented).
- [x] **Visual Simulators:** Transistor-exact modeling complete.
- [ ] **Physical Synthesis:** In-progress for N7/N3 target nodes.
- [ ] **Tape-Out:** Scheduled for upcoming MPW (Multi-Project Wafer) runs.

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

## 🔬 Literature Survey & Competitive Analysis

How does UPU compare to the most prominent open-source hardware research and industrial projects in the world?

| Feature | **UPU (This Project)** | **OpenPiton** [1] | **ESP Platform** [2] | **PULP Platform** [3] | **Celerity SoC** [4] |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Architectural Scope** | **End-to-End** (Edge to HPC) | General-purpose Manycore | SoC Integration Platform | Ultra Low-Power (IoT) | Tiered Accelerator Fabric |
| **Heterogeneous Cores** | **Unified**: CPU+GPU+TPU+NPU | Primarily CPU (RISC-V) | Accelerator Socket-based | RISC-V Clusters | CPU + Manycore + BNN |
| **Interconnect** | **Hyper-NoC** + UCIe Chiplets | P-Mesh NoC | Heterogeneous NoC | Crossbar / NoC | Tiered Fabric NoC |
| **Silicon Nodes** | **130nm → 7nm → 2nm GAA** | IBM 32nm / TSMC 28nm | Various (FPGA/ASIC) | GF 22nm | TSMC 16nm FFC |
| **Visual Verification** | **Yes**: Transistor-Exact Sim | No (Waveform only) | No | No | No |
| **Open Source** | **Full RTL Monorepo** | Permissive | Open SoC Platform | Permissive | Partially Open |

### **References:**
*   [1] **OpenPiton**: *Jonathan Balkind et al.*, "OpenPiton: An Open Source Manycore Research Platform," ASPLOS 2016.
*   [2] **ESP**: *Luca Carloni et al.*, "The Embedded Scalable Platforms Interface," Columbia University.
*   [3] **PULP**: *Luca Benini et al.*, "Parallel Ultra-Low-Power Platform for IoT," DATE 2017.
*   [4] **Celerity**: *Scott Davidson et al.*, "The Celerity Open-Source RISC-V Tiered Accelerator Fabric SoC," IEEE Micro 2018.

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
