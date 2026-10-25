-- BCD to seven-segment decoder modelled on the SN74LS247 (TI SDLS083, function table T1).
--
-- Outputs are active low like the open-collector outputs of the chip, so '0' lights a segment.
-- seg_n(6) is segment a and seg_n(0) is segment g.
--
-- On the chip BI and RBO share one wired-AND pin. Inside an FPGA a pin cannot be both an input
-- and an open-collector output, so it is split into the input bi_n and the output rbo_n here.

library ieee;
use ieee.std_logic_1164.all;

entity ls247 is
    port (
        bcd   : in  std_logic_vector(3 downto 0);  -- D C B A
        lt_n  : in  std_logic;                     -- lamp test, active low
        rbi_n : in  std_logic;                     -- ripple blanking input, active low
        bi_n  : in  std_logic;                     -- blanking input, active low
        rbo_n : out std_logic;                     -- ripple blanking output, active low
        seg_n : out std_logic_vector(6 downto 0)   -- a b c d e f g, active low
    );
end entity ls247;

architecture rtl of ls247 is
    constant ALL_OFF : std_logic_vector(6 downto 0) := "1111111";
    constant ALL_ON  : std_logic_vector(6 downto 0) := "0000000";

    signal ripple_blank : std_logic;
    signal pattern      : std_logic_vector(6 downto 0);
begin
    -- A zero is blanked when RBI is low and the lamp test is not active (note 3)
    ripple_blank <= '1' when rbi_n = '0' and lt_n = '1' and bcd = "0000" else '0';
    rbo_n        <= not ripple_blank;

    -- Segment patterns from table T1, abcdefg, 0 = on.
    -- 6 and 9 are drawn with tails, 10 to 14 are the special symbols and 15 is blank.
    with bcd select pattern <=
        "0000001" when "0000",  -- 0
        "1001111" when "0001",  -- 1
        "0010010" when "0010",  -- 2
        "0000110" when "0011",  -- 3
        "1001100" when "0100",  -- 4
        "0100100" when "0101",  -- 5
        "0100000" when "0110",  -- 6
        "0001111" when "0111",  -- 7
        "0000000" when "1000",  -- 8
        "0000100" when "1001",  -- 9
        "1110010" when "1010",  -- 10
        "1100110" when "1011",  -- 11
        "1011100" when "1100",  -- 12
        "0110100" when "1101",  -- 13
        "1110000" when "1110",  -- 14
        ALL_OFF   when others;  -- 15

    -- Priority follows the notes of table T1.
    -- BI blanks everything (note 2), then the lamp test lights everything (note 4),
    -- then the ripple blanking of a zero (note 3), otherwise the decoded digit.
    seg_n <= ALL_OFF when bi_n = '0'         else
             ALL_ON  when lt_n = '0'         else
             ALL_OFF when ripple_blank = '1' else
             pattern;
end architecture rtl;
