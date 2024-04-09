// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

  logic [31:0]     data_mem[];  // this variable holds the whole memory content
  logic [31:0]     instr_mem[]; // this variable holds the whole memory content
  event            event_mem_load;

  task mem_preload;
    integer      addr;
    integer      mem_addr;
    integer      row_addr;
    integer      instr_size;
    integer      instr_width;
    integer      data_size;
    integer      data_width;
    logic [31:0] data;
    string       l2_imem_file;
    string       l2_dmem_file;
    begin
      $display("Preloading memory");

      instr_size   = tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.RAM_SIZE;
      instr_width = tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.DATA_WIDTH;

      data_size   = tb.top_i.core_region_i.data_mem.RAM_SIZE;
      data_width = tb.top_i.core_region_i.data_mem.DATA_WIDTH;

      instr_mem = new [instr_size/4];
      data_mem  = new [data_size/4];

      if(!$value$plusargs("l2_imem=%s", l2_imem_file))
         l2_imem_file = "slm_files/l2_stim.slm";

      $display("Preloading instruction memory from %0s", l2_imem_file);
      $readmemh(l2_imem_file, instr_mem);

      if(!$value$plusargs("l2_dmem=%s", l2_dmem_file))
         l2_dmem_file = "slm_files/tcdm_bank0.slm";

      $display("Preloading data memory from %0s", l2_dmem_file);
      $readmemh(l2_dmem_file, data_mem);


      // preload data memory
      for(addr = 0; addr < data_size/4; addr++) begin
        mem_addr = addr % 2048;
        row_addr = addr / 2048;
        data = data_mem[addr];

        if (row_addr == 0) begin
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[0].ram_byte[0].sram_2k1.Mem[mem_addr] = data[ 7: 0];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[0].ram_byte[1].sram_2k1.Mem[mem_addr] = data[15: 8];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[0].ram_byte[2].sram_2k1.Mem[mem_addr] = data[23:16];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[0].ram_byte[3].sram_2k1.Mem[mem_addr] = data[31:24];

        end else if (row_addr == 1) begin
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[1].ram_byte[0].sram_2k1.Mem[mem_addr] = data[ 7: 0];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[1].ram_byte[1].sram_2k1.Mem[mem_addr] = data[15: 8];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[1].ram_byte[2].sram_2k1.Mem[mem_addr] = data[23:16];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[1].ram_byte[3].sram_2k1.Mem[mem_addr] = data[31:24];

        end else if (row_addr == 2) begin
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[2].ram_byte[0].sram_2k1.Mem[mem_addr] = data[ 7: 0];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[2].ram_byte[1].sram_2k1.Mem[mem_addr] = data[15: 8];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[2].ram_byte[2].sram_2k1.Mem[mem_addr] = data[23:16];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[2].ram_byte[3].sram_2k1.Mem[mem_addr] = data[31:24];

        end else if (row_addr == 3) begin
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[3].ram_byte[0].sram_2k1.Mem[mem_addr] = data[ 7: 0];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[3].ram_byte[1].sram_2k1.Mem[mem_addr] = data[15: 8];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[3].ram_byte[2].sram_2k1.Mem[mem_addr] = data[23:16];
          tb.top_i.core_region_i.data_mem.sp_ram_i.ram_row[3].ram_byte[3].sram_2k1.Mem[mem_addr] = data[31:24];
        end
      end

      // preload instruction memory
      for(addr = 0; addr < instr_size/4; addr++) begin
        mem_addr = addr % 2048;
        row_addr = addr / 2048;
        data = instr_mem[addr];

        if (row_addr == 0) begin
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[0].ram_byte[0].sram_2k1.Mem[mem_addr] = data[ 7: 0];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[0].ram_byte[1].sram_2k1.Mem[mem_addr] = data[15: 8];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[0].ram_byte[2].sram_2k1.Mem[mem_addr] = data[23:16];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[0].ram_byte[3].sram_2k1.Mem[mem_addr] = data[31:24];

        end else if (row_addr == 1) begin
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[1].ram_byte[0].sram_2k1.Mem[mem_addr] = data[ 7: 0];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[1].ram_byte[1].sram_2k1.Mem[mem_addr] = data[15: 8];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[1].ram_byte[2].sram_2k1.Mem[mem_addr] = data[23:16];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[1].ram_byte[3].sram_2k1.Mem[mem_addr] = data[31:24];

        end else if (row_addr == 2) begin
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[2].ram_byte[0].sram_2k1.Mem[mem_addr] = data[ 7: 0];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[2].ram_byte[1].sram_2k1.Mem[mem_addr] = data[15: 8];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[2].ram_byte[2].sram_2k1.Mem[mem_addr] = data[23:16];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[2].ram_byte[3].sram_2k1.Mem[mem_addr] = data[31:24];

        end else if (row_addr == 3) begin
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[3].ram_byte[0].sram_2k1.Mem[mem_addr] = data[ 7: 0];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[3].ram_byte[1].sram_2k1.Mem[mem_addr] = data[15: 8];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[3].ram_byte[2].sram_2k1.Mem[mem_addr] = data[23:16];
          tb.top_i.core_region_i.instr_mem.sp_ram_wrap_i.sp_ram_i.ram_row[3].ram_byte[3].sram_2k1.Mem[mem_addr] = data[31:24];
        end
      end
    end
  endtask
