library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.types.all;

entity fadd_fsub is
	port (
		clk       : in  std_logic;
		fadd_op   : in  std_logic;
		fadd_in1  : in  std_logic_vector (31 downto 0);
		fadd_in2  : in  std_logic_vector (31 downto 0);
		fadd_out  : out std_logic_vector (31 downto 0)
	);
end fadd_fsub;

architecture struct of fadd_fsub is

	component FADD is
		port (
			CLK     : in  std_logic;
			input_a : in  std_logic_vector (31 downto 0);
			input_b : in  std_logic_vector (31 downto 0);
			output  : out std_logic_vector (31 downto 0)
		);
	end component;

	signal body_in2 : std_logic_vector (31 downto 0) := (others => '0');

begin

	fadd_body : FADD port map (
		CLK     => clk,
		input_a => fadd_in1,
		input_b => body_in2,
		output  => fadd_out
	);

	body_in2 <= (not fadd_in2(31)) & fadd_in2(30 downto 0) when fadd_op = FADD_OP_SUB else fadd_in2;

end;
