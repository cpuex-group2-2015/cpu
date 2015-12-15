library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity multi_plexer8 is
	port (
		sel		: in  std_logic_vector (2 downto 0);
		mux_in0	: in  std_logic_vector (31 downto 0);
		mux_in1	: in  std_logic_vector (31 downto 0);
		mux_in2	: in  std_logic_vector (31 downto 0);
		mux_in3	: in  std_logic_vector (31 downto 0);
		mux_in4	: in  std_logic_vector (31 downto 0);
		mux_in5	: in  std_logic_vector (31 downto 0);
		mux_in6	: in  std_logic_vector (31 downto 0);
		mux_in7	: in  std_logic_vector (31 downto 0);
		mux_out	: out std_logic_vector (31 downto 0)
	);
end multi_plexer8;

architecture struct of multi_plexer8 is
begin

	mux_out <= mux_in0 when sel = "000"
	else       mux_in1 when sel = "001"
	else       mux_in2 when sel = "010"
	else       mux_in3 when sel = "011"
	else       mux_in4 when sel = "100"
	else       mux_in5 when sel = "101"
	else       mux_in6 when sel = "110"
	else       mux_in7;

end;