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
        
        -- SIGNALS FROM CONTROLLER TO CONVOLVER:
        conv_res_i      : in std_logic_vector(7 downto 0);
        conv_res_rdy_i  : in std_logic;
        conv_nrow_i     : in std_logic_vector(4 downto 0);
        conv_ncol_i     : in std_logic_vector(4 downto 0);
        conv_nchn_i     : in std_logic_vector(1 downto 0);
        input_window_o  : out std_logic_vector(74 downto 0);
        filter_o        : out std_logic_vector(74 downto 0);
        valid_data_o    : out std_logic;
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
    signal filter_reg, filter_reg_next: std_logic_vector(74 downto 0);
    
    apb_addr_trimmed <= PADDR(11 downto 2);

    -- conv controller signals
    type state_type is (s_WAIT_DATA, s_WAIT_CALC, s_STORE_RESULT);
    signal state_reg, state_next : state_type;
    signal outdata_cnt_reg, outdata_cnt_next : unsigned(9 downto 0);
    signal temp_outdata_reg, temp_outdata_next : unsigned(7 downto 0);
begin

    --  █████  ██████  ██████  
    -- ██   ██ ██   ██ ██   ██ 
    -- ███████ ██████  ██████  
    -- ██   ██ ██      ██   ██ 
    -- ██   ██ ██      ██████  

    PREADY <= '1';
    PSLVERR <= '0';

    -- peripheral registers update on rising clock edge
    apb_reg_update: process (HCLK, HRESETn)
    begin
        if (rising_edge(HCLK)) then
            if (HRESETn = '0') then
                indata_reg <= (others => (others => '0'));
                indata_row_cnt <= "010";
                indata_rx_cnt <= (others => '0');
                ctrl_reg <= (others => '0');
                status_reg <= (others => '0');
                outdata_reg <= (others => (others => '0'));
                filter_reg <= (others => '0');
            else 
                indata_reg <= indata_next;
                indata_row_cnt <= indata_row_cnt_next;
                indata_rx_cnt <= indata_rx_count_next;
                ctrl_reg <= ctrl_next;
                status_reg <= status_next;
                outdata_reg <= outdata_next;
                filter_reg <= filter_reg_next;
            end if;
        end if;
    end process apb_reg_update;

    -- write register logic
    apb_write_logic : process (PSEL, PENABLE, PWRITE, PADDR, indata_reg, indata_rx_cnt, indata_row_cnt, PWDATA, filter_reg, clear_start_bit, ctrl_reg)
    begin
        indata_next <= indata_reg;
        indata_rx_cnt_next <= indata_rx_cnt;
        indata_row_cnt_next <= indata_row_cnt;
        filter_reg_next <= filter_reg;
        ctrl_next <= ctrl_reg;

        if (PSEL = '1' and PENABLE = '1' and PWRITE = '1' and indata_row_cnt < "011100") then -- indata_row_cnt = 28
            if (PADDR = x"1A103500") then
                ctrl_next <= PWDATA(0);
            elsif (PADDR = x"1A103508") then
                if (indata_row_cnt > "100") then
                    indata_next(0) <= indata_reg(1);
                    indata_next(1) <= indata_reg(2);
                    indata_next(2) <= indata_reg(3);
                    indata_next(4) <= indata_reg(5);
                    indata_next(5)(89 downto 62) <= PWDATA(27 downto 0);
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
                filter_reg_next(74 downto 45) <= PWDATA(29 downto 0);
            elsif (PADDR = x"1A103904") then
                filter_reg_next(44 downto 15) <= PWDATA(29 downto 0);
            elsif (PADDR = x"1A103908") then
                filter_reg_next(14 downto 0) <= PWDATA(14 downto 0);
            end if;
        end if;
        
        if (clear_start_bit = '1') then
            ctrl_next(0) <= '1';
        end if;
    end process apb_write_logic;

    -- read register logic
    apb_read_logic : process(PSEL, PENABLE, PWRITE, PADDR, outdata_reg, filter_reg, ctrl_reg, status_reg)
    begin
        PRDATA <= (others => '0');
        if (PSEL = '1' and PENABLE = '1' and PWRITE = '0') then
            if (PADDR = x"1A103500") then
                PRDATA <= "0000000000000000000000000000000" & ctrl_reg;
            elsif (PADDR = x"1A103504") then
                PRDATA <= "00000000000000000000000000000" & status_reg;
            elsif (PADDR  >= x"1A10350C" and PADDR <= x"1A103818") then
                PRDATA <= outdata_reg(PADDR(11 downto 2) - 323);
            elsif (PADDR = x"1A103900") then
                PRDATA <= filter_reg(74 downto 45);
            elsif (PADDR = x"1A103904") then
                PRDATA <= filter_reg(44 downto 15);
            elsif (PADDR = x"1A103908") then
                PRDATA <= filter_reg(14 downto 0);
            end if;
        end if;
    end process;

    --  ██████  ██████  ███    ██ ██    ██      ██████ ████████ ██████  ██      
    -- ██      ██    ██ ████   ██ ██    ██     ██         ██    ██   ██ ██      
    -- ██      ██    ██ ██ ██  ██ ██    ██     ██         ██    ██████  ██      
    -- ██      ██    ██ ██  ██ ██  ██  ██      ██         ██    ██   ██ ██      
    --  ██████  ██████  ██   ████   ████        ██████    ██    ██   ██ ███████ 
    filter_o <= filter_reg;

    process (conv_ncol_i, indata_reg)
        variable msb_pos: integer;
        variable lsb_pos: integer; 
    begin
        msb_pos := 95 - conv_ncol_i * 3;
        lsb_pos := 81 - conv_ncol_i * 3;
        input_window_o <= indata_reg(0)(msb_pos downto lsb_pos);
    end process;

    process (HCLK, HRESETn)
    begin
        if (rising_edge(HCLK)) then
            if (HRESETn = '0') then
                outdata_cnt_reg <= (others => '0');
                state_reg <= s_WAIT_DATA;
                temp_outdata_reg <= (others => '0');
            else
                outdata_cnt_reg <= outdata_cnt_next;
                state_reg <= state_next;
                temp_outdata_reg <= temp_outdata_next;
            end if;
        end if;
    end process;

    process (state_reg, temp_outdata_reg, outdata_cnt_reg, ctrl_reg, status_reg)
    begin
        status_next <= status_reg;
        state_next <= state_reg;
        temp_outdata_next <= temp_outdata_reg;
        outdata_cnt_next <= outdata_cnt_reg;
        clear_start_bit <= '0';

        case state_reg is 
            when s_WAIT_DATA =>
                if (ctrl_reg = '1') then
                    clear_start_bit <= '1';
                    status_next <= "000";
                    state_next <= s_WAIT_CALC;
                else
                    state_next <= s_WAIT_DATA;
                end if;

            when s_WAIT_CALC =>
                valid_data_o <= '1';
                if (conv_res_rdy_i = '1') then
                    valid_data_o <= '0';
                    temp_outdata_next <= outdata_reg(outdata_cnt_reg(9 downto 2))(outdata_cnt_reg())
                else
                    state_next <= s_WAIT_CALC;
                end if;
            
            when s_STORE_RESULT =>
                
                
        end case;

    end process;

end Behavioural;
