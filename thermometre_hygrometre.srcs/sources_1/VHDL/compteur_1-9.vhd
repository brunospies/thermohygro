library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity compteur_1_9 is
    port ( horloge   : in std_logic;
	       raz       : in std_logic;
           load      : in std_logic;
           sortie    : out std_logic_vector(3 downto 0));

end compteur_1_9;


architecture compteur_1_9_a of compteur_1_9 is

    signal cpt_val : unsigned(3 downto 0);

begin 

    cpt : process (horloge)
        
    begin  -- process cpt
        
      if horloge'event and horloge = '1' then
          if raz = '1' then
                  cpt_val <= "0000";	
          elsif load = '1' then    
                  if cpt_val = "1001" then
                     cpt_val <= "0001";
                  else
                     cpt_val <= cpt_val + 1;
                  end if; 
          end if;  
       end if;
    end process cpt;

    sortie <= std_logic_vector(cpt_val);


end compteur_1_9_a;
