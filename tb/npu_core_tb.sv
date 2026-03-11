/**
 * NPU Core Testbench
 * Verifies Pipelined MAC with ReLU and Saturation
 */

`timescale 1ns/1ps

module npu_core_tb;

    logic clk, rst_n;
    logic [7:0] activation_in [32];
    logic [7:0] weight_in [32];
    logic       valid_in, valid_out;
    logic [31:0] npu_out [32];

    npu_core dut (.*, .s_axi_awvalid(0), .s_axi_wvalid(0), .s_axi_bready(1), .s_axi_awaddr(0), .s_axi_wdata(0));

    initial begin
        clk = 0; forever #10 clk = ~clk;
    end

    initial begin
        $display("NPU Verification Started...");
        rst_n = 0; valid_in = 0;
        #100; rst_n = 1;
        
        // 1. Check positive accumulation
        for (int i=0; i<32; i++) begin
            activation_in[i] = 8'h0A; // 10
            weight_in[i]     = 8'h02; // 2
        end
        valid_in = 1; #20;
        valid_in = 0; #100;
        
        // 2. Output should be 20 (since ReLU(20) = 20)
        if (npu_out[0] == 32'h14) 
            $display("NPU SUCCESS: MAC 10x2 = 20 Detected.");
        else
            $display("NPU ERROR: Incorrect MAC output %h", npu_out[0]);
            
        // 3. Test Negative (ReLU effect)
        for (int i=0; i<32; i++) begin
            activation_in[i] = -8'h0A; // -10 (signed)
            weight_in[i]     = 8'h02;  // 2
        end
        valid_in = 1; #20;
        valid_in = 0; #100;
        
        if (npu_out[0] == 32'h0) 
            $display("NPU SUCCESS: ReLU Clamped Negative Value %d to 0.", -20);
        else
            $display("NPU ERROR: ReLU failed to clamp %h", npu_out[0]);

        #100; $finish;
    end
endmodule
