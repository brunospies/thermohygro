library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity top_pmod_hygro is
    Port(
    clk :  in std_logic;
    reset: in std_logic;
    temp : out std_logic_vector(10 downto 0);
    hygro : out std_logic_vector(7 downto 0);
    ack_error: out std_logic;
    hygro_scl : INOUT STD_LOGIC;
    hygro_sda : INOUT STD_LOGIC
    );
end top_pmod_hygro;

architecture Behavioral of top_pmod_hygro is

COMPONENT pmod_hygrometer IS
  GENERIC(
    sys_clk_freq            : INTEGER := 5_000;        --input clock speed from user logic in Hz
    humidity_resolution     : INTEGER RANGE 0 TO 14 := 14;  --RH resolution in bits (must be 14, 11, or 8)
    temperature_resolution  : INTEGER RANGE 0 TO 14 := 14); --temperature resolution in bits (must be 14 or 11)
  PORT(
    clk               : IN    STD_LOGIC;                                            --system clock
    reset_n           : IN    STD_LOGIC;                                            --asynchronous active-low reset
    scl               : INOUT STD_LOGIC;                                            --I2C serial clock
    sda               : INOUT STD_LOGIC;                                            --I2C serial data
    i2c_ack_err       : OUT   STD_LOGIC;                                            --I2C slave acknowledge error flag
    relative_humidity : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);     --relative humidity data obtained
    temperature       : OUT   STD_LOGIC_VECTOR(10 DOWNTO 0)); --temperature data obtained
END COMPONENT;

signal reset_inverse : std_logic := '0';
begin
    process(reset)
    begin
        if(reset='1') then
            reset_inverse<='0';
        else
            reset_inverse<='1';
        end if;
    end process;

    aa: pmod_hygrometer 
    generic map(sys_clk_freq => 50_000_000, humidity_resolution => 8, temperature_resolution => 11)
    port map(clk => clk, reset_n => reset_inverse, scl => hygro_scl, sda =>hygro_sda, i2c_ack_err => ack_error, relative_humidity => hygro, temperature => temp);

end Behavioral;