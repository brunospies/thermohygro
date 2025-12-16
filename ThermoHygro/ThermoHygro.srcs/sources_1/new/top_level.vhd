library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity top_level is
    Port ( 
        clk         : in    STD_LOGIC;
        reset       : in    STD_LOGIC;
        
        PMOD_CS     : out   STD_LOGIC;
        PMOD_MOSI   : out   STD_LOGIC;
        PMOD_SCK    : out   STD_LOGIC;
        PMOD_DC     : out   STD_LOGIC;
        PMOD_RES    : out   STD_LOGIC;
        PMOD_VCCEN  : out   STD_LOGIC;
        PMOD_EN     : out   STD_LOGIC;
        
        HYGRO_SCL   : inout STD_LOGIC;
        HYGRO_SDA   : inout STD_LOGIC; 
        
        SPI_MISO    : in  std_logic;
        
        SPI_SS      : out std_logic;
        SPI_SCK     : out std_logic;
        LED         : out std_logic_vector(15 downto 0);
        LED16_B     : out std_logic;
        LED16_G     : out std_logic;
        LED16_R     : out std_logic;
        LED17_B     : out std_logic;
        LED17_G     : out std_logic;
        LED17_R     : out std_logic
     );
end top_level;

architecture Behavioral of top_level is

    component RAM_Display IS
        PORT (
            CLOCK          : IN  STD_LOGIC;
            WE             : IN  STD_LOGIC;
            ADDR_R         : IN  STD_LOGIC_VECTOR (12 downto 0);
            ADDR_W         : IN  STD_LOGIC_VECTOR (12 downto 0);
            DATA_IN        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            DATA_OUT       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    end component;
 
    signal ADDR_W    : STD_LOGIC_VECTOR (12 downto 0);
    signal data_char : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    component PmodOLEDrgb_bitmap is
        Generic (
            CLK_FREQ_HZ : integer := 100000000;        -- by default, we run at 100MHz
            BPP         : integer range 1 to 16 := 16; -- bits per pixel
            GREYSCALE   : boolean := False;            -- color or greyscale ? (only for BPP>6)
            LEFT_SIDE   : boolean := False);           -- True if the Pmod is on the left side of the board
        Port (
            clk          : in  STD_LOGIC;
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
            PMOD_EN      : out STD_LOGIC
        );
    end component;
    
    signal ADDR_R       : STD_LOGIC_VECTOR (12 downto 0);
    signal pix_write    : STD_LOGIC;	                         
    signal pix_col      : STD_LOGIC_VECTOR (6 downto 0); 
    signal pix_row      : STD_LOGIC_VECTOR (5 downto 0); 
    signal pix_data     : STD_LOGIC_VECTOR (15 downto 0); 
    signal pix_data_out : STD_LOGIC_VECTOR (15 downto 0); 

    component FSM_pixel is                                                                                                                
        Port ( 
            clk          : in  STD_LOGIC;                                                          
            reset        : in  STD_LOGIC;  
            ADDR_R       : out STD_LOGIC_VECTOR (12 downto 0);                                          
            pix_write    : out STD_LOGIC;	                                                     
            pix_col      : out STD_LOGIC_VECTOR (6 downto 0);                
            pix_row      : out STD_LOGIC_VECTOR (5 downto 0)
        );                                                     
    end component;                                                                                                         
   
    signal ADDR_char  : std_logic_vector(11 DOWNTO 0);
    signal SEL        : std_logic;
    signal NUMBER     : std_logic_vector(3 DOWNTO 0);
    signal EMOJI      : std_logic_vector(1 downto 0);
    signal WE_display : std_logic;
   
    component ROM_CHAR IS
        PORT (
            CLOCK          : IN  STD_LOGIC;
            ADDR           : IN  std_logic_vector(11 DOWNTO 0);
            SEL            : IN  std_logic;
            NUMBER         : IN std_logic_vector(3 DOWNTO 0);
            EMOJI          : IN std_logic_vector(1 downto 0);
            DATA_OUT       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    end component;
    
    component Write_Control_Unit is
        Port ( 
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            
            TEMP         : in  STD_LOGIC_VECTOR(10 DOWNTO 0);
            HYGRO        : in  STD_LOGIC_VECTOR( 7 DOWNTO 0);
            
            WE_display   : out STD_LOGIC;
            SEL          : out STD_LOGIC;
            EMOJI        : out STD_LOGIC_VECTOR( 1 downto 0);
            NUMBER       : out STD_LOGIC_VECTOR( 3 DOWNTO 0);
            ADDR_W       : out STD_LOGIC_VECTOR(12 downto 0);
            addr_char    : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;
    
    component top_pmod_hygro is
        Port(
            clk      :  in std_logic;
            reset    : in std_logic;
            temp     : out std_logic_vector(10 downto 0);
            hygro    : out std_logic_vector(7 downto 0);
            ack_error: out std_logic;
            hygro_scl: INOUT STD_LOGIC;
            hygro_sda: INOUT STD_LOGIC
        );
    end component;
    
    signal TEMP  : STD_LOGIC_VECTOR(10 DOWNTO 0);
    signal HYGRO : STD_LOGIC_VECTOR( 7 DOWNTO 0);
    
    component top_luminosite is
        Port(
            clk, reset      : in std_logic;
            spi_miso        : in std_logic;
            spi_ss, spi_sck : out std_logic;
            LED             : out std_logic_vector(15 downto 0);
            LED16_B, LED16_G, LED16_R, LED17_B, LED17_G, LED17_R : out std_logic
        );
    end component;

begin
    
    FSM_PIXEL_I : FSM_pixel 
        port map ( 
            clk       => clk,
            reset     => reset,
            ADDR_R    => ADDR_R,
            pix_write => pix_write,
            pix_col   => pix_col,    
            pix_row   => pix_row
        );    
                    
                       
    ECRAN : PmodOLEDrgb_bitmap
        generic map (
            CLK_FREQ_HZ   => 100000000,         
            LEFT_SIDE     => False
        )   
        
        port map    (
            clk          => clk,
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
            PMOD_EN      => PMOD_EN
        );

    RAM_DISPLAY_I : RAM_Display 
        port map(
            clock    => clk, 
            WE       => WE_display,
            ADDR_R   => ADDR_R, 
            ADDR_W   => ADDR_W,    
            data_in  => data_char, 
            data_out => pix_data
        );
                
    
    ROM_CHAR_I:  ROM_CHAR
        port map (
            CLOCK     => clk,
            ADDR      => addr_char,
            SEL       => SEL,
            NUMBER    => NUMBER,
            EMOJI     => EMOJI,
            DATA_OUT  => data_char
        );
        
   WRITE_CONTROL_I: Write_Control_Unit 
        port map ( 
            clk          => clk,
            reset        => reset,
            
            TEMP         => TEMP,
            HYGRO        => HYGRO,
            
            NUMBER       => NUMBER,
            WE_display   => WE_display,
            SEL          => SEL,
            EMOJI        => EMOJI,
            ADDR_W       => ADDR_W,
            addr_char    => addr_char       
        );  
        
        
    PMOD_HYGRO_I: top_pmod_hygro
        port map (
            clk       => clk,
            reset     => reset,
            temp      => TEMP,
            hygro     => HYGRO,
            hygro_scl => HYGRO_SCL,
            hygro_sda => HYGRO_SDA
        );
        
    LUMINOSITE: top_luminosite
        port map (
            clk       => clk,
            reset     => reset,
            spi_miso  => SPI_MISO,
            spi_ss    => SPI_SS, 
            spi_sck   => SPI_SCK,
            LED       => LED,
            LED16_B   => LED16_B,
            LED16_G   => LED16_G,
            LED16_R   => LED16_R,
            LED17_B   => LED17_B,
            LED17_G   => LED17_G,
            LED17_R   => LED17_R
        );
     

end Behavioral;
