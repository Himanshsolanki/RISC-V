create_clock -name core_clk -period 20.000 [get_ports clk]
set_input_delay 2.0 -clock core_clk [get_ports reset]
set_output_delay 2.0 -clock core_clk [get_ports halted]
set_load 0.05 [get_ports halted]
