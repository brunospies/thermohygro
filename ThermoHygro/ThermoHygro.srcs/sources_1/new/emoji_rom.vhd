-- emoji_rom.vhd
-- ROM-like combinational generator that draws a simple emoji (96x64) procedurally
-- Designed to work with your FSM_pixel where row increments 0..63 fastest and column 0..95
-- Addressing used in FSM: address = column*64 + row
-- The module outputs a BPP-bit pixel (default 16 bits, RGB565 style):
--   - outside circle: black (x"0000")
--   - face: yellow (x"FFE0")
--   - eyes/mouth: black (x"0000") and white highlights (x"FFFF")
-- To use: instantiate emoji_rom and connect pix_col, pix_row signals to its inputs.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity emoji_rom is
  generic (
    BPP : integer := 16  -- bits per pixel (assumed RGB565 when 16)
  );
  port (
    col      : in  STD_LOGIC_VECTOR(6 downto 0); -- 0..95
    row      : in  STD_LOGIC_VECTOR(5 downto 0); -- 0..63
    pix_data : out STD_LOGIC_VECTOR(BPP-1 downto 0)
  );
end entity;

architecture Behavioral of emoji_rom is
  -- constants for RGB565 colors (16-bit)
  constant C_BLACK  : std_logic_vector(15 downto 0) := x"0000";
  constant C_WHITE  : std_logic_vector(15 downto 0) := x"FFFF";
  constant C_YELLOW : std_logic_vector(15 downto 0) := x"FFE0"; -- full red + full green

  -- convert inputs to integers for math
  signal ci : integer range 0 to 95;
  signal ri : integer range 0 to 63;

  -- computed pixel
  signal pixel_out : std_logic_vector(15 downto 0);

begin
  ci <= to_integer(unsigned(col));
  ri <= to_integer(unsigned(row));

  -- Combinational process that draws a simple emoji using arithmetic (no big ROM init required)
  process(ci, ri)
    variable cx : integer := 47; -- center column ~ middle of 0..95
    variable cy : integer := 31; -- center row ~ middle of 0..63
    variable dx : integer;
    variable dy : integer;
    variable dist2 : integer;
    variable r : integer := 28; -- radius of the face circle
    variable eye_dx : integer;
    variable eye_dy : integer;
    variable eye_r : integer := 3; -- eye radius
    variable mouth_dx : integer;
    variable mouth_dy : integer;
    variable mouth_dist2 : integer;
  begin
    dx := ci - cx;
    dy := ri - cy;
    dist2 := dx*dx + dy*dy;

    -- default: transparent/outside -> black
    pixel_out <= C_BLACK;

    if dist2 <= r*r then
      -- inside the face circle: yellow by default
      pixel_out <= C_YELLOW;

      -- left eye
      eye_dx := ci - (cx - 9);
      eye_dy := ri - (cy - 6);
      if (eye_dx*eye_dx + eye_dy*eye_dy) <= eye_r*eye_r then
        pixel_out <= C_BLACK;
      end if;

      -- right eye
      eye_dx := ci - (cx + 9);
      eye_dy := ri - (cy - 6);
      if (eye_dx*eye_dx + eye_dy*eye_dy) <= eye_r*eye_r then
        pixel_out <= C_BLACK;
      end if;

      -- small white highlights in eyes (offset inside the eye)
      eye_dx := ci - (cx - 10);
      eye_dy := ri - (cy - 7);
      if (eye_dx*eye_dx + eye_dy*eye_dy) <= 1 then
        pixel_out <= C_WHITE;
      end if;

      eye_dx := ci - (cx + 8);
      eye_dy := ri - (cy - 7);
      if (eye_dx*eye_dx + eye_dy*eye_dy) <= 1 then
        pixel_out <= C_WHITE;
      end if;

      -- mouth: draw a simple arc using an offset and distance test
      mouth_dx := ci - cx;
      mouth_dy := ri - (cy + 6);
      mouth_dist2 := (mouth_dx)*(mouth_dx) + (mouth_dy)*(mouth_dy);
      if (mouth_dy >= 0) and (mouth_dist2 <= 14*14) and (mouth_dist2 >= 6*6) then
        -- make the mouth thicker by setting several nearby pixels to black
        pixel_out <= C_BLACK;
      end if;

    end if;
  end process;

  -- truncate or extend to requested BPP width
 pix_data <= pixel_out;


end Behavioral;

-- Integration notes (use these lines in your top-level file):
-- 1) Instantiate:
--    u_emoji: entity work.emoji_rom
--      generic map (BPP => 16)
--      port map (
--        col => pix_col,
--        row => pix_row,
--        pix_data => emoji_pix_data
--      );
-- 2) In your FSM_pixel process replace the fixed pix_data_reg <= x"FFFF" with:
--      pix_data_reg <= emoji_pix_data; -- where emoji_pix_data is the signal connected above
-- 3) If you want a true ROM file instead (for FPGA block-RAM initialization), I can also
--    generate a .mem file (6144 words) from this procedural drawing and a simple VHDL
--    ROM that reads the file at synthesis time. Ask and I'll output the .mem as a text file.

-- End of file
