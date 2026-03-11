/**
 * ECHO NPU - Neural PE Cluster (Skeleton)
 */
module npu_echo #(
    parameter PE_COUNT = 64
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // AXI-Stream for Weights & Activations
    input  logic [63:0]            s_axis_tdata,
    input  logic                   s_axis_tvalid,
    output logic                   s_axis_tready,

    output logic [63:0]            m_axis_tdata,
    output logic                   m_axis_tvalid,
    input  logic                   m_axis_tready
);

    assign s_axis_tready = m_axis_tready;
    assign m_axis_tdata  = s_axis_tdata;
    assign m_axis_tvalid = s_axis_tvalid;

endmodule
