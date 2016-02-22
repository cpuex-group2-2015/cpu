library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.types.all;

entity control is
	port (
		clk                : in  std_logic;
		opcode             : in  std_logic_vector (5 downto 0);
		sub_opcode         : in  std_logic_vector (9 downto 0);
		branch_op          : in  std_logic_vector (3 downto 0);
		cr                 : in  std_logic_vector (3 downto 0);
		cache_hit_miss     : in  std_logic;
		sender_full        : in  std_logic;
		recver_empty       : in  std_logic;
		gpr_write_enable   : out std_logic                     := '0';
		fpr_write_enable   : out std_logic                     := '0';
		cache_write_enable : out std_logic                     := '0';
		dmem_write_enable  : out std_logic                     := '0';
		cr_g_write_enable  : out std_logic                     := '0';
		cr_f_write_enable  : out std_logic                     := '0';
		lr_write_enable    : out std_logic                     := '0';
		ctr_write_enable   : out std_logic                     := '0';
		ext_op             : out std_logic_vector (1 downto 0) := EXT_OP_UNSIGNED;
		alu_op             : out std_logic_vector (2 downto 0) := ALU_OP_ADD;
		fpu_op             : out std_logic_vector (1 downto 0) := FPU_OP_BYPASS;
		fadd_op            : out std_logic                     := FADD_OP_ADD;
		alu_src            : out std_logic                     := ALU_SRC_GPR;
		dmem_src           : out std_logic                     := DMEM_SRC_GPR;
		regs_src           : out std_logic_vector (3 downto 0) := REGS_SRC_ALU;
		lr_src             : out std_logic                     := LR_SRC_PC;
		ia_src             : out std_logic_vector (1 downto 0) := IA_SRC_PC;
		stall              : out std_logic                     := '0';
		sender_send        : out std_logic                     := '0';
		recver_recv        : out std_logic                     := '0'
	);
end control;

architecture struct of control is

	signal wait_count : std_logic_vector(2 downto 0) := (others => '0');

begin

	gpr_write_enable <= '1'
		when   (opcode = OP_RECV
			or  opcode = OP_LD
			or  opcode = OP_ADDI
			or  opcode = OP_ADDIS
			or  opcode = OP_ANDI
			or  opcode = OP_ORI
			or  opcode = OP_MFFTG
			or (opcode = OP_3OP
				and (sub_opcode = SUB_OP_LDX
				or   sub_opcode = SUB_OP_ADD
				or   sub_opcode = SUB_OP_NEG
				or   sub_opcode = SUB_OP_AND
				or   sub_opcode = SUB_OP_OR
				or   sub_opcode = SUB_OP_MFLR
				or   sub_opcode = SUB_OP_SL
				or   sub_opcode = SUB_OP_SR)))
		else '0';

	fpr_write_enable <= '1'
		when   (opcode = OP_LDF
			or  opcode = OP_MFGTF
			or (opcode = OP_3OP
				and  sub_opcode = SUB_OP_LDFX)
			or (opcode = OP_FP
				and (sub_opcode = SUB_OP_FMR
				or   sub_opcode = SUB_OP_FADD
				or   sub_opcode = SUB_OP_FSUB
				or   sub_opcode = SUB_OP_FMUL
				or   sub_opcode = SUB_OP_FINV
				or   sub_opcode = SUB_OP_FNEG
				or   sub_opcode = SUB_OP_FABS)))
		else '0';

	cache_write_enable <= '1'
		when   (opcode = OP_ST
			or  opcode = OP_STF
			or (opcode = OP_3OP
				and (sub_opcode = SUB_OP_STX
				or   sub_opcode = SUB_OP_STFX)))
		else '0';


	dmem_write_enable <= '1'
		when   (opcode = OP_ST
			or  opcode = OP_STF
			or (opcode = OP_3OP
				and (sub_opcode = SUB_OP_STX
				or   sub_opcode = SUB_OP_STFX)))
		else '0';

	cr_g_write_enable <= '1'
		when   (opcode = OP_CMPI
			or  opcode = OP_CMP)
		else '0';

	cr_f_write_enable <= '1'
		when (opcode = OP_FP and sub_opcode = SUB_OP_FCMP)
		else '0';

	lr_write_enable <= '1'
		when  ((opcode = OP_B and branch_op(3) = '1')
			or (opcode = OP_BC and cr(conv_integer(branch_op(1 downto 0))) = branch_op(2) and branch_op(3) = '1')
			or (opcode = OP_BCTR and branch_op(3) = '1')
			or (opcode = OP_3OP and sub_opcode = SUB_OP_MTLR))
		else '0';

	ctr_write_enable <= '1'
		when   (opcode = OP_3OP and sub_opcode = SUB_OP_MTCTR)
		else '0';

	ext_op <= EXT_OP_UNSIGNED
			when   (opcode = OP_ANDI
				or  opcode = OP_ORI
				or  opcode = OP_B
				or  opcode = OP_BC)
		else EXT_OP_SIGNED
			when   (opcode = OP_LD
				or  opcode = OP_LDF
				or  opcode = OP_ST
				or  opcode = OP_STF
				or  opcode = OP_ADDI
				or  opcode = OP_CMPI)
		else EXT_OP_SIGNED_SHIFTED
			when   (opcode = OP_ADDIS)
		else "--";

	alu_op <= ALU_OP_ADD
			when   (opcode = OP_LD
				or  opcode = OP_LDF
				or  opcode = OP_ST
				or  opcode = OP_STF
				or  opcode = OP_ADDI
				or  opcode = OP_ADDIS
				or (opcode = OP_3OP
					and (sub_opcode = SUB_OP_LDX
					or   sub_opcode = SUB_OP_LDFX
					or   sub_opcode = SUB_OP_STX
					or   sub_opcode = SUB_OP_STFX
					or   sub_opcode = SUB_OP_ADD)))
		else ALU_OP_NEG
			when   (opcode = OP_3OP
					and  sub_opcode = SUB_OP_NEG)
		else ALU_OP_AND
			when   (opcode = OP_ANDI
				or (opcode = OP_3OP
					and sub_opcode = SUB_OP_AND))
		else ALU_OP_OR
			when   (opcode = OP_ORI
				or  opcode = OP_MFGTF
				or (opcode = OP_3OP
					and (sub_opcode = SUB_OP_OR
					or   sub_opcode = SUB_OP_MTLR
					or   sub_opcode = SUB_OP_MTCTR)))
		else ALU_OP_SL
			when   (opcode = OP_3OP and sub_opcode = SUB_OP_SL)
		else ALU_OP_SR
			when   (opcode = OP_3OP and sub_opcode = SUB_OP_SR)
		else ALU_OP_CMP
			when   (opcode = OP_CMPI
				or  opcode = OP_CMP)
		else "---";

	fpu_op <= FPU_OP_BYPASS
			when   (opcode = OP_MFFTG
				or (opcode = OP_FP
					and  sub_opcode = SUB_OP_FMR))
		else FPU_OP_NEG
			when   (opcode = OP_FP
					and  sub_opcode = SUB_OP_FNEG)
		else FPU_OP_ABS
			when   (opcode = OP_FP
					and  sub_opcode = SUB_OP_FABS)
		else FPU_OP_CMP
			when   (opcode = OP_FP
					and  sub_opcode = SUB_OP_FCMP)
		else "--";

	fadd_op <= FADD_OP_ADD
			when (opcode = OP_FP and sub_opcode = SUB_OP_FADD)
		else FADD_OP_SUB
			when (opcode = OP_FP and sub_opcode = SUB_OP_FSUB)
		else '-';

	alu_src <= ALU_SRC_GPR
		when   (opcode = OP_CMP
			or  opcode = OP_MFGTF
			or (opcode = OP_3OP
				and (sub_opcode = SUB_OP_LDX
				or   sub_opcode = SUB_OP_LDFX
				or   sub_opcode = SUB_OP_STX
				or   sub_opcode = SUB_OP_STFX
				or   sub_opcode = SUB_OP_ADD
				or   sub_opcode = SUB_OP_AND
				or   sub_opcode = SUB_OP_OR
				or   sub_opcode = SUB_OP_MTLR
				or   sub_opcode = SUB_OP_MTCTR
				or   sub_opcode = SUB_OP_SL
				or   sub_opcode = SUB_OP_SR)))
		else ALU_SRC_EXT
		when   (opcode = OP_LD
			or  opcode = OP_LDF
			or  opcode = OP_ST
			or  opcode = OP_STF
			or  opcode = OP_ADDI
			or  opcode = OP_ADDIS
			or  opcode = OP_ANDI
			or  opcode = OP_ORI
			or  opcode = OP_CMPI)
		else '-';

	dmem_src <= DMEM_SRC_GPR
			when   (opcode = OP_SEND
				or  opcode = OP_ST
				or (opcode = OP_3OP
					and sub_opcode = SUB_OP_STX))
		else DMEM_SRC_FPR
			when   (opcode = OP_STF
				or (opcode = OP_3OP
					and sub_opcode = SUB_OP_STFX))
		else '-';

	regs_src <= REGS_SRC_ALU
			when   (opcode = OP_ADDI
				or  opcode = OP_ADDIS
				or  opcode = OP_ANDI
				or  opcode = OP_ORI
				or  opcode = OP_MFGTF
				or (opcode = OP_3OP
					and (sub_opcode = SUB_OP_ADD
					or   sub_opcode = SUB_OP_NEG
					or   sub_opcode = SUB_OP_AND
					or   sub_opcode = SUB_OP_OR
					or   sub_opcode = SUB_OP_SL
					or   sub_opcode = SUB_OP_SR)))
		else REGS_SRC_CACHE
			when   (wait_count /= "010"
				and (opcode = OP_LD
				or   opcode = OP_LDF
				or  (opcode = OP_3OP
					and (sub_opcode = SUB_OP_LDX
					or   sub_opcode = SUB_OP_LDFX))))
		else REGS_SRC_DMEM
			when   (wait_count = "010"
				and (opcode = OP_LD
				or   opcode = OP_LDF
				or  (opcode = OP_3OP
					and (sub_opcode = SUB_OP_LDX
					or   sub_opcode = SUB_OP_LDFX))))
		else REGS_SRC_LR
			when   (opcode = OP_3OP
					and  sub_opcode = SUB_OP_MFLR)
		else REGS_SRC_RECV
			when   (opcode = OP_RECV)
		else REGS_SRC_FPU
			when   (opcode = OP_MFFTG
				or (opcode = OP_FP
					and (sub_opcode = SUB_OP_FMR
					or   sub_opcode = SUB_OP_FNEG
					or   sub_opcode = SUB_OP_FABS)))
		else REGS_SRC_FADD
			when   (opcode = OP_FP
					and (sub_opcode = SUB_OP_FADD
					or   sub_opcode = SUB_OP_FSUB))
		else REGS_SRC_FMUL
			when   (opcode = OP_FP
					and  sub_opcode = SUB_OP_FMUL)
		else REGS_SRC_FINV
			when   (opcode = OP_FP
					and  sub_opcode = SUB_OP_FINV)
		else "----";

	lr_src <= LR_SRC_PC
			when  ((opcode = OP_B and branch_op(3) = '1')
				or (opcode = OP_BC and branch_op(3) = '1')
				or (opcode = OP_BCTR and branch_op(3) = '1'))
		else LR_SRC_ALU
			when   (opcode = OP_3OP and sub_opcode = SUB_OP_MTLR)
		else '-';

	ia_src <= IA_SRC_LR
			when   (opcode = OP_BLR)
		else IA_SRC_CTR
			when   (opcode = OP_BCTR)
		else IA_SRC_EXT
			when   (opcode = OP_B
				or (opcode = OP_BC and cr(conv_integer(branch_op(1 downto 0))) = branch_op(2)))
		else IA_SRC_PC;

	stall <= '1'
		when (opcode = OP_SEND and sender_full = '1')
		or   (opcode = OP_RECV and recver_empty = '1')
		or  ((wait_count = "000" or (wait_count = "001" and cache_hit_miss = '0'))
			and (opcode = OP_LD
			or   opcode = OP_LDF
			or  (opcode = OP_3OP
				and (sub_opcode = SUB_OP_LDX
				or   sub_opcode = SUB_OP_LDFX))))
		or (wait_count /= "010"	-- 3clk instructions
			and (opcode = OP_FP
				and (sub_opcode = SUB_OP_FADD
				or   sub_opcode = SUB_OP_FSUB
				or   sub_opcode = SUB_OP_FMUL
				or   sub_opcode = SUB_OP_FINV)))
		else '0';

	process (clk, opcode, sub_opcode, branch_op, cr)
	begin
		if (rising_edge(clk)) then
			-- 3clk instructions
			if (opcode = OP_LD  or
			    opcode = OP_LDF or
			   (opcode = OP_3OP and
			       (sub_opcode = SUB_OP_LDX    or
			        sub_opcode = SUB_OP_LDFX))) then

				if ((wait_count = "001" and cache_hit_miss = '1') or wait_count = "010") then
						wait_count <= "000";
				else
						wait_count <= wait_count + 1;
				end if;
			end if;
			if (opcode = OP_FP and
			       (sub_opcode = SUB_OP_FADD   or
			        sub_opcode = SUB_OP_FSUB   or
			        sub_opcode = SUB_OP_FMUL   or
			        sub_opcode = SUB_OP_FINV)) then

				if (wait_count = "010") then
						wait_count <= "000";
				else
						wait_count <= wait_count + 1;
				end if;
			end if;
		end if;
	end process;

	sender_send <= '1' when (opcode = OP_SEND)
		else '0';

	recver_recv <= '1' when (opcode = OP_RECV)
		else '0';

end;
