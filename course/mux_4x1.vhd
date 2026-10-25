-- 4-to-1 multiplexer, a course exercise kept as it was written.
-- S1 and S0 select which of w, x, y and z appears on f.
-- Selecting on the concatenation S1 & S0 needs VHDL-2008.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux_4x1 is
    Port (
        w  : in  STD_LOGIC;
        x  : in  STD_LOGIC;
        y  : in  STD_LOGIC;
        z  : in  STD_LOGIC;
        S1 : in  STD_LOGIC;
        S0 : in  STD_LOGIC;
        f  : out STD_LOGIC
    );
end Mux_4x1;

architecture RTL of Mux_4x1 is
begin
    with S1 & S0 select
        f <= w when "00",
             x when "01",
             y when "10",
             z when "11",
             '0' when others;
end RTL;
