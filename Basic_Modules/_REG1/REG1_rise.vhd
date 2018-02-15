library ieee;
use ieee.std_logic_1164.all;

entity REG1_rise is
port (clk : std_logic;
		input : in std_logic;
		output: out std_logic);
end REG1_rise;

architecture behave of REG1_rise is
signal temp : std_logic;
begin
output <= temp;
process(clk)
begin
if rising_edge(clk) then temp <= input;
else temp <= temp;
end if;
end process;
end behave;