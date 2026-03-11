/**
 * Timer Peripheral
 * Target: Sky130B @ 50MHz
 */

module timer_simple (
    input  logic        clk,
    input  logic        rst_n,

    // AXI-Lite Slave
    input  logic [31:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,
    input  logic [31:0] s_axi_wdata,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,

    output logic        interrupt
);

    logic [31:0] counter_q;
    logic [31:0] compare_q;
    logic        enable_q;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            counter_q <= 0;
            compare_q <= 32'hFFFFFFFF;
            enable_q  <= 0;
            s_axi_awready <= 1'b1;
            s_axi_wready  <= 1'b1;
        end else begin
            if (enable_q) counter_q <= counter_q + 1;

            if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                case (s_axi_awaddr[7:0])
                    8'h00: enable_q  <= s_axi_wdata[0];
                    8'h04: compare_q <= s_axi_wdata;
                    8'h08: counter_q <= s_axi_wdata;
                endcase
            end
        end
    end

    assign interrupt = enable_q && (counter_q >= compare_q);

endmodule
