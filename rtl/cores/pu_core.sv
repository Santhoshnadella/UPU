/**
 * PU (Processing Unit) Core - Secondary auxiliary scalar unit
 * Target: Sky130B @ 50MHz
 */

module pu_core (
    input  logic                   clk,
    input  logic                   rst_n,

    // AXI-Lite Slave (Control / Registers)
    input  logic [31:0]            s_axi_awaddr,
    input  logic                   s_axi_awvalid,
    output logic                   s_axi_awready,
    input  logic [31:0]            s_axi_wdata,
    input  logic                   s_axi_wvalid,
    output logic                   s_axi_wready,

    output logic                   pu_done_irq
);

    logic [31:0] registers [4];
    logic        start_q;
    logic [1:0]  op_q;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            start_q <= 0;
            op_q    <= 0;
            pu_done_irq <= 0;
        end else if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
            case (s_axi_awaddr[7:0])
                8'h00: begin start_q <= s_axi_wdata[0]; op_q <= s_axi_wdata[2:1]; end
                8'h04: registers[0] <= s_axi_wdata;
                8'h08: registers[1] <= s_axi_wdata;
                8'h0C: registers[2] <= s_axi_wdata;
            endcase
            pu_done_irq <= 1'b0;
        end else if (start_q) begin
            // Generic 2-cycle arithmetic
            case (op_q)
                2'h0: registers[3] <= registers[0] + registers[1];
                2'h1: registers[3] <= registers[0] - registers[1];
                2'h2: registers[3] <= registers[0] & registers[1];
                2'h3: registers[3] <= registers[0] | registers[1];
            endcase
            start_q <= 1'b0;
            pu_done_irq <= 1'b1;
        end else begin
            pu_done_irq <= 1'b0;
        end
    end

    assign s_axi_awready = 1'b1;
    assign s_axi_wready  = 1'b1;

endmodule
