set_clock_latency -source -early -max  0.5 [get_clocks {clk_jtag}]
set_clock_latency -source -late -max  0.5 [get_clocks {clk_jtag}]
set_clock_latency -source -early -max  0.5 [get_clocks {clk_spi}]
set_clock_latency -source -late -max  0.5 [get_clocks {clk_spi}]
set_clock_latency -source -early -min -rise  0.311333 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -early -min -fall  0.303059 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -late -min -rise  0.311333 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -late -min -fall  0.303059 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -early -min -rise  0.377082 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -early -min -fall  0.371656 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -late -min -rise  0.377082 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -late -min -fall  0.371656 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -early -max   0.5 [get_ports {clk}]
set_clock_latency -source -late -max   0.5 [get_ports {clk}]
set_clock_latency -source -early -min -rise  0.213669 [get_ports {clk}] -clock clk 
set_clock_latency -source -early -min -fall  0.204352 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -min -rise  0.213669 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -min -fall  0.204352 [get_ports {clk}] -clock clk 
