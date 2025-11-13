library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    Port ( clk          : in STD_LOGIC;
           reset        : in STD_LOGIC;
           validation   : in STD_LOGIC;
           Saut_ligne   : in STD_LOGIC;
           PMOD_CS      : out STD_LOGIC;
           PMOD_MOSI    : out STD_LOGIC;
           PMOD_SCK     : out STD_LOGIC;
           PMOD_DC      : out STD_LOGIC;
           PMOD_RES     : out STD_LOGIC;
           PMOD_VCCEN   : out STD_LOGIC;
           PMOD_EN      : out STD_LOGIC);
end top_level;

architecture Behavioral of top_level is

signal s_ready             : STD_LOGIC;
signal s_char_write        : STD_LOGIC;
signal s_validation_filtre : STD_LOGIC;
signal s_val_bin           : STD_LOGIC_VECTOR(3 downto 0);
signal s_val_ASCII         : STD_LOGIC_VECTOR(7 downto 0);
signal s_char_OLED         : STD_LOGIC_VECTOR(7 downto 0);

constant return_char       : STD_LOGIC_VECTOR(7 downto 0) := x"0D";


--component PmodOLEDrgb_terminal is
--    Generic (CLK_FREQ_HZ   : integer := 100000000;        -- by default, we run at 100MHz
--             PARAM_BUFF    : boolean := False;            -- if True, no need to hold inputs while module busy
--             LEFT_SIDE     : boolean := False);           -- True if the Pmod is on the left side of the board
--    Port (clk          : in  STD_LOGIC;
--          reset        : in  STD_LOGIC;
          
--          char_write   : in  STD_LOGIC;
--          char         : in  STD_LOGIC_VECTOR(7 downto 0);
--          ready        : out STD_LOGIC;
--          foregnd      : in  STD_LOGIC_VECTOR(7 downto 0):=x"FF";
--          backgnd      : in  STD_LOGIC_VECTOR(7 downto 0):=x"00";
--          screen_clear : in  STD_LOGIC := '0';
          
--          PMOD_CS      : out STD_LOGIC;
--          PMOD_MOSI    : out STD_LOGIC;
--          PMOD_SCK     : out STD_LOGIC;
--          PMOD_DC      : out STD_LOGIC;
--          PMOD_RES     : out STD_LOGIC;
--          PMOD_VCCEN   : out STD_LOGIC;
--          PMOD_EN      : out STD_LOGIC);
--   end component;

component PmodOLEDrgb_bitmap is
    Generic (CLK_FREQ_HZ : integer := 100000000;        -- by default, we run at 100MHz
             BPP         : integer range 1 to 16 := 16; -- bits per pixel
             GREYSCALE   : boolean := False;            -- color or greyscale ? (only for BPP>6)
             LEFT_SIDE   : boolean := False);           -- True if the Pmod is on the left side of the board
    Port (clk          : in  STD_LOGIC;
          reset        : in  STD_LOGIC;
          
          pix_write    : in  STD_LOGIC;
          pix_col      : in  STD_LOGIC_VECTOR(    6 downto 0);
          pix_row      : in  STD_LOGIC_VECTOR(    5 downto 0);
          pix_data_in  : in  STD_LOGIC_VECTOR(BPP-1 downto 0);
          pix_data_out : out STD_LOGIC_VECTOR(BPP-1 downto 0);
          
          PMOD_CS      : out STD_LOGIC;
          PMOD_MOSI    : out STD_LOGIC;
          PMOD_SCK     : out STD_LOGIC;
          PMOD_DC      : out STD_LOGIC;
          PMOD_RES     : out STD_LOGIC;
          PMOD_VCCEN   : out STD_LOGIC;
          PMOD_EN      : out STD_LOGIC);
end component;


-- component FSM_OLED is
--    Port ( clk        : in STD_LOGIC;
--           reset      : in STD_LOGIC;
--           ready      : in STD_LOGIC;
--           validation : in STD_LOGIC;
--           char_write : out STD_LOGIC);
--  end component;

signal pix_write : STD_LOGIC;	                         
signal pix_col   : STD_LOGIC_VECTOR (6 downto 0); 
signal pix_row   : STD_LOGIC_VECTOR (5 downto 0); 
signal pix_data  : STD_LOGIC_VECTOR (15 downto 0); 
signal pix_data_out : STD_LOGIC_VECTOR (15 downto 0); 

component FSM_pixel is                                                                                                 
    Generic( BPP         : integer range 1 to 16 := 16 -- bits per pixel                                               
    );                                                                                                                 
    Port ( clk          : in STD_LOGIC;                                                          
           reset        : in STD_LOGIC;                                            
           pix_write    : out STD_LOGIC;	                                                     
           pix_col      : out  STD_LOGIC_VECTOR (    6 downto 0);                
           pix_row      : out  STD_LOGIC_VECTOR (    5 downto 0);       
           pix_data     : out  STD_LOGIC_VECTOR (BPP-1 downto 0));                                                     
end component;                                                                                                         

component  detec_impulsion IS
    Port (
      CLOCK   : IN  STD_LOGIC;
      INPUT   : IN  STD_LOGIC;
      OUTPUT  : OUT STD_LOGIC
      );
 end component;
 
 component compteur_1_9 is
    port ( horloge   : in std_logic;
	       raz       : in std_logic;
           load      : in std_logic;
           sortie    : out std_logic_vector(3 downto 0)
          );
  end component;
  
 component transcodeur is
    port (
	        nb_binaire     : in STD_LOGIC_VECTOR(3 downto 0);       
            char_OLED      : out STD_LOGIC_VECTOR (7 downto 0)
          );
   end component;
  
begin

Filtre : detec_impulsion
     port map   (CLOCK        => clk,
                 INPUT        => validation,
                 OUTPUT        => s_validation_filtre);

--FSM : FSM_OLED
--     port map   (clk          => clk,
--                 reset        => reset,
--                 ready        => s_ready,
--                 validation   => s_validation_filtre,
--                 char_write   => s_char_write);


FSM : FSM_pixel 
    port map ( clk=>clk,
               reset => reset,
               pix_write=>pix_write,
               pix_col=>pix_col,    
               pix_row=>pix_row,     
               pix_data=>pix_data);    
                    
                       
Ecran : PmodOLEDrgb_bitmap
    generic map (CLK_FREQ_HZ   => 100000000,         
                 LEFT_SIDE     => False)   
                       
    port map     (clk         => clk,
                 reset        => reset,
                 pix_write    => pix_write,
                 pix_col      => pix_col,
                 pix_row      => pix_row,
                 pix_data_in  => pix_data,
                 pix_data_out => pix_data_out,
                 
                 PMOD_CS      => PMOD_CS,
                 PMOD_MOSI    => PMOD_MOSI,
                 PMOD_SCK     => PMOD_SCK,
                 PMOD_DC      => PMOD_DC,
                 PMOD_RES     => PMOD_RES,
                 PMOD_VCCEN   => PMOD_VCCEN, 
                 PMOD_EN      => PMOD_EN);

--Ecran : PmodOLEDrgb_terminal 
--    generic map (CLK_FREQ_HZ   => 100000000,        
--                 PARAM_BUFF    =>  False,           
--                 LEFT_SIDE     => False)   
                       
--    port map     (clk         => clk,
--                 reset        => reset,
--                 char_write   => s_char_write,
--                 char         => s_char_OLED,
--                 ready        => s_ready,
--                 foregnd      => x"03",
--                 backgnd      => x"FF",
--                 screen_clear => reset,
--                 PMOD_CS      => PMOD_CS,
--                 PMOD_MOSI    => PMOD_MOSI,
--                 PMOD_SCK     => PMOD_SCK,
--                 PMOD_DC      => PMOD_DC,
--                 PMOD_RES     => PMOD_RES,
--                 PMOD_VCCEN   => PMOD_VCCEN, 
--                 PMOD_EN      => PMOD_EN);
                 
-- val_char : Process (Saut_ligne, s_val_ASCII)
--    begin   
--       if (Saut_ligne='1') then
--           s_char_OLED <= return_char;	
--       else
           s_char_OLED <= s_val_ASCII;	      
--       end if;  
--    end process;           

end Behavioral;
