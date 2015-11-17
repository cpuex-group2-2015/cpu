library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity multi_plexer2 is
	port (
		sel		: in  std_logic;
		mux_in0	: in  std_logic_vector (31 downto 0);
		mux_in1	: in  std_logic_vector (31 downto 0);
		mux_out	: out std_logic_vector (31 downto 0)
	);
end multi_plexer2;

architecture struct of multi_plexer2 is
begin

	mux_out <= mux_in0 when sel = '0'
	else       mux_in1;

end;