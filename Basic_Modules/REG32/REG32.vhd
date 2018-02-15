library ieee;
use ieee.std_logic_1164.all;

entity REG32 is
port (clk : in std_logic;
		input : in std_logic_vector(31 downto 0);
		output: out std_logic_vector(31 downto 0));
end REG32;

architecture behave of REG32 is
begin
REG16_0 : entity work.REG16
			port map(clk => clk, input => input(15 downto 0), output => output(15 downto 0));
REG16_1 : entity work.REG16
			port map(clk => clk, input => input(31 downto 16), output => output(31 downto 16));
end behave;