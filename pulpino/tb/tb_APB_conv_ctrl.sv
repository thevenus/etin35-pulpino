module tb_APB_conv_ctrl;
  parameter s_IDLE = 3'b000, s_INPUT_M_5R = 3'b001, s_INPUT_F = 3'b010, s_ROW_UPD = 3'b011, s_MATRIX_FINISHED = 3'b100, s_CONV_RES = 3'b101;

  logic           Hclk = 1'b0;
  logic           Hresetn = 1'b1;
  logic [31:0]    Paddr = '{default:'0};
  logic [31:0]    Pwdata = '{default:'0};
  logic	          Pwrite = 1'b0;
  logic 	        Psel;
  logic 	        Penable;
  logic [31:0]    Prdata;
  logic	          Pready;
  logic 	        Pslverr;
  logic	          start_transfer = 1'b0;

  logic [1:0]	    state_reg, state_next;

  apb_conv
  apb_conv_inst
  (
    .HCLK        (Hclk),
    .HRESETn     (Hresetn),
    .PADDR       (Paddr),
    .PWDATA      (Pwdata),
    .PWRITE      (Pwrite),
    .PSEL        (Psel),
    .PENABLE     (Penable),
    .PRDATA      (Prdata),
    .PREADY      (Pready),
    .PSLVERR     (Pslverr)
  );

  always #10ns Hclk = ~Hclk;

  logic [2:0] input_matrix [3][28][28];
  logic [2:0] filter_matrix [3][5][5];
  logic [7:0] result_matrix [28][28];
  integer inp_m, filt_m, res_m, i;

  logic [1:0]  tmp_reg;
  int wd_cnt;
  
  initial begin
    start_transfer = 1'b0;
    Hresetn = 1'b0;
    Paddr = 0;
    Pwrite = 1'b1;

    #200ns;
    Hresetn = 1'b1;    

    #20000ns;
    inp_m = $fopen("/h/d7/z/vi0873st-s/Downloads/ifm.txt", "r");
    //inp_m = $fopen("/h/d9/n/fu6315ma-s/Downloads/ifm.txt", "r");
    for (int channel = 0; channel < 3; channel++) begin
      for (int row = 0; row < 28; row++) begin
        for (int col = 0; col < 28; col++) begin
          $fscanf(inp_m, "%d", input_matrix[channel][row][col]);
        end
      end
    end

    #20ns;
    $fclose(inp_m);

    #20ns;
    filt_m = $fopen("/h/d7/z/vi0873st-s/Downloads/w.txt", "r");
    //filt_m = $fopen("/h/d9/n/fu6315ma-s/Downloads/w.txt", "r");
    for (int channel = 0; channel < 3; channel++) begin
      for (int row = 0; row < 5; row++) begin
        for (int col = 0; col < 5; col++) begin
          $fscanf(filt_m, "%d", filter_matrix[channel][row][col]);
        end
      end
    end

    #20ns;
    $fclose(filt_m);

    #20ns;
    res_m = $fopen("/h/d7/z/vi0873st-s/Downloads/ofm.txt", "r");
    //res_m = $fopen("/h/d9/n/fu6315ma-s/Downloads/ofm.txt", "r");
    for (int channel = 0; channel < 3; channel++) begin
      for (int row = 0; row < 28; row++) begin
        for (int col = 0; col < 28; col++) begin
          $fscanf(res_m, "%d", result_matrix[channel][row][col]);
        end
      end
    end

    #20ns;
    $fclose(res_m);

    #20ns;

    start_transfer = 1'b0;
    for (int channel = 0; channel < 3; channel++) begin
      // Load filter
      for (int k = 0; k < 3; k++) begin
        Pwrite = 1'b1;
        if (k == 0) begin
          Paddr = 32'h1A10_3900;
          Pwdata[31:30] = 2'b0;
          wd_cnt = 29;
          for (int i = 0; i < 5; i++) begin
            Pwdata[wd_cnt -: 3] = filter_matrix[channel][0][i];
            wd_cnt -= 3;
          end
          for (int i = 0; i < 5; i++) begin
            Pwdata[wd_cnt -: 3] = filter_matrix[channel][1][i];
            wd_cnt -= 3;
          end
        end

        else if (k == 1) begin
          Paddr = 32'h1A10_3904;
          Pwdata[31:30] = 2'b0;
          wd_cnt = 29;
          for (int i = 0; i < 5; i++) begin
            Pwdata[wd_cnt -: 3] = filter_matrix[channel][2][i];
            wd_cnt -= 3;
          end
          for (int i = 0; i < 5; i++) begin
            Pwdata[wd_cnt -: 3] = filter_matrix[channel][3][i];
            wd_cnt -= 3;
          end
        end

        else begin
          Paddr = 32'h1A10_3908;
          Pwdata[31:15] = 17'b0;
          wd_cnt = 14;
          for (int i = 0; i < 5; i++) begin
            Pwdata[wd_cnt -: 3] = filter_matrix[channel][4][i];
            wd_cnt -= 3;
          end
        end
        
        start_transfer = 1'b1;
        wait(Penable);
        start_transfer = 1'b0;
        wait(Penable == 1'b0);

        // #10ns;
      end

      // Load input rows sequentially
      for (int row = 0; row < 28; row++) begin
        for (int loc = 0; loc < 3; loc++) begin
          Paddr = 'h1A10_3508;
          Pwrite = 1'b1;
          if (loc == 0 || loc == 1) begin
            Pwdata[31:30] = 2'b0;
            wd_cnt = 29;
            for (int inpos = loc*10; inpos < loc*10+10; inpos++) begin 
              Pwdata[wd_cnt -: 3] = input_matrix[channel][row][inpos];
              wd_cnt -= 3;
            end
            start_transfer = 1'b1;
            wait(Penable);
            start_transfer = 1'b0;
            wait(Penable == 1'b0);
            // Pwdata = {2'b0, input_matrix[channel][row][27-loc*10 -:9]};
          end
          else begin
            Pwdata[31:24] = 8'b0;
            wd_cnt = 23;
            for (int inpos = loc*10; inpos < loc*10+8; inpos++) begin 
              Pwdata[wd_cnt -: 3] = input_matrix[channel][row][inpos];
              wd_cnt -= 3;
            end
            start_transfer = 1'b1;
            wait(Penable);
            start_transfer = 1'b0;
            wait(Penable == 1'b0);
          end
        end

          // don't set the start bit until the first 3 rows have been loaded
          // if the row number is 2 it means we have loaded 3 rows already
        if (row >= 2) begin
          // set the start bit as 1
          Paddr = 'h1A10_3500;
          Pwrite = 1'b1;
          Pwdata = {31'b0, 1'b1};

          start_transfer = 1'b1;
          wait(Penable);
          start_transfer = 1'b0;
          wait(Penable == 1'b0);

          // wait for the row done bit to get set
          Paddr = 'h1A10_3504;
          Pwrite = 1'b0;
          start_transfer = 1'b1;
          wait(Prdata[1] == 1'b1);
          start_transfer = 1'b0;
          wait(Penable == 1'b0);
        end

          // #10ns;
      end

      // wait for the channel done bit
      Paddr = 'h1A10_3504;
      Pwrite = 1'b0;
      start_transfer = 1'b1;
      wait(Prdata[2] == 1'b1);
      start_transfer = 1'b0;
      wait(Penable == 1'b0);

      // while (1) begin
      //   Paddr = 'h1A10_3504;
      //   Pwrite = 1'b0;

      //   start_transfer = 1'b1;
      //   wait(Penable);

      //   if (Prdata[2] == 1'b1) begin
      //     start_transfer = 1'b0;
      //     wait(Penable == 1'b0);
      //     break;
      //   end

      //   start_transfer = 1'b0;
      //   wait(Penable == 1'b0);

      // end
    end

    $stop();        

  end

  always @(posedge Hclk) begin
    if (Hresetn == 1'b0) begin
      tmp_reg <= 2'b00;
    end else begin
      case (tmp_reg)
      2'b00: begin 
        if (start_transfer)
          tmp_reg <= 2'b01;
      end
      2'b01: tmp_reg <= 2'b11;
      2'b11: tmp_reg <= 2'b00;		 
      endcase;
    end
  end

  assign Psel = tmp_reg[0];
  assign Penable = tmp_reg[1];

      // always @(*) begin
      //   //        state_next <= state_reg;
      //   Psel = 1'b0;
      //   Penable = 1'b0;
      //   //
      //   //	case (state_reg)
      //   //	    s_IDLE : begin
      //   //		Psel = 1'b0;
      //   //		Penable = 1'b0;
      //   //	        if (start_transfer)
      //   //		    state_next = s_INPUT_M_5R;
      //   //	    end
      //   //
      //   //	    s_INPUT_M_5R : begin
      //   //	        Psel = 1'b1;
      //   //		Penable = 1'b1;
      //   //		state_next = s_INPUT_F;
      //   //	    end
      //   //
      //   //	    s_INPUT_F : begin
      //   //	        Psel = 1'b1;
      //   //		Penable = 1'b1;
      //   //		state_next = s_ROW_UPD;
      //   //	    end
      //   //		
      //   //	    s_ROW_UPD : begin
      //   //	        Psel = 1'b1;
      //   //		Penable = 1'b1;
      //   //	    end
      //   //
      //   //	    s_MATRIX_FINISHED : begin
      //   //	    end
      //   //
      //   //	    s_CONV_RES : begin
      //   //	        Psel = 1'b1;
      //   //		Penable = 1'b1;
      //   //	    end
      //   //        endcase
      // end

endmodule