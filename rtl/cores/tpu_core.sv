/**
 * TPU Core (16x16 Systolic Array)
 * Target: Sky130B @ 50MHz
 * Design Contract: TPU (INT8 × INT8 = INT32)
 */

module tpu_core #(
    parameter ARRAY_SIZE = 16,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // AXI-Lite Peripheral Slave (Registers)
    input  logic [ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  logic                   s_axi_awvalid,
    output logic                   s_axi_awready,
    input  logic [DATA_WIDTH-1:0]  s_axi_wdata,
    input  logic                   s_axi_wvalid,
    output logic                   s_axi_wready,
    output logic                   s_axi_bvalid,
    input  logic                   s_axi_bready,

    // AXI4 Master (DMA access to L2)
    output logic [ADDR_WIDTH-1:0]  m_axi_araddr,
    output logic                   m_axi_arvalid,
    input  logic                   m_axi_arready,
    input  logic [63:0]            m_axi_rdata,
    input  logic                   m_axi_rvalid,
    output logic                   m_axi_rready
);

    // TPU Systolic Array: 16x16 PEs
    logic [7:0]  pe_north_in [ARRAY_SIZE][ARRAY_SIZE];
    logic [7:0]  pe_west_in  [ARRAY_SIZE][ARRAY_SIZE];
    logic [7:0]  pe_south_out [ARRAY_SIZE][ARRAY_SIZE];
    logic [7:0]  pe_east_out  [ARRAY_SIZE][ARRAY_SIZE];
    logic [31:0] pe_acc_out   [ARRAY_SIZE][ARRAY_SIZE];
    logic        pe_clear_acc [ARRAY_SIZE][ARRAY_SIZE];

    // Array Generation Logic
    genvar row, col;
    generate
        for (row = 0; row < ARRAY_SIZE; row++) begin : row_gen
            for (col = 0; col < ARRAY_SIZE; col++) begin : col_gen
                tpu_pe #(8, 32) pe_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    // Connect based on grid position
                    .north_data_in ( (row == 0) ? pe_north_in[0][col] : pe_south_out[row-1][col] ),
                    .west_data_in  ( (col == 0) ? pe_west_in[row][0]  : pe_east_out[row][col-1] ),
                    .south_data_out( pe_south_out[row][col] ),
                    .east_data_out ( pe_east_out[row][col] ),
                    .clear_acc     ( pe_clear_acc[row][col] ),
                    .acc_data_out  ( pe_acc_out[row][col] )
                );
            end
        end
    endgenerate

    // ─────────────────────────────────────────────────────────────────────────
    // Control Registers
    // ─────────────────────────────────────────────────────────────────────────
    logic [31:0] reg_ctrl;        // [0]: start, [1]: busy, [2]: done, [7:3]: state
    logic [31:0] reg_north_src;   // L2 Base for North data
    logic [31:0] reg_west_src;    // L2 Base for West data
    logic [15:0] reg_count;       // Total steps to run

    // State Machine
    typedef enum logic [3:0] {
        IDLE, 
        AR_ADDR_NORTH, 
        R_DATA_NORTH,
        AR_ADDR_WEST,
        R_DATA_WEST,
        COMPute, 
        FINISH
    } tpu_state_t;
    tpu_state_t state_q;

    // Internal Buffers for Systolic Feeding
    logic [7:0] north_feeding_buf [ARRAY_SIZE];
    logic [7:0] west_feeding_buf  [ARRAY_SIZE];
    logic [7:0] step_counter;

    // AXI-Lite Slave (Control) Logic
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            s_axi_awready <= 1'b1;
            s_axi_wready <= 1'b1;
            s_axi_bvalid <= 1'b0;
            reg_ctrl <= 0;
            reg_north_src <= 0;
            reg_west_src <= 0;
            reg_count <= 0;
        end else begin
            if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                case (s_axi_awaddr[7:0])
                    8'h00: reg_ctrl      <= s_axi_wdata;
                    8'h04: reg_north_src <= s_axi_wdata;
                    8'h08: reg_west_src  <= s_axi_wdata;
                    8'h0C: reg_count     <= s_axi_wdata[15:0];
                endcase
                s_axi_bvalid <= 1'b1;
            end
            if (s_axi_bvalid && s_axi_bready) s_axi_bvalid <= 1'b0;
            
            // Auto-clear start and manage busy/done
            if (reg_ctrl[0] && state_q == IDLE) reg_ctrl[1] <= 1'b1; // Set Busy
            if (state_q == FINISH) begin
                reg_ctrl[1] <= 1'b0; // Clear Busy
                reg_ctrl[2] <= 1'b1; // Set Done
            end
        end
    end

    // DMA Master Logic (Simplified for 64-bit bursts)
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state_q <= IDLE;
            m_axi_arvalid <= 1'b0;
            m_axi_araddr  <= 0;
            m_axi_rready  <= 1'b0;
            step_counter  <= 0;
        end else begin
            case (state_q)
                IDLE: begin
                    if (reg_ctrl[0]) state_q <= AR_ADDR_NORTH;
                    step_counter <= 0;
                    m_axi_arvalid <= 1'b0;
                end

                AR_ADDR_NORTH: begin
                    m_axi_araddr  <= reg_north_src + (step_counter << 3); // 8-byte steps
                    m_axi_arvalid <= 1'b1;
                    if (m_axi_arready) begin
                        m_axi_arvalid <= 1'b0;
                        state_q <= R_DATA_NORTH;
                    end
                end

                R_DATA_NORTH: begin
                    m_axi_rready <= 1'b1;
                    if (m_axi_rvalid) begin
                        // Load 8 elements (assuming INT8) from 64-bit bus
                        for (int i=0; i<8; i++) north_feeding_buf[i] <= m_axi_rdata[i*8 +: 8];
                        state_q <= AR_ADDR_WEST;
                    end
                end

                AR_ADDR_WEST: begin
                    m_axi_araddr  <= reg_west_src + (step_counter << 3);
                    m_axi_arvalid <= 1'b1;
                    if (m_axi_arready) begin
                        m_axi_arvalid <= 1'b0;
                        state_q <= R_DATA_WEST;
                    end
                end

                R_DATA_WEST: begin
                    m_axi_rready <= 1'b1;
                    if (m_axi_rvalid) begin
                        for (int i=0; i<8; i++) west_feeding_buf[i] <= m_axi_rdata[i*8 +: 8];
                        state_q <= COMPute;
                    end
                end

                COMPute: begin
                    // Feeding the systolic grid
                    for (int i=0; i<ARRAY_SIZE; i++) begin
                        pe_north_in[0][i] <= north_feeding_buf[i];
                        pe_west_in[i][0]  <= west_feeding_buf[i];
                    end
                    
                    if (step_counter < reg_count) begin
                        step_counter <= step_counter + 1;
                        state_q <= AR_ADDR_NORTH;
                    end else begin
                        state_q <= FINISH;
                    end
                end

                FINISH: begin
                    state_q <= IDLE;
                end
            endcase
        end
    end

endmodule
