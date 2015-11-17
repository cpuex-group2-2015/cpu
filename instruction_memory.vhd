library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity instruction_memory is
	port (
		clk					: in  std_logic;
		instruction_address	: in  std_logic_vector (13 downto 0);
		instruction			: out std_logic_vector (31 downto 0)
	);
end instruction_memory;

architecture struct of instruction_memory is

	component block_ram is
		port (
			clka  : in  std_logic;
			addra : in  std_logic_vector (13 downto 0);
			douta : out std_logic_vector (31 downto 0)
		);
	end component;

begin

	bram : block_ram port map (
		clka  => clk,
		addra => instruction_address,
		douta => instruction
	);

end;