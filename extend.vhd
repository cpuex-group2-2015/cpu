library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.types.all;

entity extend is
	port (
		ext_op  : in  ext_op_t;
		ext_in  : in  std_logic_vector (15 downto 0);
		ext_out : out std_logic_vector (31 downto 0)
	);
end extend;

architecture struct of extend is
begin

	ext_out <= "0000000000000000"  & ext_in                                   when ext_op = ext_op_unsigned								-- EXT(D)
	else       "00000000000000000" & ext_in(14 downto 0)                      when ext_op = ext_op_signed         and ext_in(15) = '0'	-- EXTS(D)
	else       "11111111111111111" & ext_in(14 downto 0)                      when ext_op = ext_op_signed         and ext_in(15) = '1'	-- EXTS(D)
	else       "0"                 & ext_in(14 downto 0) & "0000000000000000" when ext_op = ext_op_signed_shifted and ext_in(15) = '0'	-- EXTS(D || 0x0000)
	else       "1"                 & ext_in(14 downto 0) & "0000000000000000" when ext_op = ext_op_signed_shifted and ext_in(15) = '1'	-- EXTS(D || 0x0000)
	else       "0000000000000000"  & ext_in;

end;