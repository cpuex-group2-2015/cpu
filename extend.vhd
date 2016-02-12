library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.types.all;

entity extend is
	port (
		ext_op  : in  std_logic_vector (1 downto 0);
		ext_in  : in  std_logic_vector (15 downto 0);
		ext_out : out std_logic_vector (31 downto 0)
	);
end extend;

-- ext_op
-- 00 : 16bit           -> 32bit, unsigned
-- 01 : 16bit           -> 32bit, signed
-- 10 : 16bit || 0x0000 -> 32bit, signed

architecture struct of extend is
begin

	ext_out <= "0000000000000000"  & ext_in                                   when ext_op = EXT_OP_UNSIGNED                            else
	           "00000000000000000" & ext_in(14 downto 0)                      when ext_op = EXT_OP_SIGNED         and ext_in(15) = '0' else
	           "11111111111111111" & ext_in(14 downto 0)                      when ext_op = EXT_OP_SIGNED         and ext_in(15) = '1' else
	           "0"                 & ext_in(14 downto 0) & "0000000000000000" when ext_op = EXT_OP_SIGNED_SHIFTED and ext_in(15) = '0' else
	           "1"                 & ext_in(14 downto 0) & "0000000000000000" when ext_op = EXT_OP_SIGNED_SHIFTED and ext_in(15) = '1' else
	           "0000000000000000"  & ext_in;

end;
