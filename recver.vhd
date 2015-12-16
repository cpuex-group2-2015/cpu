library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity recver is
	port (
		clk          : in  std_logic;
		recver_recv  : in  std_logic;
		recver_in    : in  std_logic;
		recver_empty : out std_logic;
		recver_out   : out std_logic_vector (31 downto 0)
	);
end recver;

architecture struct of recver is

	component fifo32_recv
		port (
			clk   : in  std_logic;
			wr_en : in  std_logic;
			rd_en : in  std_logic;
			din   : in  std_logic_vector (31 downto 0);
			dout  : out std_logic_vector (31 downto 0);
			full  : out std_logic;
			empty : out std_logic
		);
	end component;

	signal fifo_wr_en : std_logic                      := '0';
	signal fifo_rd_en : std_logic                      := '0';
	signal fifo_din   : std_logic_vector (31 downto 0) := (others => '0');
	signal fifo_dout  : std_logic_vector (31 downto 0);
	signal fifo_full  : std_logic;
	signal fifo_empty : std_logic;

	type state_t is (ready, recving_start_bit, recving_data, recving_stop_bit);
	signal state : state_t := ready;

	signal count : std_logic_vector (15 downto 0) := (others=> '0');

	signal bit_count  : integer := 0;
	signal byte_count : integer := 0;

	signal recv_buf : std_logic_vector (31 downto 0) := (others => '0');

begin

	fifo : fifo32_recv port map (
		clk   => clk,
		wr_en => fifo_wr_en,
		rd_en => fifo_rd_en,
		din   => fifo_din,
		dout  => fifo_dout,
		full  => fifo_full,
		empty => fifo_empty
	);

	recver_empty <= fifo_empty;
	recver_out <= fifo_dout;

	fifo_rd_en <= recver_recv when (fifo_empty = '0')
		else '0';

	fifo_din <= recv_buf;

	-- recv
	process (clk)

		variable fifo_wr_en_tmp : std_logic := '0';

	begin
		if rising_edge(clk) then

			fifo_wr_en_tmp := '0';

			case state is
			when ready =>	-- waiting for start bit
				if (recver_in = '0') then
					state          <= recving_start_bit;
				end if;
			when recving_start_bit =>
				if (count = x"0D8B") then
					state <= recving_data;
					count <= x"0000";
				else
					count <= count + 1;
				end if;
			when recving_data =>
				if (count = x"1B16") then
					recv_buf(byte_count * 8 + bit_count) <= recver_in;
					if (bit_count = 7) then
						state <= recving_stop_bit;
						bit_count <= 0;
					else
						bit_count <= bit_count + 1;
					end if;
					count <= x"0000";
				else
					count <= count + 1;
				end if;
			when recving_stop_bit =>
				if (count = x"1B16") then
					state <= ready;
					if (byte_count = 3) then
						fifo_wr_en_tmp := '1';
						byte_count <= 0;
					else
						byte_count <= byte_count + 1;
					end if;
					count <= x"0000";
				else
					count <= count + 1;
				end if;
			when others =>
				state <= ready;
			end case;

			fifo_wr_en <= fifo_wr_en_tmp;
		end if;
	end process;

end;