library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.types.all;

entity arithmetic_logic_unit is
	port (
		alu_op   : in  std_logic_vector (2 downto 0);
		alu_in1  : in  std_logic_vector (31 downto 0);
		alu_in2  : in  std_logic_vector (31 downto 0);
		alu_out  : out std_logic_vector (31 downto 0)
	);
end arithmetic_logic_unit;

architecture struct of arithmetic_logic_unit is
begin

	process(alu_op, alu_in1, alu_in2)
	begin
		case alu_op is
		when ALU_OP_ADD =>
			alu_out  <= alu_in1 + alu_in2;
		when ALU_OP_NEG =>
			alu_out  <= (not alu_in1) + 1;
		when ALU_OP_AND =>
			alu_out <= alu_in1 and alu_in2;
		when ALU_OP_OR =>
			alu_out <= alu_in1 or alu_in2;
		when ALU_OP_SL =>
			case alu_in2(4 downto 0) is
			when "00000" => alu_out <= alu_in1;
			when "00001" => alu_out <= alu_in1(30 downto 0) & '0';
			when "00010" => alu_out <= alu_in1(29 downto 0) & "00";
			when "00011" => alu_out <= alu_in1(28 downto 0) & "000";
			when "00100" => alu_out <= alu_in1(27 downto 0) & "0000";
			when "00101" => alu_out <= alu_in1(26 downto 0) & "00000";
			when "00110" => alu_out <= alu_in1(25 downto 0) & "000000";
			when "00111" => alu_out <= alu_in1(24 downto 0) & "0000000";
			when "01000" => alu_out <= alu_in1(23 downto 0) & "00000000";
			when "01001" => alu_out <= alu_in1(22 downto 0) & "000000000";
			when "01010" => alu_out <= alu_in1(21 downto 0) & "0000000000";
			when "01011" => alu_out <= alu_in1(20 downto 0) & "00000000000";
			when "01100" => alu_out <= alu_in1(19 downto 0) & "000000000000";
			when "01101" => alu_out <= alu_in1(18 downto 0) & "0000000000000";
			when "01110" => alu_out <= alu_in1(17 downto 0) & "00000000000000";
			when "01111" => alu_out <= alu_in1(16 downto 0) & "000000000000000";
			when "10000" => alu_out <= alu_in1(15 downto 0) & "0000000000000000";
			when "10001" => alu_out <= alu_in1(14 downto 0) & "00000000000000000";
			when "10010" => alu_out <= alu_in1(13 downto 0) & "000000000000000000";
			when "10011" => alu_out <= alu_in1(12 downto 0) & "0000000000000000000";
			when "10100" => alu_out <= alu_in1(11 downto 0) & "00000000000000000000";
			when "10101" => alu_out <= alu_in1(10 downto 0) & "000000000000000000000";
			when "10110" => alu_out <= alu_in1( 9 downto 0) & "0000000000000000000000";
			when "10111" => alu_out <= alu_in1( 8 downto 0) & "00000000000000000000000";
			when "11000" => alu_out <= alu_in1( 7 downto 0) & "000000000000000000000000";
			when "11001" => alu_out <= alu_in1( 6 downto 0) & "0000000000000000000000000";
			when "11010" => alu_out <= alu_in1( 5 downto 0) & "00000000000000000000000000";
			when "11011" => alu_out <= alu_in1( 4 downto 0) & "000000000000000000000000000";
			when "11100" => alu_out <= alu_in1( 3 downto 0) & "0000000000000000000000000000";
			when "11101" => alu_out <= alu_in1( 2 downto 0) & "00000000000000000000000000000";
			when "11110" => alu_out <= alu_in1( 1 downto 0) & "000000000000000000000000000000";
			when "11111" => alu_out <= alu_in1( 0 downto 0) & "0000000000000000000000000000000";
			when others  => alu_out <= alu_in1;
			end case;
		when ALU_OP_SR =>
			case alu_in2(4 downto 0) is
			when "00000" => alu_out <= alu_in1;
			when "00001" => alu_out <= '0'                               & alu_in1(31 downto  1);
			when "00010" => alu_out <= "00"                              & alu_in1(31 downto  2);
			when "00011" => alu_out <= "000"                             & alu_in1(31 downto  3);
			when "00100" => alu_out <= "0000"                            & alu_in1(31 downto  4);
			when "00101" => alu_out <= "00000"                           & alu_in1(31 downto  5);
			when "00110" => alu_out <= "000000"                          & alu_in1(31 downto  6);
			when "00111" => alu_out <= "0000000"                         & alu_in1(31 downto  7);
			when "01000" => alu_out <= "00000000"                        & alu_in1(31 downto  8);
			when "01001" => alu_out <= "000000000"                       & alu_in1(31 downto  9);
			when "01010" => alu_out <= "0000000000"                      & alu_in1(31 downto 10);
			when "01011" => alu_out <= "00000000000"                     & alu_in1(31 downto 11);
			when "01100" => alu_out <= "000000000000"                    & alu_in1(31 downto 12);
			when "01101" => alu_out <= "0000000000000"                   & alu_in1(31 downto 13);
			when "01110" => alu_out <= "00000000000000"                  & alu_in1(31 downto 14);
			when "01111" => alu_out <= "000000000000000"                 & alu_in1(31 downto 15);
			when "10000" => alu_out <= "0000000000000000"                & alu_in1(31 downto 16);
			when "10001" => alu_out <= "00000000000000000"               & alu_in1(31 downto 17);
			when "10010" => alu_out <= "000000000000000000"              & alu_in1(31 downto 18);
			when "10011" => alu_out <= "0000000000000000000"             & alu_in1(31 downto 19);
			when "10100" => alu_out <= "00000000000000000000"            & alu_in1(31 downto 20);
			when "10101" => alu_out <= "000000000000000000000"           & alu_in1(31 downto 21);
			when "10110" => alu_out <= "0000000000000000000000"          & alu_in1(31 downto 22);
			when "10111" => alu_out <= "00000000000000000000000"         & alu_in1(31 downto 23);
			when "11000" => alu_out <= "000000000000000000000000"        & alu_in1(31 downto 24);
			when "11001" => alu_out <= "0000000000000000000000000"       & alu_in1(31 downto 25);
			when "11010" => alu_out <= "00000000000000000000000000"      & alu_in1(31 downto 26);
			when "11011" => alu_out <= "000000000000000000000000000"     & alu_in1(31 downto 27);
			when "11100" => alu_out <= "0000000000000000000000000000"    & alu_in1(31 downto 28);
			when "11101" => alu_out <= "00000000000000000000000000000"   & alu_in1(31 downto 29);
			when "11110" => alu_out <= "000000000000000000000000000000"  & alu_in1(31 downto 30);
			when "11111" => alu_out <= "0000000000000000000000000000000" & alu_in1(31 downto 31);
			when others  => alu_out <= alu_in1;
			end case;
		when others =>
			alu_out <= alu_in1;
 		end case;
	end process;

end;
