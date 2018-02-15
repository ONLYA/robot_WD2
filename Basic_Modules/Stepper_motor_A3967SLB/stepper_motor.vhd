library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stepper_motor is
generic (step_len : natural := 0); --0-1/8  1-1/4  2-1/2  3-1 step
port (clk       : in std_logic;
		en        : in std_logic; --1 enable , 0 disable
		direction : in std_logic; --1 cw     , 0 ccw
		rst       : in std_logic; --1 reset  , 0 normal
		sleep_n   : in std_logic; --1 normal , 0 sleeping
		enable   : out std_logic;
		dir      : out std_logic;
		reset    : out std_logic;
		sleep    : out std_logic;
		ms       : out std_logic_vector(1 downto 0); --ms(1)=ms1  ms(0)=ms2
		--ms2      : out std_logic;
		speed    : in natural;  --speed in percentage of 100%
		step     : out std_logic);
end stepper_motor;


architecture behave of stepper_motor is
signal count : natural   :=  1 ;
signal temp  : std_logic := '0';
begin

reset  <= not rst;
dir    <= direction;
enable <= not en;
sleep  <= sleep_n;

with step_len select
	ms <= "11" when 0, --1/8 step => 360/32 degrees one step
			"01" when 1,
			"10" when 2,
			"00" when others;

process(clk)
begin
if rising_edge(clk) then
--	count <= count+1;
	if speed = 0 then temp <= '0';
	elsif (count = 50000000/speed) then  --0~100Hz
		temp <= not temp;
		count <= 1;
	else count <= count + 1;
	end if;
end if;
step <= temp;
end process;

end behave;