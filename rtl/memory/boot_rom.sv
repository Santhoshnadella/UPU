/**
 * 4KB Boot ROM (preloaded with bootloader)
 * Target: Sky130B @ 50MHz
 */

module boot_rom (
    input  logic        clk,
    input  logic        rst_n,

    // Simplified AXI4-Lite port (for ROM access)
    input  logic [31:0] s_axi_araddr,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,
    output logic [63:0] s_axi_rdata,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready
);

    // 4KB = 512 x 64-bit words
    logic [63:0] rom_data [0:511];

    // ROM is preloaded (e.g., using $readmemh)
    initial begin
        // $readmemh("bootloader.hex", rom_data);
        // Fill some default values for testing
        for (int i=0; i<512; i++) begin
            rom_data[i] = {32'h0, 32'h0}; // NOP or reset vector
        end
        // Set reset vector to jump to L2 SRAM @ 0x10000000
        // (Simplified placeholder)
        rom_data[0] = 64'h0000000010000000;
    end

    // Clocked address for ROM (Synchronous read)
    logic [8:0] addr_reg;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            addr_reg <= 9'b0;
        end else if (s_axi_arvalid && s_axi_arready) begin
            addr_reg <= s_axi_araddr[11:3];
        end
    end

    // ROM Output Register (to obey "arithmetic/output registered" rule)
    logic [63:0] rdata_next;
    assign rdata_next = rom_data[addr_reg];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            s_axi_rdata <= 64'b0;
            s_axi_rvalid <= 1'b0;
        end else begin
            s_axi_rdata <= rdata_next;
            // Simplified handshake logic for ROM (1-cycle latency)
            s_axi_rvalid <= s_axi_arvalid && s_axi_arready;
        end
    end

    // For fixed-latency ROM, ready can be 1-cycle after valid or constant.
    // Contract says VALID must never depend on READY, and outputs registered.
    assign s_axi_arready = 1'b1;

endmodule
