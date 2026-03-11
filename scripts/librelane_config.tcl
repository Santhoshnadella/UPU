# LibreLane Configuration for UPU v1
# Pre-validated parameters as per upu_contract.yaml

# ─────────────────────────────────────────────────────────────────────────────
# 1. CORE CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
set ::env(DESIGN_NAME) "upu_top"
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/rtl/*.sv $::env(DESIGN_DIR)/rtl/**/*.sv]
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "20.0" ;# 50MHz

# ─────────────────────────────────────────────────────────────────────────────
# 2. SYNTHESIS & TIMING
# ─────────────────────────────────────────────────────────────────────────────
set ::env(SYNTH_STRATEGY) "DELAY 2"
set ::env(SYNTH_MAX_FANOUT) 8
set ::env(SYNTH_BUFFER_LIST) {sky130_fd_sc_hd__buf_1 sky130_fd_sc_hd__buf_2}
set ::env(CTS_TARGET_SKEW) 200
set ::env(CTS_CLK_BUFFER_LIST) {sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8 sky130_fd_sc_hd__clkbuf_16}

# ─────────────────────────────────────────────────────────────────────────────
# 3. FLOORPLAN & PDN
# ─────────────────────────────────────────────────────────────────────────────
set ::env(FP_CORE_UTIL) 45
set ::env(FP_ASPECT_RATIO) 1
set ::env(PL_TARGET_DENSITY) 0.45
set ::env(GLB_RT_ADJUSTMENT) 0.15

# PDN parameters
set ::env(FP_PDN_VPITCH) 100
set ::env(FP_PDN_HPITCH) 100
set ::env(FP_PDN_VWIDTH) 1.6
set ::env(FP_PDN_HWIDTH) 1.6

# ─────────────────────────────────────────────────────────────────────────────
# 4. UNIT PLACEMENT (FLOORPLAN HINTS)
# ─────────────────────────────────────────────────────────────────────────────
# Note: These values from contract (die is 2000x2000um)
# l2_sram:  900, 900
# cpu:      400, 900
# tpu:      900, 400
# npu:      1400, 900
# gpu:      900, 1400

# OpenLane placement macro (Simplified example)
# set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/scripts/macro_placement.cfg
