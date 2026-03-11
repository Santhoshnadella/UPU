/**
 * PLIC (Platform-Level Interrupt Controller) - Simple v1
 * Target: Sky130B @ 50MHz
 * Design Contract: interrupts (sources: 8)
 */

module plic_simple (
    input  logic        clk,
    input  logic        rst_n,

    // AXI-Lite Slave (32-bit data)
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

    // Interrupt Sources (8)
    input  logic [7:0]  irq_sources,
    
    // Output to CPU
    output logic        irq_to_cpu
);

    // PLIC Registers (Simplified)
    // 0x000: Priority (8 regs)
    // 0x400: Pending (1 reg)
    // 0x800: Enable   (1 reg)
    // 0xC00: Threshold (1 reg)
    // 0xC04: Claim/Complete (1 reg)

    logic [31:0] priority_regs [0:7];
    logic [7:0]  pending_reg;
    logic [7:0]  enable_reg;
    logic [31:0] threshold_reg;
    logic [7:0]  claim_id;

    // Interrupt Logic
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pending_reg <= 8'b0;
        end else begin
            // Pulse detection / Edge latching
            pending_reg <= pending_reg | irq_sources;
        end
    end

    // Simple priority arbitration (Highest ID wins if multiple pending/enabled)
    always_comb begin
        irq_to_cpu = |(pending_reg & enable_reg);
    end

    // AXI Handshake
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            s_axi_awready <= 1'b1;
            s_axi_wready  <= 1'b1;
            s_axi_arready <= 1'b1;
            s_axi_rvalid  <= 1'b0;
            s_axi_rdata   <= 32'b0;
            enable_reg    <= 8'b0;
            threshold_reg <= 32'b0;
        end else begin
            // 1-transaction-at-a-time logic
            if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                if (s_axi_awaddr[11:0] == 12'h800) enable_reg <= s_axi_wdata[7:0];
                if (s_axi_awaddr[11:0] == 12'hC00) threshold_reg <= s_axi_wdata;
            end
            
            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rvalid <= 1'b1;
                s_axi_arready <= 1'b0;
                case (s_axi_araddr[11:0])
                    12'h400: s_axi_rdata <= {24'b0, pending_reg};
                    12'h800: s_axi_rdata <= {24'b0, enable_reg};
                    default: s_axi_rdata <= 32'h0;
                endcase
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
                s_axi_arready <= 1'b1;
            end
        end
    end

endmodule
