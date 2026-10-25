-- Exhaustive testbench for Mux_4x1, all 64 combinations of the four data inputs and the select lines.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_mux_4x1 is
end entity tb_mux_4x1;

architecture sim of tb_mux_4x1 is
    signal w, x, y, z, s1, s0, f : std_logic;
    signal errors : natural := 0;
begin
    dut : entity work.Mux_4x1
        port map (w => w, x => x, y => y, z => z, S1 => s1, S0 => s0, f => f);

    stimulus : process
        variable v      : std_logic_vector(5 downto 0);  -- w x y z S1 S0
        variable data   : std_logic_vector(3 downto 0);  -- w x y z
        variable sel    : natural;
        variable expect : std_logic;
    begin
        for i in 0 to 63 loop
            v := std_logic_vector(to_unsigned(i, 6));
            w <= v(5); x <= v(4); y <= v(3); z <= v(2); s1 <= v(1); s0 <= v(0);

            data   := v(5 downto 2);
            sel    := to_integer(unsigned(v(1 downto 0)));
            expect := data(3 - sel);  -- select 0 picks w, 3 picks z
            wait for 10 ns;

            if f /= expect then
                report "wxyz=" & to_string(data) & " S1S0=" & to_string(v(1 downto 0))
                     & " FAILED, f=" & std_logic'image(f) & ", expected " & std_logic'image(expect)
                     severity error;
                errors <= errors + 1;
                wait for 0 ns;
            end if;
        end loop;

        if errors = 0 then
            report "mux_4x1: all checks passed" severity note;
        else
            report "mux_4x1: " & integer'image(errors) & " checks failed" severity failure;
        end if;
        wait;
    end process;
end architecture sim;
