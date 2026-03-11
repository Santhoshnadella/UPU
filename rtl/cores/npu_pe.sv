/**
 * NPU Processing Element (PE)
 * 8-bit activations, 8-bit weights, 32-bit MAC.
 * Saturation policy (per contract rule 101).
 * Target: Sky130B @ 50MHz
 */

module npu_pe #(
    parameter ACT_BITS  = 8,
    parameter WGT_BITS  = 8,
    parameter ACC_BITS = 32
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // Input Port
    input  logic [ACT_BITS-1:0]    activation_in,
    input  logic [WGT_BITS-1:0]    weight_in,
    input  logic                   valid_in,

    // Internal accumulation control
    input  logic                   clear_acc,
    output logic [ACC_BITS-1:0]    acc_data_out
);

    // Max/Min values for SATURATE overflow policy (INT32)
    localparam [ACC_BITS-1:0] MAX_POS = 32'h7FFFFFFF;
    localparam [ACC_BITS-1:0] MAX_NEG = 32'h80000000;

    // Registers (Registered Outputs per contract)
    logic [ACC_BITS-1:0] product_q;
    logic [ACC_BITS-1:0] acc_q;

    // Phase 1: Product Stage (Registered)
    // 8x8 signed multiply
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            product_q <= 0;
        end else if (valid_in) begin
            product_q <= $signed(activation_in) * $signed(weight_in);
        end else begin
            product_q <= 0;
        end
    end

    // Phase 2: Accumulate Stage (SATURATE policy)
    // Contract: if (sum > MAX_VAL) sum = MAX_VAL; after EACH addition.
    // 32-bit Signed Accumulator
    logic [ACC_BITS:0] full_sum; // 33 bits for overflow detection
    assign full_sum = $signed(acc_q) + $signed(product_q);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            acc_q <= 0;
        end else if (clear_acc) begin
            acc_q <= 0;
        end else begin
            // Saturation Check (Rule 101: Never WRAP — wrap is silent corruption)
            if (full_sum[ACC_BITS] ^ full_sum[ACC_BITS-1]) begin
                // Overflow occurred in 32-bit signed addition
                if (full_sum[ACC_BITS]) begin
                    // Negative overflow
                    acc_q <= MAX_NEG;
                end else begin
                    // Positive overflow
                    acc_q <= MAX_POS;
                end
            end else begin
                // No overflow
                acc_q <= full_sum[ACC_BITS-1:0];
            end
        end
    end

    assign acc_data_out = acc_q;

endmodule
