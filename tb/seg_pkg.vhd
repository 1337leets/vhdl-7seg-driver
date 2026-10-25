-- Helpers shared by the testbenches.
-- The expected values are written as the lit segment letters from table T1 of the datasheet,
-- not as bit vectors, so a typo in the decoder table cannot be repeated here by copying.

library ieee;
use ieee.std_logic_1164.all;

package seg_pkg is
    subtype seg_t is std_logic_vector(6 downto 0);

    type glyphs_t is array (0 to 15) of string(1 to 7);
    -- Lit segments for every input, padded with spaces
    constant GLYPHS : glyphs_t := (
        "abcdef ", "bc     ", "abdeg  ", "abcdg  ",  --  0  1  2  3
        "bcfg   ", "acdfg  ", "acdefg ", "abc    ",  --  4  5  6  7
        "abcdefg", "abcdfg ", "deg    ", "cdg    ",  --  8  9 10 11
        "bfg    ", "adfg   ", "defg   ", "       "   -- 12 13 14 15
    );

    -- Turns a string of segment letters into the active-low output vector
    function to_seg_n(lit : string) return seg_t;

    -- Shows which segments are lit, for readable error messages
    function lit_of(s : seg_t) return string;
end package seg_pkg;

package body seg_pkg is
    constant NAMES : string(1 to 7) := "abcdefg";

    function to_seg_n(lit : string) return seg_t is
        variable v : seg_t := "1111111";
    begin
        for i in lit'range loop
            for k in NAMES'range loop
                if lit(i) = NAMES(k) then
                    v(7 - k) := '0';  -- a is bit 6, g is bit 0
                end if;
            end loop;
        end loop;
        return v;
    end function;

    function lit_of(s : seg_t) return string is
        variable r : string(1 to 7) := "       ";
    begin
        for k in NAMES'range loop
            if s(7 - k) = '0' then
                r(k) := NAMES(k);
            end if;
        end loop;
        return r;
    end function;
end package body seg_pkg;
