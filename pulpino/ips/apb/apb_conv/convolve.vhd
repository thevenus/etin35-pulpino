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
    type state_type is (s_init, s_calculate, s_of_check, s_output_result, s_next_column, s_next_row, s_next_matrix);
    signal state_reg, state_next : state_type;

    signal it_cnt_reg, it_cnt_next : unsigned(3 downto 0);
    signal row_cnt_reg, row_cnt_next: unsigned(4 downto 0);
    signal col_cnt_reg, col_cnt_next: unsigned(4 downto 0);
    signal temp_res_reg, temp_res_next : unsigned(8 downto 0);
    signal matrix_num_reg, matrix_num_next : unsigned(2 downto 0);
    signal row1, row2, row3, row4, row5 : std_logic_vector(14 downto 0);
    signal el1, el2, el3, el4, el5 : std_logic_vector(2 downto 0); -- chosen input elements for multiplication in each iteration
    signal filel1, filel2, filel3, filel4, filel5 : std_logic_vector(2 downto 0); -- chosen filter elements for multiplication in each iteration
begin
    row1 <= input_data(74 downto 60);
    row2 <= input_data(59 downto 45);
    row3 <= input_data(44 downto 30);
    row4 <= input_data(29 downto 15);
    row5 <= input_data(14 downto 0);

    element_selection: process (it_cnt)
    begin
        case it_cnt is
            when 0 =>
                el1 <= row1(14 downto 12);
                el2 <= row2(14 downto 12);
                el3 <= row3(14 downto 12);
                el4 <= row4(14 downto 12);
                el5 <= row5(14 downto 12);

                filel1 <= filter(74 downto 72);
                filel2 <= filter(59 downto 57);
                filel3 <= filter(44 downto 42);
                filel4 <= filter(29 downto 27);
                filel5 <= filter(14 downto 12);
            when 1 =>
                el1 <= row1(11 downto 9);
                el2 <= row2(11 downto 9);
                el3 <= row3(11 downto 9);
                el4 <= row4(11 downto 9);
                el5 <= row5(11 downto 9);

                filel1 <= filter(71 downto 69);
                filel2 <= filter(56 downto 54);
                filel3 <= filter(41 downto 39);
                filel4 <= filter(26 downto 24);
                filel5 <= filter(11 downto 9);
            when 2 =>
                el1 <= row1(8 downto 6);
                el2 <= row2(8 downto 6);
                el3 <= row3(8 downto 6);
                el4 <= row4(8 downto 6);
                el5 <= row5(8 downto 6);

                filel1 <= filter(68 downto 66);
                filel2 <= filter(53 downto 51);
                filel3 <= filter(38 downto 36);
                filel4 <= filter(23 downto 21);
                filel5 <= filter(8 downto 6);
            when 3 =>
                el1 <= row1(5 downto 3);
                el2 <= row2(5 downto 3);
                el3 <= row3(5 downto 3);
                el4 <= row4(5 downto 3);
                el5 <= row5(5 downto 3);

                filel1 <= filter(65 downto 63);
                filel2 <= filter(50 downto 48);
                filel3 <= filter(35 downto 33);
                filel4 <= filter(20 downto 18);
                filel5 <= filter(5 downto 3);
            when 4 =>
                el1 <= row1(2 downto 0);
                el2 <= row2(2 downto 0);
                el3 <= row3(2 downto 0);
                el4 <= row4(2 downto 0);
                el5 <= row5(2 downto 0);

                filel1 <= filter(62 downto 60);
                filel2 <= filter(47 downto 45);
                filel3 <= filter(32 downto 30);
                filel4 <= filter(17 downto 15);
                filel5 <= filter(2 downto 0);
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
            if (rst = '1') then
                state_reg <= s_init;
            else
                state_reg <= state_next;
            end if;
        end if;
    end process state_register;

--register update
    register_update: process(clk, rst_n)
    begin

        if (rising_edge(clk))
            if (rst_n = '1') then
                row_cnt_reg <= (others => '0');
                col_cnt_reg <= (others => '0');
                it_cnt_reg <= (others => '0');
                temp_res_reg <= (others => '0');
                matrix_num_reg <= (others => '0');
            else
                row_cnt_reg <= row_cnt_next;
                col_cnt_reg <= col_cnt_next;
                it_cnt_reg <= it_cnt_next;
                temp_res_reg <= temp_res_next;
                matrix_num_reg <= matrix_num_next;
            end if;
        end if;

    end process register_update;

    next_state_logic: process(state_reg, row_cnt_reg, col_cnt_reg, it_cnt_reg, temp_res_reg, matrix_num_reg, valid_data)
    begin

        row_cnt_next <= row_cnt_reg;
        col_cnt_next <= col_cnt_reg;
        it_cnt_next <= it_cnt_reg;
        temp_res_next <= temp_res_reg;
        matrix_num_next <= matrix_num_reg;
        state_next <= state_reg;

        case state_reg is

            when s_init =>
                row_cnt_reg <= (others => '0');
                col_cnt_reg <= (others => '0');
                it_cnt_reg <= (others => '0');
                temp_res_reg <= (others => '0');
                matrix_num_reg <= (others => '0');
                state_next <= s_calculate;

            when s_calculate =>
                if valid_data = '1' then
                    temp_res_next <= temp_res_reg + el1 * filel1 + el2 * filel2 + el3 * filel3 + el4 * filel4 + el5 * filel5;
                    it_cnt_next <= it_cnt_reg + 1;
                    state_next <= s_calculate;
                else 
                    state_next <= s_calculate;
                end if ;
            when s_of_check =>
            when s_next =>

        end case;
    end process;
end Behavioural;