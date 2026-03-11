/**
 * GPU Vector Core (32 lanes × 32-bit)
 * Target: Sky130B @ 50MHz
 * Design Contract: GPU (lane_count: 32, lane_width: 32)
 */

module gpu_core #(
    parameter LANE_COUNT = 32,
    parameter LANE_WIDTH = 32,
    parameter REG_COUNT  = 32
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // AXI-Lite Slave (Instruction / Config)
    input  logic [31:0]            s_axi_awaddr,
    input  logic                   s_axi_awvalid,
    output logic                   s_axi_awready,
    input  logic [31:0]            s_axi_wdata,
    input  logic                   s_axi_wvalid,
    output logic                   s_axi_wready,

    // Vector Register File (32 registers × 32 lanes × 32 bits)
    // -------------------------------------------------------------------------
    // Note: Vector register file is large (32KB). In ASIC, this would be SRAM banks.
    // For v1 description, we'll model as logic registers.

    output logic                   gpu_done_irq
);

    // Vector Registers (VR0 to VR31)
    // Each VR contains LANE_COUNT 32-bit elements.
    logic [LANE_WIDTH-1:0] vrf [REG_COUNT][LANE_COUNT];

    // ─────────────────────────────────────────────────────────────────────────
    // Control Interface
    // ─────────────────────────────────────────────────────────────────────────
    logic [4:0] dest_id_q, src_a_id_q, src_b_id_q;
    logic [2:0] op_code_q;
    logic       start_exec_q;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            s_axi_awready <= 1'b1;
            s_axi_wready  <= 1'b1;
            start_exec_q  <= 1'b0;
            op_code_q     <= 0;
            dest_id_q     <= 0;
            src_a_id_q    <= 0;
            src_b_id_q    <= 0;
        end else begin
            if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                case (s_axi_awaddr[7:0])
                    8'h00: begin start_exec_q <= s_axi_wdata[0]; op_code_q <= s_axi_wdata[3:1]; end
                    8'h04: dest_id_q <= s_axi_wdata[4:0];
                    8'h08: src_a_id_q <= s_axi_wdata[4:0];
                    8'h0C: src_b_id_q <= s_axi_wdata[4:0];
                endcase
            end else begin
                start_exec_q <= 1'b0;
            end
        end
    end

    // ─────────────────────────────────────────────────────────────────────────
    // Vector Execute Stage (SIMD)
    // ─────────────────────────────────────────────────────────────────────────
    logic [LANE_WIDTH-1:0] lanes_alu_out [LANE_COUNT];
    logic                  lanes_valid_out_q;

    generate
        for (genvar i = 0; i < LANE_COUNT; i++) begin : simd_lanes
            always_ff @(posedge clk) begin
                if (!rst_n) begin
                    lanes_alu_out[i] <= 0;
                end else if (start_exec_q) begin
                    case (op_code_q)
                        3'h0: lanes_alu_out[i] <= vrf[src_a_id_q][i] + vrf[src_b_id_q][i]; // ADD
                        3'h1: lanes_alu_out[i] <= vrf[src_a_id_q][i] - vrf[src_b_id_q][i]; // SUB
                        3'h2: lanes_alu_out[i] <= vrf[src_a_id_q][i] & vrf[src_b_id_q][i]; // AND
                        3'h3: lanes_alu_out[i] <= vrf[src_a_id_q][i] | vrf[src_b_id_q][i]; // OR
                        3'h5: lanes_alu_out[i] <= (vrf[src_a_id_q][i] > vrf[src_b_id_q][i]) ? vrf[src_a_id_q][i] : vrf[src_b_id_q][i]; // MAX
                        default: lanes_alu_out[i] <= 0;
                    endcase
                end
            end
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (!rst_n) lanes_valid_out_q <= 1'b0;
        else        lanes_valid_out_q <= start_exec_q;
    end

    // ─────────────────────────────────────────────────────────────────────────
    // Vector Writeback Stage
    // ─────────────────────────────────────────────────────────────────────────
    always_ff @(posedge clk) begin
        if (lanes_valid_out_q) begin
            for (int i=0; i<LANE_COUNT; i++) begin
                vrf[dest_id_q][i] <= lanes_alu_out[i];
            end
            gpu_done_irq <= 1'b1;
        end else begin
            gpu_done_irq <= 1'b0;
        end
    end

endmodule
