library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RC is
port (
		clk : in std_logic;
		rxd : in std_logic;
		txd : out std_logic;
		
		enable : out std_logic;
		dir : out std_logic;
		reset : out std_logic;
		sleep : out std_logic;
		ms : out std_logic_vector(1 downto 0);
		step : out std_logic);
end RC;

architecture behave of RC is
signal rx_data : std_logic_vector(7 downto 0);
signal tx_data : std_logic_vector(7 downto 0);
signal en : std_logic := '1';
signal direction : std_logic;
signal rst : std_logic := '0';
signal sleep_n : std_logic := '1';
signal speed : natural;
signal tmp : unsigned(6 downto 0);

component UART is port (
	clk : in std_logic;
	RxD : in std_logic;
	TxD : out std_logic;
	GPout : out std_logic_vector(7 downto 0); --rxdata
	GPin : in std_logic_vector(7 downto 0));  --txdata
end component;

component stepper_motor is port (
		clk       : in std_logic;
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
end component;

begin

UART_m : UART 
port map(
		clk => clk,
		RxD => rxd,
		TxD => txd,
		GPout => rx_data,
		GPin => tx_data);
		
stepper : stepper_motor 
port map(
		clk => clk,
		en => en,
		direction => direction,
		rst => rst,
		sleep_n => sleep_n,
		enable => enable,
		dir => dir,
		reset => reset,
		sleep => sleep,
		ms => ms,
		speed => speed,
		step => step);
		
direction <= rx_data(7);
tmp <= unsigned(rx_data(6 downto 0));
speed <= to_integer(tmp) / 127 * 100;
tx_data <= std_logic_vector(to_unsigned(speed, 8));

end behave;
