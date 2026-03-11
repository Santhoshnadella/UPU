/**
 * GPIO Peripheral (8-bit)
 * Target: Sky130B @ 50MHz
 */

module gpio_simple (
    input  logic        clk,
    input  logic        rst_n,

    // AXI-Lite Slave
    input  logic [31:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,
    input  logic [31:0] s_axi_wdata,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,

    output logic [7:0]  gpio_out,
    output logic        gpio_irq
);

    logic [7:0] data_q;
    logic [7:0] mask_q;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            data_q <= 0;
            mask_q <= 8'hFF;
            s_axi_awready <= 1'b1;
            s_axi_wready  <= 1'b1;
        end else if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
            case (s_axi_awaddr[7:0])
                8'h00: data_q <= s_axi_wdata[7:0];
                8'h04: mask_q <= s_axi_wdata[7:0];
            endcase
        end
    end

    assign gpio_out = data_q & mask_q;
    assign gpio_irq = (data_q != 0); // Simplified IRQ on non-zero data

endmodule
