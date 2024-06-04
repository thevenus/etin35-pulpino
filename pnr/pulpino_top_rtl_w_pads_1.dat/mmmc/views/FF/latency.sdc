set_clock_latency -source -early -max  0.5 [get_clocks {clk_jtag}]
set_clock_latency -source -late -max  0.5 [get_clocks {clk_jtag}]
set_clock_latency -source -early -max  0.5 [get_clocks {clk_spi}]
set_clock_latency -source -late -max  0.5 [get_clocks {clk_spi}]
set_clock_latency -source -early -min -rise  0.299106 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -early -min -fall  0.2919 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -late -min -rise  0.299106 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -late -min -fall  0.2919 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -early -min -rise  0.331317 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -early -min -fall  0.322703 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -late -min -rise  0.331317 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -late -min -fall  0.322703 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -early -max   0.5 [get_ports {clk}]
set_clock_latency -source -late -max   0.5 [get_ports {clk}]
set_clock_latency -source -early -min -rise  0.196558 [get_ports {clk}] -clock clk 
set_clock_latency -source -early -min -fall  0.186007 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -min -rise  0.196558 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -min -fall  0.186007 [get_ports {clk}] -clock clk 
