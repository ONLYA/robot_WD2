library ieee;
use ieee.std_logic_1164.all;

entity REG8 is
port (clk : in std_logic;
		input : in std_logic_vector(7 downto 0);
		output: out std_logic_vector(7 downto 0));
end REG8;

architecture behave of REG8 is
begin
REG4_0 : entity work.REG4
			port map(clk => clk, input => input(3 downto 0), output => output(3 downto 0));
REG4_1 : entity work.REG4
			port map(clk => clk, input => input(7 downto 4), output => output(7 downto 4));
end behave;