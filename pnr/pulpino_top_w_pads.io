
version: 3

Orient: R270
Pad: PcornerLL SW PADSPACE_C_74x74u_CH
Orient: R0x3
Pad: PcornerLR SE PADSPACE_C_74x74u_CH
Orient: R90
Pad: PcornerUR NE PADSPACE_C_74x74u_CH
Orient: R180
Pad: PcornerUL NW PADSPACE_C_74x74u_CH


# # ------------------------------------------------ #
# # NORTH
# # ------------------------------------------------ #

Pad: InPads[0].InPad  N CPAD_S_74x50u_IN
Pad: InPads[1].InPad  N CPAD_S_74x50u_IN
Pad: InPads[2].InPad  N CPAD_S_74x50u_IN
Pad: InPads[3].InPad  N CPAD_S_74x50u_IN
Pad: PVDD1    N CPAD_S_74x50u_VDD
Pad: PVDD2    N CPAD_S_74x50u_VDD
Pad: InPads[4].InPad  N CPAD_S_74x50u_IN
Pad: InPads[5].InPad  N CPAD_S_74x50u_IN

# # ------------------------------------------------ #
# # WEST 
# # ------------------------------------------------ #
Pad: jtag_clk_pad W CPAD_S_74x50u_IN
Pad: InPads[6].InPad  W CPAD_S_74x50u_IN
Pad: InPads[7].InPad  W CPAD_S_74x50u_IN
Pad: InPads[8].InPad  W CPAD_S_74x50u_IN
Pad: InPads[9].InPad  W CPAD_S_74x50u_IN
Pad: InPads[10].InPad W CPAD_S_74x50u_IN
Pad: InPads[11].InPad W CPAD_S_74x50u_IN
Pad: clkpad   W CPAD_S_74x50u_IN
# # ------------------------------------------------ #
# # SOUTH
# # ------------------------------------------------ #

Pad: OutPads[0].OutPad S CPAD_S_74x50u_OUT
Pad: OutPads[1].OutPad S CPAD_S_74x50u_OUT
Pad: OutPads[2].OutPad S CPAD_S_74x50u_OUT
Pad: OutPads[3].OutPad S CPAD_S_74x50u_OUT
Pad: PGND1    S CPAD_S_74x50u_GND
Pad: PGND2    S CPAD_S_74x50u_GND
Pad: OutPads[4].OutPad S CPAD_S_74x50u_OUT
Pad: OutPads[5].OutPad S CPAD_S_74x50u_OUT

# # ------------------------------------------------ #
# # EAST 
# # ------------------------------------------------ #

Pad: spi_clk_pad  E CPAD_S_74x50u_IN
Pad: InPads[12].InPad E CPAD_S_74x50u_IN
Pad: InPads[13].InPad E CPAD_S_74x50u_IN
Pad: OutPads[6].OutPad E CPAD_S_74x50u_OUT
Pad: OutPads[7].OutPad E CPAD_S_74x50u_OUT
Pad: OutPads[8].OutPad E CPAD_S_74x50u_OUT
Pad: OutPads[9].OutPad E CPAD_S_74x50u_OUT
Pad: OutPads[10].OutPad E CPAD_S_74x50u_OUT


