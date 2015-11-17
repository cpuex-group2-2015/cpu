library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity multi_plexer4 is
	port (
		sel		: in  std_logic_vector (1 downto 0);
		mux_in0	: in  std_logic_vector (31 downto 0);
		mux_in1	: in  std_logic_vector (31 downto 0);
		mux_in2	: in  std_logic_vector (31 downto 0);
		mux_in3	: in  std_logic_vector (31 downto 0);
		mux_out	: out std_logic_vector (31 downto 0)
	);
end multi_plexer4;

architecture struct of multi_plexer4 is
begin

	mux_out <= mux_in0 when sel = "00"
	else       mux_in1 when sel = "01"
	else       mux_in2 when sel = "10"
	else       mux_in3;

end;