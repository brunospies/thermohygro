----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.01.2020 16:02:20
-- Design Name: 
-- Module Name: FSM_OLED - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM_OLED is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           ready : in STD_LOGIC;
           validation : in STD_LOGIC;
           char_write : out STD_LOGIC);
end FSM_OLED;

architecture Behavioral of FSM_OLED is

TYPE STATE_TYPE IS (init, attente, ecriture, acquisition);
SIGNAL current_state, next_state : STATE_TYPE;
	
BEGIN

--State register

  PROCESS (clk)
   BEGIN
     IF (clk'EVENT AND clk = '1') THEN
        IF reset = '1' THEN
             current_state  <= init;
        ELSE
             current_state <= next_state;
        END IF;
     END IF;
   END PROCESS;
   
  --Next state computation
  
   PROCESS (current_state, ready, validation)
    BEGIN       
         CASE current_state IS
            WHEN init =>
                    next_state <= attente;
            WHEN attente =>
               IF validation = '1' THEN
						next_state <= ecriture;
               ELSE	
                        next_state <= attente;		
               END IF;
            WHEN ecriture =>
               IF ready = '0' THEN
                     next_state <= acquisition;    
               ELSE    
                     next_state <= ecriture;        
               END IF;
            WHEN acquisition =>
               IF ready = '1' THEN
                     next_state <= attente;    
               ELSE    
                     next_state <= acquisition;        
               END IF;
         END CASE;
	END PROCESS; 

--Output signal computation

 PROCESS (current_state)
  BEGIN
    CASE current_state IS
      WHEN init =>
          char_write <= '0';
      WHEN attente =>
          char_write <= '0';
      WHEN ecriture =>
          char_write <= '1';
      WHEN acquisition =>
          char_write <= '0';
    END CASE;
  END PROCESS;
  
end Behavioral;
