-- Self-checking testbench for display4.
-- Inputs and expected outputs are written as the four characters the display should show,
-- with a space for a blanked digit and "8888" for the lamp test.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.seg_pkg.all;

entity tb_display4 is
end entity tb_display4;

architecture sim of tb_display4 is
    signal bcd   : std_logic_vector(15 downto 0) := (others => '0');
    signal lt_n  : std_logic := '1';
    signal rbi_n : std_logic := '0';
    signal bi_n  : std_logic := '1';
    signal seg_n : std_logic_vector(27 downto 0);

    -- Packs four decimal characters into four BCD codes, leftmost first
    function to_bcd(s : string(1 to 4)) return std_logic_vector is
        variable v : std_logic_vector(15 downto 0);
        variable i : natural;
    begin
        for k in 1 to 4 loop
            i := 4 - k;
            v(4 * i + 3 downto 4 * i) :=
                std_logic_vector(to_unsigned(character'pos(s(k)) - character'pos('0'), 4));
        end loop;
        return v;
    end function;

    -- The segment outputs expected for the four characters, a space meaning blank
    function to_display(s : string(1 to 4)) return std_logic_vector is
        variable v : std_logic_vector(27 downto 0);
        variable i : natural;
    begin
        for k in 1 to 4 loop
            i := 4 - k;
            if s(k) = ' ' then
                v(7 * i + 6 downto 7 * i) := "1111111";
            else
                v(7 * i + 6 downto 7 * i) := to_seg_n(GLYPHS(character'pos(s(k)) - character'pos('0')));
            end if;
        end loop;
        return v;
    end function;

    -- Reads the segment outputs back as characters, '?' for anything that is not 0 to 9 or blank
    function show(v : std_logic_vector(27 downto 0)) return string is
        variable r : string(1 to 4) := "????";
        variable d : seg_t;
        variable i : natural;
    begin
        for k in 1 to 4 loop
            i := 4 - k;
            d := v(7 * i + 6 downto 7 * i);
            if d = "1111111" then
                r(k) := ' ';
            else
                for n in 0 to 9 loop
                    if d = to_seg_n(GLYPHS(n)) then
                        r(k) := character'val(character'pos('0') + n);
                    end if;
                end loop;
            end if;
        end loop;
        return r;
    end function;

    signal errors : natural := 0;
begin
    dut : entity work.display4
        port map (
            bcd   => bcd,
            lt_n  => lt_n,
            rbi_n => rbi_n,
            bi_n  => bi_n,
            seg_n => seg_n
        );

    stimulus : process
        procedure check(digits : string(1 to 4); expected : string(1 to 4)) is
        begin
            bcd <= to_bcd(digits);
            wait for 10 ns;
            if seg_n /= to_display(expected) then
                report "input " & digits & " FAILED, shows [" & show(seg_n)
                     & "], expected [" & expected & "]" severity error;
                errors <= errors + 1;
                wait for 0 ns;
            end if;
        end procedure;
    begin
        -- 1. Leading zero blanking (rbi_n low)
        check("0042", "  42");
        check("0000", "   0");
        check("0007", "   7");
        check("0010", "  10");
        check("0100", " 100");
        check("0105", " 105");
        check("1000", "1000");
        check("1234", "1234");
        check("9999", "9999");

        -- 2. Blanking disabled, every zero is shown
        rbi_n <= '1';
        check("0042", "0042");
        check("0000", "0000");
        rbi_n <= '0';

        -- 3. Lamp test lights every segment of every digit
        lt_n <= '0';
        check("0042", "8888");
        lt_n <= '1';

        -- 4. BI blanks the whole display
        bi_n <= '0';
        check("1234", "    ");
        bi_n <= '1';
        wait for 10 ns;

        if errors = 0 then
            report "display4: all checks passed" severity note;
        else
            report "display4: " & integer'image(errors) & " checks failed" severity failure;
        end if;
        wait;
    end process;
end architecture sim;
