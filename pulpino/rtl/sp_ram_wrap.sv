// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "config.sv"

module sp_ram_wrap
  #(
    parameter RAM_SIZE   = 32768,              // in bytes
    parameter ADDR_WIDTH = $clog2(RAM_SIZE),
    parameter DATA_WIDTH = 32
  )(
    // Clock and Reset
    input  logic                    clk,
    input  logic                    rstn_i,
    input  logic                    en_i,
    input  logic [ADDR_WIDTH-1:0]   addr_i,
    input  logic [DATA_WIDTH-1:0]   wdata_i,
    output logic [DATA_WIDTH-1:0]   rdata_o,
    input  logic                    we_i,
    input  logic [DATA_WIDTH/8-1:0] be_i,
    input  logic                    bypass_en_i
  );

  `ifdef PULP_FPGA_EMUL
    xilinx_mem_8192x32
    sp_ram_i
    (
      .clka   ( clk                    ),
      .rsta   ( 1'b0                   ), // reset is active high

      .ena    ( en_i                   ),
      .addra  ( addr_i[ADDR_WIDTH-1:2] ),
      .dina   ( wdata_i                ),
      .douta  ( rdata_o                ),
      .wea    ( be_i & {4{we_i}}       )
    );

    // TODO: we should kill synthesis when the ram size is larger than what we
    // have here

  `elsif ASIC
    // RAM bypass logic
    logic [31:0] ram_out_int;
    // assign rdata_o = (bypass_en_i) ? wdata_i : ram_out_int;
    assign rdata_o = ram_out_int;

    sp_ram_bank
    #(
      .NUM_BANKS  ( RAM_SIZE/4096 ),
      .BANK_SIZE  ( 1024          )
    )
    sp_ram_bank_i
    (
      .clk_i   ( clk                     ),
      .rstn_i  ( rstn_i                  ),
      .en_i    ( en_i                    ),
      .addr_i  ( addr_i                  ),
      .wdata_i ( wdata_i                 ),
      .rdata_o ( ram_out_int             ),
      .we_i    ( (we_i & ~bypass_en_i)   ),
      .be_i    ( be_i                    )
    );

  `else
    // new SRAM consists of 4 banks, 2048x32 each
    logic [3:0][7:0] st_ram_rdata_o[4];
    logic [7:0] st_ram_wdata_i[16];
    logic [14:0] st_ram_addr_i;
    logic [3:0] st_ram_row_en;
    
    // choosing SRAM banks based on the given address
    always @(*) begin
      if (en_i) begin
        case (st_ram_addr_i[14:13]) begin
          2'b00   :   st_ram_en = 4'b1110;
          2'b01   :   st_ram_en = 4'b1101;
          2'b10   :   st_ram_en = 4'b1011;
          2'b11   :   st_ram_en = 4'b0111; 
        endcase
      end else begin
        st_ram_en = 4'b0000;
      end
    end
    // TODO: Implement write data signal selection

    // generate 16 RAM cells
    genvar i,j;
    generate
      for (i=1; i<=4; i++) begin: gen_ram_rows
        for (j=1; j<=4; j++) begin: gen_ram_cells
          ST_SPHDL_2048x8m8_L
          sram_2048_8_i
          (
            .Q        ( st_ram_rdata_o[i][j]  ),
            .RY       (                       ),
            .CK       ( clk                   ),
            .CSN      ( st_ram_en[i]          ),
            .TBYPASS  (                       ),
            .WEN      ( ~(we_i & be_i[j])     ),
            .A        ( st_ram_addr_i[12:2]   ),
            .D        ( wdata_i               )
          );
        end
      end
    endgenerate

    sp_ram
    #(
      .ADDR_WIDTH ( ADDR_WIDTH ),
      .DATA_WIDTH ( DATA_WIDTH ),
      .NUM_WORDS  ( RAM_SIZE   )
    )
    sp_ram_i
    (
      .clk     ( clk       ),

      .en_i    ( en_i      ),
      .addr_i  ( addr_i    ),
      .wdata_i ( wdata_i   ),
      .rdata_o ( rdata_o   ),
      .we_i    ( we_i      ),
      .be_i    ( be_i      )
    );
  `endif

endmodule
