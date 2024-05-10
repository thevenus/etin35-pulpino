// APB Wrapper for our Jollof MMU module

module apb_mmu 
(
    input  logic                      HCLK,
    input  logic                      HRESETn,
    input  logic               [31:0] PADDR,
    input  logic               [31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic               [31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR
);

    //  █████  ██████  ██████  
    // ██   ██ ██   ██ ██   ██ 
    // ███████ ██████  ██████  
    // ██   ██ ██      ██   ██ 
    // ██   ██ ██      ██████  
                      
                        
    logic [31:0]    indata_reg [64], indata_next [64];
    logic [31:0]    outdata_reg [160], outdata_next [160];
    logic [3:0]     ctrl_reg, ctrl_next;
    logic           status_reg, status_next;

    // sequential part
    always_ff @(posedge HCLK, negedge HRESETn) 
    begin
        if (~HRESETn) begin
            for (int i = 0; i<64; i++) begin
                indata_reg[i] <= 32'b0;
            end

            for (int i = 0; i<160; i++) begin
                outdata_reg[i] <= 32'b0;
            end

            ctrl_reg <= 4'b0;
            status_reg <= 1'b0;
        end else begin
            for (int i = 0; i<64; i++) begin
                indata_reg[i] <= indata_next[i];
            end

            for (int i = 0; i<160; i++) begin
                outdata_reg[i] <= outdata_next[i];
            end

            ctrl_reg <= ctrl_next;
            status_reg <= status_next;
        end    
    end
 
    // write register logic
    always_comb
    begin
        indata_next = indata_reg;
        ctrl_next = ctrl_reg;

        if (PSEL && PENABLE && PWRITE) begin
            if (PADDR >= 32'h1A10_3100 && PADDR <= 32'h1A10_31FF) begin
                indata_next[PADDR[7:2]] = PWDATA;
            end else if (PADDR == 32'h1A10_3000) begin
                ctrl_next = PWDATA;
            end
        end
    end

    // read register logic
    always_comb
    begin
        PRDATA = 32'b0;

        if (PSEL && PENABLE && !PWRITE) begin
            if (PADDR >= 32'h1A10_3200 && PADDR <= 32'h1A10_3480) begin
                PRDATA = outdata_reg[PADDR[7:2]];
            end else if (PADDR >= 32'h1A10_3100 && PADDR <= 32'h1A10_31FF) begin
                PRDATA = indata_reg[PADDR[7:2]];
            end else if (PADDR == 32'h1A10_3000) begin 
                PRDATA = ctrl_reg;
            end else if (PADDR == 32'h1A10_3480) begin
                PRDATA = status_reg;
            end
        end
    end

    always_comb
    begin
        status_next = status_reg;
        outdata_next = outdata_reg;    
    end

    assign PREADY = 1'b1;
    assign PSLVERR = 1'b0; 


    // ███    ███ ███    ███ ██    ██ 
    // ████  ████ ████  ████ ██    ██ 
    // ██ ████ ██ ██ ████ ██ ██    ██ 
    // ██  ██  ██ ██  ██  ██ ██    ██ 
    // ██      ██ ██      ██  ██████                        

    logic       [7:0]   mmu_input_data_i;
    logic       [17:0]  mmu_read_data_out_o;
    logic               mmu_valid_input_i;
    logic               mmu_read_ram_i;
    logic               mmu_finish_o;

    jollof_top
    jollof_top_inst
    (
        .clk                (HCLK),
        .rst                (~HRESETn),
        .input_data         (mmu_input_data_i),
        .valid_input        (mmu_valid_input_i),
        .read_ram           (mmu_read_ram_i),
        .read_data_out      (mmu_read_data_out_o),
        .finish             (mmu_finish_o)
    );

    always_comb 
    begin
        if (ctrl_reg[0])
        
    end

    
endmodule