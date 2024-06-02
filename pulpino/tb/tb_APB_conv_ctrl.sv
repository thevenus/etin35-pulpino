module tb_APB_conv_ctrl;
    parameter s_IDLE = 2'b00, s_SETUP = 2'b01, s_ACCESS = 2'b10;

    logic           Hclk = 1'b0;
    logic           Hresetn = 1'b0
    logic [31:0]    Paddr = '{default:'0};
    logic [31:0]    Pwdata = '{default:'0};
    logic	    Pwrite = 1'b0;
    logic 	    Psel = 1'b0;
    logic 	    Penable = 1'b0;
    logic [31:0]    Prdata = '{default:'0};
    logic	    Pready = 1'b0;
    logic 	    Pslverr = 1'b0;

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

    integer fd, i;

    initial begin
        
