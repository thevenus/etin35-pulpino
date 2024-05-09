----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/24/2024 03:06:20 PM
-- Design Name: 
-- Module Name: rom - Behavioral
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

entity rom is
  Port ( addr : in std_logic_vector(3 downto 0);
         dout : out std_logic_vector(13 downto 0));
end rom;

architecture Behavioral of rom is
    type rom_array_type is array (15 downto 0) of std_logic_vector(13 downto 0);
    signal rom_reg : rom_array_type;
begin
    rom_reg(0)  <= "00000110010110";
    rom_reg(1)  <= "00010110000001";
    rom_reg(2)  <= "00010000000011";
    rom_reg(3)  <= "00000010000010";
    rom_reg(4)  <= "00010000001111";
    rom_reg(5)  <= "00000100000100";
    rom_reg(6)  <= "00011000000110";
    rom_reg(7)  <= "00000010000010";
    rom_reg(8)  <= "00100100101000";
    rom_reg(9)  <= "00000110000010";
    rom_reg(10) <= "00100000001001";
    rom_reg(11) <= "00000010000010";
    rom_reg(12) <= "00000010001010";
    rom_reg(13) <= "00001000000000";
    rom_reg(14) <= "00000100001100";
    rom_reg(15) <= "00000010000010";
    
    process (addr)
    begin
        dout <= rom_reg(to_integer(unsigned(addr)));
    end process;
end Behavioral;
