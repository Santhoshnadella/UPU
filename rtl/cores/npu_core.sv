/**
 * NPU Core (Neural Processing Unit)
 * Target: Sky130B @ 50MHz
 * Features: Pipelined MAC with Saturation + ReLU Activation
 */

module npu_core #(
    parameter PE_COUNT = 32,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // AXI-Lite Slave (Control)
    input  logic [ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  logic                   s_axi_awvalid,
    output logic                   s_axi_awready,
    input  logic [DATA_WIDTH-1:0]  s_axi_wdata,
    input  logic                   s_axi_wvalid,
    output logic                   s_axi_wready,
    output logic                   s_axi_bvalid,
    input  logic                   s_axi_bready,

    // Interface to Memory (Simplified for v1)
    input  logic [7:0]             activation_in [PE_COUNT],
    input  logic [7:0]             weight_in [PE_COUNT],
    input  logic                   valid_in,

    // Output to Memory
    output logic [31:0]            npu_out [PE_COUNT],
    output logic                   valid_out
);

    // ─────────────────────────────────────────────────────────────────────────
    // PE Array Instantiation
    // ─────────────────────────────────────────────────────────────────────────
    logic [31:0] pe_acc_raw [PE_COUNT];
    logic        clear_acc;

    generate
        for (genvar i = 0; i < PE_COUNT; i++) begin : pe_array
            npu_pe #(8, 8, 32) pe_inst (
                .clk(clk),
                .rst_n(rst_n),
                .activation_in(activation_in[i]),
                .weight_in(weight_in[i]),
                .valid_in(valid_in),
                .clear_acc(clear_acc),
                .acc_data_out(pe_acc_raw[i])
            );
        end
    endgenerate

    // ─────────────────────────────────────────────────────────────────────────
    // ReLU Activation & Registration
    // Rule 77: All arithmetic outputs registered.
    // ─────────────────────────────────────────────────────────────────────────
    logic [31:0] relu_out_q [PE_COUNT];
    logic        relu_valid_q;

    generate
        for (genvar i = 0; i < PE_COUNT; i++) begin : act_gen
            always_ff @(posedge clk) begin
                if (!rst_n) begin
                    relu_out_q[i] <= 0;
                end else begin
                    // ReLU: max(0, x)
                    if (pe_acc_raw[i][31]) // Negative sign bit
                        relu_out_q[i] <= 32'b0;
                    else
                        relu_out_q[i] <= pe_acc_raw[i];
                end
            end
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (!rst_n) relu_valid_q <= 1'b0;
        else        relu_valid_q <= valid_in; // Simplified latency
    end

    assign npu_out   = relu_out_q;
    assign valid_out = relu_valid_q;

    // ─────────────────────────────────────────────────────────────────────────
    // Control Registers
    // ─────────────────────────────────────────────────────────────────────────
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            s_axi_awready <= 1'b1;
            s_axi_wready  <= 1'b1;
            s_axi_bvalid  <= 1'b0;
            clear_acc     <= 1'b0;
        end else begin
            if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                if (s_axi_awaddr[7:0] == 8'h00) clear_acc <= s_axi_wdata[0];
                s_axi_bvalid <= 1'b1;
            end else begin
                clear_acc <= 1'b0;
            end
            
            if (s_axi_bvalid && s_axi_bready) s_axi_bvalid <= 1'b0;
        end
    end

endmodule
