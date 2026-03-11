# UPU v2 "Ultra" Synthesis Configuration (7nm HPC)
# Target Clock: 2.0 GHz (500ps)

# ─────────────────────────────────────────────────────────────────────────────
# 1. CORE CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
set ::env(DESIGN_NAME) "upu_v2_ultra_top"
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/rtl/*.sv $::env(DESIGN_DIR)/rtl/**/*.sv]
set ::env(CLOCK_PORT) "clk_2ghz"
set ::env(CLOCK_PERIOD) "0.50" ;# 2.0GHz (500ps)

# ─────────────────────────────────────────────────────────────────────────────
# 2. ADVANCED HPC SYNTHESIS
# ─────────────────────────────────────────────────────────────────────────────
set ::env(SYNTH_STRATEGY) "DELAY 1" ;# Maximum timing focus
set ::env(SYNTH_MAX_FANOUT) 4      ;# Aggressive fanout limit for 2GHz
set ::env(SYNTH_TIMING_DERATE) 0.05 ;# 5% Timing margin

# ─────────────────────────────────────────────────────────────────────────────
# 3. FLOORPLAN & DIE (15mm x 15mm)
# ─────────────────────────────────────────────────────────────────────────────
set ::env(DIE_AREA) "0 0 15000 15000"
set ::env(PL_TARGET_DENSITY) 0.65 ;# High-density placement for short wires
set ::env(GLB_RT_ADJUSTMENT) 0.10

# ─────────────────────────────────────────────────────────────────────────────
# 4. VOLTAGE & POWER
# ─────────────────────────────────────────────────────────────────────────────
set ::env(VDD_VALUE) 0.85 ;# 7nm Nominal Voltage
set ::env(VSS_VALUE) 0.00
set ::env(TP_POWER_BUDGET) 125 ;# 125W TDP

# ─────────────────────────────────────────────────────────────────────────────
# 5. HARD-MACRO CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
# Macro placement for HBM3 PHYs and L3 Cache banks
# hbm3_phy_0:  0, 0
# hbm3_phy_1:  0, 7500
# tpu_infinity: 2500, 2500
# gpu_titan:   2500, 7500
# cpu_titan:   7500, 5000
