// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module sp_ram
  #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter NUM_WORDS  = 256
  )(
    // Clock and Reset
    input  logic                    clk,

    input  logic                    en_i,
    input  logic [ADDR_WIDTH-1:0]   addr_i,
    input  logic [DATA_WIDTH-1:0]   wdata_i,
    output logic [DATA_WIDTH-1:0]   rdata_o,
    input  logic                    we_i,
    input  logic [DATA_WIDTH/8-1:0] be_i
  );

  logic [3:0][7:0]    st_ram_rrowd_o[4];
  logic [3:0]         st_ram_row_en;
  logic [3:0][3:0]    st_ram_ready; 
  logic               st_ram_tbypass;
  logic [1:0]         addr_rowsel_reg;

  assign st_ram_tbypass = 1'b0;

  // Register for address row selection bits(14:13)
  // to delay it one cc
  always @(posedge clk) begin
    addr_rowsel_reg <= addr_i[14:13];
  end

  // choosing SRAM banks based on the given address
  always @(*) begin
    if (en_i) begin
      case (addr_i[14:13]) 
        2'b00   :   st_ram_row_en = 4'b1110;
        2'b01   :   st_ram_row_en = 4'b1101;
        2'b10   :   st_ram_row_en = 4'b1011;
        2'b11   :   st_ram_row_en = 4'b0111; 
      endcase
    end else begin
      st_ram_row_en = 4'b1111;
    end
  end

  // generate 16 RAM cells
  genvar i,j;
  generate
    for (i=0; i<4; i++) begin: ram_row
      for (j=0; j<4; j++) begin: ram_byte
        ST_SPHDL_2048x8m8_L
        sram_2k1
        (
          .Q        ( st_ram_rrowd_o[i][j]      ),
          .RY       ( st_ram_ready[i][j]        ),
          .CK       ( clk                       ),
          .CSN      ( st_ram_row_en[i]          ),
          .TBYPASS  ( st_ram_tbypass            ),
          .WEN      ( ~(we_i & be_i[j])         ),
          .A        ( addr_i[12:2]              ),
          .D        ( wdata_i[(j+1)*8-1:j*8]    )
        );
      end
    end
  endgenerate

  // Multiplex output from all rows into one
  always @(*) begin
    case (addr_rowsel_reg) 
      2'b00   :   rdata_o = st_ram_rrowd_o[0];
      2'b01   :   rdata_o = st_ram_rrowd_o[1];
      2'b10   :   rdata_o = st_ram_rrowd_o[2];
      2'b11   :   rdata_o = st_ram_rrowd_o[3]; 
    endcase
  end
endmodule
