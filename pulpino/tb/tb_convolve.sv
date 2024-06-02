module tb_convolve;
    logic               clk = 1'b0;
    logic               rst_n = 1'b0;
    logic               valid_data = 1'b0;
    logic   [2 : 0]     input_stimuli [3][32][32] = '{default:'0};
    logic   [2 : 0]     filter_stimuli [3][5][5] = '{default:'0};
    logic   [7 : 0]     output_array [3][28][28] = '{default:'0};
    logic   [7 : 0]     total_output [28][28];
    logic   [7 : 0]     result;
    logic               ready;
    logic   [4 : 0]     n_row;
    logic   [4 : 0]     n_col;
    logic   [1 : 0]     n_chn;

    logic   [74:0]      input_data;
    logic   [74 : 0]    filter_data;

    convolve conv_i (
        .clk            (clk),
        .rst_n          (rst_n),
        .valid_data     (valid_data),
        .input_data     (input_data),
        .filter_data    (filter_data),
        .result         (result),
        .ready          (ready),
        .n_row          (n_row),
        .n_col          (n_col),
        .n_chn          (n_chn)
    );
    
    always #10ns clk = ~clk;
    integer fd;
    initial begin
        rst_n = 1'b0;
        
        #100ns;
        rst_n = 1'b1;

        #1000ns;
        fd = $fopen("/h/d9/n/fu6315ma-s/Downloads/ifm.txt", "r");
        for (int channel = 0; channel < 3; channel++) begin
            for (int row = 2; row < 30; row++) begin
                for (int col = 2; col < 30; col++) begin
                    $fscanf(fd, "%d", input_stimuli[channel][row][col]);
                end
            end
        end

        #1000ns
        fd = $fopen("/h/d9/n/fu6315ma-s/Downloads/w.txt", "r");
        for (int channel = 0; channel < 3; channel++) begin
            for (int row = 0; row < 5; row++) begin
                for (int col = 0; col < 5; col++) begin
                    $fscanf(fd, "%d", filter_stimuli[channel][row][col]);
                end
            end
        end

        #1000ns
        for (int channel = 0; channel < 3; channel++) begin
            for (int row = 0; row < 28; row++) begin
                for (int col = 0; col < 28; col++) begin
                    for (int i = n_row; i < n_row+5; i++) begin
                        for (int j = n_col; j < n_col+5; j++) begin
                            input_data[74-((i-n_row)*5+(j-n_col))*3 -: 3] = input_stimuli[n_chn][i][j];
                        end
                    end
                    valid_data = 1'b1;
                    wait(ready === 1'b1);
                    valid_data = 1'b0;
                    output_array[channel][row][col] = result;
                    wait(ready === 1'b0);
                end
            end
        end

        #1000ns;
        for (int row=0; row < 28; row++) begin
            for (int col=0; col < 28; col++) begin
                if ((output_array[0][row][col] + output_array[1][row][col] + output_array[2][row][col]) <= 255) begin
                    total_output[row][col] = output_array[0][row][col] + output_array[1][row][col] + output_array[2][row][col];
                end else begin 
                    total_output[row][col] = 255;
                end
            end
        end

       $stop();        
    end

    always_comb begin
        for (int i = 0; i < 5; i++) begin
            for (int j = 0; j < 5; j++) begin
                filter_data[74-(i*5+j)*3 -: 3] = filter_stimuli[n_chn][i][j];
            end
        end
    end

endmodule