library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sender is
	port (
		clk         : in  std_logic;
		sender_send : in  std_logic;
		sender_in   : in  std_logic_vector (31 downto 0);
		sender_full : out std_logic;
		sender_out  : out std_logic := '1'
	);
end sender;

architecture struct of sender is

	component fifo32_send
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

	type state_t is (ready, sending_start_bit, sending_data, sending_stop_bit);
	signal state : state_t := ready;

	signal count : std_logic_vector (15 downto 0) := (others=> '0');

	signal bit_count  : integer := 0;
	signal byte_count : integer := 0;

	signal send_buf : std_logic_vector (31 downto 0) := (others => '0');

begin

	fifo : fifo32_send port map (
		clk   => clk,
		wr_en => fifo_wr_en,
		rd_en => fifo_rd_en,
		din   => fifo_din,
		dout  => fifo_dout,
		full  => fifo_full,
		empty => fifo_empty
	);

	sender_full <= fifo_full;
	fifo_wr_en <= sender_send;
	fifo_din <= sender_in;

	-- send
	process (clk)

		variable fifo_rd_en_tmp : std_logic := '0';

	begin
		if rising_edge(clk) then

			fifo_rd_en_tmp := '0';

			case state is
			when ready =>	-- fetch data from fifo
				sender_out <= '1';
				if (fifo_empty = '0') then
					fifo_rd_en_tmp := '1';
					send_buf       <= fifo_dout;
					state          <= sending_start_bit;
				end if;
			when sending_start_bit =>
				sender_out <= '0';
				if (count = x"1B16") then
					state <= sending_data;
					count <= x"0000";
				else
					count <= count + 1;
				end if;
			when sending_data =>
				sender_out <= send_buf(byte_count * 8 + bit_count);
				if (count = x"1B16") then
					if (bit_count = 7) then
						state <= sending_stop_bit;
						bit_count <= 0;
					else
						bit_count <= bit_count + 1;
					end if;
					count <= x"0000";
				else
					count <= count + 1;
				end if;
			when sending_stop_bit =>
				sender_out <= '1';
				if (count = x"1B16") then
					if (byte_count = 3) then
						state <= ready;
						byte_count <= 0;
					else
						state <= sending_start_bit;
						byte_count <= byte_count + 1;
					end if;
					count <= x"0000";
				else
					count <= count + 1;
				end if;
			when others =>
				sender_out <= '1';
				state <= ready;
			end case;

			fifo_rd_en <= fifo_rd_en_tmp;
		end if;
	end process;

end;