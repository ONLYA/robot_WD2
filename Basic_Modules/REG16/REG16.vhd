library ieee;
use ieee.std_logic_1164.all;

entity REG16 is
port (clk : in std_logic;
		input : in std_logic_vector(15 downto 0);
		output: out std_logic_vector(15 downto 0));
end REG16;

architecture behave of REG16 is
begin
REG8_0 : entity work.REG8
			port map(clk => clk, input => input(7 downto 0), output => output(7 downto 0));
REG8_1 : entity work.REG8
			port map(clk => clk, input => input(15 downto 8), output => output(15 downto 8));
end behave;