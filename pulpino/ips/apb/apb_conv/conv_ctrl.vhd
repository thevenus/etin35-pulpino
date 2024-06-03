-- Convolution controller design
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;

entity conv_ctrl is 
    port (
        -- APB BUS
        HCLK            : IN  STD_LOGIC;
        HRESETn         : IN  STD_LOGIC;
        PADDR           : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
        PWDATA          : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
        PWRITE          : IN  STD_LOGIC;
        PSEL            : IN  STD_LOGIC;
        PENABLE         : IN  STD_LOGIC;
        PRDATA          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        PREADY          : OUT STD_LOGIC;
        PSLVERR         : OUT STD_LOGIC;
        
        -- SIGNALS FROM CONTROLLER TO CONVOLVER:
        conv_res_i      : in  std_logic_vector(7 downto 0);
        conv_res_rdy_i  : in  std_logic;
        conv_nrow_i     : in  std_logic_vector(4 downto 0);
        conv_ncol_i     : in  std_logic_vector(4 downto 0);
        conv_nchn_i     : in  std_logic_vector(1 downto 0);
        input_window_o  : out std_logic_vector(74 downto 0);
        filter_o        : out std_logic_vector(74 downto 0);
        valid_data_o    : out std_logic
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
    signal apb_addr_trimmed : std_logic_vector(9 downto 0);
    signal filter_reg, filter_reg_next: std_logic_vector(74 downto 0);

    -- conv controller signals
    type state_type is (s_WAIT_DATA, s_WAIT_CALC, s_STORE_RESULT);
    signal state_reg, state_next : state_type;
    signal outdata_cnt_reg, outdata_cnt_next : unsigned(9 downto 0);
    signal temp_outdata_reg, temp_outdata_next : unsigned(8 downto 0);

begin

    --  █████  ██████  ██████  
    -- ██   ██ ██   ██ ██   ██ 
    -- ███████ ██████  ██████  
    -- ██   ██ ██      ██   ██ 
    -- ██   ██ ██      ██████  
    
    apb_addr_trimmed <= PADDR(11 downto 2);
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
                ctrl_reg <= '0';
                status_reg <= (others => '0');
                outdata_reg <= (others => (others => '0'));
                filter_reg <= (others => '0');
            else 
                indata_reg <= indata_next;
                indata_row_cnt <= indata_row_cnt_next;
                indata_rx_cnt <= indata_rx_cnt_next;
                ctrl_reg <= ctrl_next;
                status_reg <= status_next;
                outdata_reg <= outdata_next;
                filter_reg <= filter_reg_next;
            end if;
        end if;
    end process apb_reg_update;

    -- write register logic
    apb_write_logic : process (PSEL, PENABLE, PWRITE, PADDR, PWDATA, indata_reg, indata_rx_cnt, indata_row_cnt, filter_reg, clear_start_bit, ctrl_reg)
    begin
        indata_next <= indata_reg;
        indata_rx_cnt_next <= indata_rx_cnt;
        indata_row_cnt_next <= indata_row_cnt;
        filter_reg_next <= filter_reg;
        ctrl_next <= ctrl_reg;

        if (PSEL = '1' and PENABLE = '1' and PWRITE = '1') then -- indata_row_cnt < 28
            if (PADDR = x"1A103500") then -- ctrl register address
                ctrl_next <= PWDATA(0);
            elsif (PADDR = x"1A103508") then -- indata address
                if (indata_row_cnt > "100") then
                    indata_next(0) <= indata_reg(1);
                    indata_next(1) <= indata_reg(2);
                    indata_next(2) <= indata_reg(3);
                    indata_next(3) <= indata_reg(4);
                    indata_next(4)(89 downto 60) <= PWDATA(29 downto 0);
                    indata_row_cnt <= "100";
                    indata_rx_cnt_next <= "01";        
                else
                    if (indata_rx_cnt = "00") then
                        indata_next(to_integer(indata_row_cnt))(89 downto 60) <= PWDATA(29 downto 0);
                        indata_rx_cnt_next <= indata_rx_cnt + 1;
                    elsif (indata_rx_cnt = "01") then
                        indata_next(to_integer(indata_row_cnt))(59 downto 30) <= PWDATA(29 downto 0);
                        indata_rx_cnt_next <= indata_rx_cnt + 1;
                    elsif (indata_rx_cnt = "10") then
                        indata_next(to_integer(indata_row_cnt))(29 downto 6) <= PWDATA(23 downto 0);
                        indata_rx_cnt_next <= (others => '0');
                        indata_row_cnt_next <= indata_row_cnt + 1;
                    end if;
                end if;
            elsif (PADDR = x"1A103900") then -- filter reg 1 address
                filter_reg_next(74 downto 45) <= PWDATA(29 downto 0);
            elsif (PADDR = x"1A103904") then -- filter reg 2 address
                filter_reg_next(44 downto 15) <= PWDATA(29 downto 0);
            elsif (PADDR = x"1A103908") then -- filter reg 3 address
                filter_reg_next(14 downto 0) <= PWDATA(14 downto 0);
            end if;
        end if;
        
        if (clear_start_bit = '1') then
            ctrl_next <= '0';
        end if;

    end process apb_write_logic;

    -- read register logic
    apb_read_logic : process(PSEL, PENABLE, PWRITE, PADDR, outdata_reg, filter_reg, ctrl_reg, status_reg)
    begin
        PRDATA <= (others => '0');
        if (PSEL = '1' and PENABLE = '1' and PWRITE = '0') then
            if (PADDR = x"1A103500") then -- ctrl reg address
                PRDATA <= "0000000000000000000000000000000" & ctrl_reg;
            elsif (PADDR = x"1A103504") then -- status reg address
                PRDATA <= "00000000000000000000000000000" & status_reg;
            elsif (PADDR  >= x"1A10350C" and PADDR <= x"1A103818") then -- outdata reg addresses
                PRDATA <= outdata_reg(to_integer(unsigned(PADDR(11 downto 2)) - "101000011"));--323);
           elsif (PADDR = x"1A103900") then -- filter reg 1 address
               PRDATA <= "00" & filter_reg(74 downto 45);
           elsif (PADDR = x"1A103904") then -- filter reg 2 address
               PRDATA <= "00" & filter_reg(44 downto 15);
           elsif (PADDR = x"1A103908") then -- filter reg 3 address
               PRDATA <= "00000000000000000" & filter_reg(14 downto 0);
            end if;
        end if;
    end process;

    --  ██████  ██████  ███    ██ ██    ██      ██████ ████████ ██████  ██      
    -- ██      ██    ██ ████   ██ ██    ██     ██         ██    ██   ██ ██      
    -- ██      ██    ██ ██ ██  ██ ██    ██     ██         ██    ██████  ██      
    -- ██      ██    ██ ██  ██ ██  ██  ██      ██         ██    ██   ██ ██      
    --  ██████  ██████  ██   ████   ████        ██████    ██    ██   ██ ███████ 

    filter_o <= filter_reg;

    --update column data process
    process (conv_ncol_i, indata_reg)
        variable msb_pos: integer;
        variable lsb_pos: integer; 
    begin
        msb_pos := 95 - to_integer((unsigned(conv_ncol_i) * 3));
        lsb_pos := 81 - to_integer((unsigned(conv_ncol_i) * 3));
        case conv_nrow_i is 
            when "11010" => -- 26
                input_window_o <= (others => '0');
                input_window_o(74 downto 15) <= indata_reg(1)(msb_pos downto lsb_pos) & indata_reg(2)(msb_pos downto lsb_pos) & 
                                                indata_reg(3)(msb_pos downto lsb_pos) & indata_reg(4)(msb_pos downto lsb_pos);
            when "11011" => -- 27
                input_window_o <= (others => '0');
                input_window_o(74 downto 30) <= indata_reg(2)(msb_pos downto lsb_pos) & 
                                                indata_reg(3)(msb_pos downto lsb_pos) & 
                                                indata_reg(4)(msb_pos downto lsb_pos);
            when others =>
                input_window_o <= indata_reg(0)(msb_pos downto lsb_pos) & indata_reg(1)(msb_pos downto lsb_pos) & 
                                  indata_reg(2)(msb_pos downto lsb_pos) & indata_reg(3)(msb_pos downto lsb_pos) & 
                                  indata_reg(4)(msb_pos downto lsb_pos);
        end case;
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

    process (state_reg, temp_outdata_reg, outdata_reg, outdata_cnt_reg, ctrl_reg, status_reg, 
             conv_res_i, conv_res_rdy_i, conv_ncol_i, conv_nrow_i, conv_nchn_i)
        variable outdata_slice_msb : integer;
        variable outdata_slice_lsb : integer;
    begin
        outdata_slice_msb := to_integer(outdata_cnt_reg(1 downto 0) & "111");
        outdata_slice_lsb := to_integer(outdata_cnt_reg(1 downto 0) & "000");

        status_next <= status_reg;
        state_next <= state_reg;
        temp_outdata_next <= temp_outdata_reg;
        outdata_cnt_next <= outdata_cnt_reg;
        outdata_next <= outdata_reg;
        clear_start_bit <= '0';
        valid_data_o <= '0';

        case state_reg is 
            when s_WAIT_DATA =>
                if (conv_nrow_i < "11010") then -- 26
                    if (ctrl_reg = '1') then -- start = 1
                        clear_start_bit <= '1';
                        status_next <= "000";
                        state_next <= s_WAIT_CALC;
                    else
                        state_next <= s_WAIT_DATA;
                    end if;
                else
                    state_next <= s_WAIT_CALC;
                end if;

            when s_WAIT_CALC =>
                valid_data_o <= '1';
                if (conv_res_rdy_i = '1') then
                    valid_data_o <= '0';
                    temp_outdata_next <= unsigned(('0' & outdata_reg(to_integer(outdata_cnt_reg(9 downto 2)))(outdata_slice_msb downto outdata_slice_lsb))) + unsigned('0' & conv_res_i);
                    state_next <= s_STORE_RESULT;
                else
                    state_next <= s_WAIT_CALC;
                end if;
            
            when s_STORE_RESULT =>
                outdata_cnt_next <= outdata_cnt_reg + 1;
                if (temp_outdata_reg > "011111111") then -- 255
                    outdata_next(to_integer(outdata_cnt_reg(9 downto 2)))(outdata_slice_msb downto outdata_slice_lsb) <= "11111111";
                else
                    outdata_next(to_integer(outdata_cnt_reg(9 downto 2)))(outdata_slice_msb downto outdata_slice_lsb) <= std_logic_vector(temp_outdata_reg(7 downto 0));
                end if;

                if (conv_ncol_i /= "11011") then --27
                    state_next <= s_WAIT_CALC;
                else
                    status_next(1) <= '1'; -- row_done_bit <= '1'
                    if (conv_nrow_i = "11011") then -- 27
                        status_next(2) <= '1'; -- channel_done_bit <= '1'
                        outdata_cnt_next <= (others => '0');
                        if (conv_nchn_i = "10") then
                            status_next(0) <= '1'; -- done_bit <= '1'
                        end if;
                    end if;
                    state_next <= s_WAIT_DATA;
                end if;
        end case;

    end process;

end Behavioural;
