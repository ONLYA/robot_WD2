library ieee;
use ieee.std_logic_1164.all;

entity REG4 is
port (clk : in std_logic;
		input : in std_logic_vector(3 downto 0);
		output: out std_logic_vector(3 downto 0));
end REG4;

architecture behave of REG4 is
begin
REG2_0 : entity work.REG2
			port map(clk => clk, input => input(1 downto 0), output => output(1 downto 0));
REG2_1 : entity work.REG2
			port map(clk => clk, input => input(3 downto 2), output => output(3 downto 2));
end behave;