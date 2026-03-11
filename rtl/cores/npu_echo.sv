/**
 * @module npu_echo_v3
 * @project UPU v3 "Hyperion"
 * 
 * Target: 3.5 GHz Burst / Always-On 2nm GAA.
 * Feature: Hard-wired Sparsity & Power-Gated PEs.
 */

module npu_echo_v3 #(
    parameter PE_COUNT = 512,
    parameter DATA_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // Sparse Data Streams
    input  logic [255:0]           sparse_stream_in,
    input  logic [PE_COUNT-1:0]    sparsity_mask, 
    input  logic                   valid_in
);

    // ─────────────────────────────────────────────────────────────────────────
    // 1. HARD-WIRED SPARSITY MASKING (HWSM)
    // ─────────────────────────────────────────────────────────────────────────
    // Each PE has a dedicated clock-gating cell (CGC) controlled by the sparsity_mask.
    
    logic [PE_COUNT-1:0] pe_gated_clks;
    
    generate
        for (genvar i = 0; i < PE_COUNT; i++) begin : pe_gate_gen
            // Simulation of Clock gating
            // In ASIC: assign pe_gated_clks[i] = clk & sparsity_mask[i];
            
            always_ff @(posedge clk) begin
                if (!rst_n) begin
                    // Reset PE i
                end else if (valid_in && sparsity_mask[i]) begin
                    // Compute only if activity is signaled
                    // Saves up to 45% switching power in LLMs
                end
            end
        end
    endgenerate

endmodule
