--REFERENCE ON https://github.com/adafruit/Adafruit-PWM-Servo-Driver-Library
--feedback from adc can be added...
--/init(pwm freq), more...
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common.all;

entity servo is   --using i2c
generic (max_pulse : natural := 4095;
			max_twenty: natural := 819;
			addr      : in std_logic_vector(6 downto 0) := "1111111"; --test
			no_servos : natural range 1 to 16 := 4); --internal address +4 for each servo -- from led0, led1 ... to ledn
port (clk              : in std_logic;
		scl              : inout std_logic;
		sda              : inout std_logic;
		angle            : in angles(0 to no_servos-1);
		reset_n          : in std_logic);
end servo;

architecture behave of servo is

signal ena : std_logic;
signal rw  : std_logic;
signal data_wr : std_logic_vector(7 downto 0);
signal busy : std_logic;
signal data_rd : std_logic_vector(7 downto 0);
signal ack_error : std_logic;

type state_t is (enl, init, wrl, dil, enh, wrh, dih);
signal state : state_t := enl;

shared variable count : natural := 1;
shared variable busy_cnt : natural := 0;
signal address_L : unsigned(7 downto 0) := "00001000";  --init addr_l as led0_off_l 8
signal address_H : unsigned(7 downto 0) := "00001001";  --init addr_h as led0_on_h  9
signal busy_prev : std_logic;

signal value : values(0 to no_servos-1); --Important --need to be calculated on a paralell operation

begin

i2c_mast : entity work.i2c_master
	port map (
					clk       => clk,
					reset_n   => reset_n,
					ena       => ena,
					addr      => addr,
					rw        => rw,
					data_wr   => data_wr,
					busy      => busy,
					data_rd   => data_rd,
					ack_error => ack_error,
					sda       => sda,
					scl       => scl);


State_machine : process(clk)
	begin
	
	if rising_edge(clk) then
		case state is
			when enl =>
				ena <= '1';
				if count < no_servos and count > 1 then
					count := count + 1;
					address_L <= address_L + 4;
					address_H <= address_H + 4;
				else
					count := 1;
					address_L <= "00001000"; --8
					address_H <= "00001001"; --9
				end if;
				state <= init;
			when init =>
				busy_prev <= busy;
				if busy_prev = '0' and busy = '1' then
					busy_cnt := busy_cnt + 1;
				end if;
				case busy_cnt is
					when 0 =>
						rw <= '0';
						data_wr <= "11111110"; --prescaling address
					when 1 =>
						data_wr <= "10000111"; --prescale for 50Hz  floor(25000000/(4096*50*0.9)-1+0.5)
						state <= wrl;
						busy_cnt := 0;
					when others => null;
				end case;
			when wrl =>
				busy_prev <= busy;
				if busy_prev = '0' and busy = '1' then
					busy_cnt := busy_cnt + 1;
				end if;
				case busy_cnt is
					when 0 =>
						rw <= '0';
						data_wr <= std_logic_vector(address_L); --type casting
					when 1 =>
						data_wr <= std_logic_vector(value(count)(7 downto 0));
						state <= dil;
						busy_cnt := 0;
					when others => null;
				end case;
			when dil =>
				ena <= '0';
				state <= enh;
			when enh =>
				ena <= '1';
				state <= wrh;
			when wrh =>
				busy_prev <= busy;
				if busy_prev = '0' and busy = '1' then
					busy_cnt := busy_cnt + 1;
				end if;
				case busy_cnt is
					when 0 =>
						rw <= '0';
						data_wr <= std_logic_vector(address_H); --type casting
					when 1 =>
						data_wr <= "0000" & std_logic_vector(value(count)(11 downto 8));
						state <= dih;
						busy_cnt := 0;
					when others => null;
				end case;
			when dih =>
				ena <= '0';
			when others => null;
		end case;
	end if;
end process state_machine;

end behave;
