library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.types.all;

entity compare_unit is
    port (
        gp_in1  : in  std_logic_vector (31 downto 0);
        gp_in2  : in  std_logic_vector (31 downto 0);
        fp_in1  : in  std_logic_vector (31 downto 0);
        fp_in2  : in  std_logic_vector (31 downto 0);
        gp_cond : out std_logic_vector (2 downto 0);
        fp_cond : out std_logic_vector (3 downto 0)
    );
end compare_unit;

architecture struct of compare_unit is
begin

    gp_cond <=
        COND_LT when ((gp_in1(31) = gp_in2(31) and gp_in1(30 downto 0) < gp_in2(30 downto 0)) or (gp_in1(31) = '1' and gp_in2(31) = '0')) else
        COND_GT when ((gp_in1(31) = gp_in2(31) and gp_in1(30 downto 0) > gp_in2(30 downto 0)) or (gp_in1(31) = '0' and gp_in2(31) = '1')) else
        COND_EQ;

    fp_cond <=
        "0001"        when ((fp_in1(30 downto 23) = "11111111" and fp_in1(22 downto 0) /= "00000000000000000000000")  or
                            (fp_in2(30 downto 23) = "11111111" and fp_in2(22 downto 0) /= "00000000000000000000000")) else
        COND_EQ & '0' when  (fp_in1(30 downto 0) = "000000000000000000000000000000"  and
                             fp_in2(30 downto 0) = "000000000000000000000000000000") else
        COND_LT & '0' when ((fp_in1(31) = '0' and fp_in2(31) = '0' and fp_in1(30 downto 0) < fp_in2(30 downto 0)) or
                            (fp_in1(31) = '1' and fp_in2(31) = '1' and fp_in1(30 downto 0) > fp_in2(30 downto 0)) or
                            (fp_in1(31) = '1' and fp_in2(31) = '0')) else
        COND_GT & '0' when ((fp_in1(31) = '0' and fp_in2(31) = '0' and fp_in1(30 downto 0) > fp_in2(30 downto 0)) or
                            (fp_in1(31) = '1' and fp_in2(31) = '1' and fp_in1(30 downto 0) < fp_in2(30 downto 0)) or
                            (fp_in1(31) = '0' and fp_in2(31) = '1')) else
        COND_EQ & '0';

end;
