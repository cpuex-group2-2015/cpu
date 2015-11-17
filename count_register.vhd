library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity count_register is
	port (
		clk              : in  std_logic;
		ctr_write_enable : in  std_logic;
		ctr_in           : in  std_logic_vector (31 downto 0);
		ctr_out          : out std_logic_vector (31 downto 0)
	);
end count_register;

architecture struct of count_register is

	signal ctr : std_logic_vector (31 downto 0);

begin

	ctr_out <= ctr;

	process (clk)
	begin
		if (rising_edge(clk) and ctr_write_enable = '1') then
			ctr <= ctr_in;
		end if;
	end process;

end;