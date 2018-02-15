library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common is
	type angles is array (natural range <>) of natural range 0 to 180; --angle array
	type values is array (natural range <>) of unsigned(11 downto 0);  --value array
end common; 
