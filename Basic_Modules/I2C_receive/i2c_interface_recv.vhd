library ieee;
use ieee.std_logic_1164.all;

entity i2c_interface_recv is
port (
		rst              : in std_logic;
		clk              : in std_logic;
		scl              : inout std_logic;
		sda              : inout std_logic;
		internal_addr    : out std_logic_vector(7 downto 0);
		internal_data    : out std_logic_vector(7 downto 0));
end i2c_interface_recv;

architecture behave of i2c_interface_recv is
signal address_reg             : std_logic_vector(7 downto 0);
signal data_reg                : std_logic_vector(7 downto 0);

signal read_req                : std_logic;
signal data_to_master          : std_logic_vector(7 downto 0);
signal data_valid              : std_logic;
signal data_from_master        : std_logic_vector(7 downto 0);

signal count                   : integer range 0 to 11 := 0;
signal count_call              : integer range 0 to 3  := 0;
signal data_valid_rem          : std_logic := '0';

signal scl_delay               : std_logic;
signal scl_rising              : std_logic := '0';
signal scl_falling             : std_logic := '0';

begin

--------------------------------------------------------
--i2c interface
--------------------------------------------------------

 I2C : entity work.i2c_slave
	generic map (
					SLAVE_ADDR => "1010101")
	port map (
					scl  =>  scl,
					sda  =>  sda,
					clk  =>  clk,
					rst  =>  rst,
					
					read_req => read_req,
					data_to_master => data_to_master,
					data_valid => data_valid,
					data_from_master => data_from_master);

	--------------------------------------------------------
	--Determine rising_edge and falling_edge of scl
	--------------------------------------------------------
	
	rise_fall_scl : process(clk) is
	begin
	scl_delay <= scl;
	if rising_edge(clk) then
		
		if scl_delay = '0' and scl = '1' then
		--if (!scl_delay & scl) then
			scl_rising <= '1';
			scl_falling<= '0';
		elsif scl_delay = '1' and scl = '0' then
			scl_rising <= '0';
			scl_falling<= '1';
		else
			scl_falling<= '0';
			scl_rising <= '0';
		end if;
	end if;
	end process rise_fall_scl;
	
	--------------------------------------------------------
	--To count with scl signal
	--------------------------------------------------------
					
	scl_counter : process(data_valid, scl, clk) is
	begin
	if rising_edge(clk) then
		if data_valid = '1' then
			data_valid_rem <= '1';
		elsif count = 11 then
			data_valid_rem <= '0';
			count <= 0;
		end if;
		
		if scl_rising = '1' then
			if data_valid_rem = '1' then
				count <= count + 1;
			end if;
		end if;
	end if;
	
	end process scl_counter;
	
	--------------------------------------------------------
	--Get internal address into register
	--------------------------------------------------------
					
	internal_address : process(data_valid, count, clk) is
	begin
	if rising_edge(clk) then
		if data_valid = '1' then
			if count = 1 then
				address_reg <= data_from_master;
			elsif count_call = 3 then
				address_reg <= (others => '0');
			end if;
		end if;
	end if;
	end process internal_address;
	
	--------------------------------------------------------
	--Get data into register
	--------------------------------------------------------
	
	datafrom_master : process(data_valid, count, clk) is
	begin
	if rising_edge(clk) then
		if data_valid = '1' then
			if count /= 1 then
				data_reg <= data_from_master;
			elsif count_call = 3 then
				data_reg <= (others => '0');
			end if;
		end if;
	end if;
	end process datafrom_master;
	
	--------------------------------------------------------
	--To clear the internal_address and data_reg
	--if another i2c is called
	--------------------------------------------------------
	
	clear_for_other_i2c_call : process(data_valid, count, count_call, clk) is
	begin
	if rising_edge(clk) then
		if data_valid = '1' then
			if count = 1 then
				count_call <= 1;
			else
				count_call <= count_call + 1;
			end if;
		end if;
		
		if count_call = 3 then
			count_call  <= 0;
		end if;
	end if;
	
	end process clear_for_other_i2c_call;
	
	internal_addr    <= address_reg;
	internal_data    <= data_reg;
	
end behave;