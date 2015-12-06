library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity general_purpose_registers is
	port (
		clk               : in  std_logic;
		gpr_write_enable  : in  std_logic;
		gpr_read_reg_num1 : in  std_logic_vector (4 downto 0);
		gpr_read_reg_num2 : in  std_logic_vector (4 downto 0);
		gpr_read_reg_num3 : in  std_logic_vector (4 downto 0);
		gpr_write_reg_num : in  std_logic_vector (4 downto 0);
		gpr_write_data    : in  std_logic_vector (31 downto 0);
		gpr_read_data1    : out std_logic_vector (31 downto 0);
		gpr_read_data2    : out std_logic_vector (31 downto 0);
		gpr_read_data3    : out std_logic_vector (31 downto 0)
	);
end general_purpose_registers;

architecture struct of general_purpose_registers is

	type regs32_32 is array(0 to 31) of std_logic_vector (31 downto 0);
	signal gpr : regs32_32 := (others => (others => '0'));

begin

	gpr_read_data1 <= gpr(conv_integer(gpr_read_reg_num1));
	gpr_read_data2 <= gpr(conv_integer(gpr_read_reg_num2));
	gpr_read_data3 <= gpr(conv_integer(gpr_read_reg_num3));

	gpr(conv_integer(gpr_write_reg_num)) <= gpr_write_data when rising_edge(clk) and gpr_write_enable = '1' and gpr_write_reg_num /= "00000";

end;