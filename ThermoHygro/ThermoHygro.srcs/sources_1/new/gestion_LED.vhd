library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity gestion_LED is
port(   data_in : in std_logic_vector(7 downto 0);
        LED : out std_logic_vector(15 downto 0)
     );
end gestion_LED;

architecture Behavioral of gestion_LED is

signal intensite : integer range 0 to 255;
constant div : natural := 16;

begin

intensite<=to_integer(unsigned(data_in));

process(intensite)
begin

--LED 0
if(intensite>div) then
    LED(0)<='1';
else
    LED(0)<='0';
end if;

 --LED 1
if(intensite>2*div) then
    LED(1)<='1';
else
    LED(1)<='0';
end if;

 --LED 2
if(intensite>3*div) then
    LED(2)<='1';
else
    LED(2)<='0';
end if;

 --LED 3
if(intensite>4*div) then
    LED(3)<='1';
else
    LED(3)<='0';
end if;

 --LED 4
if(intensite>5*div) then
    LED(4)<='1';
else
    LED(4)<='0';
end if;

 --LED 5
if(intensite>6*div) then
    LED(5)<='1';
else
    LED(5)<='0';
end if;

 --LED 6
if(intensite>7*div) then
    LED(6)<='1';
else
    LED(6)<='0';
end if;

 --LED 7
if(intensite>8*div) then
    LED(7)<='1';
else
    LED(7)<='0';
end if;

 --LED 8
if(intensite>9*div) then
    LED(8)<='1';
else
    LED(8)<='0';
end if;

 --LED 9
if(intensite>10*div) then
    LED(9)<='1';
else
    LED(9)<='0';
end if;

 --LED 10
if(intensite>11*div) then
    LED(10)<='1';
else
    LED(10)<='0';
end if;

 --LED 11
if(intensite>12*div) then
    LED(11)<='1';
else
    LED(11)<='0';
end if;

 --LED 12
if(intensite>13*div) then
    LED(12)<='1';
else
    LED(12)<='0';
end if;

 --LED 13
if(intensite>14*div) then
    LED(13)<='1';
else
    LED(13)<='0';
end if;

 --LED 14
if(intensite>15*div) then
    LED(14)<='1';
else
    LED(14)<='0';
end if;

 --LED 15
if(intensite>250) then
    LED(15)<='1';
else
    LED(15)<='0';
end if;

end process;

end Behavioral;