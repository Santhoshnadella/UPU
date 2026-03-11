/**
 * @module hyperion_compute_chiplet
 * @project UPU v3 "Hyperion"
 * 
 * 2nm GAA (Gate-All-Around) Compute Tile.
 * Contains the primary logic clusters: Titan CPUs and Infinity TPU.
 * Designed for 3.5 GHz operation.
 */

module hyperion_compute_chiplet (
    input  logic         clk,
    input  logic         rst_n,

    // UCIe Interface to Base Die (3D Stack)
    output logic [255:0] ucie_tx_data,
    output logic         ucie_tx_valid,
    input  logic         ucie_tx_ready,
    input  logic [255:0] ucie_rx_data,
    input  logic         ucie_rx_valid
);

    // --- Internal Signals ---
    logic [255:0] noc_packet;
    logic         noc_valid;

    // ─────────────────────────────────────────────────────────────────────────
    // 1. TITAN CPU CLUSTER (Titan-Next)
    // ─────────────────────────────────────────────────────────────────────────
    // 8x P-Cores with 18-stage pipeline for 3.5 GHz
    rv64_titan_next #(
        .XLEN(64),
        .PIPELINE_STAGES(18)
    ) cpu_cluster_0 (
        .clk(clk),
        .rst_n(rst_n),
        .instr_addr(),             // Connected to L1 Instruction cache
        .instr_req(),
        .instr_data(32'h0),
        .instr_valid(1'b0),
        .noc_tx_packet(noc_packet),
        .noc_tx_valid(noc_valid),
        .noc_tx_ready(1'b1)
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 2. INFINITY TPU (v3 Sparse-Decompression)
    // ─────────────────────────────────────────────────────────────────────────
    tpu_infinity_v3 #(
        .N(1024),
        .DATA_WIDTH(16)
    ) tpu_array (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(ucie_rx_data),
        .valid_in(ucie_rx_valid),
        .ready_out(),
        .weight_compressed_in(256'h0),
        .weight_valid(1'b0)
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 3. UCIe D2D BRIDGE (Silicon Link)
    // ─────────────────────────────────────────────────────────────────────────
    ucie_d2d_bridge #(
        .FLIT_WIDTH(256),
        .LANES(16)
    ) compute_link (
        .clk_core(clk),
        .rst_n(rst_n),
        
        .tx_data_in(noc_packet),
        .tx_valid_in(noc_valid),
        .tx_ready_out(),           // Logic for NoC backpressure

        .rx_data_out(ucie_rx_data), // Bridge to internal fabric
        .rx_valid_out(ucie_rx_valid),

        // Physical UCIe pins (not exposed here, handled at top-level)
        .ucie_tx_p(), .ucie_tx_n(), .ucie_rx_p(), .ucie_rx_n(),
        .ucie_sideband()
    );

endmodule
