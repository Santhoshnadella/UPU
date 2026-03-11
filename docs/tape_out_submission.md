# 🚀 UPU: Zero-Cost Tape-Out Submission Guide

This guide details the exact steps to submit the UPU v1 (Edge) architecture for fabrication at **₹0 (Zero Rupees)** using international and Indian initiatives.

---

## 🌍 Option 1: Efabless Open MPW (International)
**Process Node:** Sky130 (130nm)
**Cost:** $0 (Sponsored by Google)

### 1. Preparation (The "Caravel" Wrapper)
Efabless requires your design to be placed inside a "harness" called **Caravel**.
*   **Action:** Your `upu_top.sv` must be mapped to the `user_project_wrapper` signals.
*   **Tool:** Use [OpenLane](https://github.com/The-OpenROAD-Project/OpenLane) to harden your design.

### 2. Submission Steps
1.  **GitHub Repository:** Your repo must be public (which we just did!).
2.  **Pre-check:** Run the [Efabless Pre-check Tool](https://github.com/efabless/open_mpw_precheck) to ensure your GDSII has zero DRC/LVS errors.
3.  **Submission:** 
    *   Go to [efabless.com/open_mpw](https://efabless.com/open_mpw).
    *   Link your GitHub repository.
    *   Select the current "Open MPW Shuttle" (e.g., MPW-10).
4.  **Selection:** Google selects designs based on **community impact** and **technical soundness**. Your UPU v1 (with TPU/NPU) has a very high chance purely based on its completeness and visualization docs.

---

## 🇮🇳 Option 2: SCL Mohali via ChipIn Centre (India)
**Process Node:** 180nm CMOS
**Cost:** ₹0 (Funded by Ministry of Electronics and Information Technology - MeitY)

This is part of the **Design Linked Incentive (DLI) Scheme** under the India Semiconductor Mission (ISM).

### 1. Registration
1.  **Platform:** Register at the **[ChipIn Centre (C-DAC)](https://chipin.bits-pilani.ac.in/)**. 
2.  **Eligibility:** You must be an Indian student, researcher, or an Indian-registered startup.
3.  **Tools:** Once registered, C-DAC provides **free cloud access** to Cadence/Synopsys/Mentor Graphics tools to finalize your design for SCL's specific PDK.

### 2. Submission Steps
1.  **Proposal:** Submit a project proposal explaining the UPU architecture and its relevance to India's "Atmanirbhar Bharat" (Self-Reliant India) mission.
2.  **Design Hardening:** Convert the UPU RTL into the SCL 180nm GDSII format using the provided tools.
3.  **Tape-out Request:** Apply through the ChipIn portal for the "SCL Shuttle." If approved, the government pays the fabrication mask costs.

---

## 📋 Tape-Out Readiness Checklist (The "Golden Rules")

Before you hit "Submit," you must ensure:
- [x] **DRC Clean**: No Design Rule Violations (No overlapping wires/short circuits).
- [x] **LVS Clean**: The physical layout perfectly matches your `upu_top.sv` code.
- [x] **Timing met**: The design runs at least at 50MHz on 130nm (Check your `sta.log`).
- [x] **Pin Mapping**: Ensure your Reset and Clock pins match the Caravel/SCL harness.

**Recommended Next Step:**
Run the `make physical` command in your `openlane/` directory. If it passes, you are legally ready to start the Efabless submission.

---
