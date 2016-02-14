library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity floating_point_registers is
	port (
		clk              : in  std_logic;
		fpr_write_enable : in  std_logic;
		fpr_reg_num1     : in  std_logic_vector (4 downto 0);
		fpr_reg_num2     : in  std_logic_vector (4 downto 0);
		fpr_reg_num3     : in  std_logic_vector (4 downto 0);
		fpr_reg_numw     : in  std_logic_vector (4 downto 0);
		fpr_data_in      : in  std_logic_vector (31 downto 0);
		fpr_data_out1    : out std_logic_vector (31 downto 0);
		fpr_data_out2    : out std_logic_vector (31 downto 0);
		fpr_data_out3    : out std_logic_vector (31 downto 0)
	);
end floating_point_registers;

architecture struct of floating_point_registers is

	type regs32_32 is array(0 to 31) of std_logic_vector (31 downto 0);
	signal fpr : regs32_32 := (others => (others => '0'));

begin

	fpr_data_out1 <= fpr_data_in when fpr_write_enable = '1' and fpr_reg_num1 = fpr_reg_numw else fpr(conv_integer(fpr_reg_num1));
	fpr_data_out2 <= fpr_data_in when fpr_write_enable = '1' and fpr_reg_num2 = fpr_reg_numw else fpr(conv_integer(fpr_reg_num2));
	fpr_data_out3 <= fpr_data_in when fpr_write_enable = '1' and fpr_reg_num3 = fpr_reg_numw else fpr(conv_integer(fpr_reg_num3));

	fpr(conv_integer(fpr_reg_numw)) <= fpr_data_in when rising_edge(clk) and fpr_write_enable = '1';

end;