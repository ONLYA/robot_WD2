library ieee;
use ieee.std_logic_1164.all;

entity REG1_fall is
port (clk : std_logic;
		input : in std_logic;
		output: out std_logic);
end REG1_fall;

architecture behave of REG1_fall is
signal temp : std_logic;
begin
output <= temp;
process(clk)
begin
if falling_edge(clk) then temp <= input;
else temp <= temp;
end if;
end process;
end behave;