library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.types.all;

entity floating_point_unit is
	port (
		fpu_op   : in  std_logic_vector (1 downto 0);
		fpu_in1  : in  std_logic_vector (31 downto 0);
		fpu_in2  : in  std_logic_vector (31 downto 0);
		fpu_out  : out std_logic_vector (31 downto 0)
	);
end floating_point_unit;

architecture struct of floating_point_unit is
begin

	process(fpu_op, fpu_in1, fpu_in2)
	begin
		case fpu_op is
		when FPU_OP_BYPASS =>
			fpu_out  <= fpu_in2;
		when FPU_OP_NEG =>
			fpu_out  <= (not fpu_in2(31)) & fpu_in2(30 downto 0);
		when FPU_OP_ABS =>
			fpu_out <= '0' & fpu_in2(30 downto 0);
		when others =>
			fpu_out <= fpu_in1;
 		end case;
	end process;

end;
