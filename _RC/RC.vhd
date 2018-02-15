library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rc is
--generic ();
port (
		clk    : in std_logic;
		txd    : out std_logic;
		rxd    : in std_logic;
		enable : out std_logic;
		dir    : out std_logic;
		reset  : out std_logic;
		sleep  : out std_logic;
		ms     : out std_logic_vector(1 downto 0);
		step   : out std_logic);
end rc;

architecture behave of rc is
signal reset_n : std_logic := '1';
signal rst     : std_logic;
signal rx_data : std_logic_vector(7 downto 0);
signal rx_busy : std_logic;
signal rx_error: std_logic;
signal tx_data : std_logic_vector(7 downto 0);
signal tx_ena  : std_logic;
signal tx_busy : std_logic;

signal en      : std_logic;
signal direction : std_logic;
signal sleep_n : std_logic;
signal speed   : natural;
begin
	UART_rx : entity work.uart
		port map(
					clk => clk,
					reset_n => reset_n,
					tx_ena => tx_ena,
					tx_data => tx_data,
					rx => rxd,
					rx_busy => rx_busy,
					rx_error => rx_error,
					rx_data => rx_data,
					tx_busy => tx_busy,
					tx => txd);
					
	stepper : entity work.stepper_motor
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
	rst <= '0';
	tx_data <= (others => '1');
	en <= '1';
	direction <= '1';
	sleep_n <= '1';
--	speed <= 50;
	
	process(clk)
	begin
	if rising_edge(clk) then
		if rx_error = '1' then reset_n <= '0';
--		elsif rx_busy = '0' then
--			en <= rx_data(7);
--			direction <= rx_data(6);
--			sleep_n <= rx_data(5);
--			speed <= to_integer(unsigned(rx_data(4 downto 0)) / 31 * 100);
--			tx_data <= std_logic_vector(to_unsigned(speed, 8));
--			speed <= to_integer((unsigned(rx_data)*100)/255);
		elsif rx_data = "11111111" then speed <= 100;
		else speed <= 50; end if;
			
--		end if;
	end if;
	end process;
end behave;