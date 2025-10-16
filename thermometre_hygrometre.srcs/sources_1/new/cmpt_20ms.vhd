library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity cmpt_20ms is
Port (
    horloge, enable, reset : in std_logic;
    sortie : out std_logic_vector(20 downto 0)
    );
end cmpt_20ms;

architecture Behavioral of cmpt_20ms is  
signal count : integer range 0 to 2_000_000;
begin

process(horloge) begin
    if rising_edge(horloge) then 
        if (reset = '1') then 
            count <= 0;
        elsif(enable='1') then
            if(count<2_000_000) then
                count<=count+1;
            end if;
        end if;
    end if;   
end process;
    
sortie <= std_logic_vector(to_unsigned(count, 21));

end Behavioral;