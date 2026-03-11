#!/bin/bash
# UPU v1: Silicon Tape-Out Workflow (Locally Run on EDA Workstation)
# -----------------------------------------------------------------------------
# This script automates the full flow from Firmware -> Simulation -> Synthesis.

set -e

echo "--- [UPU v1 SoC: Tape-out Push Started] ---"

# 1. Compile Firmware (Requires riscv64-unknown-elf-gcc)
echo "[Step 1/4] Building SoC Firmware..."
make firmware
echo "SUCCESS: Bootloader generated at ./build/bootloader.bin"

# 2. Run Logical Verification (Requires Icarus Verilog / IVerilog)
echo "[Step 2/4] Executing RTL Verification Suite..."
make all
echo "SUCCESS: All core testbenches passed simulation."

# 3. Silicon Synthesis (Requires Yosys + Sky130 PDK)
echo "[Step 3/4] Synthesizing RTL to Gate-Level Netlist (Sky130B)..."
make synth
echo "SUCCESS: Gate-level netlist (GLN) finalized for upu_top."

# 4. Physical Design (Requires OpenLane / LibreLane)
echo "[Step 4/4] Executing Physical Layout flow (GDSII)..."
make physical
echo "SUCCESS: Silicon Masks generated at ./OpenLane/runs/upu_top/results/final/gds/"

echo "--- [UPU v1 SoC: TAPE-OUT PUSH COMPLETE] ---"
echo "The GDSII file is ready for fabrication at the foundry."
