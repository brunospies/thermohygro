library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Write_Control_Unit is
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
end Write_Control_Unit;

architecture Behavioral of Write_Control_Unit is

    type states is (state_T1, state_T2, state_T3, state_H1, state_H2, state_EMOJI);
    signal current_state : states;

    signal count : integer range 0 to 99_999_999;
    signal addr_char_signal : integer range 0 to 4095;
    signal addr_display : integer range 0 to 6143;
    signal count_aux  : integer range 0 to 63;
    signal flag_write : std_logic;
    signal EMOJI_sig  : STD_LOGIC_VECTOR(1 downto 0);
    
    signal TEMP_INT  : integer;
    signal HYGRO_INT : integer;
    
    signal TEMP1  : STD_LOGIC_VECTOR(3 downto 0);
    signal TEMP2  : STD_LOGIC_VECTOR(3 downto 0);
    signal TEMP3  : STD_LOGIC_VECTOR(3 downto 0);
    signal HYGRO1 : STD_LOGIC_VECTOR(3 downto 0);
    signal HYGRO2 : STD_LOGIC_VECTOR(3 downto 0);

begin

    process(clk, reset) begin
        if rising_edge(clk) then
            if reset = '1' or count = 99_999_999 then
                count <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
    
    process(clk, reset) begin
        if rising_edge(clk) then
            if reset = '1' then
                WE_display <= '0';
            else
                WE_display <= flag_write;
            end if;  
        end if;
    end process;

    process(clk, reset) begin
        if rising_edge(clk) then
            if reset = '1' then
                addr_char_signal <= 0;
                addr_display <= 0;
                count_aux <= 0;
                flag_write <= '0';
                NUMBER <= "0000";
                current_state <= state_T1;
                EMOJI <= "00";
                
            elsif count = 99_999_999 then
                NUMBER <= TEMP3;
                flag_write <= '1';
                addr_char_signal <= 0;
                count_aux <= 0;
                addr_display <= 369;
                            
            elsif flag_write = '1' then
                case current_state is
                    when state_T1 | state_T2 | state_T3 | state_H1 | state_H2 =>
                        if count_aux = 11 then
                            count_aux <= 0;
                            addr_display <= addr_display + 85;
                        else
                            if addr_char_signal /= 0 then
                                count_aux <= count_aux + 1;
                            end if;
                            addr_display <= addr_display + 1;
                        end if;
                        
                        addr_char_signal <= addr_char_signal + 1;
                        
                    when others =>
                        if count_aux = 63 then
                            count_aux <= 0;
                            addr_display <= addr_display + 33;
                        else
                            if addr_char_signal /= 0 then
                                count_aux <= count_aux + 1;
                            end if;
                            addr_display <= addr_display + 1;
                        end if;
                        addr_char_signal <= addr_char_signal + 1;
                end case;
                
                if addr_char_signal = 95 and current_state /= state_EMOJI then
                
                    addr_char_signal <= 0;
                    count_aux <= 0;
                    
                    if current_state = state_T1 then
                        current_state <= state_T2;
                        addr_display <= 1329;
                        NUMBER <= TEMP2;
                    elsif current_state = state_T2 then 
                        current_state <= state_T3;
                        addr_display <= 2673;-- 2577;
                        NUMBER <= TEMP1;
                    elsif current_state = state_T3 then
                        current_state <= state_H1;
                        addr_display <= 353;
                        EMOJI <= EMOJI_sig;
                        NUMBER <= HYGRO2;
                    elsif current_state = state_H1 then
                        current_state <= state_H2;
                        addr_display <= 1313;
                        NUMBER <= HYGRO1;
                    elsif current_state = state_H2 then
                        current_state <= state_EMOJI;
                        addr_display <= 0;
                        NUMBER <= TEMP3;
                    end if;
                    
                elsif addr_char_signal = 4095 and current_state = state_EMOJI then
                
                    current_state <= state_T1;
                    addr_display <= 369;
                    addr_char_signal <= 0;
                    count_aux <= 0;
                    flag_write <= '0';
                    
                end if;
            end if;
        end if;
    end process;
    
    TEMP_INT <= (TO_INTEGER(UNSIGNED(TEMP))*1650)/2048 - 400; --2^11 = 2048
    HYGRO_INT <= (TO_INTEGER(UNSIGNED(HYGRO))*100)/256; -- 2^8 = 256
    
    TEMP3 <= std_logic_vector(to_unsigned(TEMP_INT / 100, 4));
    TEMP2 <= std_logic_vector(to_unsigned((TEMP_INT / 10) mod 10, 4));
    TEMP1 <= std_logic_vector(to_unsigned(TEMP_INT mod 10, 4));

    
    HYGRO2 <= std_logic_vector(to_unsigned(HYGRO_INT / 10, 4));
    HYGRO1 <= std_logic_vector(to_unsigned(HYGRO_INT mod 10, 4));
    
--    TEMP3 <= TEMP(10 downto 7);
--    TEMP2 <= TEMP( 6 downto 3);
--    TEMP1 <= TEMP( 2 downto 0) & '0';
    
--    HYGRO2 <= HYGRO(7 downto 4);
--    HYGRO1 <= HYGRO(3 downto 0);
    
    SEL <= '1' when current_state = state_EMOJI else
           '0';
           
    EMOJI_sig <= "00" when unsigned(HYGRO2)>="0100" and unsigned(HYGRO2)<="0110" else
                 "01" when unsigned(HYGRO2)>="0011" and unsigned(HYGRO2)<="0111" else
                 "10";       
              
    ADDR_W <= std_logic_vector(to_unsigned(addr_display, 13));
    addr_char <= std_logic_vector(to_unsigned(addr_char_signal, 12));

end Behavioral;