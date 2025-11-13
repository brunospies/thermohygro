library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity transcodeur is
    port (
	        nb_binaire     : in STD_LOGIC_VECTOR(3 downto 0);       
            char_OLED      : out STD_LOGIC_VECTOR (7 downto 0)
          );
end transcodeur;

architecture transcodeur_a of transcodeur is


begin
    
aff : process(nb_binaire)
        begin
				case nb_binaire is
						when "0001"  => char_OLED  <= x"43"; --x"31";
						when "0010"  => char_OLED  <= x"48"; --x"32";
						when "0011"  => char_OLED  <= x"41"; --x"33";
						when "0100"  => char_OLED  <= x"52"; --x"34";	
						when "0101"  => char_OLED  <= x"4C"; --x"35";
						when "0110"  => char_OLED  <= x"45"; --x"36";
						when "0111"  => char_OLED  <= x"53"; --x"37";
						when "1000"  => char_OLED  <= x"20"; --x"38";	
						when "1001"  => char_OLED  <= x"20"; --x"39";							
                        when others  => char_OLED  <= x"20"; --x"30";
				end case;
		 end process aff;			




end transcodeur_a;
