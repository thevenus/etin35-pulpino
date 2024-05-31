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
        -- ....
        );
end conv_ctrl;

architecture Behavioural of conv_ctrl is
    -- type state_type is (s_init, s_calculate, s_of_check, s_output_result, s_next_column, s_next_row, s_next_matrix);
    type t_indata_array is array (0 to 4) of std_logic_vector(83 downto 0);
    signal indata_reg, indata_next : t_indata_array;

begin
    --  █████  ██████  ██████  
    -- ██   ██ ██   ██ ██   ██ 
    -- ███████ ██████  ██████  
    -- ██   ██ ██      ██   ██ 
    -- ██   ██ ██      ██████  

    apb_reg_update: process (HCLK, HRESETn)
    begin
        if (rising_edge(HCLK)) then
            if (HRESETn = '0') then
                indata_reg <= (others => (others => '0'));
            else 
                indata_reg <= indata_next;
            end if;
        end if;
    end process apb_reg_update;

    apb_write_logic : process (PSEL, PENABLE, PWRITE, PADDR)
    begin
        if (PSEL = '1' and PENABLE = '1' and PWRITE = '1') then
            if (PADDR = )
        end if;
    end process apb_write_logic;

end Behavioural;