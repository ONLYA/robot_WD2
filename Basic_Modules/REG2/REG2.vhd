library ieee;
use ieee.std_logic_1164.all;

entity REG2 is
port (clk : in std_logic;
		input : in std_logic_vector(1 downto 0);
		output: out std_logic_vector(1 downto 0));
end REG2;

architecture behave of REG2 is
begin
REG1_0 : entity work.REG1
			port map(clk => clk, input => input(0), output => output(0));
REG1_1 : entity work.REG1
			port map(clk => clk, input => input(1), output => output(1));
end behave;