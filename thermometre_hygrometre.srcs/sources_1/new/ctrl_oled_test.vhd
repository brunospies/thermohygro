library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ctrl_oled_test is
port(
    horloge : in std_logic;
    reset : in std_logic;
    cmpt_20ms : in std_logic_vector(20 downto 0);
    oled_commande, oled_reset, oled_vcc_enable, oled_pmod_enable : out std_logic
    );
end ctrl_oled_test;

architecture Behavioral of ctrl_oled_test is

signal temp : integer range 0 to 2_000_000;
begin

process(horloge)
begin
    if(reset='1' and to_integer(21, cmpt_20ms))then
        oled_commande<='0'; --pin 7
        oled_reset<='1'; -- pin 8
        oled_vcc_enable<='0'; --pin 9
        oled_pmod_enable<='1'; --pin 10
        
    end if;
end process;
end Behavioral;
