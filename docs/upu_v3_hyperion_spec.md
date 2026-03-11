# UPU v3 "Hyperion" Architectural Specification
**Target Node**: 2nm GAA (Gate-All-Around) with Backside Power Delivery (BSPD)
**Architecture**: Disaggregated 3D Heterogeneous Chiplet System
**Status**: Initial Spec & Kickoff

---

## 1. Design Philosophy: The Disaggregated Leap
The **UPU v3 "Hyperion"** moves away from the monolithic constraints of v2. By utilizing **TSMC SoIC (System on Integrated Chips)**, we stack high-performance compute logic directly over energy-efficient I/O and Cache tiles, eliminating the "routing wall" and NoC congestion encountered at 7nm.

## 2. Core Chiplet breakdown (Disaggregated)

### 🚀 Compute Tile (Hyperion-C)
*   **Process**: 2nm GAA.
*   **Cores**: 8x Titan-Next OoO Cores (P-Cores) + 32x Efficiency Cores.
*   **Specialty**: Pure logic, zero internal SRAM macros to maximize thermal dissipation.
*   **Voltage**: 0.70V Nominal (Ultra-low voltage for 2nm efficiency).

### 🧠 Cache & Memory Hub (Hyperion-M)
*   **Process**: 5nm FinFET (Cost-optimized for SRAM density).
*   **L3 Cache**: 128MB 3D-stacked SRAM (Base die).
*   **Interconnect**: Photonic PHYs for multi-terabit chiplet-to-chiplet fabric.
*   **Memory**: Support for **HBM4** (1024 GB/s theoretical peak).

### 🔌 I/O & Connectivity (Hyperion-X)
*   **Process**: 6nm/7nm (Optimized for Analog/PHY).
*   **Connectivity**: PCIe Gen 6.0, CXL 3.0, and 800G Ethernet PHYs.

---

## 3. Backside Power Delivery (BSPD) Strategy
To solve the IR-drop issues seen in v2's TPU:
*   **Frontside**: Dedicated entirely to signal routing (M1-M15).
*   **Backside**: Power and Ground delivery (V_{DD}/V_{SS}) via **Nano-TSVs** directly to the transistor source/drain.
*   **Benefit**: 30% reduction in power network impedance and 15% area savings by removing frontside PDN straps.

---

## 4. Hyper-NoC 3D Fabric
*   **Extension**: The NoC now spans vertically through the 3D stack.
*   **Topology**: 3D Torus (Packet-switched) with integrated photonic routing for cross-chiplet jumps.
*   **Throughput Target**: 10 Terabits per second cross-sectional bandwidth.

---

## 5. Implementation Roadmap
1. [ ] **v3.1**: PDK Characterization for 2nm GAA-FETs.
2. [ ] **v3.2**: SystemC modeling of 3D-Stacked L3 latency.
3. [ ] **v3.3**: BSPD Power Integrity (PI) simulation in Cadence Voltus.
4. [ ] **v3.4**: Photonic Interconnect Proto-Link validation.
