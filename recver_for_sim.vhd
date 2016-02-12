library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_textio.all;
use STD.TEXTIO.all;

use work.types.all;

entity recver_for_sim is
	port (
		clk          : in  std_logic;
		recver_in    : in  std_logic
	);
end recver_for_sim;

architecture struct of recver_for_sim is

	file text_out : text is out "out.txt";

	type state_t is (ready, recving_start_bit, recving_data, recving_stop_bit);
	signal state : state_t := ready;

	signal count : std_logic_vector (15 downto 0) := (others=> '0');

	signal bit_count : integer := 0;

	signal recv_buf : std_logic_vector (7 downto 0) := (others => '0');

begin

	-- recv
	process (clk)
		variable line_out : line;
	begin
		if rising_edge(clk) then
			case state is
			when ready =>	-- waiting for start bit
				if (recver_in = '0') then
					state          <= recving_start_bit;
				end if;
			when recving_start_bit =>
				if (count = WTIME_RECV_HALF) then
					state <= recving_data;
					count <= x"0000";
				else
					count <= count + 1;
				end if;
			when recving_data =>
				if (count = WTIME_RECV) then
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
				if (count = WTIME_RECV) then
					state <= ready;
					write(line_out, recv_buf, LEFT, 8);
					writeline(text_out, line_out);
					count <= x"0000";
				else
					count <= count + 1;
				end if;
			when others =>
				state <= ready;
			end case;
		end if;
	end process;

end;
