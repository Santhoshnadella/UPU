create_clock [get_ports clk]  -name clk  -period 10.0000
set_input_delay  0.1 -clock clk [all_inputs]
set_output_delay 0.1 -clock clk [all_outputs]
