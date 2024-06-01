-- Convolution Calculator

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity convolve is 
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        valid_data: in std_logic;
        input_data : in std_logic_vector(74 downto 0);
        filter_data : in std_logic_vector(74 downto 0);
        result : out std_logic_vector(7 downto 0);
        ready : out std_logic;
        n_row : out std_logic_vector(4 downto 0);
        n_col : out std_logic_vector(4 downto 0);
        n_chn : out std_logic_vector(1 downto 0)
    );
end convolve;

architecture Behavioural of convolve is
    type state_type is (s_init, s_calculate, s_output_result);
    signal state_reg, state_next : state_type;

    signal it_cnt_reg, it_cnt_next : unsigned(3 downto 0);
    signal row_cnt_reg, row_cnt_next: unsigned(4 downto 0);
    signal col_cnt_reg, col_cnt_next: unsigned(4 downto 0);
    signal matrix_num_reg, matrix_num_next : unsigned(1 downto 0);
    signal row1, row2, row3, row4, row5 : std_logic_vector(14 downto 0);
    signal el1, el2, el3, el4, el5 : unsigned(2 downto 0); -- chosen input elements for multiplication in each iteration
    signal filel1, filel2, filel3, filel4, filel5 : unsigned(2 downto 0); -- chosen filter elements for multiplication in each iteration
    signal result_extended_reg, result_extended_next : unsigned(8 downto 0);
begin
    row1 <= input_data(74 downto 60);
    row2 <= input_data(59 downto 45);
    row3 <= input_data(44 downto 30);
    row4 <= input_data(29 downto 15);
    row5 <= input_data(14 downto 0);

    element_selection: process (it_cnt_reg, row1, row2, row3, row4, row5, filter_data)
    begin
        case it_cnt_reg is
            when "0000" =>
                el1 <= unsigned(row1(14 downto 12));
                el2 <= unsigned(row2(14 downto 12));
                el3 <= unsigned(row3(14 downto 12));
                el4 <= unsigned(row4(14 downto 12));
                el5 <= unsigned(row5(14 downto 12));

                filel1 <= unsigned(filter_data(74 downto 72));
                filel2 <= unsigned(filter_data(59 downto 57));
                filel3 <= unsigned(filter_data(44 downto 42));
                filel4 <= unsigned(filter_data(29 downto 27));
                filel5 <= unsigned(filter_data(14 downto 12));
            when "0001" =>
                el1 <= unsigned(row1(11 downto 9));
                el2 <= unsigned(row2(11 downto 9));
                el3 <= unsigned(row3(11 downto 9));
                el4 <= unsigned(row4(11 downto 9));
                el5 <= unsigned(row5(11 downto 9));

                filel1 <= unsigned(filter_data(71 downto 69));
                filel2 <= unsigned(filter_data(56 downto 54));
                filel3 <= unsigned(filter_data(41 downto 39));
                filel4 <= unsigned(filter_data(26 downto 24));
                filel5 <= unsigned(filter_data(11 downto 9));
            when "0010" =>
                el1 <= unsigned(row1(8 downto 6));
                el2 <= unsigned(row2(8 downto 6));
                el3 <= unsigned(row3(8 downto 6));
                el4 <= unsigned(row4(8 downto 6));
                el5 <= unsigned(row5(8 downto 6));

                filel1 <= unsigned(filter_data(68 downto 66));
                filel2 <= unsigned(filter_data(53 downto 51));
                filel3 <= unsigned(filter_data(38 downto 36));
                filel4 <= unsigned(filter_data(23 downto 21));
                filel5 <= unsigned(filter_data(8 downto 6));
            when "0011" =>
                el1 <= unsigned(row1(5 downto 3));
                el2 <= unsigned(row2(5 downto 3));
                el3 <= unsigned(row3(5 downto 3));
                el4 <= unsigned(row4(5 downto 3));
                el5 <= unsigned(row5(5 downto 3));

                filel1 <= unsigned(filter_data(65 downto 63));
                filel2 <= unsigned(filter_data(50 downto 48));
                filel3 <= unsigned(filter_data(35 downto 33));
                filel4 <= unsigned(filter_data(20 downto 18));
                filel5 <= unsigned(filter_data(5 downto 3));
            when "0100" =>
                el1 <= unsigned(row1(2 downto 0));
                el2 <= unsigned(row2(2 downto 0));
                el3 <= unsigned(row3(2 downto 0));
                el4 <= unsigned(row4(2 downto 0));
                el5 <= unsigned(row5(2 downto 0));

                filel1 <= unsigned(filter_data(62 downto 60));
                filel2 <= unsigned(filter_data(47 downto 45));
                filel3 <= unsigned(filter_data(32 downto 30));
                filel4 <= unsigned(filter_data(17 downto 15));
                filel5 <= unsigned(filter_data(2 downto 0));
            when others =>
                el1 <= (others => '0');
                el2 <= (others => '0');
                el3 <= (others => '0');
                el4 <= (others => '0');
                el5 <= (others => '0');

                filel1 <= (others => '0');
                filel2 <= (others => '0');
                filel3 <= (others => '0');
                filel4 <= (others => '0');
                filel5 <= (others => '0');
        end case;
    end process element_selection;

    --state register update
    state_register: process (clk, rst_n)
    begin   
        if (rising_edge(clk)) then
            if (rst_n = '0') then
                state_reg <= s_init;
            else
                state_reg <= state_next;
            end if;
        end if;
    end process state_register;

    --register update
    register_update: process(clk, rst_n)
    begin
        if (rising_edge(clk)) then
            if (rst_n = '0') then
                row_cnt_reg <= (others => '0');
                col_cnt_reg <= (others => '0');
                it_cnt_reg <= (others => '0');
                matrix_num_reg <= (others => '0');
                result_extended_reg <= (others => '0');

            else
                row_cnt_reg <= row_cnt_next;
                col_cnt_reg <= col_cnt_next;
                it_cnt_reg <= it_cnt_next;
                matrix_num_reg <= matrix_num_next;
                result_extended_reg <= result_extended_next;

            end if;
        end if;

    end process register_update;


    next_state_logic: process(state_reg, row_cnt_reg, col_cnt_reg, it_cnt_reg, matrix_num_reg, valid_data,
                              result_extended_reg, el1, el2, el3, el4, el5,
                              filel1, filel2, filel3, filel4, filel5)
    begin
        row_cnt_next <= row_cnt_reg;
        col_cnt_next <= col_cnt_reg;
        it_cnt_next <= it_cnt_reg;
        matrix_num_next <= matrix_num_reg;
        state_next <= state_reg;
        result_extended_next <= result_extended_reg;

        ready <= '0';

        case state_reg is
            when s_init =>
                row_cnt_next <= (others => '0');
                col_cnt_next <= (others => '0');
                it_cnt_next <= (others => '0');
                matrix_num_next <= (others => '0');
                result_extended_next <= (others => '0');

                state_next <= s_calculate;

            when s_calculate =>
                if (valid_data = '1') then
                    if (result_extended_reg(8) = '1') then
                        state_next <= s_output_result;
                    else 
                        result_extended_next <= result_extended_reg + (('0' & el1) * ('0' & filel1) + ('0' & el2) * ('0' & filel2) + ('0' & el3) * ('0' & filel3) + ('0' & el4) * ('0' & filel4) + ('0' & el5) * ('0' & filel5));
                        it_cnt_next <= it_cnt_reg + 1;
                        if (it_cnt_reg = 4) then
                            state_next <= s_output_result;
                        else
                            state_next <= s_calculate;
                        end if;
                    end if;
                else
                    state_next <= s_calculate;
                end if;
       
            when s_output_result =>
                it_cnt_next <= (others => '0');
                ready <= '1';
                if (col_cnt_reg = 27) then
                    if (row_cnt_reg = 27) then
                        if (matrix_num_reg = "10") then
                            state_next <= s_init;
                        else 
                            matrix_num_next <= matrix_num_reg + 1;
                            row_cnt_next <= (others => '0');
                            col_cnt_next <= (others => '0');
                            state_next <= s_calculate;
                        end if;
                    else
                        row_cnt_next <= row_cnt_reg + 1;
                        col_cnt_next <= (others => '0');
                        state_next <= s_calculate;
                    end if;
                else 
                    col_cnt_next <= col_cnt_reg + 1;
                    state_next <= s_calculate;
                end if;
                result_extended_next <= (others => '0');
        end case;
    end process;

    result <= std_logic_vector(result_extended_reg(7 downto 0)) when (result_extended_reg(8) = '0') else "11111111";
    n_row <= std_logic_vector(row_cnt_reg);
    n_col <= std_logic_vector(col_cnt_reg);
    n_chn <= std_logic_vector(matrix_num_reg);
end Behavioural;