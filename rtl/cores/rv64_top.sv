/**
 * RV64I CPU (64-bit RISC-V Integer Base)
 * Target: Sky130B @ 50MHz
 * Design Contract: XLEN 64, arithmetic registered outputs.
 * Architecture: 5-Stage In-Order Pipeline
 */

module rv64_top #(
    parameter XLEN = 64,
    parameter FLEN = 64
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

    // Data AXI4 Master (Load/Store)
    output logic [31:0]            data_axi_araddr,
    output logic                   data_axi_arvalid,
    input  logic                   data_axi_arready,
    input  logic [XLEN-1:0]         data_axi_rdata,
    input  logic                   data_axi_rvalid,
    output logic                   data_axi_rready,

    output logic [31:0]            data_axi_awaddr,
    output logic                   data_axi_awvalid,
    input  logic                   data_axi_awready,
    output logic [XLEN-1:0]         data_axi_wdata,
    output logic                   data_axi_wvalid,
    input  logic                   data_axi_wready
);

    // ─────────────────────────────────────────────────────────────────────────
    // 1. FETCH STAGE
    // ─────────────────────────────────────────────────────────────────────────
    logic [31:0] pc_q;
    logic [31:0] instr_q;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pc_q <= 32'h0;
            instr_q <= 32'h0;
            instr_axi_araddr <= 32'h0;
            instr_axi_arvalid <= 1'b0;
        end else begin
            // Instruction Fetch logic
            if (instr_axi_arready || !instr_axi_arvalid) begin
                instr_axi_arvalid <= 1'b1;
                instr_axi_araddr <= pc_q;
            end
            
            if (instr_axi_rvalid && instr_axi_rready) begin
                instr_q <= instr_axi_rdata;
                pc_q <= pc_q + 4; // Increment PC
            end
        end
    end
    assign instr_axi_rready = 1'b1;

    // ─────────────────────────────────────────────────────────────────────────
    // 2. DECODE STAGE
    // ─────────────────────────────────────────────────────────────────────────
    logic [XLEN-1:0] regfile [0:31];
    logic [4:0]      rs1_addr, rs2_addr, rd_addr;
    logic [XLEN-1:0] op_a_q, op_b_q;
    logic [63:0]     imm_q;
    logic [6:0]      opcode_q;
    logic [2:0]      funct3_q;
    logic [6:0]      funct7_q;

    // Hardwired zero register
    initial regfile[0] = 0;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            op_a_q   <= 0;
            op_b_q   <= 0;
            imm_q    <= 0;
            rd_addr  <= 0;
            opcode_q <= 0;
            funct3_q <= 0;
            funct7_q <= 0;
        end else begin
            opcode_q <= instr_q[6:0];
            rd_addr  <= instr_q[11:7];
            rs1_addr <= instr_q[19:15];
            rs2_addr <= instr_q[24:20];
            funct3_q <= instr_q[14:12];
            funct7_q <= instr_q[31:25];
            
            op_a_q <= regfile[rs1_addr];
            op_b_q <= regfile[rs2_addr];
            
            // Immediate Generation
            case (instr_q[6:0])
                7'h37, 7'h17: imm_q <= { {32{instr_q[31]}}, instr_q[31:12], 12'b0 }; // U-Type
                7'h6F:        imm_q <= { {43{instr_q[31]}}, instr_q[31], instr_q[19:12], instr_q[20], instr_q[30:21], 1'b0 }; // J-Type
                7'h63:        imm_q <= { {51{instr_q[31]}}, instr_q[31], instr_q[7], instr_q[30:25], instr_q[11:8], 1'b0 }; // B-Type
                7'h23:        imm_q <= { {52{instr_q[31]}}, instr_q[31:25], instr_q[11:7] }; // S-Type
                default:      imm_q <= { {52{instr_q[31]}}, instr_q[31:20] }; // I-Type
            endcase
        end
    end

    // ─────────────────────────────────────────────────────────────────────────
    // 3. EXECUTE STAGE
    // ─────────────────────────────────────────────────────────────────────────
    logic [XLEN-1:0] alu_out_q;
    logic [4:0]      rd_addr_exec_q;
    logic            we_exec_q;
    logic            is_load_q, is_store_q;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            alu_out_q <= 0;
            rd_addr_exec_q <= 0;
            we_exec_q <= 0;
            is_load_q <= 0;
            is_store_q <= 0;
        end else begin
            rd_addr_exec_q <= rd_addr;
            we_exec_q <= (opcode_q != 7'h23 && opcode_q != 7'h63); // Not Store or Branch
            is_load_q  <= (opcode_q == 7'h03);
            is_store_q <= (opcode_q == 7'h23);

            case (opcode_q)
                7'h37: alu_out_q <= imm_q; // LUI
                7'h17: alu_out_q <= pc_q + imm_q; // AUIPC
                7'h13: begin // OP-IMM
                    case (funct3_q)
                        3'h0: alu_out_q <= op_a_q + imm_q; // ADDI
                        3'h2: alu_out_q <= ($signed(op_a_q) < $signed(imm_q)) ? 1 : 0; // SLTI
                        3'h3: alu_out_q <= (op_a_q < imm_q) ? 1 : 0; // SLTIU
                        3'h4: alu_out_q <= op_a_q ^ imm_q; // XORI
                        3'h6: alu_out_q <= op_a_q | imm_q; // ORI
                        3'h7: alu_out_q <= op_a_q & imm_q; // ANDI
                        3'h1: alu_out_q <= op_a_q << imm_q[5:0]; // SLLI
                        3'h5: alu_out_q <= (funct7_q[5]) ? ($signed(op_a_q) >>> imm_q[5:0]) : (op_a_q >> imm_q[5:0]); // SRLI/SRAI
                        default: alu_out_q <= 0;
                    endcase
                end
                7'h33: begin // OP
                    case (funct3_q)
                        3'h0: alu_out_q <= (funct7_q[5]) ? (op_a_q - op_b_q) : (op_a_q + op_b_q); // ADD/SUB
                        3'h1: alu_out_q <= op_a_q << op_b_q[5:0]; // SLL
                        default: alu_out_q <= 0;
                    endcase
                end
                7'h03, 7'h23: alu_out_q <= op_a_q + imm_q; // Load/Store Address
                default: alu_out_q <= 0;
            endcase
        end
    end

    // ─────────────────────────────────────────────────────────────────────────
    // 4. MEMORY & WRITEBACK STAGE
    // ─────────────────────────────────────────────────────────────────────────
    assign data_axi_araddr  = alu_out_q[31:0];
    assign data_axi_arvalid = is_load_q;
    assign data_axi_rready  = 1'b1;

    assign data_axi_awaddr  = alu_out_q[31:0];
    assign data_axi_awvalid = is_store_q;
    assign data_axi_wdata   = op_b_q; // Data to store
    assign data_axi_wvalid  = is_store_q;

    always_ff @(posedge clk) begin
        if (we_exec_q && rd_addr_exec_q != 0) begin
            if (is_load_q && data_axi_rvalid)
                regfile[rd_addr_exec_q] <= data_axi_rdata;
            else
                regfile[rd_addr_exec_q] <= alu_out_q;
        end
    end

endmodule
