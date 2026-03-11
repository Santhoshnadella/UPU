/**
 * ARTY A7 FPGA WRAPPER for UPU
 */
module arty_a7_wrapper (
    input  logic CLK100MHZ,
    input  logic ck_rst,
    
    // UART
    output logic uart_txd,
    input  logic uart_rxd
);

    logic clk, rst_n;
    assign clk = CLK100MHZ; // Placeholder for PLL
    assign rst_n = ck_rst;

    // Instantiate UPU SoC
    upu_top u_soc (
        .clk(clk),
        .rst_n(rst_n)
    );

    // ILA Core could be added here for Phase 5 verification

endmodule
