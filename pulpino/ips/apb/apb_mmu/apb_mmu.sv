// APB Wrapper for our Jollof MMU module
`define REG_MMU_CTRL            10'b0000000000 //size of data ram in multiples of 8 kBye
`define REG_MMU_STATUS          10'b0000000001 //size of data ram in multiples of 8 kBye
`define REG_MMU_INDATA_START    10'b0001000000 //size of data ram in multiples of 8 kBye
`define REG_MMU_INDATA_STOP     10'b0001111111 //size of data ram in multiples of 8 kBye
`define REG_MMU_OUTDATA_START   10'b0010000000 //size of data ram in multiples of 8 kBye
`define REG_MMU_OUTDATA_STOP    10'b0100011111 //size of data ram in multiples of 8 kBye

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
    logic [17:0]    outdata_reg [160], outdata_next [160];
    logic [3:0]     ctrl_reg, ctrl_next;
    logic [1:0]     status_reg, status_next;
    logic           clear_start_bit;
    logic [9:0]     apb_addr_trimmed;

    assign apb_addr_trimmed = PADDR[11:2];

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
            status_reg <= 2'b00;
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
            if (apb_addr_trimmed >= `REG_MMU_INDATA_START && apb_addr_trimmed <= `REG_MMU_INDATA_STOP) begin
                indata_next[apb_addr_trimmed[5:0]] = PWDATA;
            end else if (apb_addr_trimmed == `REG_MMU_CTRL) begin
                ctrl_next = PWDATA[3:0];
            end
        end

        // clearing the start bit
        if (clear_start_bit)
            ctrl_next = {ctrl_reg[3:1], 1'b0};
    end

    // read register logic
    always_comb
    begin
        PRDATA = 32'b0;

        if (PSEL && PENABLE && !PWRITE) begin
            if (apb_addr_trimmed >= `REG_MMU_OUTDATA_START && apb_addr_trimmed <= `REG_MMU_OUTDATA_STOP) begin
                PRDATA = {14'b0, outdata_reg[apb_addr_trimmed[5:0]]};
            end else if (apb_addr_trimmed >= `REG_MMU_INDATA_START && apb_addr_trimmed <= `REG_MMU_INDATA_STOP) begin
                PRDATA = indata_reg[apb_addr_trimmed[5:0]];
            end else if (apb_addr_trimmed == `REG_MMU_CTRL) begin 
                PRDATA = {28'b0, ctrl_reg};
            end else if (apb_addr_trimmed == `REG_MMU_STATUS) begin
                PRDATA = {30'b0, status_reg};
            end
        end
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

    // Wrapper FSM
    parameter s_IDLE        = 3'b000,
              s_GIVE_INPUT  = 3'b001,
              s_WAIT_CALC   = 3'b010,
              s_START_READ  = 3'b011,
              s_READ_RAM    = 3'b100;
    
    logic   [2:0]   state_reg, state_next;
    logic   [7:0]   cnt_reg, cnt_next;
    logic   [2:0]   num_mat_reg, num_mat_next;

    
    always_ff @( posedge HCLK, negedge HRESETn ) 
    begin
        if (!HRESETn) begin
            state_reg <= s_IDLE;
            cnt_reg <= 8'b0;
            num_mat_reg <= 3'b0;
        end else begin
            state_reg <= state_next;
            cnt_reg <= cnt_next;
            num_mat_reg <= num_mat_next;
        end
    end

    always_comb
    begin
        state_next = state_reg;
        mmu_valid_input_i = 1'b0;
        mmu_read_ram_i = 1'b0;
        mmu_input_data_i = 8'b0;
        cnt_next = cnt_reg;
        num_mat_next = num_mat_reg;
        status_next = status_reg;
        outdata_next = outdata_reg;
        clear_start_bit = 1'b0;

        case (state_reg)
            s_IDLE: begin
                cnt_next = 8'b0;
                num_mat_next = ctrl_reg[3:1];

                // if the start bit is set and number of matrices to be multiplied is bigger than 0
                if (ctrl_reg[0] == 1'b1 && num_mat_reg != 3'b000) begin
                    state_next = s_GIVE_INPUT;
                end
            end

            s_GIVE_INPUT: begin
                mmu_valid_input_i = 1'b1;
                mmu_input_data_i = indata_reg[cnt_reg[7:2]][(24-(cnt_reg[1:0]<<3)) +: 8];
                clear_start_bit = 1'b1;
                cnt_next = cnt_reg + 1;

                if (cnt_reg[4:0] == 8'd31) begin
                    state_next = s_WAIT_CALC;                   
                end
            end

            s_WAIT_CALC: begin
                mmu_valid_input_i = 1'b0;

                if (mmu_finish_o) begin
                    if (num_mat_reg > 3'd1) begin
                        num_mat_next = num_mat_reg - 1;
                        state_next = s_GIVE_INPUT;
                    end else begin
                        state_next = s_START_READ;
                        cnt_next = 8'b0;
                    end
                end
            end

            s_START_READ: begin
                mmu_read_ram_i = 1'b1;

                if (mmu_read_data_out_o != 18'b0) begin
                    outdata_next[cnt_reg] = mmu_read_data_out_o;
                    cnt_next = cnt_reg + 1;
                    state_next = s_READ_RAM;
                end
            end

            s_READ_RAM: begin
                outdata_next[cnt_reg] = mmu_read_data_out_o;

                if (cnt_reg == 8'd159) begin
                    status_next = 2'b01;
                    state_next = s_IDLE;
                end else begin
                    cnt_next = cnt_reg + 1;
                end
            end
        endcase
    end
endmodule