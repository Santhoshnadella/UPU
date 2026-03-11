/**
 * UART Peripheral (Simple 16550 compatible subset)
 * Target: Sky130B @ 50MHz
 */

module uart_simple (
    input  logic        clk,
    input  logic        rst_n,

    // AXI-Lite Slave (32-bit data as per contract)
    input  logic [31:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,
    input  logic [31:0] s_axi_wdata,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,

    input  logic [31:0] s_axi_araddr,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,
    output logic [31:0] s_axi_rdata,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready,

    // UART Signals
    output logic        tx,
    input  logic        rx,
    output logic        interrupt
);

    // Registers (Simplified)
    // 0x0: THR (W) / RBR (R)
    // 0x4: IER (RW)
    // 0x8: IIR (R) / FCR (W)
    // 0xC: LCR (RW)
    // 0x14: LSR (R) - Status register
    
    logic [7:0] tx_data_reg;
    logic       tx_busy;
    logic       rx_data_ready;
    logic [7:0] rx_data_reg;

    // AXI Logic
    // -------------------------------------------------------------------------
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            s_axi_awready <= 1'b1;
            s_axi_wready  <= 1'b1;
            s_axi_arready <= 1'b1;
            s_axi_rvalid  <= 1'b0;
            s_axi_rdata   <= 32'b0;
            tx_data_reg   <= 8'b0;
            tx_busy       <= 1'b0;
        end else begin
            // Write
            if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                if (s_axi_awaddr[7:0] == 8'h00) begin
                    tx_data_reg <= s_axi_wdata[7:0];
                    // Trigger UART transmit (behavioral placeholder)
                    tx_busy <= 1'b1;
                end
            end
            
            // Read
            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rvalid <= 1'b1;
                s_axi_arready <= 1'b0;
                case (s_axi_araddr[7:0])
                    8'h00: s_axi_rdata <= {24'b0, rx_data_reg}; // RBR
                    8'h14: s_axi_rdata <= {30'b0, rx_data_ready, !tx_busy}; // LSR: [1]: TX empty, [0]: RX ready
                    default: s_axi_rdata <= 32'h0;
                endcase
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
                s_axi_arready <= 1'b1;
            end

            // Pseudo-UART bit engine (Simulation only for now)
            if (tx_busy) tx_busy <= 1'b0;
        end
    end

    // Always registered output (per contract)
    assign tx = 1'b1; // Idle high
    assign interrupt = 1'b0;

endmodule
