library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cache_memory is
	port (
		clk                : in  std_logic;
		cache_write_enable : in  std_logic;
		cache_address      : in  std_logic_vector (19 downto 0);
		cache_data_in      : in  std_logic_vector (31 downto 0);
		cache_data_out     : out std_logic_vector (31 downto 0);
		cache_hit_miss     : out std_logic := '0'
	);
end cache_memory;

architecture struct of cache_memory is

	type tag_t is array (7 downto 0) of std_logic_vector (16 downto 0);
	signal tag_array : tag_t := (others => (others => '0'));

	type data_t is array (7 downto 0) of std_logic_vector (31 downto 0);
	signal data_array : data_t := (others => (others => '0'));

begin

	--cache_hit_miss <= '1' when (cache_address(19 downto 3) = tag_array(conv_integer(cache_address(2 downto 0)))) else '0';
	cache_hit_miss <= '0';

	cache_data_out <= data_array(conv_integer(cache_address(2 downto 0)));

	process (clk, cache_write_enable, cache_address, cache_data_in)
	begin
		if (rising_edge(clk)) then
			if (cache_write_enable = '1') then
				tag_array(conv_integer(cache_address(2 downto 0)))  <= cache_address(19 downto 3);
				data_array(conv_integer(cache_address(2 downto 0))) <= cache_data_in;
			end if ;
		end if;
	end process;

end;