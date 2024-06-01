-- Convolution controller design
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity conv_ctrl is 
    port (
        -- APB BUS
        HCLK        : in std_logic;
        HRESETn     : IN STD_LOGIC;
        PADDR       : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        PWDATA      : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        PWRITE      : IN STD_LOGIC;
        PSEL        : IN STD_LOGIC;
        PENABLE     : IN STD_LOGIC;
        PRDATA      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        PREADY      : OUT STD_LOGIC;
        PSLVERR     : OUT STD_LOGIC;
        valid_data_o : OUT STD_LOGIC;
        filter_o : OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
        input_window_o : OUT STD_LOGIC_VECTOR(74 DOWNTO 0)
        
        -- SIGNALS FROM CONTROLLER TO CONVOLVER:
        -- ....
        );
end conv_ctrl;

architecture Behavioural of conv_ctrl is
    -- type state_type is (s_init, s_calculate, s_of_check, s_output_result, s_next_column, s_next_row, s_next_matrix);
    type t_indata_array is array (0 to 4) of std_logic_vector(95 downto 0);
    signal indata_reg, indata_next : t_indata_array;
    type t_outdata_array is array (0 to 195) of std_logic_vector(31 downto 0);
    signal outdata_reg, outdata_next : t_outdata_array;
    signal ctrl_reg, ctrl_next : std_logic;
    signal status_reg, status_next : std_logic_vector(2 downto 0);
    signal clear_start_bit : std_logic;
    signal indata_row_cnt, indata_row_cnt_next : unsigned(2 downto 0);
    signal indata_rx_cnt, indata_rx_cnt_next : unsigned(1 downto 0);
    signal apb_addr_trimmed : std_logic(9 downto 0);
    
    apb_addr_trimmed <= PADDR(11 downto 2);

begin

    --  █████  ██████  ██████  
    -- ██   ██ ██   ██ ██   ██ 
    -- ███████ ██████  ██████  
    -- ██   ██ ██      ██   ██ 
    -- ██   ██ ██      ██████  

    PREADY <= '1';
    PSLVERR <= '0';

    apb_reg_update: process (HCLK, HRESETn)
    begin
        if (rising_edge(HCLK)) then
            if (HRESETn = '0') then
                indata_reg <= (others => (others => '0'));
                indata_row_cnt <= "010";
                indata_rx_cnt <= (others => '0');
                ctrl_reg <= (others => '0');
                status_reg <= (others => '0');
            else 
                indata_reg <= indata_next;
                indata_row_cnt <= indata_row_cnt_next;
                indata_rx_cnt <= indata_rx_count_next;
                ctrl_reg <= ctrl_next;
                status_reg <= status_next;
            end if;
        end if;
    end process apb_reg_update;

    apb_write_logic : process (PSEL, PENABLE, PWRITE, PADDR)
    begin
        indata_next <= indata_reg;
        indata_rx_cnt_next <= indata_rx_cnt;
        indata_row_cnt_next <= indata_row_cnt;
        filter_reg_1_next <= filter_reg_1;
        filter_reg_2_next <= filter_reg_2;
        filter_reg_3_next <= filter_reg_3;
        if (PSEL = '1' and PENABLE = '1' and PWRITE = '1' and indata_row_cnt < "011100") then -- indata_row_cnt = 28
            if (PADDR = x"1A103500") then
                ctrl_next <= PWDATA(0);
            elsif (PADDR = x"1A103508") then
                if (indata_row_cnt > "100") then
                    indata_next(0) <= indata_reg(1);
                    indata_next(1) <= indata_reg(2);
                    indata_next(2) <= indata_reg(3);
                    indata_next(4) <= indata_reg(5);
                    indata_next(5) <= PWDATA(27 downto 0);
                    indata_row_cnt <= "100";
                    indata_rx_cnt_next <= "01";
                else
                    if (indata_rx_cnt = "00") then
                        indata_next(indata_row_cnt)(89 downto 62) <= PWDATA(27 downto 0);
                        indata_rx_cnt_next <= indata_rx_cnt + 1;
                    elsif (indata_rx_cnt = "01") then
                        indata_next(indata_row_cnt)(61 downto 34) <= PWDATA(27 downto 0);
                        indata_rx_cnt_next <= indata_rx_cnt + 1;
                    elsif (indata_rx_cnt = "10") then
                        indata_next(indata_row_cnt)(33 downto 6) <= PWDATA(27 downto 0);
                        indata_rx_cnt_next <= (others => '0');
                        indata_row_cnt_next <= indata_row_cnt + 1;
                    end if;
                end if;
            elsif (PADDR = x"1A103900") then
                filter_reg_1_next <= PWDATA(29 downto 0);
            elsif (PADDR = x"1A103904") then
                filter_reg_2_next <= PWDATA(29 downto 0);
            elsif (PADDR = x"1A103904") then
                filter_reg_3_next <= PWDATA(14 downto 0);
			end if;
        end if;
        
        if (clear_start_bit = '1') then
            ctrl_next(0) <= '1';
        end if;

    end process apb_write_logic;

    -- read register logic
    apb_read_logic : process(PSEL, PENABLE, PWRITE)
    begin
        PRDATA <= (others => '0');
        if (PSEL = '1' and PENABLE = '1' and PWRITE = '0') then
            if (PADDR = x"1A103500") then
                PRDATA <= "0000000000000000000000000000000" & ctrl_reg;
            elsif (PADDR = x"1A103508") then

            elsif (PADDR  >= x"1A10350C" and PADDR <= x"1A103818") then

            elsif (PADDR = x"1A103900") then

            elsif (PADDR = x"1A103904") then

            elsif (PADDR = x"1A103908") then

            end if;
        end if;
    end process;
    
end Behavioural;
