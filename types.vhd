library ieee;
use ieee.std_logic_1164.all;

package types is

    constant OP_LD    : std_logic_vector (5 downto 0) := "100000";
    constant OP_ST    : std_logic_vector (5 downto 0) := "100100";
    constant OP_ADDI  : std_logic_vector (5 downto 0) := "001110";
    constant OP_ADDIS : std_logic_vector (5 downto 0) := "001111";
    constant OP_ANDI  : std_logic_vector (5 downto 0) := "011100";
    constant OP_ORI   : std_logic_vector (5 downto 0) := "011001";
    constant OP_CMPI  : std_logic_vector (5 downto 0) := "001011";
    constant OP_CMP   : std_logic_vector (5 downto 0) := "011110";
    constant OP_B     : std_logic_vector (5 downto 0) := "010010";
    constant OP_BC    : std_logic_vector (5 downto 0) := "010000";
    constant OP_BLR   : std_logic_vector (5 downto 0) := "010011";
    constant OP_BCTR  : std_logic_vector (5 downto 0) := "010100";
    constant OP_LDF   : std_logic_vector (5 downto 0) := "110010";
    constant OP_STF   : std_logic_vector (5 downto 0) := "110100";
    constant OP_SEND  : std_logic_vector (5 downto 0) := "000001";
    constant OP_RECV  : std_logic_vector (5 downto 0) := "000010";
    constant OP_MFGTF : std_logic_vector (5 downto 0) := "010101";
    constant OP_MFFTG : std_logic_vector (5 downto 0) := "010110";
    constant OP_3OP   : std_logic_vector (5 downto 0) := "011111";
    constant OP_FP    : std_logic_vector (5 downto 0) := "111111";

    constant SUB_OP_LDX   : std_logic_vector (9 downto 0) := "0000010111";
    constant SUB_OP_STX   : std_logic_vector (9 downto 0) := "0010010111";
    constant SUB_OP_ADD   : std_logic_vector (9 downto 0) := "0100001010";
    constant SUB_OP_NEG   : std_logic_vector (9 downto 0) := "0001101000";
    constant SUB_OP_AND   : std_logic_vector (9 downto 0) := "0000011100";
    constant SUB_OP_OR    : std_logic_vector (9 downto 0) := "0110111100";
    constant SUB_OP_MTLR  : std_logic_vector (9 downto 0) := "0111010011";
    constant SUB_OP_MFLR  : std_logic_vector (9 downto 0) := "0101010011";
    constant SUB_OP_MTCTR : std_logic_vector (9 downto 0) := "0111010100";
    constant SUB_OP_LDFX  : std_logic_vector (9 downto 0) := "1001010111";
    constant SUB_OP_STFX  : std_logic_vector (9 downto 0) := "1010010111";
    constant SUB_OP_FMR   : std_logic_vector (9 downto 0) := "0001001000";
    constant SUB_OP_FADD  : std_logic_vector (9 downto 0) := "0000010101";
    constant SUB_OP_FSUB  : std_logic_vector (9 downto 0) := "0000010100";
    constant SUB_OP_FMUL  : std_logic_vector (9 downto 0) := "0000011001";
    constant SUB_OP_FINV  : std_logic_vector (9 downto 0) := "0000010010";
    constant SUB_OP_FNEG  : std_logic_vector (9 downto 0) := "0000101000";
    constant SUB_OP_FABS  : std_logic_vector (9 downto 0) := "0100001000";
    constant SUB_OP_FCMP  : std_logic_vector (9 downto 0) := "0000000000";
    constant SUB_OP_SL    : std_logic_vector (9 downto 0) := "0000011000";
    constant SUB_OP_SR    : std_logic_vector (9 downto 0) := "1000011000";

    constant COND_EQ : std_logic_vector (2 downto 0) := "001";
    constant COND_GT : std_logic_vector (2 downto 0) := "010";
    constant COND_LT : std_logic_vector (2 downto 0) := "100";

    constant EXT_OP_UNSIGNED       : std_logic_vector (1 downto 0) := "00";	-- EXT(D)
    constant EXT_OP_SIGNED         : std_logic_vector (1 downto 0) := "01";	-- EXTS(D)
    constant EXT_OP_SIGNED_SHIFTED : std_logic_vector (1 downto 0) := "10";	-- EXTS(D || 0x0000)

    constant ALU_OP_ADD : std_logic_vector (2 downto 0) := "000";
    constant ALU_OP_NEG : std_logic_vector (2 downto 0) := "001";
    constant ALU_OP_AND : std_logic_vector (2 downto 0) := "010";
    constant ALU_OP_OR  : std_logic_vector (2 downto 0) := "011";
    constant ALU_OP_SL  : std_logic_vector (2 downto 0) := "100";
    constant ALU_OP_SR  : std_logic_vector (2 downto 0) := "101";
    constant ALU_OP_CMP : std_logic_vector (2 downto 0) := "110";

    constant FPU_OP_BYPASS : std_logic_vector (1 downto 0) := "00";
    constant FPU_OP_NEG    : std_logic_vector (1 downto 0) := "01";
    constant FPU_OP_ABS    : std_logic_vector (1 downto 0) := "10";
    constant FPU_OP_CMP    : std_logic_vector (1 downto 0) := "11";

    constant FADD_OP_ADD : std_logic := '0';
    constant FADD_OP_SUB : std_logic := '1';

    constant ALU_SRC_GPR : std_logic := '0';
    constant ALU_SRC_EXT : std_logic := '1';

    constant DMEM_SRC_GPR : std_logic := '0';
    constant DMEM_SRC_FPR : std_logic := '1';

    constant REGS_SRC_ALU  : std_logic_vector (2 downto 0) := "000";
    constant REGS_SRC_DMEM : std_logic_vector (2 downto 0) := "001";
    constant REGS_SRC_LR   : std_logic_vector (2 downto 0) := "010";
    constant REGS_SRC_RECV : std_logic_vector (2 downto 0) := "011";
    constant REGS_SRC_FPU  : std_logic_vector (2 downto 0) := "100";
    constant REGS_SRC_FADD : std_logic_vector (2 downto 0) := "101";
    constant REGS_SRC_FMUL : std_logic_vector (2 downto 0) := "110";
    constant REGS_SRC_FINV : std_logic_vector (2 downto 0) := "111";

    constant LR_SRC_PC  : std_logic := '0';
    constant LR_SRC_ALU : std_logic := '1';

    constant IA_SRC_PC  : std_logic_vector (1 downto 0) := "00";
    constant IA_SRC_LR  : std_logic_vector (1 downto 0) := "01";
    constant IA_SRC_CTR : std_logic_vector (1 downto 0) := "10";
    constant IA_SRC_EXT : std_logic_vector (1 downto 0) := "11";

    -- -- 9600, 66MHz
    -- constant WTIME_SEND      : std_logic_vector (15 downto 0) := x"1B16";
    -- constant WTIME_RECV      : std_logic_vector (15 downto 0) := x"1B16";
    -- constant WTIME_RECV_HALF : std_logic_vector (15 downto 0) := x"0D8B";
    --
    -- -- 115200, 66MHz
    -- constant WTIME_SEND      : std_logic_vector (15 downto 0) := x"0242";
    -- constant WTIME_RECV      : std_logic_vector (15 downto 0) := x"0242";
    -- constant WTIME_RECV_HALF : std_logic_vector (15 downto 0) := x"0121";
    --
    -- -- 115200, 77MHz
    -- constant WTIME_SEND      : std_logic_vector (15 downto 0) := x"02AF";
    -- constant WTIME_RECV      : std_logic_vector (15 downto 0) := x"0290";
    -- constant WTIME_RECV_HALF : std_logic_vector (15 downto 0) := x"0148";

    -- 115200, 88MHz
    constant WTIME_SEND      : std_logic_vector (15 downto 0) := x"02FF";
    constant WTIME_RECV      : std_logic_vector (15 downto 0) := x"02F0";
    constant WTIME_RECV_HALF : std_logic_vector (15 downto 0) := x"0178";

    -- -- 115200, 99MHz
    -- constant WTIME_SEND      : std_logic_vector (15 downto 0) := x"0360";
    -- constant WTIME_RECV      : std_logic_vector (15 downto 0) := x"0350";
    -- constant WTIME_RECV_HALF : std_logic_vector (15 downto 0) := x"01A8";

    constant FWD_SRC_REG      : std_logic_vector (3 downto 0) := "0000";
    constant FWD_SRC_ALU_MEM  : std_logic_vector (3 downto 0) := "0001";
    constant FWD_SRC_LR_MEM   : std_logic_vector (3 downto 0) := "0010";
    constant FWD_SRC_FPU_MEM  : std_logic_vector (3 downto 0) := "0011";
    constant FWD_SRC_FADD_MEM : std_logic_vector (3 downto 0) := "0100";
    constant FWD_SRC_FMUL_MEM : std_logic_vector (3 downto 0) := "0101";
    constant FWD_SRC_FINV_MEM : std_logic_vector (3 downto 0) := "0110";
    constant FWD_SRC_ALU_WB   : std_logic_vector (3 downto 0) := "1001";
    constant FWD_SRC_LR_WB    : std_logic_vector (3 downto 0) := "1010";
    constant FWD_SRC_FPU_WB   : std_logic_vector (3 downto 0) := "1011";
    constant FWD_SRC_FADD_WB  : std_logic_vector (3 downto 0) := "1100";
    constant FWD_SRC_FMUL_WB  : std_logic_vector (3 downto 0) := "1101";
    constant FWD_SRC_FINV_WB  : std_logic_vector (3 downto 0) := "1110";

end package;
