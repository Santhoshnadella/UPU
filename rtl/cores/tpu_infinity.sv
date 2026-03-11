/**
 * INFINITY TPU - Systolic Array (Skeleton)
 * Interface: AXI4-Stream
 */
module tpu_infinity #(
    parameter DIM = 16,
    parameter DATA_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // Matrix input
    input  logic [DATA_WIDTH-1:0]  s_axis_tdata,
    input  logic                   s_axis_tvalid,
    output logic                   s_axis_tready,

    // Result output
    output logic [31:0]            m_axis_tdata,
    output logic                   m_axis_tvalid,
    input  logic                   m_axis_tready
);

    // Systolic Multiply-Accumulate placeholder
    assign s_axis_tready = m_axis_tready;
    assign m_axis_tdata  = {24'b0, s_axis_tdata};
    assign m_axis_tvalid = s_axis_tvalid;

endmodule
