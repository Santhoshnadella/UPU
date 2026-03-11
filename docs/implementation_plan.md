# 🗺️ UPU Implementation Masterplan (8-Phase Roadmap)

This document outlines the 8-week transformation of the UPU repository from a skeleton to a 9/10 industry-standard VLSI project.

---

## 📅 Roadmap Overview

| Phase | Timeline | Focus Area | Key Deliverables |
| :--- | :--- | :--- | :--- |
| **0** | Day 1-2 | **Baseline** | License, GHA Lint, Clean Repo, Basic Makefile |
| **1** | Week 1 | **CPU Core** | Synthesizable RV64I Core + AXI4-Lite Wrapper |
| **2** | Week 2 | **Hyper-NoC** | 4x4 Mesh, 3 Priority Levels, Real-time WCET (<20 cycles) |
| **3** | Week 3 | **Verification** | UVM 1.2 Environment, 95%+ Coverage, `make uvm` |
| **4** | Week 4 | **Physical Design** | OpenLane Flow, GDSII, Area/Power/STA/Thermal Reports |
| **5** | Week 5 | **FPGA Integration** | Arty A7 Wrapper, UART, "UPU Alive" Firmware |
| **6** | Week 6 | **CI/CD & Docs** | Full GHA Pipelines, Micro-arch PDF, README Badges |
| **7** | Week 7 | **Advanced Cores** | GPU/TPU/NPU Skeletons with AXI-Stream Interfaces |
| **8** | Week 8 | **Tape-out Ready** | Final Sign-off, MPW Submission Checklist, 9/10 Rating |

---

## 🛠️ Technology Stack
- **RTL**: SystemVerilog-2017 (Strict Linting)
- **Verification**: UVM 1.2 + Verilator / Icarus Verilog
- **Physical Design**: OpenLane (Sky130 PDK)
- **FPGA**: Vivado WebPACK (Arty A7-100T)
- **CI/CD**: GitHub Actions

---

## 📋 The "9/10" Standard Checklist
- [ ] No latches, no `initial` blocks in synthesizable code.
- [ ] Synchronous resets + Proper CDC (Gray Coding) everywhere.
- [ ] Registered outputs for all hierarchy boundaries.
- [ ] 95%+ Functional + Code + Toggle Coverage.
- [ ] Clean DRC/LVS on Sky130.
- [ ] Deterministic Latency (WCET) on NoC high-priority packets.
