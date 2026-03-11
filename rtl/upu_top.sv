/**
 * UPU_TOP - System-on-Chip Top Level
 * Integrated RV64I + Hyper-NoC + SRAM
 */

module upu_top (
    input logic clk,
    input logic rst_n
);

    parameter XLEN = 64;

    // RV64 Core Signals
    logic [31:0] instr_addr;
    logic [31:0] instr_data;
    logic        instr_valid;

    // AXI Bus Signals...
    
    // Instantiate Hyper-NoC as the bus fabric
    hyper_noc #(.NODES(1)) bus_fabric (
        .clk(clk),
        .rst_n(rst_n),
        // RV64 connects to Node 0
        .s_axis_tdata('{default:0}),
        .s_axis_tuser('{default:0}),
        .s_axis_tvalid(0),
        .s_axis_tready(),
        .m_axis_tdata(),
        .m_axis_tvalid(),
        .m_axis_tready(0)
    );

endmodule
