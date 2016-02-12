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

	signal body_in1 : std_logic_vector (31 downto 0) := (others => '0');
	signal body_in2 : std_logic_vector (31 downto 0) := (others => '0');
	signal body_out : std_logic_vector (31 downto 0) := (others => '0');

	type inputs is array(0 to 3) of std_logic_vector (31 downto 0);
	signal inputs1 : inputs := (others => (others => '0'));
	signal inputs2 : inputs := (others => (others => '0'));

begin

	fadd_body : FADD port map (
		CLK     => clk,
		input_a => body_in1,
		input_b => body_in2,
		output  => body_out
	);

	body_in1 <= fadd_in1;
	body_in2 <= (not fadd_in2(31)) & fadd_in2(30 downto 0) when fadd_op = FADD_OP_SUB else fadd_in2;

	fadd_out <= inputs1(3) when (inputs2(3)(30 downto 23) = "00000000")
		   else inputs2(3) when (inputs1(3)(30 downto 23) = "00000000")
		   else body_out;

	process(clk)
	begin
		if (rising_edge(clk)) then
			inputs1(0) <= fadd_in1;
			if (fadd_op = FADD_OP_SUB) then
				inputs2(0) <= (not fadd_in2(31)) & fadd_in2(30 downto 0);
			else
				inputs2(0) <= fadd_in2;
			end if;

			inputs1(1) <= inputs1(0);
			inputs2(1) <= inputs2(0);
			inputs1(2) <= inputs1(1);
			inputs2(2) <= inputs2(1);
			inputs1(3) <= inputs1(2);
			inputs2(3) <= inputs2(2);
		end if;
	end process ;
end;
