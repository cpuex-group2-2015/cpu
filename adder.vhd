library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity adder is
	port (
		adder_a	: in  std_logic_vector (31 downto 0);
		adder_b	: in  std_logic_vector (31 downto 0);
		adder_s	: out std_logic_vector (31 downto 0)
	);
end adder;

architecture struct of adder is
begin

	adder_s <= adder_a + adder_b;

end;