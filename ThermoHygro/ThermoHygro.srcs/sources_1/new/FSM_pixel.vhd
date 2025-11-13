library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity FSM_pixel is
    Generic( BPP         : integer range 1 to 16 := 16 -- bits per pixel
    );
    Port ( clk          : in STD_LOGIC;
           reset        : in STD_LOGIC;
           pix_write    : out STD_LOGIC;
           pix_col      : out  STD_LOGIC_VECTOR (    6 downto 0);
           pix_row      : out  STD_LOGIC_VECTOR (    5 downto 0);
           pix_data     : out  STD_LOGIC_VECTOR (BPP-1 downto 0));
end FSM_pixel;

architecture Behavioral of FSM_pixel is

signal row : integer range 0 to 63:=0;
signal column : integer range 0 to 95:=0;
signal flag, pix_write_reg : std_logic:= '0';
signal pix_col_sig : STD_LOGIC_VECTOR (6 downto 0);
signal pix_row_sig : STD_LOGIC_VECTOR (5 downto 0);
signal address : integer range 0 to 6144;

component ROM_Display IS
PORT (
      CLOCK          : IN  STD_LOGIC;
      ADDR_R         : IN  integer range 0 to 6143;
      DATA_OUT       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
      );
END component;

BEGIN

--State register

  PROCESS (clk)
   BEGIN
     IF rising_edge(clk) THEN
        if reset = '1' then 
            column <= 0;
            row <= 0;
            address <= 0;
            pix_write_reg <= '0';
            flag <= '0';
        else
            if row < 63 and column = 95 then 
                row <= row + 1;
                column <= 0;
                address <= address + 1;
            elsif row = 63 and column = 95 then
                row <= 0;
                column <= 0;
                address <= 0;
                flag <= '1';
            else 
                column <= column + 1;
                address <= address + 1;
            end if;
            
            if flag = '0' then
                pix_write_reg <= '1';
            else 
                pix_write_reg <= '0';
            end if;
        end if;     
     END IF;
   END PROCESS;

--PROCESS (clk)
--   BEGIN
--     IF rising_edge(clk) THEN
--        if reset = '1' then 
--            column <= 0;
--            row <= 0;
--            address <= 0;
--            pix_write_reg <= '0';
--            flag <= '0';
--        else
--            if row = 63 and column < 95 then 
--                column <= column + 1;
--                row <= 0;
--                address <= address + 1;
--            elsif row = 63 and column = 95 then
--                row <= 0;
--                column <= 0;
--                address <= 0;
--                flag <= '1';
--            else 
--                row <= row + 1;
--                address <= address + 1;
--            end if;
            
--            if flag = '0' then
--                pix_write_reg <= '1';
--            else 
--                pix_write_reg <= '0';
--            end if;
--        end if;     
--     END IF;
--   END PROCESS;
   
   ROM : ROM_Display port map (clock=>clk, ADDR_R=>address, data_out=>pix_data);
   
   pix_col_sig <= std_logic_vector(to_unsigned(column, 7));
   pix_row_sig <= std_logic_vector(to_unsigned(row, 6));
   
   pix_col <= pix_col_sig;
   pix_row<=pix_row_sig;
   pix_write <= pix_write_reg;

end Behavioral;
