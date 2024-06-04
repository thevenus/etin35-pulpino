set_clock_latency -source -early -max  0.5 [get_clocks {clk_jtag}]
set_clock_latency -source -late -max  0.5 [get_clocks {clk_jtag}]
set_clock_latency -source -early -max  0.5 [get_clocks {clk_spi}]
set_clock_latency -source -late -max  0.5 [get_clocks {clk_spi}]
set_clock_latency -source -early -max -rise  0.280582 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -early -max -fall  0.268367 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -late -max -rise  0.280582 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -late -max -fall  0.268367 [get_ports {spi_clk}] -clock clk_spi 
set_clock_latency -source -early -max -rise  0.390512 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -early -max -fall  0.376957 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -late -max -rise  0.390512 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -late -max -fall  0.376957 [get_ports {jtag_clk}] -clock clk_jtag 
set_clock_latency -source -early -max   0.5 [get_ports {clk}]
set_clock_latency -source -late -max   0.5 [get_ports {clk}]
set_clock_latency -source -early -max -rise  -0.292685 [get_ports {clk}] -clock clk 
set_clock_latency -source -early -max -fall  -0.263504 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -max -rise  -0.292685 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -max -fall  -0.263504 [get_ports {clk}] -clock clk 
