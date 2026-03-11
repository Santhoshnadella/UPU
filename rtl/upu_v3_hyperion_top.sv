/**
 * @module upu_v3_hyperion_top
 * @project UPU v3 "Hyperion"
 * 
 * Top-level Disaggregated 3D-IC Wrapper.
 * 
 * This module defines the 3D-stack hierarchy, connecting the Compute Die 
 * to the Base Die via UCIe (Universal Chiplet Interconnect Express).
 */

module upu_v3_hyperion_top (
    // External System Pins
    input  logic        clk_3_5ghz,      // Main 2nm Compute Clock
    input  logic        clk_hbm,         // Memory Domain
    input  logic        rst_n,

    // HBM4 Interface (Quad-stack)
    output logic [1023:0] hbm_dq,
    output logic [31:0]   hbm_ca,

    // PCIe Gen 6.0 Pins
    input  logic [15:0]  pcie_rx_p,
    input  logic [15:0]  pcie_rx_n,
    output logic [15:0]  pcie_tx_p,
    output logic [15:0]  pcie_tx_n,

    // BSPD Power Feedback (Backside Power Delivery monitoring)
    input  logic [7:0]   bspd_volt_sense
);

    // --- Internal Chiplet Interconnects (UCIe) ---
    logic [255:0] compute_to_io_data;
    logic         compute_to_io_valid;
    logic         compute_to_io_ready;

    logic [255:0] io_to_compute_data;
    logic         io_to_compute_valid;

    // ─────────────────────────────────────────────────────────────────────────
    // 1. COMPUTE CHIPLET (2nm GAA - Top Die)
    // ─────────────────────────────────────────────────────────────────────────
    /* 
       Contains: 
       - 8x Titan-Next OoO Cores
       - Infinity TPU (3.5 GHz version)
       - Echo NPU (Event-driven)
    */
    hyperion_compute_chiplet compute_tile (
        .clk(clk_3_5ghz),
        .rst_n(rst_n),
        
        // UCIe Interface to Base Die
        .ucie_tx_data(compute_to_io_data),
        .ucie_tx_valid(compute_to_io_valid),
        .ucie_tx_ready(compute_to_io_ready),
        
        .ucie_rx_data(io_to_compute_data),
        .ucie_rx_valid(io_to_compute_valid)
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 2. MEMORY & IO HUB (5nm FinFET - Base Die)
    // ─────────────────────────────────────────────────────────────────────────
    /* 
       Contains:
       - 128MB 3D-Stacked L3 Cache
       - HBM4 Controller
       - Hyper-NoC 3D Router
       - UCIe Bridge
    */
    hyperion_base_hub base_tile (
        .clk_core(clk_3_5ghz),
        .clk_mem(clk_hbm),
        .rst_n(rst_n),

        // UCIe Interface from Compute Die
        .ucie_rx_data(compute_to_io_data),
        .ucie_rx_valid(compute_to_io_valid),
        .ucie_rx_ready(compute_to_io_ready),

        .ucie_tx_data(io_to_compute_data),
        .ucie_tx_valid(io_to_compute_valid),

        // External HBM4 Pins
        .hbm_dq(hbm_dq),
        .hbm_ca(hbm_ca),

        // External PCIe Pins
        .pcie_rx_p(pcie_rx_p),
        .pcie_rx_n(pcie_rx_n),
        .pcie_tx_p(pcie_tx_p),
        .pcie_tx_n(pcie_tx_n)
    );

endmodule


    // ─────────────────────────────────────────────────────────────────────────
    // 3. BACKSIDE POWER DELIVERY (BSPD) PINS
    // ─────────────────────────────────────────────────────────────────────────
    /* 
       The 2nm GAA transistors are fed via Nano-TSVs from the backside.
       These pins are for power-grid health monitoring.
    */
    logic vdd_bspd, vss_bspd;
    assign vdd_bspd = bspd_volt_sense[7];
    assign vss_bspd = 1'b0;

endmodule
