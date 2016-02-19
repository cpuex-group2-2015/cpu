library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity condition_register is
	port (
		clk                : in  std_logic;
		cr_gp_write_enable : in  std_logic;
		cr_fp_write_enable : in  std_logic;
		cr_gp_in           : in  std_logic_vector (2 downto 0);
		cr_fp_in           : in  std_logic_vector (3 downto 0);
		cr_out             : out std_logic_vector (3 downto 0)
	);
end condition_register;

architecture struct of condition_register is

	signal cr : std_logic_vector (3 downto 0) := "0000";

begin

	cr_out <=
		cr_gp_in & cr(0) when cr_gp_write_enable = '1' else
		cr_fp_in         when cr_fp_write_enable = '1' else
		cr;

	process (clk)
	begin
		if rising_edge(clk) then
			if (cr_gp_write_enable = '1') then
				cr(3 downto 1) <= cr_gp_in;
			end if;
			if (cr_fp_write_enable = '1') then
				cr <= cr_fp_in;
			end if;
		end if;
	end process;

end;