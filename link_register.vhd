library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity link_register is
	port (
		clk             : in  std_logic;
		lr_write_enable : in  std_logic;
		lr_in           : in  std_logic_vector (31 downto 0);
		lr_out          : out std_logic_vector (31 downto 0)
	);
end link_register;

architecture struct of link_register is

	signal lr : std_logic_vector (31 downto 0) := "00000000000000000000000000000000";

begin

	lr_out <= lr;

	process (clk)
	begin
		if (rising_edge(clk) and lr_write_enable = '1') then
			lr <= lr_in;
		end if;
	end process;

end;