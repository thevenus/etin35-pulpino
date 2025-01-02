# ETIN35 Project based on the PULPino platform

This project was aimed at enhancing the PULPino platform for Low-Power Edge ML Inference. We modified the original PULPino project as follows:
1.  Swapped the behavioral RTL RAM modules with an actual RAM IP provided by Lund University. Since the RAM IP was only 2048x8 bits and the RAM blocks in the PULPino were 8192x32 bits each (separate for Instruction and Data), we had to multiplex 16 RAM IPs to act as a single, coherent RAM module using a wrapper RTL code.
2. Swapped the Timer peripheral with the Matrix Multiplication Unit designed in a [previous project](https://github.com/thevenus/jollof_mmu). An APB bus wrapper was implemented in SystemVerilog with the corresponding register map, which enabled the module to be connected to the MCU. A C driver was written to access and set up the peripheral, ensuring correct operation.
3. Designed a new Convolution peripheral in VHDL to convolve 28x28x3 images with 5x5x3 kernels. The peripheral utilized only 5 multipliers and was fitted into the Timer register map. We also wrote a supplementary C driver to connect to set up and use the peripheral.
4. Synthesis and PnR in Cadence suit, resulting in the final chip layout.

## Project Structure
1. **master branch**: Original PULPino MCU physical chip layout using STM 65nm LPLVT process
    1. RAM IP Wrapper: [/pulpino/rtl/components/sp_ram.sv](https://github.com/thevenus/etin35-pulpino/blob/master/pulpino/rtl/components/sp_ram.sv).
    2. Matrix Multiplication C code: [/pulpino/sw/app/riscv_mmu/](https://github.com/thevenus/etin35-pulpino/tree/master/pulpino/sw/apps/riscv_mmu).
    3. Synthesis Scripts: [/synthesis/scripts/](https://github.com/thevenus/etin35-pulpino/tree/master/synthesis/scripts).
    4. PnR Files, Final Layout: [/pnr/](https://github.com/thevenus/etin35-pulpino/tree/master/pnr).
2. **apb_mmu branch**: PULPino MCU with Matrix Multiplication Peripheral
    1. MMU design and APB wrapper RTL: [/pulpino/ips/apb/apb_mmu/](https://github.com/thevenus/etin35-pulpino/tree/apb_mmu/pulpino/ips/apb/apb_mmu).
    2. MMU peripheral C driver: [/pulpino/sw/libs/sys_lib/inc/mmu.h](https://github.com/thevenus/etin35-pulpino/blob/apb_mmu/pulpino/sw/libs/sys_lib/inc/mmu.h) and [/pulpino/sw/libs/sys_lib/src/mmu.c](https://github.com/thevenus/etin35-pulpino/blob/apb_mmu/pulpino/sw/libs/sys_lib/src/mmu.c).
    3. MMU peripheral test C code: [/pulpino/sw/apps/mmutest/](https://github.com/thevenus/etin35-pulpino/blob/apb_mmu/pulpino/sw/apps/mmutest/).
    4. Synthesis and PnR folders similar to the master branch.
3. **apb_conv branch**: PULPino MCU with Convolution Peripheral:
    1. Convolution Design and APB RTL: [/pulpino/ips/apb/apb_conv/](https://github.com/thevenus/etin35-pulpino/tree/apb_conv/pulpino/ips/apb/apb_conv).
    2. CONV Peripheral C driver: [/pulpino/sw/libs/sys_lib/inc/pconv.h](https://github.com/thevenus/etin35-pulpino/blob/apb_conv/pulpino/sw/libs/sys_lib/inc/pconv.h) and [/pulpino/sw/libs/sys_lib/src/pconv.c](https://github.com/thevenus/etin35-pulpino/blob/apb_conv/pulpino/sw/libs/sys_lib/src/pconv.c).
    3. CONV Peripheral test C code: [/pulpino/sw/apps/pconv_demo](https://github.com/thevenus/etin35-pulpino/tree/apb_conv/pulpino/sw/apps/pconv_demo).
    4. Synthesis and PnR folders similar to the master branch.

4. **Diagrams.pdf**: All related block diagrams and ASMDs explaining the architecture and logic: [/Diagrams.pdf](https://github.com/thevenus/etin35-pulpino/blob/master/Diagrams.pdf). Diagrams for the Jollof MMU architecture can be found [here](https://github.com/thevenus/jollof_mmu/blob/master/diagrams/Diagrams.pdf).
