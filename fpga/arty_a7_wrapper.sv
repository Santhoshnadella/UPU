/**
 * UPU v1 FPGA Wrapper (Target: Digilent Arty A7-100T)
 * Maps physical FPGA pins to the UPU SoC ports.
 */

module upu_arty_a7_wrapper (
    input  logic        CLK100MHZ, // 100MHz Oscillator on Arty
    input  logic [3:0]  sw,        // Switches (rst_n = sw[0])
    output logic [3:0]  led,       // GPIO
    output logic        uart_tx_out,
    input  logic        uart_rx_in
);

    // ─────────────────────────────────────────────────────────────────────────
    // Clock divider (100MHz -> 50MHz for UPU v1)
    // ─────────────────────────────────────────────────────────────────────────
    logic clk_50mhz;
    logic clk_div_q;

    always_ff @(posedge CLK100MHZ) begin
        clk_div_q <= ~clk_div_q;
    end
    assign clk_50mhz = clk_div_q;

    // Reset sync
    logic rst_n_sync;
    always_ff @(posedge clk_50mhz) begin
        rst_n_sync <= sw[0]; // Switch 0 is System Reset
    end

    // ─────────────────────────────────────────────────────────────────────────
    // UPU SoC Instantiation
    // ─────────────────────────────────────────────────────────────────────────
    logic [7:0] gpio_out;

    upu_top soc_inst (
        .clk(clk_50mhz),
        .rst_n(rst_n_sync),
        .tx(uart_tx_out),
        .rx(uart_rx_in),
        .gpio_out(gpio_out)
    );

    // Map lower 4 bits of UPU GPIO to the 4 LEDs on the Arty board
    assign led = gpio_out[3:0];

endmodule
