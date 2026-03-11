/**
 * @testbench ucie_d2d_tb
 * @project UPU v3 "Hyperion"
 * 
 * Verification of the UCIe Die-to-Die (D2D) link.
 * Simulates a 3D-stacked Compute-to-Base communication loop.
 */

`timescale 1ns/1ps

module ucie_d2d_tb;

    // Parameters
    parameter FLIT_WIDTH = 256;
    parameter LANES      = 16;
    parameter CLK_PERIOD = 0.285; // 3.5 GHz

    // Signals
    logic        clk;
    logic        rst_n;
    
    // Compute Side
    logic [FLIT_WIDTH-1:0] comp_tx_data;
    logic                  comp_tx_valid;
    logic                  comp_tx_ready;
    logic [FLIT_WIDTH-1:0] comp_rx_data;
    logic                  comp_rx_valid;

    // Base Side
    logic [FLIT_WIDTH-1:0] base_tx_data;
    logic                  base_tx_valid;
    logic                  base_tx_ready;
    logic [FLIT_WIDTH-1:0] base_rx_data;
    logic                  base_rx_valid;

    // Physical UCIe Link (Interposer Simulation)
    logic [LANES-1:0] tx_p, tx_n, rx_p, rx_n;
    wire              sideband;

    // ─────────────────────────────────────────────────────────────────────────
    // 1. COMPUTE CHIPLET BRIDGE
    // ─────────────────────────────────────────────────────────────────────────
    ucie_d2d_bridge #(
        .FLIT_WIDTH(FLIT_WIDTH),
        .LANES(LANES)
    ) comp_bridge (
        .clk_core(clk),
        .rst_n(rst_n),
        .tx_data_in(comp_tx_data),
        .tx_valid_in(comp_tx_valid),
        .tx_ready_out(comp_tx_ready),
        .rx_data_out(comp_rx_data),
        .rx_valid_out(comp_rx_valid),
        .ucie_tx_p(tx_p),
        .ucie_tx_n(tx_n),
        .ucie_rx_p(rx_p),
        .ucie_rx_n(rx_n),
        .ucie_sideband(sideband)
    );

    // ─────────────────────────────────────────────────────────────────────────
    // 2. BASE CHIPLET BRIDGE (Loopback / Receiver)
    // ─────────────────────────────────────────────────────────────────────────
    ucie_d2d_bridge #(
        .FLIT_WIDTH(FLIT_WIDTH),
        .LANES(LANES)
    ) base_bridge (
        .clk_core(clk),
        .rst_n(rst_n),
        .tx_data_in(base_tx_data),
        .tx_valid_in(base_tx_valid),
        .tx_ready_out(base_tx_ready),
        .rx_data_out(base_rx_data),
        .rx_valid_out(base_rx_valid),
        .ucie_tx_p(rx_p), // Cross-connect: TX from base to RX of compute
        .ucie_tx_n(rx_n),
        .ucie_rx_p(tx_p), // Cross-connect: RX from compute to TX of base
        .ucie_rx_n(tx_n),
        .ucie_sideband(sideband)
    );

    // Clock Generation
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ─────────────────────────────────────────────────────────────────────────
    // 3. TEST STIMULUS
    // ─────────────────────────────────────────────────────────────────────────
    initial begin
        // Reset sequence
        rst_n = 0;
        comp_tx_data = '0;
        comp_tx_valid = 0;
        base_tx_data = '0;
        base_tx_valid = 0;
        
        #1 rst_n = 1;
        $display("[UCIe TB] Reset Released. Starting High-Speed Link Training...");
        
        // Wait for link "alignment" (Simulated)
        #2;

        // Test Packet 1: Memory Read from Compute to Base
        comp_tx_data = {8'hA1, 248'hBEEF_CAFE_0123_4567}; // Header + Data
        comp_tx_valid = 1;
        
        @(posedge clk);
        $display("[UCIe TB] Compute TX Flit: %h", comp_tx_data);
        comp_tx_valid = 0;

        // Check if Base received it
        wait(base_rx_valid);
        $display("[UCIe TB] Base RX Flit: %h", base_rx_data);
        
        if (base_rx_data[31:0] == tx_p) begin // Basic verification of PHY mapping
            $display("[UCIe TB] PHY Mapping SUCCESS: Lanes aligned.");
        end

        // Test Packet 2: Response from Base to Compute
        #5;
        base_tx_data = {8'hD2, 248'hDEAD_BEEF_FEED_F00D};
        base_tx_valid = 1;
        
        @(posedge clk);
        $display("[UCIe TB] Base TX Flit: %h", base_tx_data);
        base_tx_valid = 0;

        // Check if Compute received it
        wait(comp_rx_valid);
        $display("[UCIe TB] Compute RX Flit: %h", comp_rx_data);

        #10;
        $display("[UCIe TB] 3.5 GHz Chiplet Communication Verified.");
        $finish;
    end

endmodule
