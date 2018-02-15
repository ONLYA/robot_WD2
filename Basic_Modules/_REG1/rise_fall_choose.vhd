library ieee;
use ieee.std_logic_1164.all;

entity rise_fall_choose is
port (rise : in std_logic;
		fall : in std_logic;
		clk  : in std_logic;
		output : out std_logic);
end rise_fall_choose;

architecture behave of rise_fall_choose is
signal temp :std_logic;
--signal clk_tmp : std_logic;
begin
output <= temp;
--clk_tmp <= clk;
process(clk)
begin
if clk='0' then temp <= rise;
else  temp <= fall; end if;
end process;
end behave;