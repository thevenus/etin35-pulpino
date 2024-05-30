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
        n_chn : out std_logic_vector(1 downto 0));
end convolve;

architecture Behavioural of convolve is
    type state_type is (s_init, s_calculate, s_check, s_next);
    signal state_reg, state_next : state_type;

    signal it_cnt_reg, it_cnt_next : unsigned(3 downto 0);
    signal row_cnt_reg, row_cnt_next: unsigned(26 downto 0);
    signal col_cnt_reg, col_cnt_next: unsigned(26 downto 0);
    signal result: unsigned(7 downto 0);
    signal temp_res_reg, temp_res_next : unsigned(7 downto 0);
    signal matrix_num_reg, matrix_num_next : unsigned(2 downto 0);
    signal write : std_logic;
    signal filter : std_logic_vector(74 downto 0);
    signal input_data : std_logic_vector(74 downto 0);

begin

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

next_state_logic: process(row_cnt_reg, col_cnt_reg, it_cnt_reg, temp_res_reg, matrix_num_reg)
    begin

        row_cnt_next <= row_cnt_reg;
        col_cnt_next <= col_cnt_reg;
        it_cnt_next <= it_cnt_reg;
        temp_res_next <= temp_res_reg;
        matrix_num_next <= matrix_num_reg;
        state_next <= state_reg;

        valid_data <= '0';

        case state_reg is

            when s_init =>

                row_cnt_reg <= (others => '0');
                col_cnt_reg <= (others => '0');
                it_cnt_reg <= (others => '0');
                temp_res_reg <= (others => '0');
                matrix_num_reg <= (others => '0');

                if valid_data <= '1' then

                    state_next <= s_calculate;
                else 
                    state_next <= s_init;
                end if ;

            when s_calculate =>
            when s_check =>
            when s_next =>

        end case;
    end process;
end Behavioural;