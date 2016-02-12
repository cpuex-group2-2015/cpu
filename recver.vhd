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

	component fifo8_recv
		port (
			clk   : in  std_logic;
			wr_en : in  std_logic;
			rd_en : in  std_logic;
			din   : in  std_logic_vector (7 downto 0);
			dout  : out std_logic_vector (7 downto 0);
			full  : out std_logic;
			empty : out std_logic
		);
	end component;

	signal fifo_wr_en : std_logic                     := '0';
	signal fifo_rd_en : std_logic                     := '0';
	signal fifo_din   : std_logic_vector (7 downto 0) := (others => '0');
	signal fifo_dout  : std_logic_vector (7 downto 0);
	signal fifo_full  : std_logic;
	signal fifo_empty : std_logic;

	type state_t is (ready, recving_start_bit, recving_data, recving_stop_bit);
	signal state : state_t := ready;

	--constant wtime2 : std_logic_vector (15 downto 0) := x"01A8";		-- 115200, 99MHz
	--constant wtime  : std_logic_vector (15 downto 0) := x"0350";		-- 115200, 99MHz
	--constant wtime2 : std_logic_vector (15 downto 0) := x"0178";		-- 115200, 88MHz
	--constant wtime  : std_logic_vector (15 downto 0) := x"02F0";		-- 115200, 88MHz
	--constant wtime2 : std_logic_vector (15 downto 0) := x"0148";		-- 115200, 77MHz
	--constant wtime  : std_logic_vector (15 downto 0) := x"0290";		-- 115200, 77MHz
	constant wtime2 : std_logic_vector (15 downto 0) := x"0121";		-- 115200, 66MHz
	constant wtime  : std_logic_vector (15 downto 0) := x"0242";		-- 115200, 66MHz
	--constant wtime2 : std_logic_vector (15 downto 0) := x"0D8B";		-- 9600, 66MHz
	--constant wtime  : std_logic_vector (15 downto 0) := x"1B16";		-- 9600, 66MHz

	signal count  : std_logic_vector (15 downto 0) := (others=> '0');

	signal bit_count  : integer := 0;

	signal recv_buf : std_logic_vector (7 downto 0) := (others => '0');

begin

	fifo : fifo8_recv port map (
		clk   => clk,
		wr_en => fifo_wr_en,
		rd_en => fifo_rd_en,
		din   => fifo_din,
		dout  => fifo_dout,
		full  => fifo_full,
		empty => fifo_empty
	);

	recver_empty <= fifo_empty;
	recver_out <= "000000000000000000000000" & fifo_dout;

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
				if (count = wtime2) then
					state <= recving_data;
					count <= x"0000";
				else
					count <= count + 1;
				end if;
			when recving_data =>
				if (count = wtime) then
					recv_buf(bit_count) <= recver_in;
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
				if (count = wtime) then
					state <= ready;
					fifo_wr_en_tmp := '1';
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