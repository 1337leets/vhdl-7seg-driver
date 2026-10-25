-- Four-digit display driver built from four ls247 decoders.
--
-- The decoders are chained RBO to RBI from the most significant digit down, as in the
-- datasheet application for blanking leading zeros. A digit is blanked only when it is zero
-- and every digit to its left was blanked too, so 0042 shows as "  42" and 0105 as " 105".
-- The RBI of the units digit is tied high so that a value of zero still shows a single 0.
--
-- Digit 3 is the leftmost one. Its BCD code is bcd(15 downto 12) and its segments are
-- seg_n(27 downto 21), each digit in the same a to g order as ls247.

library ieee;
use ieee.std_logic_1164.all;

entity display4 is
    port (
        bcd   : in  std_logic_vector(15 downto 0);  -- four BCD digits, digit 3 first
        lt_n  : in  std_logic;                      -- lamp test for all digits, active low
        rbi_n : in  std_logic;                      -- low enables leading zero blanking
        bi_n  : in  std_logic;                      -- blanks all digits, active low
        seg_n : out std_logic_vector(27 downto 0)   -- 7 segments per digit, active low
    );
end entity display4;

architecture structural of display4 is
    -- Ripple blanking input and output of each digit
    signal rbi : std_logic_vector(3 downto 0);
    signal rbo : std_logic_vector(3 downto 0);
begin
    rbi(3) <= rbi_n;
    rbi(2) <= rbo(3);
    rbi(1) <= rbo(2);
    rbi(0) <= '1';  -- the units digit is never blanked by the chain

    digits : for i in 0 to 3 generate
        decoder : entity work.ls247
            port map (
                bcd   => bcd(4 * i + 3 downto 4 * i),
                lt_n  => lt_n,
                rbi_n => rbi(i),
                bi_n  => bi_n,
                rbo_n => rbo(i),
                seg_n => seg_n(7 * i + 6 downto 7 * i)
            );
    end generate digits;
end architecture structural;
