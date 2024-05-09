module tb_apb;
    parameter s_IDLE = 2'b00, s_SETUP = 2'b01, s_ACCESS = 2'b10;

    logic clk = 1'b0;
    logic rst_n = 1'b1;

    logic   [31:0]  paddr = 0;
    logic   [31:0]  pwdata = 0;
    logic           pwrite = 0;
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

    initial begin 
        rst_n = 1'b0; start_transfer = 1'b0;
        paddr = 0;
        pwdata = 0;
        pwrite = 1'b0;

        #200ns;
        rst_n = 1'b1; start_transfer = 1'b1;
        paddr = 32'h1A10_3100; // boot address
        pwdata = 32'hFACE_DEAD; // random data
        pwrite = 1'b1;

        #200ns;
        start_transfer = 1'b0;

        #1000ns;
        start_transfer = 1'b1;
        paddr = 32'h1A10_3100; // boot address
        pwrite = 1'b0;

        #200ns;
        start_transfer = 1'b0;
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
                if (pready)
                    state_next = s_IDLE;
            end
        endcase
    end

endmodule