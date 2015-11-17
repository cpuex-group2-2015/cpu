library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity extend is
	port (
		ext_op  : in  std_logic_vector (1 downto 0);
		ext_in  : in  std_logic_vector (15 downto 0);
		ext_out : out std_logic_vector (31 downto 0)
	);
end extend;

-- ext_op
-- 00 : 16bit         -> 32bit, unsigned
-- 01 : 16bit         -> 32bit, signed
-- 10 : 16bit || 00   -> 32bit, signed
-- 11 : 16bit || 0000 -> 32bit, signed

architecture struct of extend is
begin

	--process(ext_op, ext_in)
	--begin
	--	case ext_op is
	--	when "00" =>
	--		ext_out(31 downto 16) <= "0000000000000000";
	--		ext_out(15 downto 0)  <= ext_in;
	--	when "01" =>
	--		ext_out(31)           <= ext_in(15);
	--		ext_out(30 downto 15) <= "0000000000000000";
	--		ext_out(14 downto 0)  <= ext_in(14 downto 0);
	--	when "10" =>
	--		ext_out(31)           <= ext_in(15);
	--		ext_out(30 downto 17) <= "00000000000000";
	--		ext_out(16 downto 2)  <= ext_in(14 downto 0);
	--		ext_out(1 downto 0)   <= "00";
	--	when "11" =>
	--		ext_out(31)           <= ext_in(15);
	--		ext_out(30 downto 19) <= "000000000000";
	--		ext_out(18 downto 4)  <= ext_in(14 downto 0);
	--		ext_out(3 downto 0)   <= "0000";
	--	when others =>
	--		ext_out(31 downto 16) <= "0000000000000000";
	--		ext_out(15 downto 0)  <= ext_in;
	--	end case;
	--end process;

	ext_out <= "0000000000000000" & ext_in                                when ext_op = "00"
	else       ext_in(15) & "0000000000000000" & ext_in(14 downto 0)      when ext_op = "01"
	else       ext_in(15) & "00000000000000" & ext_in(14 downto 0) & "00" when ext_op = "10"
	else       ext_in(15) & "000000000000" & ext_in(14 downto 0) & "0000" when ext_op = "11"
	else       "0000000000000000" & ext_in;

end;