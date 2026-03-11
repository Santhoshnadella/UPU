/**
 * TPU Processing Element (PE)
 * 8-bit INT8 multiply, 32-bit INT32 accumulate.
 * Fully pipelined: 1 cycle per stage.
 * Registered input AND output (per contract rule).
 */

module tpu_pe #(
    parameter IN_BITS  = 8,
    parameter ACC_BITS = 32
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // PE-to-PE registered data forwarding
    input  logic [IN_BITS-1:0]      north_data_in,
    input  logic [IN_BITS-1:0]      west_data_in,
    output logic [IN_BITS-1:0]      south_data_out,
    output logic [IN_BITS-1:0]      east_data_out,

    // Internal accumulation
    input  logic                    clear_acc,
    output logic [ACC_BITS-1:0]     acc_data_out
);

    // Inputs registered on both axes (systolic array requirement)
    logic [IN_BITS-1:0] north_q;
    logic [IN_BITS-1:0] west_q;

    // Mult/Acc result
    logic [ACC_BITS-1:0] acc_q;
    logic [ACC_BITS-1:0] mult_q;

    // Phase 1: Register Inputs
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            north_q <= 0;
            west_q  <= 0;
        end else begin
            north_q <= north_data_in;
            west_q  <= west_data_in;
        end
    end

    // Phase 2: Compute Mult (Arithmetic output registered in separate cycle)
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            mult_q <= 0;
        end else begin
            // 8x8 = 16 bits, but padding to 32 bits as per contract
            mult_q <= north_q * west_q;
        end
    end

    // Phase 3: Accumulate (Accumulator registered)
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            acc_q <= 0;
        end else if (clear_acc) begin
            acc_q <= 0;
        end else begin
            // Saturation logic check (should be in NPU but requested for TPU too by best practice)
            // However, TPU contract says 32-bit is enough and "CANNOT overflow" (rule 91-92).
            // So pure addition is fine.
            acc_q <= acc_q + mult_q;
        end
    end

    // Forwarding logic (registered per PE-to-PE stage)
    assign south_data_out = north_q;
    assign east_data_out  = west_q;
    assign acc_data_out   = acc_q;

endmodule
