/**
 * RV64_TOP - AXI4-Lite Wrapper for RV64_CORE
 */

module rv64_top #(
    parameter XLEN = 64
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // Instruction AXI4-Lite
    output logic [31:0]            instr_axi_araddr,
    output logic                   instr_axi_arvalid,
    input  logic                   instr_axi_arready,
    input  logic [31:0]            instr_axi_rdata,
    input  logic                   instr_axi_rvalid,
    output logic                   instr_axi_rready,

    // Data AXI4 Master
    output logic [31:0]            data_axi_araddr,
    output logic                   data_axi_arvalid,
    input  logic                   data_axi_arready,
    input  logic [XLEN-1:0]        data_axi_rdata,
    input  logic                   data_axi_rvalid,
    output logic                   data_axi_rready,

    output logic [31:0]            data_axi_awaddr,
    output logic                   data_axi_awvalid,
    input  logic                   data_axi_awready,
    output logic [XLEN-1:0]        data_axi_wdata,
    output logic                   data_axi_wvalid,
    input  logic                   data_axi_wready
);

    logic [XLEN-1:0] imem_addr;
    logic [31:0]     imem_rdata;
    logic            imem_rvalid;
    
    logic [XLEN-1:0] dmem_addr, dmem_wdata, dmem_rdata;
    logic            dmem_we, dmem_rvalid;
    logic [7:0]      dmem_be;

    // Instantiate Core
    rv64_core #(.XLEN(XLEN)) u_core (
        .clk        (clk),
        .rst_n      (rst_n),
        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata),
        .imem_rvalid(imem_rvalid),
        .dmem_addr  (dmem_addr),
        .dmem_wdata (dmem_wdata),
        .dmem_we    (dmem_we),
        .dmem_be    (dmem_be),
        .dmem_rdata (dmem_rdata),
        .dmem_rvalid(dmem_rvalid)
    );

    // Simple AXI-Lite Bridge Logic (Stateless)
    assign instr_axi_araddr  = imem_addr[31:0];
    assign instr_axi_arvalid = 1'b1;
    assign instr_axi_rready  = 1'b1;
    assign imem_rdata        = instr_axi_rdata;
    assign imem_rvalid       = instr_axi_rvalid;

    assign data_axi_araddr   = dmem_addr[31:0];
    assign data_axi_arvalid  = !dmem_we;
    assign data_axi_awaddr   = dmem_addr[31:0];
    assign data_axi_awvalid  = dmem_we;
    assign data_axi_wdata    = dmem_wdata;
    assign data_axi_wvalid   = dmem_we;
    assign data_axi_rready   = 1'b1;
    assign dmem_rdata        = data_axi_rdata;
    assign dmem_rvalid       = data_axi_rvalid;

    // Unused outputs
    logic _unused;
    assign _unused = &{instr_axi_arready, data_axi_arready, data_axi_awready, data_axi_wready, 1'b0};

endmodule
