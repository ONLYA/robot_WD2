library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mpu6050 is
generic (addr    : std_logic_vector(6 downto 0) := "1101000";
			low_pow : natural := 0);
port (clk     : in std_logic;
		reset_n : in std_logic;
		x_gdata : out std_logic_vector(15 downto 0);
		y_gdata : out std_logic_vector(15 downto 0);
		z_gdata : out std_logic_vector(15 downto 0);
		x_adata : out std_logic_vector(15 downto 0);
		y_adata : out std_logic_vector(15 downto 0);
		z_adata : out std_logic_vector(15 downto 0);
		scl     : inout std_logic;
		sda     : inout std_logic);
end mpu6050;

architecture behave of mpu6050 is

type state_t is (init, waiting, get_data);
--					  axu, axl,
--					  ayu, ayl,
--					  azu, azl,
--					  gxu, gxl,
--					  gyu, gyl,
--					  gzu, gzl);
signal state     : state_t  := init;
					  
signal data_wr   : std_logic_vector(7 downto 0);
signal data_rd   : std_logic_vector(7 downto 0);
signal busy      : std_logic;
signal ack_error : std_logic;
signal ena       : std_logic;
signal rw        : std_logic;
signal reset_ni  : std_logic;

signal scl_delay : std_logic;
signal scl_rise  : std_logic;
signal scl_fall  : std_logic;

signal count     : natural := 0;
signal busy_prev : std_logic;
signal busy_flag : std_logic;
shared variable busy_cnt: natural;
signal busy_prevg: std_logic;
signal INT_clear : std_logic;

begin

i2c_mast : entity work.i2c_master
port map (clk => clk,
			 reset_n => reset_ni,
			 ena => ena,
			 addr => addr,
			 rw => rw,
			 data_wr => data_wr,
			 data_rd => data_rd,
			 busy => busy,
			 ack_error => ack_error,
			 scl => scl,
			 sda => sda);
			 
reset_ni <= (not ack_error) or reset_n;

busy_flagging : process(clk)
	begin
	busy_prev <= busy;
	if rising_edge(clk) then
		if busy_prev = '0' and busy = '1' then
			busy_flag <= '1';
		else
			busy_flag <= '0';
		end if;
	end if;
end process busy_flagging;

edge_scl : process(clk)
	begin
	scl_delay <= scl;
	if rising_edge(clk) then
		if scl = '1' and scl_delay = '0' then
			scl_rise <= '1';
			scl_fall <= '0';
		elsif scl = '0' and scl_delay = '1' then
			scl_rise <= '0';
			scl_fall <= '1';
		end if;
	end if;
end process edge_scl;

HIGH_POWER : if low_pow = 0 generate

	State_machine_HP : process(clk)   --high power mode
		begin
		if rising_edge(clk) then
			case state is
				
				when init =>
					ena     <= '1';
					rw      <= '0';
					data_wr <= "00111000";
					if busy_flag = '1' then
						data_wr <= "00000001";
						if busy_flag = '1' then
							ena <= '0';
							data_wr <= "01101011";
							if busy = '0' then
								ena <= '1';
								rw <= '0';
								if busy_flag = '1' then
									data_wr <= "00001000";
									if busy_flag = '1' then
										state <= waiting;
										ena <= '0';
									end if;
								end if;
							end if;
						end if;
					end if;
				
				when waiting =>
					ena   <= '1';
					count <= count + 1;
					if count = 750000 then
						count <= 0;
						state <= get_data;
					end if;
				
				when get_data =>
					busy_prevg <= busy;
					if busy_prevg = '0' and busy = '1' then
						busy_cnt := busy_cnt + 1;
					end if;
					
					case busy_cnt is
						when 0 =>
							rw <= '0';
							data_wr <= "00111011";
						when 1 =>
							rw <= '1';
						when 2 =>
							rw <= '0';
							data_wr <= "00111100";
							if busy = '0' then
								x_adata(15 downto 8) <= data_rd;
							end if;
						when 3 =>
							rw <= '1';
						when 4 =>
							rw <= '0';
							data_wr <= "00111101";
							if busy = '0' then
								x_adata(7 downto 0) <= data_rd;
							end if;
						when 5 =>
							rw <= '1';
						when 6 =>
							rw <= '0';
							data_wr <= "00111110";
							if busy = '0' then
								y_adata(15 downto 8) <= data_rd;
							end if;
						when 7 =>
							rw <= '1';
						when 8 =>
							rw <= '0';
							data_wr <= "00111111";
							if busy = '0' then
								y_adata(7 downto 0) <= data_rd;
							end if;
						when 9 =>
							rw <= '1';
						when 10 =>
							rw <= '0';
							data_wr <= "01000000";
							if busy = '0' then
								z_adata(15 downto 8) <= data_rd;
							end if;
						when 11 =>
							rw <= '1';
						when 12 =>
							rw <= '0';
							data_wr <= "01000011";
							if busy = '0' then
								z_adata(7 downto 0) <= data_rd;
							end if;
						when 13 =>
							rw <= '1';
						when 14 =>
							rw <= '0';
							data_wr <= "01000100";
							if busy = '0' then
								x_gdata(15 downto 8) <= data_rd;
							end if;
						when 15 =>
							rw <= '1';
						when 16 =>
							rw <= '0';
							data_wr <= "01000101";
							if busy = '0' then
								x_gdata(7 downto 0) <= data_rd;
							end if;
						when 17 =>
							rw <= '1';
						when 18 =>
							rw <= '0';
							data_wr <= "01000110";
							if busy = '0' then
								y_gdata(15 downto 8) <= data_rd;
							end if;
						when 19 =>
							rw <= '1';
						when 20 =>
							rw <= '0';
							data_wr <= "01000111";
							if busy = '0' then
								y_gdata(7 downto 0) <= data_rd;
							end if;
						when 21 =>
							rw <= '1';
						when 22 =>
							rw <= '0';
							data_wr <= "01001000";
							if busy = '0' then
								z_gdata(15 downto 8) <= data_rd;
							end if;
						when 23 =>
							rw <= '1';
						when 24 =>
							rw <= '0';
							data_wr <= "00111010";
							if busy = '0' then
								z_gdata(7 downto 0) <= data_rd;
							end if;
						when 25 =>
							rw <= '1';
						when 26 =>
							ena <= '0';
							if busy = '0' then
								INT_clear <= data_rd(0);
								busy_cnt := 0;                             --reset busy_cnt for next transaction
								state <= waiting;
							end if;
						when others => null;
					end case;
					
				when others => null;
					
			end case;
		end if;
	end process State_machine_HP;
end generate HIGH_POWER;

LOW_POWER : if low_pow = 1 generate

	State_machine_LP : process(clk)   --low power mode, only accelerator is activated
		begin
		if rising_edge(clk) then
			case state is
				
				when init =>
					ena     <= '1';
					rw      <= '0';
					data_wr <= "01101011";
					if busy_flag = '1' then
						data_wr <= "00101000";
						if busy_flag = '1' then
							ena <= '0';
							data_wr <= "01101100";
							if busy = '0' then
								ena <= '1';
								rw <= '0';
								if busy_flag = '1' then
									data_wr <= "00000111";   --wake-up freq = 1.25Hz
									if busy_flag = '1' then
										state <= waiting;
										ena <= '0';
									end if;
								end if;
							end if;
						end if;
					end if;
				
				when waiting =>
					ena   <= '1';
					count <= count + 1;
					if count = 750000 then
						count <= 0;
						state <= get_data;
					end if;
				
				when get_data =>
					busy_prevg <= busy;
					if busy_prevg = '0' and busy = '1' then
						busy_cnt := busy_cnt + 1;
					end if;
					
					case busy_cnt is
						when 0 =>
							rw <= '0';
							data_wr <= "00111011";
						when 1 =>
							rw <= '1';
						when 2 =>
							rw <= '0';
							data_wr <= "00111100";
							if busy = '0' then
								x_adata(15 downto 8) <= data_rd;
							end if;
						when 3 =>
							rw <= '1';
						when 4 =>
							rw <= '0';
							data_wr <= "00111101";
							if busy = '0' then
								x_adata(7 downto 0) <= data_rd;
							end if;
						when 5 =>
							rw <= '1';
						when 6 =>
							rw <= '0';
							data_wr <= "00111110";
							if busy = '0' then
								y_adata(15 downto 8) <= data_rd;
							end if;
						when 7 =>
							rw <= '1';
						when 8 =>
							rw <= '0';
							data_wr <= "00111111";
							if busy = '0' then
								y_adata(7 downto 0) <= data_rd;
							end if;
						when 9 =>
							rw <= '1';
						when 10 =>
							rw <= '0';
							data_wr <= "01000000";
							if busy = '0' then
								z_adata(15 downto 8) <= data_rd;
							end if;
						when 11 =>
							rw <= '1';
						when 12 =>
							rw <= '0';
							data_wr <= "00111010";
							if busy = '0' then
								z_adata(7 downto 0) <= data_rd;
							end if;
						when 13 =>
							rw <= '1';
						when 14 =>
							ena <= '0';
							if busy = '0' then
								INT_clear <= data_rd(0);
							end if;
						
						when others => null;
					end case;
					
				when others => null;
					
			end case;
		end if;
	end process State_machine_LP;
end generate LOW_POWER;

end behave;