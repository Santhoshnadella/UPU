/**
 * UPU (Unified Processing Unit) Top-Level SoC
 * Target: Sky130B @ 50MHz
 * Design Contract: upu_contract.yaml
 */

module upu_top (
    input  logic        clk,
    input  logic        rst_n,

    // UART
    output logic        tx,
    input  logic        rx,

    // GPIO
    output logic [7:0]  gpio_out
);

    // ─────────────────────────────────────────────────────────────────────────
    // Internal AXI4 Signals (64-bit)
    // ─────────────────────────────────────────────────────────────────────────
    
    // Master: CPU
    logic [31:0] cpu_awaddr, cpu_araddr;
    logic        cpu_awvalid, cpu_awready, cpu_arvalid, cpu_arready;
    logic [63:0] cpu_wdata, cpu_rdata;
    logic        cpu_wvalid, cpu_wready, cpu_rvalid, cpu_rready, cpu_bvalid, cpu_bready;

    // Slave Ports (Managed by Crossbar)
    logic [31:0] rom_araddr; logic rom_arvalid, rom_arready, rom_rvalid, rom_rready; logic [63:0] rom_rdata;
    logic [31:0] l2_awaddr, l2_araddr; logic l2_awvalid, l2_awready, l2_arvalid, l2_arready, l2_wvalid, l2_wready, l2_rvalid, l2_rready, l2_bvalid, l2_bready; logic [63:0] l2_wdata, l2_rdata;
    
    // AXI-Lite Slaves (32-bit)
    logic [31:0] tpu_awaddr, tpu_wdata; logic tpu_awvalid, tpu_awready, tpu_wvalid, tpu_wready, tpu_bvalid, tpu_bready;
    logic [31:0] npu_awaddr, npu_wdata; logic npu_awvalid, npu_awready, npu_wvalid, npu_wready, npu_bvalid, npu_bready;
    logic [31:0] gpu_awaddr, gpu_wdata; logic gpu_awvalid, gpu_awready, gpu_wvalid, gpu_wready, gpu_bvalid, gpu_bready;
    logic [31:0] pu_awaddr, pu_wdata;   logic pu_awvalid, pu_awready, pu_wvalid, pu_wready, pu_bvalid, pu_bready;
    
    logic [31:0] plic_awaddr, plic_araddr, plic_wdata, plic_rdata; logic plic_awvalid, plic_awready, plic_arvalid, plic_arready, plic_wvalid, plic_wready, plic_rvalid, plic_rready, plic_bvalid, plic_bready;
    logic [31:0] uart_awaddr, uart_araddr, uart_wdata, uart_rdata; logic uart_awvalid, uart_awready, uart_arvalid, uart_arready, uart_wvalid, uart_wready, uart_rvalid, uart_rready, uart_bvalid, uart_bready;
    logic [31:0] timer_awaddr, timer_araddr, timer_wdata, timer_rdata; logic timer_awvalid, timer_awready, timer_arvalid, timer_arready, timer_wvalid, timer_wready;
    logic [31:0] gpio_awaddr, gpio_wdata; logic gpio_awvalid, gpio_awready, gpio_wvalid, gpio_wready, gpio_bvalid, gpio_bready;

    // Interrupts
    logic [7:0] irq_sources;
    logic       irq_to_cpu;

    // ─────────────────────────────────────────────────────────────────────────
    // CPU Core (RV64I)
    // ─────────────────────────────────────────────────────────────────────────
    rv64_top cpu_inst (
        .clk(clk), .rst_n(rst_n),
        .instr_axi_araddr(cpu_araddr), .instr_axi_arvalid(cpu_arvalid), .instr_axi_arready(cpu_arready), .instr_axi_rdata(cpu_rdata[31:0]), .instr_axi_rvalid(cpu_rvalid), .instr_axi_rready(cpu_rready),
        .data_axi_araddr(), .data_axi_awaddr(cpu_awaddr), .data_axi_awvalid(cpu_awvalid), .data_axi_awready(cpu_awready), .data_axi_wdata(cpu_wdata), .data_axi_wvalid(cpu_wvalid), .data_axi_wready(cpu_wready)
    );
    assign cpu_bready = 1'b1;

    // ─────────────────────────────────────────────────────────────────────────
    // Interconnect & Slaves
    // ─────────────────────────────────────────────────────────────────────────
    axi_crossbar xbar_inst (.*);

    boot_rom rom_inst (.clk(clk), .rst_n(rst_n), .s_axi_araddr(rom_araddr), .s_axi_arvalid(rom_arvalid), .s_axi_arready(rom_arready), .s_axi_rdata(rom_rdata), .s_axi_rvalid(rom_rvalid), .s_axi_rready(rom_rready));
    l2_sram l2_inst (.clk(clk), .rst_n(rst_n), .s_axi_awaddr(l2_awaddr), .s_axi_awvalid(l2_awvalid), .s_axi_awready(l2_awready), .s_axi_wdata(l2_wdata), .s_axi_wstrb(8'hFF), .s_axi_wvalid(l2_wvalid), .s_axi_wready(l2_wready), .s_axi_bvalid(l2_bvalid), .s_axi_bready(l2_bready), .s_axi_araddr(l2_araddr), .s_axi_arvalid(l2_arvalid), .s_axi_arready(l2_arready), .s_axi_rdata(l2_rdata), .s_axi_rvalid(l2_rvalid), .s_axi_rready(l2_rready));

    tpu_core tpu_inst (.clk(clk), .rst_n(rst_n), .s_axi_awaddr(tpu_awaddr), .s_axi_awvalid(tpu_awvalid), .s_axi_awready(tpu_awready), .s_axi_wdata(tpu_wdata), .s_axi_wvalid(tpu_wvalid), .s_axi_wready(tpu_wready), .s_axi_bvalid(tpu_bvalid), .s_axi_bready(tpu_bready), .m_axi_araddr(), .m_axi_arvalid(), .m_axi_arready(1'b1), .m_axi_rdata(64'h0), .m_axi_rvalid(1'b0), .m_axi_rready());
    npu_core npu_inst (.clk(clk), .rst_n(rst_n), .s_axi_awaddr(npu_awaddr), .s_axi_awvalid(npu_awvalid), .s_axi_awready(npu_awready), .s_axi_wdata(npu_wdata), .s_axi_wvalid(npu_wvalid), .s_axi_wready(npu_wready), .s_axi_bvalid(npu_bvalid), .s_axi_bready(npu_bready), .activation_in('{default:0}), .weight_in('{default:0}), .valid_in(1'b0), .npu_out(), .valid_out());
    gpu_core gpu_inst (.clk(clk), .rst_n(rst_n), .s_axi_awaddr(gpu_awaddr), .s_axi_awvalid(gpu_awvalid), .s_axi_awready(gpu_awready), .s_axi_wdata(gpu_wdata), .s_axi_wvalid(gpu_wvalid), .s_axi_wready(gpu_wready), .gpu_done_irq(irq_sources[2]));
    pu_core  pu_inst  (.clk(clk), .rst_n(rst_n), .s_axi_awaddr(pu_awaddr), .s_axi_awvalid(pu_awvalid), .s_axi_awready(pu_awready), .s_axi_wdata(pu_wdata), .s_axi_wvalid(pu_wvalid), .s_axi_wready(pu_wready), .pu_done_irq(irq_sources[3]));

    plic_simple  plic_inst  (.clk(clk), .rst_n(rst_n), .s_axi_awaddr(plic_awaddr), .s_axi_awvalid(plic_awvalid), .s_axi_awready(plic_awready), .s_axi_wdata(plic_wdata), .s_axi_wvalid(plic_wvalid), .s_axi_wready(plic_wready), .s_axi_bvalid(plic_bvalid), .s_axi_bready(plic_bready), .s_axi_araddr(plic_araddr), .s_axi_arvalid(plic_arvalid), .s_axi_arready(plic_arready), .s_axi_rdata(plic_rdata), .s_axi_rvalid(plic_rvalid), .s_axi_rready(plic_rready), .irq_sources(irq_sources), .irq_to_cpu(irq_to_cpu));
    uart_simple  uart_inst  (.clk(clk), .rst_n(rst_n), .s_axi_awaddr(uart_awaddr), .s_axi_awvalid(uart_awvalid), .s_axi_awready(uart_awready), .s_axi_wdata(uart_wdata), .s_axi_wvalid(uart_wvalid), .s_axi_wready(uart_wready), .s_axi_araddr(uart_araddr), .s_axi_arvalid(uart_arvalid), .s_axi_arready(uart_arready), .s_axi_rdata(uart_rdata), .s_axi_rvalid(uart_rvalid), .s_axi_rready(uart_rready), .tx(tx), .rx(rx), .interrupt(irq_sources[5]));
    timer_simple timer_inst (.clk(clk), .rst_n(rst_n), .s_axi_awaddr(timer_awaddr), .s_axi_awvalid(timer_awvalid), .s_axi_awready(timer_awready), .s_axi_wdata(timer_wdata), .s_axi_wvalid(timer_wvalid), .s_axi_wready(timer_wready), .interrupt(irq_sources[6]));
    gpio_simple  gpio_inst  (.clk(clk), .rst_n(rst_n), .s_axi_awaddr(gpio_awaddr), .s_axi_awvalid(gpio_awvalid), .s_axi_awready(gpio_awready), .s_axi_wdata(gpio_wdata), .s_axi_wvalid(gpio_wvalid), .s_axi_wready(gpio_wready), .gpio_out(gpio_out), .gpio_irq(irq_sources[7]));

    assign irq_sources[0] = tpu_inst.reg_ctrl[2]; // TPU_DONE
    assign irq_sources[1] = npu_inst.valid_out;   // NPU_DONE
    assign irq_sources[4] = 1'b0;                // DMA spare

endmodule
