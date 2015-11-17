library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity program_counter is
	port (
		clk		: in  std_logic;
		pc_in	: in  std_logic_vector (31 downto 0);
		pc_out	: out std_logic_vector (31 downto 0)
	);
end program_counter;

architecture struct of program_counter is

	signal pc : std_logic_vector (31 downto 0) := (others => '0');

begin

	pc_out <= pc;

	process (clk)
	begin
		if rising_edge(clk) then
			pc <= pc_in;
		end if;
	end process;

end;