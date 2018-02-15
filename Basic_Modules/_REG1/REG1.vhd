library ieee;
use ieee.std_logic_1164.all;

entity REG1 is
port (clk : std_logic;
		input : in std_logic;
		output: out std_logic);
end REG1;

architecture behave of REG1 is
signal output_r, output_f : std_logic;
begin
rise_r : entity work.REG1_rise
			port map(clk=>clk, input=>input, output=>output_r);
fall_r : entity work.REG1_fall
			port map(clk=>clk, input=>input, output=>output_f);
choosen: entity work.rise_fall_choose
			port map(clk=>clk, rise=>output_r, fall=>output_f, output=>output);
end behave;