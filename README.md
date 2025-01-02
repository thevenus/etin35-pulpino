# ETIN35 Project based on the PULPino platform

This project was aimed at enhancing the PULPino platform for Low-Power Edge ML Inference. We modified the original PULPino project as follows:
1.  Swapped the behavioral RTL RAM modules with an actual RAM IP provided by Lund University. Since the RAM IP was only 2048x8 bits and the RAM blocks in the PULPino were 8192x32 bits each (separate for Instruction and Data), we had to multiplex 16 RAM IPs to act as a single, coherent RAM module using a wrapper RTL code.
2. Swapped the Timer peripheral with the Matrix Multiplication Unit designed in a [previous project](https://github.com/thevenus/jollof_mmu). An APB bus wrapper was implemented in SystemVerilog with the corresponding register map, which enabled the module to be connected to the MCU. A C driver was written to access and set up the peripheral, ensuring correct operation.
3. Designed a new Convolution peripheral in VHDL to convolve 28x28x3 images with 5x5x3 kernels. The peripheral utilized only 5 multipliers and was fitted into the Timer register map. We also wrote a supplementary C driver to connect to set up and use the peripheral.
4. Synthesis and PnR in Cadence suit, resulting in the final chip layout.

## Project Structure
1. **master branch**: RAM IP Wrapper and generated layout of the original MCU: [/pulpino/rtl/components/sp_ram.sv](https://github.com/thevenus/etin35-pulpino/blob/master/pulpino/rtl/components/sp_ram.sv).
2. **apb_mmu branch**: PULPino MCU with Matrix Multiplication Peripheral: [/pulpino/ips/apb/apb_mmu/](https://github.com/thevenus/etin35-pulpino/tree/apb_mmu/pulpino/ips/apb/apb_mmu).
3. **apb_conv branch**: PULPino MCU with Convolution Peripheral: [/pulpino/ips/apb/apb_conv/](https://github.com/thevenus/etin35-pulpino/tree/apb_conv/pulpino/ips/apb/apb_conv).
4. **Diagrams.pdf**: All related block diagrams and ASMDs explaining the architecture and logic: [/Diagrams.pdf](https://github.com/thevenus/etin35-pulpino/blob/master/Diagrams.pdf). Diagrams for the Jollof MMU architecture can be found [here](https://github.com/thevenus/jollof_mmu/blob/master/diagrams/Diagrams.pdf).
