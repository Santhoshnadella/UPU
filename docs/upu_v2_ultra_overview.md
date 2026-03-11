# UPU v2 "Ultra": High-Performance Computing (HPC) SoC

Targeting the pinnacle of compute performance for **AAA Gaming**, **1B Parameter AI Models (Text-2-Video)**, and **On-Device Edge Intelligence**.

---

## 🚀 Performance Overview
- **Frequency**: **2.0 GHz** (2000 MHz) @ 7nm Node.
- **Memory Bandwidth**: **512 GB/s** via Triple-Channel **HBM3**.
- **Accelerator Peak**: **128 TFLOPS** (FP16/BF16) for TPU Infinity.
- **Graphics Power**: **AAA Title Capable** (DirectX 12 / Vulkan Level Shader Core).

---

## 📐 Architecture Modules

### 1. CPU: Titan Core Cluster
- **Architecture**: RV64GC (RISC-V 64-bit with Multi-core support).
- **Performance**: 4-Issue **Out-of-Order (OoO)** Superscalar.
- **Cache**: 64KB L1 / 1MB L2 / 32MB Shared L3.
- **Target**: High-speed task orchestration and physics logic.

### 2. GPU: Titan Shader Array
- **Capability**: **AAA Gaming Pipeline**.
- **Shader Clusters**: 64 Unified Compute Units (CUs).
- **Dedicated Tech**: Hardware **BVH Traversal** for Real-time Ray Tracing.
- **Output**: 4K @ 60fps capable logic pipeline.

### 3. TPU: Infinity Tensor Engine
- **Target**: **1 Billion Parameter Models** (Transformers / Diffusion).
- **Compute**: **1024x1024 Systolic Clusters**.
- **Data Flow**: Optimized for **Text-to-Video** inference and training.
- **Precision**: BF16, FP16, INT8, and FP8 support.

### 4. NPU: Echo Edge Intelligence
- **Efficiency**: Optimized for low-power "Always On" AI.
- **Features**: **Hard-wired Sparsity Support** (Skips 0-weight ops) and **INT4/INT2** Quantization.
- **Target**: On-device voice, vision, and contextual intelligence.

---

## ⚡ Power & Physical (HPC Ready)
- **Node**: **7nm FinFET** / **GAA (Gate-All-Around)**.
- **Thermal Design Power (TDP)**: **125W** (Active-cooled workstation target).
- **Voltage**: 0.85V Nominal.
- **Backbone**: **Hyper-NoC** Mesh Interconnect (Multi-Terabit bandwidth).

---

## 🏭 Tape-Out Push
The **UPU v2 "Ultra"** implementation is finalized at the architectural level. To begin GDSII generation, follow the [ultra_config.tcl](file:///k:/upu/upu-fab/scripts/ultra_config.tcl) and utilize the `N7` industrial PDK.
