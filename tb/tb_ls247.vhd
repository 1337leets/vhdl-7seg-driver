-- Self-checking testbench for ls247.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.seg_pkg.all;

entity tb_ls247 is
end entity tb_ls247;

architecture sim of tb_ls247 is
    signal bcd   : std_logic_vector(3 downto 0) := "0000";
    signal lt_n  : std_logic := '1';
    signal rbi_n : std_logic := '1';
    signal bi_n  : std_logic := '1';
    signal rbo_n : std_logic;
    signal seg_n : seg_t;

    signal errors : natural := 0;
begin
    dut : entity work.ls247
        port map (
            bcd   => bcd,
            lt_n  => lt_n,
            rbi_n => rbi_n,
            bi_n  => bi_n,
            rbo_n => rbo_n,
            seg_n => seg_n
        );

    stimulus : process
        procedure check(name : string; exp_seg : std_logic_vector(6 downto 0); exp_rbo : std_logic) is
        begin
            wait for 10 ns;
            if seg_n /= exp_seg or rbo_n /= exp_rbo then
                report name & " FAILED, lit [" & lit_of(seg_n) & "] rbo_n=" & std_logic'image(rbo_n)
                     & ", expected [" & lit_of(exp_seg) & "] rbo_n=" & std_logic'image(exp_rbo)
                     severity error;
                errors <= errors + 1;
                wait for 0 ns;
            end if;
        end procedure;
    begin
        -- 1. Normal decoding of 0 to 15 (RBI high, so 0 is shown)
        for i in 0 to 15 loop
            bcd <= std_logic_vector(to_unsigned(i, 4));
            check("digit " & integer'image(i), to_seg_n(GLYPHS(i)), '1');
        end loop;

        -- 2. BI low blanks every input (note 2)
        bi_n <= '0';
        for i in 0 to 15 loop
            bcd <= std_logic_vector(to_unsigned(i, 4));
            check("BI low, input " & integer'image(i), "1111111", '1');
        end loop;
        bi_n <= '1';

        -- 3. RBI low blanks a zero and pulls RBO low (note 3)
        rbi_n <= '0';
        bcd   <= "0000";
        check("RBI low, input 0", "1111111", '0');

        -- 4. RBI low does not blank other digits
        for i in 1 to 15 loop
            bcd <= std_logic_vector(to_unsigned(i, 4));
            check("RBI low, input " & integer'image(i), to_seg_n(GLYPHS(i)), '1');
        end loop;
        rbi_n <= '1';

        -- 5. Lamp test lights every segment for every input (note 4)
        lt_n <= '0';
        for i in 0 to 15 loop
            bcd <= std_logic_vector(to_unsigned(i, 4));
            check("LT low, input " & integer'image(i), "0000000", '1');
        end loop;

        -- 6. Lamp test wins over ripple blanking of a zero
        rbi_n <= '0';
        bcd   <= "0000";
        check("LT low and RBI low, input 0", "0000000", '1');

        -- 7. BI wins over the lamp test
        bi_n <= '0';
        check("LT low and BI low", "1111111", '1');

        lt_n <= '1'; rbi_n <= '1'; bi_n <= '1';
        wait for 10 ns;

        if errors = 0 then
            report "ls247: all checks passed" severity note;
        else
            report "ls247: " & integer'image(errors) & " checks failed" severity failure;
        end if;
        wait;
    end process;
end architecture sim;
