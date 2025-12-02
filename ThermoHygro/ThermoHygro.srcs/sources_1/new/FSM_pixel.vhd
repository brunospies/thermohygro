library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity FSM_pixel is
    Port ( 
           clk          : in  STD_LOGIC;
           reset        : in  STD_LOGIC;
           
           ADDR_R       : out STD_LOGIC_VECTOR (12 downto 0);
           
           pix_write    : out STD_LOGIC;
           pix_col      : out STD_LOGIC_VECTOR (6 downto 0);
           pix_row      : out STD_LOGIC_VECTOR (5 downto 0)
          );
end FSM_pixel;

architecture Behavioral of FSM_pixel is

signal row : integer range 0 to 63:=0;
signal column : integer range 0 to 95:=0;


signal ADDR_REG : integer range 0 to 6143;


BEGIN

--State register

  PROCESS (clk)
   BEGIN
     IF rising_edge(clk) THEN
        if reset = '1' then 
            column <= 0;
            row <= 0;
            ADDR_REG <= 0;
            pix_write <= '0';
        else
            if row < 63 and column = 95 then 
                row <= row + 1;
                column <= 0;
                ADDR_REG <= ADDR_REG + 1;
            elsif row = 63 and column = 95 then
                row <= 0;
                column <= 0;
                ADDR_REG <= 0;
            else 
                column <= column + 1;
                ADDR_REG <= ADDR_REG + 1;
            end if;
        end if;     
     END IF;
   END PROCESS;
   
   pix_col <= std_logic_vector(to_unsigned(column, 7));
   pix_row<=std_logic_vector(to_unsigned(row, 6));
   
   pix_write <= '1';
   
   ADDR_R <= std_logic_vector(to_unsigned(ADDR_REG, 13));

end Behavioral;
