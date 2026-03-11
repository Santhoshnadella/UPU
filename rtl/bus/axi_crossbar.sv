/**
 * AXI4 Interconnect / Crossbar (1xN Master/Slaves)
 * Target: Sky130B @ 50MHz
 * Design Contract: AXI4 (64-bit data, 32-bit addr)
 */

module axi_crossbar #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // CPU (Master)
    input  logic [ADDR_WIDTH-1:0]  cpu_axi_awaddr,
    input  logic                   cpu_axi_awvalid,
    output logic                   cpu_axi_awready,
    input  logic [DATA_WIDTH-1:0]  cpu_axi_wdata,
    input  logic                   cpu_axi_wvalid,
    output logic                   cpu_axi_wready,
    output logic                   cpu_axi_bvalid,
    input  logic                   cpu_axi_bready,
    input  logic [ADDR_WIDTH-1:0]  cpu_axi_araddr,
    input  logic                   cpu_axi_arvalid,
    output logic                   cpu_axi_arready,
    output logic [DATA_WIDTH-1:0]  cpu_axi_rdata,
    output logic                   cpu_axi_rvalid,
    input  logic                   cpu_axi_rready,

    // Slaves
    // -------------------------------------------------------------------------
    
    // Slv 0: Boot ROM (Read Only)
    output logic [31:0]            rom_axi_araddr,
    output logic                   rom_axi_arvalid,
    input  logic                   rom_axi_arready,
    input  logic [63:0]            rom_axi_rdata,
    input  logic                   rom_axi_rvalid,
    output logic                   rom_axi_rready,

    // Slv 1: L2 SRAM (Read/Write)
    output logic [31:0]            l2_axi_awaddr,
    output logic                   l2_axi_awvalid,
    input  logic                   l2_axi_awready,
    output logic [63:0]            l2_axi_wdata,
    output logic                   l2_axi_wvalid,
    input  logic                   l2_axi_wready,
    input  logic                   l2_axi_bvalid,
    output logic                   l2_axi_bready,
    output logic [31:0]            l2_axi_araddr,
    output logic                   l2_axi_arvalid,
    input  logic                   l2_axi_arready,
    input  logic [63:0]            l2_axi_rdata,
    input  logic                   l2_axi_rvalid,
    output logic                   l2_axi_rready,

    // Slv 2-4: TPU, NPU, GPU, PU (32-bit AXI-Lite Regs)
    output logic [31:0]            tpu_axi_awaddr,
    output logic                   tpu_axi_awvalid,
    input  logic                   tpu_axi_awready,
    output logic [31:0]            tpu_axi_wdata,
    output logic                   tpu_axi_wvalid,
    input  logic                   tpu_axi_wready,
    input  logic                   tpu_axi_bvalid,
    output logic                   tpu_axi_bready,

    output logic [31:0]            npu_axi_awaddr,
    output logic                   npu_axi_awvalid,
    input  logic                   npu_axi_awready,
    output logic [31:0]            npu_axi_wdata,
    output logic                   npu_axi_wvalid,
    input  logic                   npu_axi_wready,
    input  logic                   npu_axi_bvalid,
    output logic                   npu_axi_bready,

    output logic [31:0]            gpu_axi_awaddr,
    output logic                   gpu_axi_awvalid,
    input  logic                   gpu_axi_awready,
    output logic [31:0]            gpu_axi_wdata,
    output logic                   gpu_axi_wvalid,
    input  logic                   gpu_axi_wready,
    input  logic                   gpu_axi_bvalid,
    output logic                   gpu_axi_bready,

    output logic [31:0]            pu_axi_awaddr,
    output logic                   pu_axi_awvalid,
    input  logic                   pu_axi_awready,
    output logic [31:0]            pu_axi_wdata,
    output logic                   pu_axi_wvalid,
    input  logic                   pu_axi_wready,
    input  logic                   pu_axi_bvalid,
    output logic                   pu_axi_bready,

    // Slv 5-8: PLIC, UART, Timer, GPIO (32-bit AXI-Lite Regs)
    output logic [31:0]            plic_axi_awaddr,
    output logic                   plic_axi_awvalid,
    input  logic                   plic_axi_awready,
    output logic [31:0]            plic_axi_wdata,
    output logic                   plic_axi_wvalid,
    input  logic                   plic_axi_wready,
    input  logic                   plic_axi_bvalid,
    output logic                   plic_axi_bready,
    output logic [31:0]            plic_axi_araddr,
    output logic                   plic_axi_arvalid,
    input  logic                   plic_axi_arready,
    input  logic [31:0]            plic_axi_rdata,
    input  logic                   plic_axi_rvalid,
    output logic                   plic_axi_rready,

    output logic [31:0]            uart_axi_awaddr,
    output logic                   uart_axi_awvalid,
    input  logic                   uart_axi_awready,
    output logic [31:0]            uart_axi_wdata,
    output logic                   uart_axi_wvalid,
    input  logic                   uart_axi_wready,
    input  logic                   uart_axi_bvalid,
    output logic                   uart_axi_bready,
    output logic [31:0]            uart_axi_araddr,
    output logic                   uart_axi_arvalid,
    input  logic                   uart_axi_arready,
    input  logic [31:0]            uart_axi_rdata,
    input  logic                   uart_axi_rvalid,
    output logic                   uart_axi_rready,

    output logic [31:0]            timer_axi_awaddr,
    output logic                   timer_axi_awvalid,
    input  logic                   timer_axi_awready,
    output logic [31:0]            timer_axi_wdata,
    output logic                   timer_axi_wvalid,
    input  logic                   timer_axi_wready,
    output logic [31:0]            timer_axi_araddr,
    output logic                   timer_axi_arvalid,
    input  logic                   timer_axi_arready,
    input  logic [31:0]            timer_axi_rdata,
    input  logic                   timer_axi_rvalid,
    output logic                   timer_axi_rready,

    output logic [31:0]            gpio_axi_awaddr,
    output logic                   gpio_axi_awvalid,
    input  logic                   gpio_axi_awready,
    output logic [31:0]            gpio_axi_wdata,
    output logic                   gpio_axi_wvalid,
    input  logic                   gpio_axi_wready,
    output logic                   gpio_axi_bvalid,
    input  logic                   gpio_axi_bready
);

    // Address Decoding
    // -------------------------------------------------------------------------
    
    // Read channel select
    logic [3:0] ar_sel;
    always_comb begin
        if (cpu_axi_araddr[31:28] == 4'h0)      ar_sel = 0; // ROM (0x0...)
        else if (cpu_axi_araddr[31:28] == 4'h1) ar_sel = 1; // L2 (0x1...)
        else if (cpu_axi_araddr[31:28] == 4'h4) ar_sel = 5; // PLIC (0x4...)
        else if (cpu_axi_araddr[31:16] == 16'h5000) ar_sel = 6; // UART (0x50000...)
        else if (cpu_axi_araddr[31:16] == 16'h5001) ar_sel = 7; // Timer (0x5001...)
        else                                    ar_sel = 15; // Error
    end

    // Write channel select
    logic [3:0] aw_sel;
    always_comb begin
        if (cpu_axi_awaddr[31:28] == 4'h1)      aw_sel = 1; // L2
        else if (cpu_axi_awaddr[31:16] == 16'h3000) aw_sel = 2; // TPU
        else if (cpu_axi_awaddr[31:16] == 16'h3001) aw_sel = 3; // NPU
        else if (cpu_axi_awaddr[31:16] == 16'h3002) aw_sel = 4; // GPU
        else if (cpu_axi_awaddr[31:16] == 16'h3003) aw_sel = 8; // PU (0x3003...)
        else if (cpu_axi_awaddr[31:28] == 4'h4) aw_sel = 5; // PLIC
        else if (cpu_axi_awaddr[31:16] == 16'h5000) aw_sel = 6; // UART
        else if (cpu_axi_awaddr[31:16] == 16'h5001) aw_sel = 7; // Timer
        else if (cpu_axi_awaddr[31:16] == 16'h5002) aw_sel = 9; // GPIO (0x5002...)
        else                                    aw_sel = 15;
    end

    // Forwarding logic (simplified)
    assign rom_axi_araddr   = cpu_axi_araddr;
    assign rom_axi_arvalid  = (ar_sel == 0) ? cpu_axi_arvalid : 1'b0;
    assign rom_axi_rready   = (ar_sel == 0) ? cpu_axi_rready : 1'b0;

    assign l2_axi_awaddr    = cpu_axi_awaddr;
    assign l2_axi_awvalid   = (aw_sel == 1) ? cpu_axi_awvalid : 1'b0;
    assign l2_axi_wdata     = cpu_axi_wdata;
    assign l2_axi_wvalid    = (aw_sel == 1) ? cpu_axi_wvalid : 1'b0;
    assign l2_axi_bready    = (aw_sel == 1) ? cpu_axi_bready : 1'b0;
    assign l2_axi_araddr    = cpu_axi_araddr;
    assign l2_axi_arvalid   = (ar_sel == 1) ? cpu_axi_arvalid : 1'b0;
    assign l2_axi_rready    = (ar_sel == 1) ? cpu_axi_rready : 1'b0;

    assign tpu_axi_awaddr   = cpu_axi_awaddr;
    assign tpu_axi_awvalid  = (aw_sel == 2) ? cpu_axi_awvalid : 1'b0;
    assign tpu_axi_wdata    = cpu_axi_wdata[31:0];
    assign tpu_axi_wvalid   = (aw_sel == 2) ? cpu_axi_wvalid : 1'b0;
    assign tpu_axi_bready   = (aw_sel == 2) ? cpu_axi_bready : 1'b0;

    assign npu_axi_awaddr   = cpu_axi_awaddr;
    assign npu_axi_awvalid  = (aw_sel == 3) ? cpu_axi_awvalid : 1'b0;
    assign npu_axi_wdata    = cpu_axi_wdata[31:0];
    assign npu_axi_wvalid   = (aw_sel == 3) ? cpu_axi_wvalid : 1'b0;
    assign npu_axi_bready   = (aw_sel == 3) ? cpu_axi_bready : 1'b0;

    assign gpu_axi_awaddr   = cpu_axi_awaddr;
    assign gpu_axi_awvalid  = (aw_sel == 4) ? cpu_axi_awvalid : 1'b0;
    assign gpu_axi_wdata    = cpu_axi_wdata[31:0];
    assign gpu_axi_wvalid   = (aw_sel == 4) ? cpu_axi_wvalid : 1'b0;
    assign gpu_axi_bready   = (aw_sel == 4) ? cpu_axi_bready : 1'b0;

    assign pu_axi_awaddr    = cpu_axi_awaddr;
    assign pu_axi_awvalid   = (aw_sel == 8) ? cpu_axi_awvalid : 1'b0;
    assign pu_axi_wdata     = cpu_axi_wdata[31:0];
    assign pu_axi_wvalid    = (aw_sel == 8) ? cpu_axi_wvalid : 1'b0;
    assign pu_axi_bready    = (aw_sel == 8) ? cpu_axi_bready : 1'b0;

    assign plic_axi_awaddr  = cpu_axi_awaddr;
    assign plic_axi_awvalid = (aw_sel == 5) ? cpu_axi_awvalid : 1'b0;
    assign plic_axi_wdata   = cpu_axi_wdata[31:0];
    assign plic_axi_wvalid  = (aw_sel == 5) ? cpu_axi_wvalid : 1'b0;
    assign plic_axi_bready  = (aw_sel == 5) ? cpu_axi_bready : 1'b0;
    assign plic_axi_araddr  = cpu_axi_araddr;
    assign plic_axi_arvalid = (ar_sel == 5) ? cpu_axi_arvalid : 1'b0;
    assign plic_axi_rready  = (ar_sel == 5) ? cpu_axi_rready : 1'b0;

    assign uart_axi_awaddr  = cpu_axi_awaddr;
    assign uart_axi_awvalid = (aw_sel == 6) ? cpu_axi_awvalid : 1'b0;
    assign uart_axi_wdata   = cpu_axi_wdata[31:0];
    assign uart_axi_wvalid  = (aw_sel == 6) ? cpu_axi_wvalid : 1'b0;
    assign uart_axi_bready  = (aw_sel == 6) ? cpu_axi_bready : 1'b0;
    assign uart_axi_araddr  = cpu_axi_araddr;
    assign uart_axi_arvalid = (ar_sel == 6) ? cpu_axi_arvalid : 1'b0;
    assign uart_axi_rready  = (ar_sel == 6) ? cpu_axi_rready : 1'b0;

    assign timer_axi_awaddr = cpu_axi_awaddr;
    assign timer_axi_awvalid = (aw_sel == 7) ? cpu_axi_awvalid : 1'b0;
    assign timer_axi_wdata   = cpu_axi_wdata[31:0];
    assign timer_axi_wvalid  = (aw_sel == 7) ? cpu_axi_wvalid : 1'b0;
    assign timer_axi_araddr  = cpu_axi_araddr;
    assign timer_axi_arvalid = (ar_sel == 7) ? cpu_axi_arvalid : 1'b0;
    assign timer_axi_rready  = (ar_sel == 7) ? cpu_axi_rready : 1'b0;

    assign gpio_axi_awaddr  = cpu_axi_awaddr;
    assign gpio_axi_awvalid = (aw_sel == 9) ? cpu_axi_awvalid : 1'b0;
    assign gpio_axi_wdata   = cpu_axi_wdata[31:0];
    assign gpio_axi_wvalid  = (aw_sel == 9) ? cpu_axi_wvalid : 1'b0;
    assign gpio_axi_bready  = (aw_sel == 9) ? cpu_axi_bready : 1'b0;

    // Master Back-routing
    always_comb begin
        case (ar_sel)
            0: begin cpu_axi_arready = rom_axi_arready; cpu_axi_rvalid = rom_axi_rvalid; cpu_axi_rdata = rom_axi_rdata; end
            1: begin cpu_axi_arready = l2_axi_arready;  cpu_axi_rvalid = l2_axi_rvalid;  cpu_axi_rdata = l2_axi_rdata; end
            5: begin cpu_axi_arready = plic_axi_arready; cpu_axi_rvalid = plic_axi_rvalid; cpu_axi_rdata = {32'h0, plic_axi_rdata}; end
            6: begin cpu_axi_arready = uart_axi_arready; cpu_axi_rvalid = uart_axi_rvalid; cpu_axi_rdata = {32'h0, uart_axi_rdata}; end
            7: begin cpu_axi_arready = timer_axi_arready; cpu_axi_rvalid = timer_axi_rvalid; cpu_axi_rdata = {32'h0, timer_axi_rdata}; end
            default: begin cpu_axi_arready = 1'b1; cpu_axi_rvalid = 1'b1; cpu_axi_rdata = 64'hDEADBEEF; end
        endcase
    end

    always_comb begin
        case (aw_sel)
            1: begin cpu_axi_awready = l2_axi_awready; cpu_axi_wready = l2_axi_wready; cpu_axi_bvalid = l2_axi_bvalid; end
            2: begin cpu_axi_awready = tpu_axi_awready; cpu_axi_wready = tpu_axi_wready; cpu_axi_bvalid = tpu_axi_bvalid; end
            3: begin cpu_axi_awready = npu_axi_awready; cpu_axi_wready = npu_axi_wready; cpu_axi_bvalid = npu_axi_bvalid; end
            4: begin cpu_axi_awready = gpu_axi_awready; cpu_axi_wready = gpu_axi_wready; cpu_axi_bvalid = 1'b1; end // GPU B is implicit
            5: begin cpu_axi_awready = plic_axi_awready; cpu_axi_wready = plic_axi_wready; cpu_axi_bvalid = plic_axi_bvalid; end
            6: begin cpu_axi_awready = uart_axi_awready; cpu_axi_wready = uart_axi_wready; cpu_axi_bvalid = 1'b1; end
            7: begin cpu_axi_awready = timer_axi_awready; cpu_axi_wready = timer_axi_wready; cpu_axi_bvalid = 1'b1; end
            8: begin cpu_axi_awready = pu_axi_awready; cpu_axi_wready = pu_axi_wready; cpu_axi_bvalid = 1'b1; end
            9: begin cpu_axi_awready = gpio_axi_awready; cpu_axi_wready = gpio_axi_wready; cpu_axi_bvalid = 1'b1; end
            default: begin cpu_axi_awready = 1'b1; cpu_axi_wready = 1'b1; cpu_axi_bvalid = 1'b1; end
        endcase
    end

endmodule
