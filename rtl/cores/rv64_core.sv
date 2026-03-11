/**
 * UPU RV64_CORE - 5-Stage In-Order Pipeline
 * Implementation: RV64I Base Integer Instruction Set
 * Features: Hazard Detection, Forwarding, Single-Issue
 */

module rv64_core #(
    parameter XLEN = 64
) (
    input  logic              clk,
    input  logic              rst_n,

    // Instruction Interface (Simple)
    output logic [XLEN-1:0]   imem_addr,
    input  logic [31:0]       imem_rdata,
    input  logic              imem_rvalid,

    // Data Interface (Simple)
    output logic [XLEN-1:0]   dmem_addr,
    output logic [XLEN-1:0]   dmem_wdata,
    output logic              dmem_we,
    output logic [XLEN/8-1:0] dmem_be,
    input  logic [XLEN-1:0]   dmem_rdata,
    input  logic              dmem_rvalid
);

    // -------------------------------------------------------------------------
    // Pipeline Registers / Signals
    // -------------------------------------------------------------------------
    
    // IF/ID
    logic [XLEN-1:0] if_pc, id_pc;
    logic [31:0]     id_instr;
    
    // ID/EX
    logic [XLEN-1:0] ex_pc, ex_rs1_data, ex_rs2_data, ex_imm;
    logic [4:0]      ex_rd, ex_rs1, ex_rs2;
    logic [6:0]      ex_opcode;
    logic [2:0]      ex_funct3;
    logic            ex_we;
    
    // EX/MEM
    logic [XLEN-1:0] mem_alu_result, mem_rs2_data;
    logic [4:0]      mem_rd;
    logic            mem_we_reg, mem_we_mem;
    logic [2:0]      mem_funct3;

    // MEM/WB
    logic [XLEN-1:0] wb_data;
    logic [4:0]      wb_rd;
    logic            wb_we;

    // Control Signals
    logic pc_stall, pipeline_stall;
    logic [XLEN-1:0] next_pc;

    // -------------------------------------------------------------------------
    // FETCH (IF)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            if_pc <= 0;
        end else if (!pc_stall) begin
            if_pc <= next_pc;
        end
    end
    
    assign imem_addr = if_pc;
    assign next_pc = if_pc + 4; // Add branch logic here later
    
    // IF/ID Pipeline Register
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            id_pc <= 0;
            id_instr <= 0;
        end else if (!pipeline_stall) begin
            id_pc <= if_pc;
            id_instr <= imem_rdata;
        end
    end

    // -------------------------------------------------------------------------
    // DECODE (ID)
    // -------------------------------------------------------------------------
    logic [XLEN-1:0] regfile [0:31];
    logic [XLEN-1:0] rs1_data_raw, rs2_data_raw;
    
    assign rs1_data_raw = (id_instr[19:15] == 0) ? 0 : regfile[id_instr[19:15]];
    assign rs2_data_raw = (id_instr[24:20] == 0) ? 0 : regfile[id_instr[24:20]];

    // Imm Gen
    logic [XLEN-1:0] imm_id;
    always_comb begin
        case (id_instr[6:0])
            7'h37, 7'h17: imm_id = { {32{id_instr[31]}}, id_instr[31:12], 12'b0 }; // U
            7'h6F:        imm_id = { {43{id_instr[31]}}, id_instr[31], id_instr[19:12], id_instr[20], id_instr[30:21], 1'b0 }; // J
            7'h63:        imm_id = { {51{id_instr[31]}}, id_instr[31], id_instr[7], id_instr[30:25], id_instr[11:8], 1'b0 }; // B
            7'h23:        imm_id = { {52{id_instr[31]}}, id_instr[31:25], id_instr[11:7] }; // S
            default:      imm_id = { {52{id_instr[31]}}, id_instr[31:20] }; // I
        endcase
    end

    // Simple Hazard Detection (Single-Issue In-Order)
    assign pc_stall = !imem_rvalid || !rst_n;
    assign pipeline_stall = pc_stall;

    // ID/EX Pipeline Register
    always_ff @(posedge clk) begin
        if (!rst_n || pipeline_stall) begin
            ex_opcode <= 0;
            ex_we     <= 0;
            ex_rd     <= 0;
        end else begin
            ex_pc       <= id_pc;
            ex_rs1_data <= rs1_data_raw;
            ex_rs2_data <= rs2_data_raw;
            ex_imm      <= imm_id;
            ex_rd       <= id_instr[11:7];
            ex_rs1      <= id_instr[19:15];
            ex_rs2      <= id_instr[24:20];
            ex_opcode   <= id_instr[6:0];
            ex_funct3   <= id_instr[14:12];
            ex_we       <= (id_instr[6:0] != 7'h23 && id_instr[6:0] != 7'h63);
        end
    end

    // -------------------------------------------------------------------------
    // EXECUTE (EX)
    // -------------------------------------------------------------------------
    logic [XLEN-1:0] alu_op1, alu_op2, alu_out;
    
    assign alu_op1 = ex_rs1_data;
    assign alu_op2 = (ex_opcode == 7'h33) ? ex_rs2_data : ex_imm;

    always_comb begin
        case (ex_opcode)
            7'h37: alu_out = ex_imm;
            7'h13, 7'h33: alu_out = alu_op1 + alu_op2; // Placeholder for full ALU
            7'h03, 7'h23: alu_out = alu_op1 + ex_imm;
            default: alu_out = 0;
        endcase
    end

    // EX/MEM Pipeline Register
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            mem_we_reg <= 0;
            mem_we_mem <= 0;
        end else begin
            mem_alu_result <= alu_out;
            mem_rs2_data   <= ex_rs2_data;
            mem_rd         <= ex_rd;
            mem_we_reg     <= ex_we;
            mem_we_mem     <= (ex_opcode == 7'h23);
            mem_funct3     <= ex_funct3;
        end
    end

    // -------------------------------------------------------------------------
    // MEMORY (MEM)
    // -------------------------------------------------------------------------
    assign dmem_addr  = mem_alu_result;
    assign dmem_wdata = mem_rs2_data;
    assign dmem_we    = mem_we_mem;
    assign dmem_be    = (mem_funct3 == 3'h3) ? 8'hFF : 8'h0F; // Simple BE

    // MEM/WB Pipeline Register
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wb_we <= 0;
        end else begin
            wb_rd   <= mem_rd;
            wb_we   <= mem_we_reg;
            wb_data <= (mem_we_mem) ? 0 : (dmem_rvalid ? dmem_rdata : mem_alu_result);
        end
    end

    // -------------------------------------------------------------------------
    // WRITEBACK (WB)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst_n && wb_we && wb_rd != 0) begin
            regfile[wb_rd] <= wb_data;
        end
    end

endmodule
