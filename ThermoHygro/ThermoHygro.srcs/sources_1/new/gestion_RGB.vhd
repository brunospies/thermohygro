library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity gestion_RGB is
port(   clk : in std_logic;
        LED : in std_logic_vector(15 downto 0);
        LED16_B, LED16_G, LED16_R, LED17_B, LED17_G, LED17_R : out std_logic
    );
end gestion_RGB;

architecture Behavioral of gestion_RGB is

component Pwm is
   port(
      clk_i : in std_logic; -- system clock = 100MHz
      data_i : in std_logic_vector(7 downto 0); -- the number to be modulated
      pwm_o : out std_logic
   );
end component;

--rom contenant les valeurs possibles de R, G et B
TYPE rom is array (1 TO 8) of unsigned(7 downto 0);
signal rom_g, rom_r, rom_b : rom;
  
ATTRIBUTE RAM_STYLE : string;
ATTRIBUTE RAM_STYLE of rom_g: signal is "BLOCK";
ATTRIBUTE RAM_STYLE of rom_r: signal is "BLOCK";
ATTRIBUTE RAM_STYLE of rom_b: signal is "BLOCK";


signal pwm16r, pwm16g, pwm16b, pwm17r, pwm17g, pwm17b : std_logic_vector(7 downto 0);

begin

--LED 16
pwm16_r : pwm port map(clk_i=>clk, data_i=>pwm16r, pwm_o=>LED16_R);
pwm16_g : pwm port map(clk_i=>clk, data_i=>pwm16g, pwm_o=>LED16_G);
pwm16_b : pwm port map(clk_i=>clk, data_i=>pwm16b, pwm_o=>LED16_B);

--LED 17
pwm17_r : pwm port map(clk_i=>clk, data_i=>pwm17r, pwm_o=>LED17_R);
pwm17_g : pwm port map(clk_i=>clk, data_i=>pwm17g, pwm_o=>LED17_G);
pwm17_b : pwm port map(clk_i=>clk, data_i=>pwm17b, pwm_o=>LED17_B);

--initialisation des valeurs dans les roms
rom_r<=(to_unsigned(5,8),
        to_unsigned(122,8),
        to_unsigned(166,8),
        to_unsigned(194,8),
        to_unsigned(217,8),
        to_unsigned(236,8),
        to_unsigned(250,8),
        to_unsigned(255,8)
        );
rom_g<=(to_unsigned(255,8),
        to_unsigned(232,8),
        to_unsigned(208,8),
        to_unsigned(183,8),
        to_unsigned(155,8),
        to_unsigned(123,8),
        to_unsigned(82,8),
        to_unsigned(0,8)
        );
rom_b<=(to_unsigned(2,8),
        to_unsigned(0,8),
        to_unsigned(0,8),
        to_unsigned(0,8),
        to_unsigned(0,8),
        to_unsigned(0,8),
        to_unsigned(0,8),
        to_unsigned(0,8)
        );

process(LED)
begin

if(LED(15)='1')then
    pwm17r<=std_logic_vector(rom_r(8));
    pwm17g<=std_logic_vector(rom_g(8));
    pwm17b<=std_logic_vector(rom_b(8));
    
    pwm16r<=std_logic_vector(rom_r(8));
    pwm16g<=std_logic_vector(rom_g(8));
    pwm16b<=std_logic_vector(rom_b(8));
elsif(LED(14)='1')then
    pwm17r<=std_logic_vector(rom_r(7));
    pwm17g<=std_logic_vector(rom_g(7));
    pwm17b<=std_logic_vector(rom_b(7));
    
    pwm16r<=std_logic_vector(rom_r(8));
    pwm16g<=std_logic_vector(rom_g(8));
    pwm16b<=std_logic_vector(rom_b(8));
elsif(LED(13)='1')then
    pwm17r<=std_logic_vector(rom_r(6));
    pwm17g<=std_logic_vector(rom_g(6));
    pwm17b<=std_logic_vector(rom_b(6));
    
    pwm16r<=std_logic_vector(rom_r(8));
    pwm16g<=std_logic_vector(rom_g(8));
    pwm16b<=std_logic_vector(rom_b(8));
elsif(LED(12)='1')then
    pwm17r<=std_logic_vector(rom_r(5));
    pwm17g<=std_logic_vector(rom_g(5));
    pwm17b<=std_logic_vector(rom_b(5));
    
    pwm16r<=std_logic_vector(rom_r(8));
    pwm16g<=std_logic_vector(rom_g(8));
    pwm16b<=std_logic_vector(rom_b(8));
elsif(LED(11)='1')then
    pwm17r<=std_logic_vector(rom_r(4));
    pwm17g<=std_logic_vector(rom_g(4));
    pwm17b<=std_logic_vector(rom_b(4));
    
    pwm16r<=std_logic_vector(rom_r(8));
    pwm16g<=std_logic_vector(rom_g(8));
    pwm16b<=std_logic_vector(rom_b(8));
elsif(LED(10)='1')then
    pwm17r<=std_logic_vector(rom_r(3));
    pwm17g<=std_logic_vector(rom_g(3));
    pwm17b<=std_logic_vector(rom_b(3));
    
    pwm16r<=std_logic_vector(rom_r(8));
    pwm16g<=std_logic_vector(rom_g(8));
    pwm16b<=std_logic_vector(rom_b(8));
elsif(LED(9)='1')then
    pwm17r<=std_logic_vector(rom_r(2));
    pwm17g<=std_logic_vector(rom_g(2));
    pwm17b<=std_logic_vector(rom_b(2));
    
    pwm16r<=std_logic_vector(rom_r(8));
    pwm16g<=std_logic_vector(rom_g(8));
    pwm16b<=std_logic_vector(rom_b(8));
elsif(LED(8)='1')then
    pwm17r<=std_logic_vector(rom_r(1));
    pwm17g<=std_logic_vector(rom_g(1));
    pwm17b<=std_logic_vector(rom_b(1));
    
    pwm16r<=std_logic_vector(rom_r(8));
    pwm16g<=std_logic_vector(rom_g(8));
    pwm16b<=std_logic_vector(rom_b(8));
elsif(LED(7)='1')then
    pwm17r<=std_logic_vector(to_unsigned(0,8));
    pwm17g<=std_logic_vector(to_unsigned(0,8));
    pwm17b<=std_logic_vector(to_unsigned(0,8));
    
    pwm16r<=std_logic_vector(rom_r(8));
    pwm16g<=std_logic_vector(rom_g(8));
    pwm16b<=std_logic_vector(rom_b(8));
elsif(LED(6)='1')then
    pwm17r<=std_logic_vector(to_unsigned(0,8));
    pwm17g<=std_logic_vector(to_unsigned(0,8));
    pwm17b<=std_logic_vector(to_unsigned(0,8));
    
    pwm16r<=std_logic_vector(rom_r(7));
    pwm16g<=std_logic_vector(rom_g(7));
    pwm16b<=std_logic_vector(rom_b(7));
elsif(LED(5)='1')then
    pwm17r<=std_logic_vector(to_unsigned(0,8));
    pwm17g<=std_logic_vector(to_unsigned(0,8));
    pwm17b<=std_logic_vector(to_unsigned(0,8));
    
    pwm16r<=std_logic_vector(rom_r(6));
    pwm16g<=std_logic_vector(rom_g(6));
    pwm16b<=std_logic_vector(rom_b(6));
elsif(LED(4)='1')then
    pwm17r<=std_logic_vector(to_unsigned(0,8));
    pwm17g<=std_logic_vector(to_unsigned(0,8));
    pwm17b<=std_logic_vector(to_unsigned(0,8));
    
    pwm16r<=std_logic_vector(rom_r(5));
    pwm16g<=std_logic_vector(rom_g(5));
    pwm16b<=std_logic_vector(rom_b(5));
elsif(LED(3)='1')then
    pwm17r<=std_logic_vector(to_unsigned(0,8));
    pwm17g<=std_logic_vector(to_unsigned(0,8));
    pwm17b<=std_logic_vector(to_unsigned(0,8));
    
    pwm16r<=std_logic_vector(rom_r(4));
    pwm16g<=std_logic_vector(rom_g(4));
    pwm16b<=std_logic_vector(rom_b(4));
elsif(LED(2)='1')then
    pwm17r<=std_logic_vector(to_unsigned(0,8));
    pwm17g<=std_logic_vector(to_unsigned(0,8));
    pwm17b<=std_logic_vector(to_unsigned(0,8));
    
    pwm16r<=std_logic_vector(rom_r(3));
    pwm16g<=std_logic_vector(rom_g(3));
    pwm16b<=std_logic_vector(rom_b(3));
elsif(LED(1)='1')then
    pwm17r<=std_logic_vector(to_unsigned(0,8));
    pwm17g<=std_logic_vector(to_unsigned(0,8));
    pwm17b<=std_logic_vector(to_unsigned(0,8));
    
    pwm16r<=std_logic_vector(rom_r(2));
    pwm16g<=std_logic_vector(rom_g(2));
    pwm16b<=std_logic_vector(rom_b(2));
elsif(LED(0)='1')then
    pwm17r<=std_logic_vector(to_unsigned(0,8));
    pwm17g<=std_logic_vector(to_unsigned(0,8));
    pwm17b<=std_logic_vector(to_unsigned(0,8));
    
    pwm16r<=std_logic_vector(rom_r(1));
    pwm16g<=std_logic_vector(rom_g(1));
    pwm16b<=std_logic_vector(rom_b(1));
else
    pwm17r<=std_logic_vector(to_unsigned(0,8));
    pwm17g<=std_logic_vector(to_unsigned(0,8));
    pwm17b<=std_logic_vector(to_unsigned(0,8));
    
    pwm16r<=std_logic_vector(to_unsigned(0,8));
    pwm16g<=std_logic_vector(to_unsigned(0,8));
    pwm16b<=std_logic_vector(to_unsigned(0,8));
end if;

end process;

end Behavioral;
