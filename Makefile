# UPU v1: SoC Build & Verification Makefile
# -------------------------------------------------------------------------
# Targets:
#   sim_top      : Runs Top-level SoC simulation
#   sim_cpu      : Runs RV64I Core simulation
#   sim_tpu      : Runs TPU Systolic Array simulation
#   sim_npu      : Runs NPU Neural PE simulation
#   sim_gpu      : Runs GPU Vector SIMD simulation
#   synth        : Runs Logic Synthesis via Yosys
#   physical     : Executed LibreLane Physical Design (GDSII)
# -------------------------------------------------------------------------

# Tool Definitions
IVERILOG  = iverilog
VVP       = vvp
VERILATOR = verilator
YOSYS     = yosys
OPENLANE  = openlane

RTL_DIR = ./rtl
TB_DIR = ./tb
OUTPUT_DIR = ./build

# RISC-V Compiler (Requires riscv64-unknown-elf-gcc)
CROSS_COMPILE = riscv64-unknown-elf-
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy

CFLAGS = -march=rv64i -mabi=lp64 -ffreestanding -O2 -I./firmware
LDFLAGS = -T ./firmware/link.ld -nostdlib

FW_SOURCES = ./firmware/src/main.c ./firmware/drivers/tpu.c ./firmware/drivers/gpu.c ./firmware/drivers/npu.c ./firmware/drivers/uart.c ./firmware/drivers/plic.c ./firmware/drivers/timer.c ./firmware/drivers/gpio.c
FW_ASM = ./firmware/crt0.S

# Source Files for Simulation
SOURCES = $(RTL_DIR)/upu_top.sv \
          $(RTL_DIR)/bus/hyper_noc.sv \
          $(RTL_DIR)/cores/rv64_top.sv \
          $(RTL_DIR)/cores/rv64_core.sv \
          $(RTL_DIR)/cores/tpu_core.sv \
          $(RTL_DIR)/cores/tpu_pe.sv \
          $(RTL_DIR)/cores/npu_core.sv \
          $(RTL_DIR)/cores/npu_pe.sv \
          $(RTL_DIR)/cores/gpu_core.sv \
          $(RTL_DIR)/memory/l2_sram.sv

.PHONY: all clean sim_top sim_cpu sim_tpu sim_npu sim_gpu synth physical firmware lint

all: firmware sim_top sim_cpu sim_tpu sim_npu sim_gpu

clean:
	rm -rf $(OUTPUT_DIR) *.vcd *.vvp *.elf *.bin *.hex obj_dir/

# -------------------------------------------------------------------------
# Linting (Verilator)
# -------------------------------------------------------------------------
lint_top:
	$(VERILATOR) --lint-only -Wall --timing -y rtl/cores -y rtl/bus rtl/upu_top.sv

lint_core:
	$(VERILATOR) --lint-only -Wall --timing -y rtl/cores -y rtl/bus rtl/cores/rv64_top.sv

lint: lint_core

# -------------------------------------------------------------------------
# Firmware Build
# -------------------------------------------------------------------------
firmware:
	mkdir -p $(OUTPUT_DIR)
	$(CC) $(CFLAGS) $(FW_ASM) $(FW_SOURCES) $(LDFLAGS) -o $(OUTPUT_DIR)/firmware.elf
	$(OBJCOPY) -O binary $(OUTPUT_DIR)/firmware.elf $(OUTPUT_DIR)/bootloader.bin
	$(OBJCOPY) -O ihex $(OUTPUT_DIR)/firmware.elf $(OUTPUT_DIR)/bootloader.hex

# -------------------------------------------------------------------------
# Simulation
# -------------------------------------------------------------------------
sim_top:
	mkdir -p $(OUTPUT_DIR)
	$(IVERILOG) -g2012 -o $(OUTPUT_DIR)/top_sim $(TB_DIR)/upu_top_tb.sv $(SOURCES)
	$(VVP) $(OUTPUT_DIR)/top_sim

sim_cpu:
	mkdir -p $(OUTPUT_DIR)
	$(IVERILOG) -g2012 -o $(OUTPUT_DIR)/cpu_sim $(TB_DIR)/rv64_top_tb.sv $(RTL_DIR)/cores/rv64_top.sv $(RTL_DIR)/cores/rv64_core.sv
	$(VVP) $(OUTPUT_DIR)/cpu_sim

sim_tpu:
	mkdir -p $(OUTPUT_DIR)
	$(IVERILOG) -g2012 -o $(OUTPUT_DIR)/tpu_sim $(TB_DIR)/tpu_core_tb.sv $(RTL_DIR)/cores/tpu_core.sv $(RTL_DIR)/cores/tpu_pe.sv
	$(VVP) $(OUTPUT_DIR)/tpu_sim

sim_npu:
	mkdir -p $(OUTPUT_DIR)
	$(IVERILOG) -g2012 -o $(OUTPUT_DIR)/npu_sim $(TB_DIR)/npu_core_tb.sv $(RTL_DIR)/cores/npu_core.sv $(RTL_DIR)/cores/npu_pe.sv
	$(VVP) $(OUTPUT_DIR)/npu_sim

sim_gpu:
	mkdir -p $(OUTPUT_DIR)
	$(IVERILOG) -g2012 -o $(OUTPUT_DIR)/gpu_sim $(TB_DIR)/gpu_core_tb.sv $(RTL_DIR)/cores/gpu_core.sv
	$(VVP) $(OUTPUT_DIR)/gpu_sim

# -------------------------------------------------------------------------
# UPU v3 "Hyperion" (2nm / 3D-IC) Targets
# -------------------------------------------------------------------------

V3_RTL = $(RTL_DIR)/v3_hyperion/hyperion_compute_chiplet.sv \
         $(RTL_DIR)/v3_hyperion/hyperion_base_hub.sv \
         $(RTL_DIR)/bus/ucie_d2d_bridge.sv \
         $(RTL_DIR)/upu_v3_hyperion_top.sv

sim_v3_ucie:
	$(IVERILOG) -g2012 -o $(OUTPUT_DIR)/v3_ucie_sim $(TB_DIR)/ucie_d2d_tb.sv $(V3_RTL)
	$(VVP) $(OUTPUT_DIR)/v3_ucie_sim

thermal_v3:
	python3 ./scripts/hyperion_thermal_model.py

# -------------------------------------------------------------------------
# Synthesis & Physical Design (Requires EDA Tools installed)
# -------------------------------------------------------------------------
synth:
	$(YOSYS) -p "read_verilog -sv $(SOURCES); synth_sky130 -top upu_top"

physical:
	tclsh ./scripts/librelane_config.tcl
	$(OPENLANE) --design upu_top --config scripts/librelane_config.tcl

physical_v3:
	$(OPENLANE) --design upu_v3_hyperion_top --config scripts/hyperion_v3_config.tcl
