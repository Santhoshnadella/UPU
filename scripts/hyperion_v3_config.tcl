# UPU v3 "Hyperion" Disaggregated Synthesis Configuration (2nm GAA / Chiplet)
# Target Clock: 3.5 GHz (285ps) - Push node limits

# ─────────────────────────────────────────────────────────────────────────────
# 1. 3D-IC HIERARCHY
# ─────────────────────────────────────────────────────────────────────────────
set ::env(DESIGN_NAME) "upu_v3_hyperion_top"
set ::env(TECHNOLOGY_NODE) "2nm_GAA"
set ::env(BACKSIDE_POWER) 1        ;# Enable BSPD Nano-TSV routing
set ::env(CHIPLET_SUPPORT) 1       ;# Enable UCIe D2D Interconnects

# ─────────────────────────────────────────────────────────────────────────────
# 2. FREQUENCY & TIMING
# ─────────────────────────────────────────────────────────────────────────────
set ::env(CLOCK_PORT) "clk_3_5ghz"
set ::env(CLOCK_PERIOD) "0.285"    ;# Target 3.5GHz
set ::env(SYNTH_MAX_FANOUT) 2      ;# Extremely aggressive for 2nm high-speed paths

# ─────────────────────────────────────────────────────────────────────────────
# 3. 3D-STACK CONFIG (SoIC)
# ─────────────────────────────────────────────────────────────────────────────
# Tile 0: Compute Die (Top)
set ::env(COMPUTE_DIE_AREA) "0 0 8000 8000" ;# Dense 8x8mm Compute Tile
set ::env(COMPUTE_VOLTAGE) 0.70

# Tile 1: Cache & Memory Die (Base) 
set ::env(BASE_DIE_AREA) "0 0 10000 10000"  ;# 10x10mm Base Tile for SRAM/IO
set ::env(SRAM_L3_SIZE) "128MB"

# ─────────────────────────────────────────────────────────────────────────────
# 4. POWER & THERMAL (2nm BSPD)
# ─────────────────────────────────────────────────────────────────────────────
set ::env(VDD_VALUE) 0.70
set ::env(TP_POWER_BUDGET) 180     ;# Increased power budget for 3D stack cooling
set ::env(BSPD_MESH_DENSITY) 0.25  ;# Backside grid density for VDD/VSS Nano-TSVs

# ─────────────────────────────────────────────────────────────────────────────
# 5. DIE-TO-DIE (D2D) PHY
# ─────────────────────────────────────────────────────────────────────────────
# Integrated UCIe PHY Coords
# ucie_phy_north: 4000, 7800
# ucie_phy_south: 4000, 200
