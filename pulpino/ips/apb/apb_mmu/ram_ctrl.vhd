----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/24/2024 03:06:20 PM
-- Design Name: 
-- Module Name: ram_ctrl - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_ctrl is
Port (
    clk: in std_logic;
    rst: in std_logic;
    load: in std_logic;
    start_read: in std_logic;
    read_data_sram: in std_logic_vector(31 downto 0);
    ready_sram: in std_logic;
    product1: in std_logic_vector(17 downto 0);
    product2: in std_logic_vector(17 downto 0);
    product3: in std_logic_vector(17 downto 0);
    product4: in std_logic_vector(17 downto 0);
    dataRAM: out std_logic_vector(31 downto 0);
    read_data_out: out std_logic_vector(17 downto 0);
    addressRAM: out std_logic_vector(7 downto 0);
    web: out std_logic;
    load_done: out std_logic
    );
    
end ram_ctrl;

architecture Behavioral of ram_ctrl is
    type state_type is (s_idle, s_prep_load, s_load_and_shift, s_ram_reset, s_read);
    signal state_reg, state_next : state_type;
   
    signal address_reg, address_next: unsigned(7 downto 0);
    signal shift_reg, shift_next: unsigned (71 downto 0);
    signal shift_cnt_reg, shift_cnt_next: unsigned (1 downto 0);
    signal load_del, load_rising: std_logic;
    signal read_cnt_reg, read_cnt_next: unsigned (7 downto 0);
    signal read_out_reg, read_out_next: std_logic_vector(17 downto 0);

begin

    state_register: process(clk,rst)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                state_reg <= s_ram_reset;
            else
                state_reg <= state_next;
            end if ;
        end if;       
    end process state_register;


    update_registers: process(clk,rst)
    begin
        if (rising_edge(clk)) then
            if (rst ='1') then
                address_reg <= (others => '0');
                shift_reg <= (others => '0');
                shift_cnt_reg <= (others => '0');
                read_cnt_reg <= (others => '0');
                read_out_reg <= (others => '0');
                load_del <= '0';
            else 
                address_reg <= address_next;
                shift_cnt_reg <= shift_cnt_next;
                shift_reg <= shift_next;  
                load_del <= load;  
                read_cnt_reg <= read_cnt_next;
                read_out_reg <= read_out_next;
            end if;    
        end if;
    end process update_registers;
        
    next_state_logic: process (start_read, state_reg, load_rising, address_reg, shift_reg, shift_cnt_reg,
                               read_cnt_reg, rst, read_data_sram, ready_sram, read_out_reg, product1, product2, product3, product4)
    begin
        state_next <= state_reg;
        address_next <= address_reg;
        shift_next <= shift_reg;
        shift_cnt_next <= shift_cnt_reg;
        read_cnt_next <= read_cnt_reg;
        read_out_next <= read_out_reg;
        load_done <= '0';
        dataRAM <= (others => '0');
        
        addressRAM <= std_logic_vector(address_reg);
        
        case state_reg is 
            
            when s_idle =>
                web  <= '1';
                dataRAM <= (others => '0');
                read_cnt_next <= (others => '0');
                 
                if (rst = '1') then
                    state_next <= s_ram_reset;
                elsif load_rising = '1' then
                    state_next <= s_prep_load;
                elsif start_read = '1' then
                    state_next <= s_read;                
                else   
                    state_next <= s_idle;    
                end if;
                
            when s_prep_load => 
                web <= '1';
                shift_next <= unsigned(product4 & product3 & product2 & product1);
                shift_cnt_next <= "11";
                state_next <= s_load_and_shift;
            
            when s_load_and_shift => 
                web <= '0';
                dataRAM <= "00000000000000" & std_logic_vector(shift_reg(17 downto 0));
                shift_next <= "000000000000000000" & shift_reg(71 downto 18);
     
                shift_cnt_next <= shift_cnt_reg - 1; 
                
                if shift_cnt_reg = 0 then
                    load_done <= '1';
                    address_next <= address_reg + 1;
                    state_next <= s_idle;
                else
                    address_next <= address_reg + 1;
                    state_next <= s_load_and_shift;          
                end if;
                
            when s_ram_reset =>
                web <= '0';
                address_next <= address_reg + 1;          
                
                if (address_reg = 159) then
                    address_next <= (others => '0');
                    state_next <= s_idle;
                else
                    state_next <= s_ram_reset;
                end if;
                
            when s_read => 
                web <= '1';
                addressRAM <= std_logic_vector(read_cnt_reg);
                read_cnt_next <= read_cnt_reg + 1;
                
                if (ready_sram = '1') then
                    read_out_next <= read_data_sram(17 downto 0);
                end if;
                
                if read_cnt_reg = 159 then
                    state_next <= s_idle;
                else 
                    state_next <= s_read;
                end if;

        end case;
    end process next_state_logic;

    load_rising <= (not load_del) and load;
    read_data_out <= read_out_reg;

end Behavioral;
