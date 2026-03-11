/**
 * ASYNC CDC FIFO with Gray Coding
 * Standard Industry Practice for Clock Domain Crossing
 */
module cdc_fifo #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
) (
    input  logic                  wr_clk,
    input  logic                  wr_rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic                  wr_full,

    input  logic                  rd_clk,
    input  logic                  rd_rst_n,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  rd_empty
);

    localparam DEPTH = 1 << ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] mem [DEPTH];

    logic [ADDR_WIDTH:0] wr_ptr, wr_ptr_gray, wr_ptr_rd_sync1, wr_ptr_rd_sync2;
    logic [ADDR_WIDTH:0] rd_ptr, rd_ptr_gray, rd_ptr_wr_sync1, rd_ptr_wr_sync2;

    // Gray conversion
    function automatic logic [ADDR_WIDTH:0] bin2gray(logic [ADDR_WIDTH:0] bin);
        return bin ^ (bin >> 1);
    endfunction

    // Write Logic
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !wr_full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1;
            wr_ptr_gray <= bin2gray(wr_ptr + 1);
        end
    end

    // Read Logic
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr <= 0;
            rd_ptr_gray <= 0;
        end else if (rd_en && !rd_empty) begin
            rd_ptr <= rd_ptr + 1;
            rd_ptr_gray <= bin2gray(rd_ptr + 1);
        end
    end
    assign rd_data = mem[rd_ptr[ADDR_WIDTH-1:0]];

    // Synchronization
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_rd_sync1 <= 0;
            wr_ptr_rd_sync2 <= 0;
        end else begin
            wr_ptr_rd_sync1 <= wr_ptr_gray;
            wr_ptr_rd_sync2 <= wr_ptr_rd_sync1;
        end
    end

    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_wr_sync1 <= 0;
            rd_ptr_wr_sync2 <= 0;
        end else begin
            rd_ptr_wr_sync1 <= rd_ptr_gray;
            rd_ptr_wr_sync2 <= rd_ptr_wr_sync1;
        end
    end

    // Full/Empty Status
    assign rd_empty = (rd_ptr_gray == wr_ptr_rd_sync2);
    assign wr_full  = (wr_ptr_gray == {~rd_ptr_wr_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rd_ptr_wr_sync2[ADDR_WIDTH-2:0]});

endmodule
