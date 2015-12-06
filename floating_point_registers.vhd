library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity floating_point_registers is
	port (
		clk               : in  std_logic;
		fpr_write_enable  : in  std_logic;
		fpr_read_reg_num1 : in  std_logic_vector (4 downto 0);
		fpr_read_reg_num2 : in  std_logic_vector (4 downto 0);
		fpr_read_reg_num3 : in  std_logic_vector (4 downto 0);
		fpr_write_reg_num : in  std_logic_vector (4 downto 0);
		fpr_write_data    : in  std_logic_vector (31 downto 0);
		fpr_read_data1    : out std_logic_vector (31 downto 0);
		fpr_read_data2    : out std_logic_vector (31 downto 0);
		fpr_read_data3    : out std_logic_vector (31 downto 0)
	);
end floating_point_registers;

architecture struct of floating_point_registers is

	type regs32_32 is array(0 to 31) of std_logic_vector (31 downto 0);
	signal fpr : regs32_32 := (others => (others => '0'));

begin

	fpr_read_data1 <= fpr(conv_integer(fpr_read_reg_num1));
	fpr_read_data2 <= fpr(conv_integer(fpr_read_reg_num2));
	fpr_read_data3 <= fpr(conv_integer(fpr_read_reg_num3));

	fpr(conv_integer(fpr_write_reg_num)) <= fpr_write_data when rising_edge(clk) and fpr_write_enable = '1';

end;