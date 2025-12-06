library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_luminosite is
port(   clk, reset : in std_logic;
        spi_miso : in std_logic;
        spi_ss, spi_sck : out std_logic;
        LED : out std_logic_vector(15 downto 0);
        LED16_B, LED16_G, LED16_R, LED17_B, LED17_G, LED17_R : out std_logic
     );
end top_luminosite;

architecture Behavioral of top_luminosite is

component top_module_ALS is
  port(
		clk      : in  std_logic;
		reset    : in  std_logic;
        spi_ss   : out STD_LOGIC;
        spi_miso : in  STD_LOGIC;
        spi_sck  : out STD_LOGIC;
        LED      : out STD_LOGIC_VECTOR (7 downto 0)
	);
end component;

component gestion_LED is
port(   data_in : in std_logic_vector(7 downto 0);
        LED : out std_logic_vector(15 downto 0)
     );
end component;

component gestion_RGB is
port(   clk : in std_logic;
        LED : in std_logic_vector(15 downto 0);
        LED16_B, LED16_G, LED16_R, LED17_B, LED17_G, LED17_R : out std_logic
    );
end component;

signal data_ALS : std_logic_vector(7 downto 0);
signal LED_s : std_logic_vector(15 downto 0);

begin

top_ALS : top_module_ALS port map(clk=>clk, reset=>reset, spi_ss=>spi_ss, spi_miso=>spi_miso, spi_sck=>spi_sck, LED=>data_ALS);
ge_led : gestion_LED port map(data_in=>data_ALS, LED=>LED_s);
ge_RGB : gestion_RGB port map(clk=>clk, LED=>LED_s, LED16_R=>LED16_R, LED16_G=>LED16_G, LED16_B=>LED16_B, LED17_R=>LED17_R, LED17_G=>LED17_G, LED17_B=>LED17_B);

LED<=LED_s;

end Behavioral;
