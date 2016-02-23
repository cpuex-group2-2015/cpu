library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cache_memory is
	port (
		clk                : in  std_logic;
		cache_write_enable : in  std_logic;
		cache_address      : in  std_logic_vector (17 downto 0);
		cache_data_in      : in  std_logic_vector (31 downto 0);
		cache_data_out     : out std_logic_vector (31 downto 0);
		cache_hit_miss     : out std_logic := '0'
	);
end cache_memory;

architecture struct of cache_memory is

	component tag_array is
		port (
			clka  : in  std_logic;
			wea   : in  std_logic_vector (0 downto 0);
			addra : in  std_logic_vector (9 downto 0);
			dina  : in  std_logic_vector (7 downto 0);
			douta : out std_logic_vector (7 downto 0)
		);
	end component;

	component data_array is
		port (
			clka  : in  std_logic;
			wea   : in  std_logic_vector (0 downto 0);
			addra : in  std_logic_vector (9 downto 0);
			dina  : in  std_logic_vector (31 downto 0);
			douta : out std_logic_vector (31 downto 0)
		);
	end component;

	signal tag1 : std_logic_vector (7 downto 0);
	signal tag2 : std_logic_vector (7 downto 0);

	signal index : std_logic_vector (9 downto 0);

	type valid_t is array (1023 downto 0) of std_logic;
	signal valid : valid_t := (others => '0');

begin

	tary : tag_array port map (
		clka   => clk,
		wea(0) => cache_write_enable,
		addra  => cache_address(9 downto 0),
		dina   => cache_address(17 downto 10),
		douta  => tag2
	);

	dary : data_array port map (
		clka   => clk,
		wea(0) => cache_write_enable,
		addra  => cache_address(9 downto 0),
		dina   => cache_data_in,
		douta  => cache_data_out
	);

	cache_hit_miss <= '1' when tag1 = tag2 and valid(conv_integer(index)) = '1' else '0';

	process (clk)
	begin
		if (rising_edge(clk)) then
			tag1  <= cache_address(17 downto 10);
			index <= cache_address(9 downto 0);

			if cache_write_enable = '1' then
				valid(conv_integer(cache_address(9 downto 0))) <= '1';
			end if;
		end if;
	end process;

end;