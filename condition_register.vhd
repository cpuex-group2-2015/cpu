library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity condition_register is
	port (
		clk               : in  std_logic;
		cr_g_write_enable : in  std_logic;
		cr_f_write_enable : in  std_logic;
		cr_in_g           : in  std_logic_vector (2 downto 0);
		cr_in_f           : in  std_logic;
		cr_out            : out std_logic_vector (3 downto 0)
	);
end condition_register;

architecture struct of condition_register is

	signal cr : std_logic_vector (3 downto 0);

begin

	cr_out <= cr;

	process (clk)
	begin
		if rising_edge(clk) then
			if (cr_g_write_enable = '1') then
				cr(3 downto 1) <= cr_in_g;
			end if;
			if (cr_f_write_enable = '1') then
				cr(0) <= cr_in_f;
			end if;
		end if;
	end process;

end;