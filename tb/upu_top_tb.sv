/**
 * UPU Top-Level Testbench
 * Verifies Boot Sequence and Peripheral Interconnect.
 */

`timescale 1ns/1ps

module upu_top_tb;

    logic        clk;
    logic        rst_n;
    logic        tx;
    logic        rx;
    logic [7:0]  gpio_out;

    // Instantiate SoC
    upu_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx(tx),
        .rx(rx),
        .gpio_out(gpio_out)
    );

    // Clock Generation (50MHz = 20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test Sequence
    initial begin
        $display("--- [UPU v1 SoC MASTER TESTBENCH] ---");
        $dumpfile("upu_top.vcd");
        $dumpvars(0, upu_top_tb);

        // Reset
        rst_n = 0;
        rx = 1'b1;
        #100;
        @(posedge clk);
        rst_n = 1;
        $display("[%0t] Reset deasserted. CPU Booting from 0x0...", $time);

        // 1. Verify ROM Fetch
        // CPU starts at 0x0, Crossbar should route arvalid to ROM.
        wait(dut.rom_arvalid);
        $display("[%0t] SUCCESS: Branch/Fetch detected at ROM address %h", $time, dut.rom_araddr);

        // 2. Verify Peripheral Reachability (PLIC)
        // Check if CPU starts initializing PLIC (0x40000000)
        // (Wait longer since CPU pipelined fetch + decode takes cycles)
        #2000;
        if (dut.xbar_inst.ar_sel == 5 || dut.xbar_inst.aw_sel == 5) begin
             $display("[%0t] SUCCESS: Communication with PLIC (0x4...) detected.", $time);
        end

        // 3. Verify TPU Register Space
        #5000;
        if (dut.xbar_inst.aw_sel == 2) begin
             $display("[%0t] SUCCESS: Matrix Multiplication Setup detected at TPU registers.", $time);
        end

        // 4. Verify GPU Register Space
        #5000;
        if (dut.xbar_inst.aw_sel == 4) begin
             $display("[%0t] SUCCESS: Vectorization Setup detected at GPU registers.", $time);
        end

        #20000;
        $display("[%0t] Simulation Finished. UPU SoC functional walkthrough completed.", $time);
        $finish;
    end

endmodule
