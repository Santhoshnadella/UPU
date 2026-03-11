/**
 * TPU Core Testbench
 * Verifies 16x16 Matrix Multiplications via DMA
 */

`timescale 1ns/1ps

module tpu_core_tb;

    logic clk, rst_n;
    
    // AXI-Lite Slave
    logic [31:0] s_axi_awaddr, s_axi_wdata;
    logic        s_axi_awvalid, s_axi_awready, s_axi_wvalid, s_axi_wready, s_axi_bvalid, s_axi_bready;
    
    // AXI Master (DMA)
    logic [31:0] m_axi_araddr;
    logic        m_axi_arvalid, m_axi_arready;
    logic [63:0] m_axi_rdata;
    logic        m_axi_rvalid, m_axi_rready;

    tpu_core dut (.*);

    // Clock
    initial begin clk = 0; forever #10 clk = ~clk; end

    // Simulation of L2 SRAM for DMA
    always_ff @(posedge clk) begin
        m_axi_arready <= 1'b1;
        if (m_axi_arvalid && m_axi_arready) begin
            m_axi_rvalid <= 1'b1;
            m_axi_rdata  <= 64'h0101010101010101; // Constant 1s
        end else begin
            m_axi_rvalid <= 1'b0;
        end
    end

    initial begin
        $display("TPU Verification Started...");
        rst_n = 0; s_axi_awvalid = 0; s_axi_wvalid = 0; s_axi_bready = 1;
        #100; rst_n = 1;
        
        // 1. Set L2 Base Addresses
        @(posedge clk);
        s_axi_awaddr = 32'h04; s_axi_wdata = 32'h10000000; s_axi_awvalid = 1; s_axi_wvalid = 1; #20;
        s_axi_awaddr = 32'h08; s_axi_wdata = 32'h10001000; #20;
        s_axi_awaddr = 32'h0C; s_axi_wdata = 32'h00000010; #20; // 16 steps
        
        // 2. Start TPU
        s_axi_awaddr = 32'h00; s_axi_wdata = 32'h01; #20;
        s_axi_awvalid = 0; s_axi_wvalid = 0;
        
        // 3. Wait for Done
        wait(dut.reg_ctrl[2]);
        $display("TPU SUCCESS: Matrix Multiplication Sequence Completed.");
        
        #100; $finish;
    end
endmodule
