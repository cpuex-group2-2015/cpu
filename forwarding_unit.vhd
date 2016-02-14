library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.types.all;

entity forwarding_unit is
    port (
        clk             : in  std_logic;
        instruction_ex  : in  std_logic_vector (31 downto 0);
        instruction_mem : in  std_logic_vector (31 downto 0);
        instruction_wb  : in  std_logic_vector (31 downto 0);
        fwd_src1        : out std_logic_vector (3 downto 0) := (others => '0');
        fwd_src2        : out std_logic_vector (3 downto 0) := (others => '0');
        fwd_src3        : out std_logic_vector (3 downto 0) := (others => '0')
    );
end forwarding_unit;

architecture struct of forwarding_unit is

    signal opcode_ex     : std_logic_vector (5 downto 0) := (others => '0');
    signal sub_opcode_ex : std_logic_vector (9 downto 0) := (others => '0');
    signal op3_ex        : std_logic_vector (4 downto 0) := (others => '0');
    signal op1_ex        : std_logic_vector (4 downto 0) := (others => '0');
    signal op2_ex        : std_logic_vector (4 downto 0) := (others => '0');

    signal opcode_mem     : std_logic_vector (5 downto 0) := (others => '0');
    signal sub_opcode_mem : std_logic_vector (9 downto 0) := (others => '0');
    signal op3_mem        : std_logic_vector (4 downto 0) := (others => '0');
    signal op1_mem        : std_logic_vector (4 downto 0) := (others => '0');
    signal op2_mem        : std_logic_vector (4 downto 0) := (others => '0');

    signal opcode_wb     : std_logic_vector (5 downto 0) := (others => '0');
    signal sub_opcode_wb : std_logic_vector (9 downto 0) := (others => '0');
    signal op3_wb        : std_logic_vector (4 downto 0) := (others => '0');
    signal op1_wb        : std_logic_vector (4 downto 0) := (others => '0');
    signal op2_wb        : std_logic_vector (4 downto 0) := (others => '0');

    signal alu_to_gpr_mem  : boolean := false;
    signal alu_to_fpr_mem  : boolean := false;
    signal lr_to_gpr_mem   : boolean := false;
    signal lr_to_fpr_mem   : boolean := false;
    signal fpu_to_gpr_mem  : boolean := false;
    signal fpu_to_fpr_mem  : boolean := false;
    signal fadd_to_gpr_mem : boolean := false;
    signal fadd_to_fpr_mem : boolean := false;
    signal fmul_to_gpr_mem : boolean := false;
    signal fmul_to_fpr_mem : boolean := false;
    signal finv_to_gpr_mem : boolean := false;
    signal finv_to_fpr_mem : boolean := false;

    signal alu_to_gpr_wb   : boolean := false;
    signal alu_to_fpr_wb   : boolean := false;
    signal lr_to_gpr_wb    : boolean := false;
    signal lr_to_fpr_wb    : boolean := false;
    signal fpu_to_gpr_wb   : boolean := false;
    signal fpu_to_fpr_wb   : boolean := false;
    signal fadd_to_gpr_wb  : boolean := false;
    signal fadd_to_fpr_wb  : boolean := false;
    signal fmul_to_gpr_wb  : boolean := false;
    signal fmul_to_fpr_wb  : boolean := false;
    signal finv_to_gpr_wb  : boolean := false;
    signal finv_to_fpr_wb  : boolean := false;

    signal in1_gpr_ex : boolean := false;
    signal in1_fpr_ex : boolean := false;
    signal in2_gpr_ex : boolean := false;
    signal in2_fpr_ex : boolean := false;
    signal in3_gpr_ex : boolean := false;
    signal in3_fpr_ex : boolean := false;

begin

    opcode_ex     <= instruction_ex(31 downto 26);
    sub_opcode_ex <= instruction_ex(10 downto 1);
    op3_ex        <= instruction_ex(25 downto 21);
    op1_ex        <= instruction_ex(20 downto 16);
    op2_ex        <= instruction_ex(15 downto 11);

    opcode_mem     <= instruction_mem(31 downto 26);
    sub_opcode_mem <= instruction_mem(10 downto 1);
    op3_mem        <= instruction_mem(25 downto 21);
    op1_mem        <= instruction_mem(20 downto 16);
    op2_mem        <= instruction_mem(15 downto 11);
    
    opcode_wb     <= instruction_wb(31 downto 26);
    sub_opcode_wb <= instruction_wb(10 downto 1);
    op3_wb        <= instruction_wb(25 downto 21);
    op1_wb        <= instruction_wb(20 downto 16);
    op2_wb        <= instruction_wb(15 downto 11);

    -- 1つ前の命令が ALU から GPR に出力する
    alu_to_gpr_mem <=
        opcode_mem = OP_ADDI  or
        opcode_mem = OP_ADDIS or
        opcode_mem = OP_ANDI  or
        opcode_mem = OP_ORI   or
       (opcode_mem = OP_3OP   and
           (sub_opcode_mem = SUB_OP_ADD  or
            sub_opcode_mem = SUB_OP_NEG  or
            sub_opcode_mem = SUB_OP_AND  or
            sub_opcode_mem = SUB_OP_OR   or
            sub_opcode_mem = SUB_OP_SL   or
            sub_opcode_mem = SUB_OP_SR));

    -- 1つ前の命令が ALU から FPR に出力する
    alu_to_fpr_mem <= opcode_mem = OP_MFGTF;

    -- 1つ前の命令が LR から GPR に出力する
    lr_to_gpr_mem <= opcode_mem = OP_3OP and sub_opcode_mem = SUB_OP_MFLR;

    -- 1つ前の命令が LR から FPR に出力する
    lr_to_fpr_mem <= false;

    -- 1つ前の命令が FPU から GPR に出力する
    fpu_to_gpr_mem <= opcode_mem = OP_MFFTG;

    -- 1つ前の命令が FPU から FPR に出力する
    fpu_to_fpr_mem <=
        opcode_mem = OP_FP and
           (sub_opcode_mem = SUB_OP_FMR  or
            sub_opcode_mem = SUB_OP_FNEG or
            sub_opcode_mem = SUB_OP_FABS);

    -- 1つ前の命令が FADD から GPR に出力する
    fadd_to_gpr_mem <= false;

    -- 1つ前の命令が FADD から FPR に出力する
    fadd_to_fpr_mem <=
        opcode_mem = OP_FP and
           (sub_opcode_mem = SUB_OP_FADD or
            sub_opcode_mem = SUB_OP_FSUB);

    -- 1つ前の命令が FMUL から GPR に出力する
    fmul_to_gpr_mem <= false;

    -- 1つ前の命令が FMUL から FPR に出力する
    fmul_to_fpr_mem <= opcode_mem = OP_FP and sub_opcode_mem = SUB_OP_FMUL;

    -- 1つ前の命令が FINV から GPR に出力する
    finv_to_gpr_mem <= false;

    -- 1つ前の命令が FINV から FPR に出力する
    finv_to_fpr_mem <= opcode_mem = OP_FP and sub_opcode_mem = SUB_OP_FINV;

    process (clk)
    begin
        if rising_edge(clk) then
            alu_to_gpr_wb  <= alu_to_gpr_mem;
            alu_to_fpr_wb  <= alu_to_fpr_mem;
            lr_to_gpr_wb   <= lr_to_gpr_mem;
            lr_to_fpr_wb   <= lr_to_fpr_mem;
            fpu_to_gpr_wb  <= fpu_to_gpr_mem;
            fpu_to_fpr_wb  <= fpu_to_fpr_mem;
            fadd_to_gpr_wb <= fadd_to_gpr_mem;
            fadd_to_fpr_wb <= fadd_to_fpr_mem;
            fmul_to_gpr_wb <= fmul_to_gpr_mem;
            fmul_to_fpr_wb <= fmul_to_fpr_mem;
            finv_to_gpr_wb <= finv_to_gpr_mem;
            finv_to_fpr_wb <= finv_to_fpr_mem;
        end if;
    end process;

    -- 現在の命令の op1 が GPR からの入力
    in1_gpr_ex <=
        opcode_ex = OP_LD    or
        opcode_ex = OP_ST    or
        opcode_ex = OP_ADDI  or
        opcode_ex = OP_ADDIS or
        opcode_ex = OP_ANDI  or
        opcode_ex = OP_ORI   or
        opcode_ex = OP_CMPI  or
        opcode_ex = OP_CMP   or
        opcode_ex = OP_LDF   or
        opcode_ex = OP_STF   or
        opcode_ex = OP_MFGTF or
       (opcode_ex = OP_3OP   and
           (sub_opcode_ex = SUB_OP_LDX   or
            sub_opcode_ex = SUB_OP_STX   or
            sub_opcode_ex = SUB_OP_ADD   or
            sub_opcode_ex = SUB_OP_NEG   or
            sub_opcode_ex = SUB_OP_AND   or
            sub_opcode_ex = SUB_OP_OR    or
            sub_opcode_ex = SUB_OP_MTLR  or
            sub_opcode_ex = SUB_OP_MTCTR or
            sub_opcode_ex = SUB_OP_LDFX  or
            sub_opcode_ex = SUB_OP_STFX  or
            sub_opcode_ex = SUB_OP_SL    or
            sub_opcode_ex = SUB_OP_SR));

    -- 現在の命令の op1 が FPR からの入力
    in1_fpr_ex <=
        opcode_ex = OP_MFFTG or
       (opcode_ex = OP_FP    and
           (sub_opcode_ex = SUB_OP_FADD or
            sub_opcode_ex = SUB_OP_FSUB or
            sub_opcode_ex = SUB_OP_FMUL or
            sub_opcode_ex = SUB_OP_FCMP));

    -- 現在の命令の op2 が GPR からの入力
    in2_gpr_ex <=
        opcode_ex = OP_CMP or
       (opcode_ex = OP_3OP and
           (sub_opcode_ex = SUB_OP_LDX  or
            sub_opcode_ex = SUB_OP_STX  or
            sub_opcode_ex = SUB_OP_ADD  or
            sub_opcode_ex = SUB_OP_AND  or
            sub_opcode_ex = SUB_OP_OR   or
            sub_opcode_ex = SUB_OP_LDFX or
            sub_opcode_ex = SUB_OP_STFX or
            sub_opcode_ex = SUB_OP_SL   or
            sub_opcode_ex = SUB_OP_SR));

    -- 現在の命令の op2 が FPR からの入力
    in2_fpr_ex <=
        opcode_ex = OP_FP and
           (sub_opcode_ex = SUB_OP_FMR  or
            sub_opcode_ex = SUB_OP_FADD or
            sub_opcode_ex = SUB_OP_FSUB or
            sub_opcode_ex = SUB_OP_FMUL or
            sub_opcode_ex = SUB_OP_FINV or
            sub_opcode_ex = SUB_OP_FNEG or
            sub_opcode_ex = SUB_OP_FABS or
            sub_opcode_ex = SUB_OP_FCMP);

    -- 現在の命令の op3 が GPR からの入力
    in3_gpr_ex <=
        opcode_ex = OP_ST   or
        opcode_ex = OP_SEND or
       (opcode_ex = OP_3OP  and sub_opcode_ex = SUB_OP_STX);

    -- 現在の命令の op3 が FPR からの入力
    in3_fpr_ex <=
        opcode_ex = OP_STF or
       (opcode_ex = OP_3OP and sub_opcode_ex = SUB_OP_STFX);

    fwd_src1 <= FWD_SRC_ALU_MEM  when ((alu_to_gpr_mem  and in1_gpr_ex) or (alu_to_fpr_mem  and in1_fpr_ex)) and (op1_ex = op3_mem) else
                FWD_SRC_LR_MEM   when ((lr_to_gpr_mem   and in1_gpr_ex) or (lr_to_fpr_mem   and in1_fpr_ex)) and (op1_ex = op3_mem) else
                FWD_SRC_FPU_MEM  when ((fpu_to_gpr_mem  and in1_gpr_ex) or (fpu_to_fpr_mem  and in1_fpr_ex)) and (op1_ex = op3_mem) else
                FWD_SRC_FADD_MEM when ((fadd_to_gpr_mem and in1_gpr_ex) or (fadd_to_fpr_mem and in1_fpr_ex)) and (op1_ex = op3_mem) else
                FWD_SRC_FMUL_MEM when ((fmul_to_gpr_mem and in1_gpr_ex) or (fmul_to_fpr_mem and in1_fpr_ex)) and (op1_ex = op3_mem) else
                FWD_SRC_FINV_MEM when ((fadd_to_gpr_mem and in1_gpr_ex) or (fadd_to_fpr_mem and in1_fpr_ex)) and (op1_ex = op3_mem) else
                FWD_SRC_ALU_WB   when ((alu_to_gpr_wb   and in1_gpr_ex) or (alu_to_fpr_wb   and in1_fpr_ex)) and (op1_ex = op3_wb)  else
                FWD_SRC_LR_WB    when ((lr_to_gpr_wb    and in1_gpr_ex) or (lr_to_fpr_wb    and in1_fpr_ex)) and (op1_ex = op3_wb)  else
                FWD_SRC_FPU_WB   when ((fpu_to_gpr_wb   and in1_gpr_ex) or (fpu_to_fpr_wb   and in1_fpr_ex)) and (op1_ex = op3_wb)  else
                FWD_SRC_FADD_WB  when ((fadd_to_gpr_wb  and in1_gpr_ex) or (fadd_to_fpr_wb  and in1_fpr_ex)) and (op1_ex = op3_wb)  else
                FWD_SRC_FMUL_WB  when ((fmul_to_gpr_wb  and in1_gpr_ex) or (fmul_to_fpr_wb  and in1_fpr_ex)) and (op1_ex = op3_wb)  else
                FWD_SRC_FINV_WB  when ((finv_to_gpr_wb  and in1_gpr_ex) or (finv_to_fpr_wb  and in1_fpr_ex)) and (op1_ex = op3_wb)  else
                FWD_SRC_REG;

    fwd_src2 <= FWD_SRC_ALU_MEM  when ((alu_to_gpr_mem  and in2_gpr_ex) or (alu_to_fpr_mem  and in2_fpr_ex)) and (op2_ex = op3_mem) else
                FWD_SRC_LR_MEM   when ((lr_to_gpr_mem   and in2_gpr_ex) or (lr_to_fpr_mem   and in2_fpr_ex)) and (op2_ex = op3_mem) else
                FWD_SRC_FPU_MEM  when ((fpu_to_gpr_mem  and in2_gpr_ex) or (fpu_to_fpr_mem  and in2_fpr_ex)) and (op2_ex = op3_mem) else
                FWD_SRC_FADD_MEM when ((fadd_to_gpr_mem and in2_gpr_ex) or (fadd_to_fpr_mem and in2_fpr_ex)) and (op2_ex = op3_mem) else
                FWD_SRC_FMUL_MEM when ((fmul_to_gpr_mem and in2_gpr_ex) or (fmul_to_fpr_mem and in2_fpr_ex)) and (op2_ex = op3_mem) else
                FWD_SRC_FINV_MEM when ((fadd_to_gpr_mem and in2_gpr_ex) or (fadd_to_fpr_mem and in2_fpr_ex)) and (op2_ex = op3_mem) else
                FWD_SRC_ALU_WB   when ((alu_to_gpr_wb   and in2_gpr_ex) or (alu_to_fpr_wb   and in2_fpr_ex)) and (op2_ex = op3_wb)  else
                FWD_SRC_LR_WB    when ((lr_to_gpr_wb    and in2_gpr_ex) or (lr_to_fpr_wb    and in2_fpr_ex)) and (op2_ex = op3_wb)  else
                FWD_SRC_FPU_WB   when ((fpu_to_gpr_wb   and in2_gpr_ex) or (fpu_to_fpr_wb   and in2_fpr_ex)) and (op2_ex = op3_wb)  else
                FWD_SRC_FADD_WB  when ((fadd_to_gpr_wb  and in2_gpr_ex) or (fadd_to_fpr_wb  and in2_fpr_ex)) and (op2_ex = op3_wb)  else
                FWD_SRC_FMUL_WB  when ((fmul_to_gpr_wb  and in2_gpr_ex) or (fmul_to_fpr_wb  and in2_fpr_ex)) and (op2_ex = op3_wb)  else
                FWD_SRC_FINV_WB  when ((finv_to_gpr_wb  and in2_gpr_ex) or (finv_to_fpr_wb  and in2_fpr_ex)) and (op2_ex = op3_wb)  else
                FWD_SRC_REG;

    fwd_src3 <= FWD_SRC_ALU_MEM  when ((alu_to_gpr_mem  and in3_gpr_ex) or (alu_to_fpr_mem  and in3_fpr_ex)) and (op3_ex = op3_mem) else
                FWD_SRC_LR_MEM   when ((lr_to_gpr_mem   and in3_gpr_ex) or (lr_to_fpr_mem   and in3_fpr_ex)) and (op3_ex = op3_mem) else
                FWD_SRC_FPU_MEM  when ((fpu_to_gpr_mem  and in3_gpr_ex) or (fpu_to_fpr_mem  and in3_fpr_ex)) and (op3_ex = op3_mem) else
                FWD_SRC_FADD_MEM when ((fadd_to_gpr_mem and in3_gpr_ex) or (fadd_to_fpr_mem and in3_fpr_ex)) and (op3_ex = op3_mem) else
                FWD_SRC_FMUL_MEM when ((fmul_to_gpr_mem and in3_gpr_ex) or (fmul_to_fpr_mem and in3_fpr_ex)) and (op3_ex = op3_mem) else
                FWD_SRC_FINV_MEM when ((fadd_to_gpr_mem and in3_gpr_ex) or (fadd_to_fpr_mem and in3_fpr_ex)) and (op3_ex = op3_mem) else
                FWD_SRC_ALU_WB   when ((alu_to_gpr_wb   and in3_gpr_ex) or (alu_to_fpr_wb   and in3_fpr_ex)) and (op3_ex = op3_wb)  else
                FWD_SRC_LR_WB    when ((lr_to_gpr_wb    and in3_gpr_ex) or (lr_to_fpr_wb    and in3_fpr_ex)) and (op3_ex = op3_wb)  else
                FWD_SRC_FPU_WB   when ((fpu_to_gpr_wb   and in3_gpr_ex) or (fpu_to_fpr_wb   and in3_fpr_ex)) and (op3_ex = op3_wb)  else
                FWD_SRC_FADD_WB  when ((fadd_to_gpr_wb  and in3_gpr_ex) or (fadd_to_fpr_wb  and in3_fpr_ex)) and (op3_ex = op3_wb)  else
                FWD_SRC_FMUL_WB  when ((fmul_to_gpr_wb  and in3_gpr_ex) or (fmul_to_fpr_wb  and in3_fpr_ex)) and (op3_ex = op3_wb)  else
                FWD_SRC_FINV_WB  when ((finv_to_gpr_wb  and in3_gpr_ex) or (finv_to_fpr_wb  and in3_fpr_ex)) and (op3_ex = op3_wb)  else
                FWD_SRC_REG;

end;
