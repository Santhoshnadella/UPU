/**
 * RV64I Core Testbench
 * Verifies Boot Sequence and AXI Handshake
 */

`timescale 1ns/1ps

module rv64_top_tb;

    logic clk, rst_n;
    
    // Instruction AXI
    logic [31:0] instr_axi_araddr;
    logic        instr_axi_arvalid, instr_axi_arready;
    logic [31:0] instr_axi_rdata;
    logic        instr_axi_rvalid, instr_axi_rready;

    // Data AXI
    logic [31:0] data_axi_araddr;
    logic        data_axi_arvalid, data_axi_arready;
    logic [63:0] data_axi_rdata;
    logic        data_axi_rvalid, data_axi_rready;
    
    // Write Data AXI
    logic [31:0] data_axi_awaddr;
    logic        data_axi_awvalid, data_axi_awready;
    logic [63:0] data_axi_wdata;
    logic        data_axi_wvalid, data_axi_wready;

    rv64_top dut (.*);

    initial begin clk = 0; forever #10 clk = ~clk; end

    // Mock Instruction Memory @ 0x0
    always_ff @(posedge clk) begin
        instr_axi_arready <= 1'b1;
        if (instr_axi_arvalid) begin
            instr_axi_rvalid <= 1'b1;
            // OP-IMM: ADDI X1, X0, 10
            instr_axi_rdata  <= 32'h00A00093;
        end else begin
            instr_axi_rvalid <= 1'b0;
        end
    end

    initial begin
        $display("RV64I Verification Started...");
        rst_n = 0;
        #100; rst_n = 1;
        
        // 1. Initial State: PC = 0
        $display("Reset deasserted. Initial PC = %h", dut.pc_q);
        
        // 2. Step 4 cycles
        #200;
        
        // 3. Check Register X1: Should be 10 (0x0A)
        if (dut.regfile[1] == 64'h0A)
            $display("RV64I SUCCESS: ADDI X1, X0, 10 Execute correctly. Reg X1 = %d", dut.regfile[1]);
        else
            $display("RV64I ERROR: Reg X1 incorrect. Output %d", dut.regfile[1]);

        #100; $finish;
    end
endmodule
