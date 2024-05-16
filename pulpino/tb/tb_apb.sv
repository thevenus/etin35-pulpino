`timescale 1ns/1ps
module tb_apb;
    parameter s_IDLE = 2'b00, s_SETUP = 2'b01, s_ACCESS = 2'b10;

    logic clk = 1'b0;
    logic rst_n = 1'b1;

    logic   [31:0]  paddr = 0;
    logic   [31:0]  pwdata = 0;
    logic           pwrite;
    logic           psel = 0;
    logic           pena = 0;
    logic   [31:0]  prdata;
    logic           pready;
    logic           pslverr;
    logic           start_transfer;

    logic   [1:0]   state_reg, state_next;

    apb_mmu
    apb_mmu_inst
    (
        .HCLK           (clk),
        .HRESETn        (rst_n),  
        .PADDR          (paddr),
        .PWDATA         (pwdata),
        .PWRITE         (pwrite),
        .PSEL           (psel),
        .PENABLE        (pena),  
        .PRDATA         (prdata),
        .PREADY         (pready),
        .PSLVERR        (pslverr)
    );

    always #50ns clk = ~clk;

    logic   [7:0] input_stimuli [256];
    integer fd, i;
    initial begin 
        rst_n = 1'b0; start_transfer = 1'b0;
        paddr = 0;
        pwrite = 1'b1;

        #200ns;
        rst_n = 1'b1;
        
        #20000ns;
        // read input stimuli txt into the array
        fd = $fopen("/h/d9/n/fu6315ma-s/Documents/jollof_mmu/functional_model_stimuli/input_stimuli_wo_0.txt", "r");
        i = 0;
        while (!$feof(fd)) begin
            $fscanf(fd, "%b", input_stimuli[i]);
            i++;
        end

        #1000ns;
        $fclose(fd);

        // give the input to the apb_mmu
        start_transfer = 1'b1;
        for (i = 0; i<160; i=i+4) begin
            wait(state_reg == s_SETUP);
            pwdata  = {input_stimuli[i], input_stimuli[i+1], input_stimuli[i+2], input_stimuli[i+3]};
            paddr   = 'h1A10_3100 + i;
            wait (state_reg == s_ACCESS);
        end
        start_transfer = 1'b0;

        #1000ns

        // set start bit and number of matrices to be multiplied
        start_transfer = 1'b1;
        paddr = 'h1A10_3000;
        pwdata = {28'b0, 3'b101, 1'b1};
        wait(state_reg == s_SETUP);
        start_transfer = 1'b0;
        wait(state_reg == s_IDLE);

        // wait for the done bit
        start_transfer = 1'b1;
        pwrite = 1'b0;
        paddr = 'h1A10_3004;
        wait(prdata[0] == 1'b1);
        start_transfer = 1'b0;
        
        // calculation is done! check the answer!

        $stop();
    end

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            state_reg <= s_IDLE;
        end else begin
            state_reg <= state_next;
        end
    end

    always @(*) begin
        state_next = state_reg;

        psel = 1'b0;
        pena = 1'b0;

        case (state_reg)
            s_IDLE : begin
                // outputs
                psel = 1'b0;
                pena = 1'b0;

                // state transition
                if (start_transfer)
                    state_next = s_SETUP;
            end
            
            s_SETUP : begin
                // outputs
                psel = 1'b1;
                pena = 1'b0;   

                // state transition
                state_next = s_ACCESS;
            end
            
            s_ACCESS : begin
                // outputs
                psel = 1'b1;
                pena = 1'b1;

                // state transition
                if (pready) begin
                    if (start_transfer)
                        state_next = s_SETUP;
                    else
                        state_next = s_IDLE;
                end
            end
        endcase
    end

endmodule