library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity floating_point_unit is
	port (
		fpu_op   : in  std_logic_vector (1 downto 0);
		fpu_in1  : in  std_logic_vector (31 downto 0);
		fpu_in2  : in  std_logic_vector (31 downto 0);
		fpu_cond : out std_logic_vector (3 downto 0);
		fpu_out  : out std_logic_vector (31 downto 0)
	);
end floating_point_unit;

-- fpu_op
-- 00 : bypass
-- 01 : neg
-- 10 : abs
-- 11 : cmp

architecture struct of floating_point_unit is
begin

	process(fpu_op, fpu_in1, fpu_in2)
	begin
		case fpu_op is
		when "00" =>						-- bypass
			fpu_out  <= fpu_in2;
			fpu_cond <= "0000";
		when "01" =>						-- neg
			fpu_out  <= (not fpu_in2(31)) & fpu_in2(30 downto 0);
			fpu_cond <= "0000";
		when "10" =>						-- abs
			fpu_out <= '0' & fpu_in2(30 downto 0);
			fpu_cond <= "0000";
		when "11" =>						-- cmp
			fpu_out <= fpu_in2;

			-- NaN
			if ((fpu_in1(30 downto 23) = "11111111" and fpu_in1(22 downto 0) /= "00000000000000000000000") or (fpu_in2(30 downto 23) = "11111111" and fpu_in2(22 downto 0) /= "00000000000000000000000")) then
				fpu_cond <= "0001";

			-- fpu_in1 = fpu_in2 = 0
			elsif (fpu_in1(30 downto 0) = "000000000000000000000000000000" and fpu_in2(30 downto 0) = "000000000000000000000000000000") then
				fpu_cond <= "0010";				

			-- fpu_in1 < fpu_in2
			elsif ((fpu_in1(31) = '0' and fpu_in2(31) = '0' and fpu_in1(30 downto 0) < fpu_in2(30 downto 0))
				or (fpu_in1(31) = '1' and fpu_in2(31) = '1' and fpu_in1(30 downto 0) > fpu_in2(30 downto 0))
				or (fpu_in1(31) = '1' and fpu_in2(31) = '0')) then
				fpu_cond <= "1000";
			
			-- fpu_in1 > fpu_in2
			elsif ((fpu_in1(31) = '0' and fpu_in2(31) = '0' and fpu_in1(30 downto 0) > fpu_in2(30 downto 0))
				or (fpu_in1(31) = '1' and fpu_in2(31) = '1' and fpu_in1(30 downto 0) < fpu_in2(30 downto 0))
				or (fpu_in1(31) = '0' and fpu_in2(31) = '1')) then
				fpu_cond <= "0100";
			
			-- fpu_in1 = fpu_in2
			else
				fpu_cond <= "0010";
			end if;
		when others =>
			fpu_out <= fpu_in1;
			fpu_cond <= "0000";
 		end case;
	end process;

end;