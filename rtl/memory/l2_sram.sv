/**
 * 256KB L2 Shared SRAM (8-way associative bank)
 * Target: Sky130B @ 50MHz
 * Design Contract: L2_shared (size_kb: 256, associativity: 8)
 * Coherency: DMA_ONLY_NO_SNOOPING
 */

module l2_sram #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 32,    // Physical addr
    parameter SIZE_KB    = 256
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // AXI4 Interface (Slave)
    input  logic [ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  logic                   s_axi_awvalid,
    output logic                   s_axi_awready,
    input  logic [DATA_WIDTH-1:0]  s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input  logic                   s_axi_wvalid,
    output logic                   s_axi_wready,
    output logic                   s_axi_bvalid,
    input  logic                   s_axi_bready,

    input  logic [ADDR_WIDTH-1:0]  s_axi_araddr,
    input  logic                   s_axi_arvalid,
    output logic                   s_axi_arready,
    output logic [DATA_WIDTH-1:0]  s_axi_rdata,
    output logic                   s_axi_rvalid,
    input  logic                   s_axi_rready
);

    // 256KB SRAM = 2^18 bytes. 
    // Data width is 64-bit (8 bytes). 
    // 256 * 1024 / 8 = 32768 words.
    // Address index for words: 15 bits.
    localparam NUM_WORDS = (SIZE_KB * 1024) / (DATA_WIDTH / 8);
    localparam INDEX_WIDTH = $clog2(NUM_WORDS);

    logic [DATA_WIDTH-1:0] sram_mem [0:NUM_WORDS-1];

    // Registered Write Address & Data
    logic [INDEX_WIDTH-1:0] waddr_reg;
    logic [DATA_WIDTH-1:0]  wdata_reg;
    logic [DATA_WIDTH/8-1:0] wstrb_reg;
    logic                    wr_active;

    // AXI Write Channel Logic
    // Contract: VALID never depends on READY. 
    // To meet timing @ 50MHz, all inputs/outputs registered.
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            s_axi_awready <= 1'b1;
            s_axi_wready  <= 1'b1;
            s_axi_bvalid  <= 1'b0;
            wr_active     <= 1'b0;
        end else begin
            // Simplified write handshake (1 transaction at a time)
            if (s_axi_awvalid && s_axi_awready) begin
                waddr_reg <= s_axi_awaddr[INDEX_WIDTH+2:3];
                s_axi_awready <= 1'b0;
            end

            if (s_axi_wvalid && s_axi_wready) begin
                wdata_reg <= s_axi_wdata;
                wstrb_reg <= s_axi_wstrb;
                s_axi_wready <= 1'b0;
                wr_active <= 1'b1;
            end

            if (wr_active) begin
                // Synchronous SRAM write with byte strobe
                for (int i=0; i<DATA_WIDTH/8; i++) begin
                    if (wstrb_reg[i]) sram_mem[waddr_reg][i*8 +: 8] <= wdata_reg[i*8 +: 8];
                end
                wr_active <= 1'b0;
                s_axi_bvalid <= 1'b1;
            end

            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
                s_axi_awready <= 1'b1;
                s_axi_wready <= 1'b1;
            end
        end
    end

    // AXI Read Channel Logic
    // 1-cycle latency SRAM read
    logic [INDEX_WIDTH-1:0] raddr_reg;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            s_axi_arready <= 1'b1;
            s_axi_rvalid  <= 1'b0;
            s_axi_rdata   <= 0;
        end else begin
            if (s_axi_arvalid && s_axi_arready) begin
                raddr_reg <= s_axi_araddr[INDEX_WIDTH+2:3];
                s_axi_arready <= 1'b0;
                s_axi_rvalid <= 1'b1;
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
                s_axi_arready <= 1'b1;
            end
            
            // Output register for sram (pipelined)
            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rdata <= sram_mem[s_axi_araddr[INDEX_WIDTH+2:3]];
            end
        end
    end

endmodule
