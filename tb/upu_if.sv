/**
 * UPU System Interface
 */
interface upu_if(input logic clk, input logic rst_n);
    logic [63:0] addr;
    logic [63:0] wdata;
    logic [63:0] rdata;
    logic        we;
    logic        valid;
    logic        ready;
endinterface
