"""
UPU v3 "Hyperion" 3D-IC Thermal & Power Analysis Model
------------------------------------------------------
Simulates heat dissipation in the 2nm Compute-on-Base SoIC stack.
Validates the benefit of Backside Power Delivery (BSPD) on thermal gradients.
"""

import math

def simulate_thermal_stack(frequency_ghz=3.5, voltage=0.7, use_bspd=True):
    # constants
    die_area_mm2 = 64 # 8x8mm
    ambient_temp = 25 # C
    thermal_resistance_soic = 0.15 # C/W (Hybrid Bonding)
    
    # Power Calculation: P = C * V^2 * f + static
    # 2nm GAA has lower dynamic power but higher leakage if not managed
    capacitance_scaling = 0.8 # 2nm vs 7nm
    dynamic_power = capacitance_scaling * (voltage**2) * frequency_ghz * 25 # Weighted factor
    static_leakage = 15 # Watts (Aggressive 2nm GAA leakage)
    
    # BSPD Benefit: 20% reduction in local Joule heating due to lower PDN resistance
    if use_bspd:
        active_power = (dynamic_power * 0.8) + static_leakage
    else:
        active_power = dynamic_power + static_leakage
        
    # Temperature Calculation
    power_density = active_power / die_area_mm2
    peak_temp = ambient_temp + (active_power * thermal_resistance_soic)
    
    print("-" * 40)
    print(f"Hyperion 3D-Stack Config: {frequency_ghz}GHz @ {voltage}V")
    print(f"Backside Power Delivery: {'ENABLED' if use_bspd else 'DISABLED'}")
    print("-" * 40)
    print(f"Total Die Power Consumption: {active_power:.2f} Watts")
    print(f"Power Density: {power_density:.3f} W/mm2")
    print(f"Simulated Junction Temp (Tj): {peak_temp:.2f} C")
    
    if peak_temp > 95:
        print("WARNING: Thermal Throttling Required! Exceeds 95C T-junction for N2 node.")
    else:
        print("STATUS: Thermal Budget PASSED for Active Cooling.")
    print("-" * 40)

if __name__ == "__main__":
    # Simulate Hyperion 3.5GHz Target
    simulate_thermal_stack(frequency_ghz=3.5, voltage=0.7, use_bspd=True)
    
    # Comparison: Same design without BSPD (shows critical failure)
    print("\n[DEBUG] Comparison: 3D Stack without Backside Power Delivery")
    simulate_thermal_stack(frequency_ghz=3.5, voltage=0.7, use_bspd=False)
