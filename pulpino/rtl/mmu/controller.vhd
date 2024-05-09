----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/24/2024 03:06:20 PM
-- Design Name: 
-- Module Name: controller - Behavioral
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

entity controller is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           input : in STD_LOGIC_VECTOR (7 downto 0);
           valid_input : in STD_LOGIC;
           dataROM : in STD_LOGIC_VECTOR (13 downto 0);
           addrROM : out STD_LOGIC_VECTOR (3 downto 0);
           p1 : out STD_LOGIC_VECTOR (17 downto 0);
           p2 : out STD_LOGIC_VECTOR (17 downto 0);
           p3 : out STD_LOGIC_VECTOR (17 downto 0);
           p4 : out STD_LOGIC_VECTOR (17 downto 0);
           loadRAM : out STD_LOGIC;
           finish : out STD_LOGIC);
end controller;

architecture Behavioral of controller is
    type state_type is (s_idle, s_store_input, s_multiply, s_load_col, s_start_next_col);
    signal state_reg, state_next : state_type;
    
    signal shift_cnt_reg, shift_cnt_next: unsigned(1 downto 0);
    signal in_cnt_reg, in_cnt_next: unsigned(4 downto 0);
    signal mul_cnt_reg, mul_cnt_next: unsigned(2 downto 0);
    signal col_cnt_reg, col_cnt_next: unsigned(1 downto 0);
    
    signal in1_reg, in2_reg, in3_reg, in4_reg : unsigned(63 downto 0);
    signal in1_next, in2_next, in3_next, in4_next : unsigned(63 downto 0);
    signal p1_reg, p2_reg, p3_reg, p4_reg : unsigned(17 downto 0);
    signal p1_next, p2_next, p3_next, p4_next : unsigned(17 downto 0);
    signal mu_flag_reg, mu_flag_next : std_logic;
    
    signal addrROM_reg, addrROM_next: unsigned(3 downto 0);
    signal coef1_reg, coef1_next, coef2_reg, coef2_next: unsigned(6 downto 0);
    
    -- 2 ALU signals
    signal x1, x2 : unsigned(7 downto 0);
    signal a1, a2 : unsigned(6 downto 0);
    signal s1, s2 : unsigned(17 downto 0);
    signal alu1_res, alu2_res : unsigned(17 downto 0);

begin
    -- state register update
    state_register: process (clk, rst)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                state_reg <= s_idle;
            else
                state_reg <= state_next;
            end if;
        end if;
    end process state_register;
    
    -- registers sequential
    register_update_seq : process(clk, rst)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                p1_reg <= (others => '0');
                p2_reg <= (others => '0');
                p3_reg <= (others => '0');
                p4_reg <= (others => '0');
                
                in_cnt_reg <= (others => '0');
                shift_cnt_reg <= (others => '0');
                in1_reg <= (others => '0');
                in2_reg <= (others => '0');
                in3_reg <= (others => '0');
                in4_reg <= (others => '0');
                
                mul_cnt_reg <= (others => '0');
                col_cnt_reg <= (others => '0');
                mu_flag_reg <= '0';
                
                addrROM_reg <= (others => '0');
                coef1_reg <= (others => '0');
                coef2_reg <= (others =>'0');
            else 
                p1_reg <= p1_next;
                p2_reg <= p2_next;
                p3_reg <= p3_next;
                p4_reg <= p4_next;
                
                in_cnt_reg <= in_cnt_next;
                shift_cnt_reg <= shift_cnt_next;
                in1_reg <= in1_next;
                in2_reg <= in2_next;
                in3_reg <= in3_next;
                in4_reg <= in4_next;
                
                mul_cnt_reg <= mul_cnt_next;
                col_cnt_reg <= col_cnt_next;
                mu_flag_reg <= mu_flag_next;
                
                addrROM_reg <= addrROM_next;
                coef1_reg <= coef1_next;
                coef2_reg <= coef2_next;
            end if;
        end if;
    end process register_update_seq;
    
    next_state_out_logic: process(input, valid_input, in_cnt_reg, shift_cnt_reg, state_reg, mul_cnt_reg, col_cnt_reg, mu_flag_reg, 
                              addrROM_reg, coef1_reg, coef2_reg, p1_reg, p2_reg, p3_reg, p4_reg, dataROM,
                              in1_reg, in2_reg, in3_reg, in4_reg, alu1_res, alu2_res)
    begin
        shift_cnt_next <= shift_cnt_reg;
        in_cnt_next <= in_cnt_reg;
        state_next <= state_reg;
        mul_cnt_next <= mul_cnt_reg;
        col_cnt_next <= col_cnt_reg;
        mu_flag_next <= mu_flag_reg;
        addrROM_next <= addrROM_reg;
        coef1_next <= coef1_reg;
        coef2_next <= coef2_reg;
        
        p1_next <= p1_reg;
        p2_next <= p2_reg;
        p3_next <= p3_reg;
        p4_next <= p4_reg;

        
        in1_next <= in1_reg;
        in2_next <= in2_reg;
        in3_next <= in3_reg;
        in4_next <= in4_reg;
        
        x1 <= (others => '0');
        x2 <= (others => '0');
        a1 <= (others => '0');
        a2 <= (others => '0');
        s1 <= (others => '0');
        s2 <= (others => '0');

        loadRAM <= '0';    
        finish <= '0';
        
        case state_reg is 

            when s_idle =>
                p1_next <= (others => '0');
                p2_next <= (others => '0');
                p3_next <= (others => '0');
                p4_next <= (others => '0');
                
                addrROM_next <= (others => '0');
                coef1_next <= unsigned(dataROM(13 downto 7));
                coef2_next <= unsigned(dataROM(6 downto 0));

                mul_cnt_next <= (others => '0');
                col_cnt_next <= (others => '0');
                mu_flag_next <= '0';
                
                finish <= '1';
                
                in_cnt_next <= (others => '0');
                shift_cnt_next <= (others => '0');
                                    
                if valid_input = '1' then 
                   finish <= '0';
                   state_next <= s_store_input;
                   in1_next <= in1_reg(55 downto 0) & unsigned(input);
                   shift_cnt_next <= "01";
                end if;
                
            when s_store_input =>
                if shift_cnt_reg = "00" then
                    in1_next <= in1_reg(55 downto 0) & unsigned(input); 
                elsif shift_cnt_reg = "01" then
                    in2_next <= in2_reg(55 downto 0) & unsigned(input);
                elsif shift_cnt_reg = "10" then
                    in3_next <= in3_reg(55 downto 0) & unsigned(input);
                else 
                    in4_next <= in4_reg(55 downto 0) & unsigned(input);
                end if;
                
                if (in_cnt_reg = 30) then
                    state_next <= s_multiply;
                else
                    state_next <= s_store_input;
                    shift_cnt_next <= shift_cnt_reg + 1;
                    in_cnt_next <= in_cnt_reg + 1;
                end if;
                             
            when s_multiply =>
                -- multiply logic using two Multiplier Units
                if (mul_cnt_reg(0) = '1') then
                    if (mu_flag_reg = '1') then
                        x1 <= in3_reg(63 downto 56);
                        a1 <= coef2_reg;
                        s1 <= p3_reg;
                        p3_next <= alu1_res;
                        
                        x2 <= in4_reg(63 downto 56);
                        a2 <= coef2_reg;
                        s2 <= p4_reg;
                        p4_next <= alu2_res;
                        
                        mul_cnt_next <= mul_cnt_reg + 1;
                        coef1_next <= unsigned(dataROM(13 downto 7));
                        coef2_next <= unsigned(dataROM(6 downto 0));
                        mu_flag_next <= '0';
                        
                        -- circular left shifting the input registers
                        in1_next <= in1_reg(55 downto 0) & in1_reg(63 downto 56);
                        in2_next <= in2_reg(55 downto 0) & in2_reg(63 downto 56);
                        in3_next <= in3_reg(55 downto 0) & in3_reg(63 downto 56);
                        in4_next <= in4_reg(55 downto 0) & in4_reg(63 downto 56);
                        
                    else
                        x1 <= in1_reg(63 downto 56);
                        a1 <= coef2_reg;
                        s1 <= p1_reg;
                        p1_next <= alu1_res;

                        x2 <= in2_reg(63 downto 56);
                        a2 <= coef2_reg;
                        s2 <= p2_reg;
                        p2_next <= alu2_res;
                        
                        mu_flag_next <= '1';
                    end if;
                else
                    if (mu_flag_reg = '1') then
                        x1 <= in3_reg(63 downto 56);
                        a1 <= coef1_reg;
                        s1 <= p3_reg;
                        p3_next <= alu1_res;
                        
                        x2 <= in4_reg(63 downto 56);
                        a2 <= coef1_reg;
                        s2 <= p4_reg;
                        p4_next <= alu2_res;

                        mul_cnt_next <= mul_cnt_reg + 1;
                        addrROM_next <= addrROM_reg + 1;
                        mu_flag_next <= '0';
                        
                        -- circular left shifting the input registers
                        in1_next <= in1_reg(55 downto 0) & in1_reg(63 downto 56);
                        in2_next <= in2_reg(55 downto 0) & in2_reg(63 downto 56);
                        in3_next <= in3_reg(55 downto 0) & in3_reg(63 downto 56);
                        in4_next <= in4_reg(55 downto 0) & in4_reg(63 downto 56);

                    else
                        x1 <= in1_reg(63 downto 56);
                        a1 <= coef1_reg;
                        s1 <= p1_reg;
                        p1_next <= alu1_res;

                        x2 <= in2_reg(63 downto 56);
                        a2 <= coef1_reg;
                        s2 <= p2_reg;
                        p2_next <= alu2_res;

                        mu_flag_next <= '1';
                    end if;
                end if;
                
                if (mul_cnt_reg = 7 and mu_flag_reg = '1') then
                    state_next <= s_load_col;
                else
                    state_next <= s_multiply;
                end if;
            
            when s_load_col => 
                loadRAM <= '1';
                
                if (col_cnt_reg = 3) then
                    finish <= '1';
                    state_next <= s_idle;
                else
                    state_next <= s_start_next_col;
                end if;
            
            when s_start_next_col =>
                p1_next <= (others => '0');
                p2_next <= (others => '0');
                p3_next <= (others => '0');
                p4_next <= (others => '0');
                col_cnt_next <= col_cnt_reg + 1;
                mul_cnt_next <= (others => '0');
                state_next <= s_multiply;

        end case;
    end process next_state_out_logic;
    
    addrROM <= std_logic_vector(addrROM_reg);
    p1 <= std_logic_vector(p1_reg);
    p2 <= std_logic_vector(p2_reg);
    p3 <= std_logic_vector(p3_reg);
    p4 <= std_logic_vector(p4_reg);
    
    -- ALUs
    alu1_res <= x1 * a1 + s1;
    alu2_res <= x2 * a2 + s2;

end Behavioral;
