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
		--cache_hit_miss     : in  std_logic;
		sender_full        : in  std_logic;
		recver_empty       : in  std_logic;
		gpr_write_enable   : out std_logic   := '0';
		fpr_write_enable   : out std_logic   := '0';
		--cache_write_enable : out std_logic   := '0';
		dmem_write_enable  : out std_logic   := '0';
		cr_g_write_enable  : out std_logic   := '0';
		cr_f_write_enable  : out std_logic   := '0';
		lr_write_enable    : out std_logic   := '0';
		ctr_write_enable   : out std_logic   := '0';
		ext_op             : out ext_op_t    := ext_op_unsigned;
		alu_op             : out alu_op_t    := alu_op_add;
		fpu_op             : out fpu_op_t    := fpu_op_bypass;
		fadd_op            : out fadd_op_t   := fadd_op_add;
		alu_src            : out alu_src_t   := alu_src_gpr;
		--cache_src          : out cache_src_t := cache_src_regs;
		dmem_src           : out dmem_src_t  := dmem_src_gpr;
		data_src           : out data_src_t  := data_src_alu;
		lr_src             : out lr_src_t    := lr_src_pc;
		ia_src             : out ia_src_t    := ia_src_pc;
		stall_src          : out stall_src_t := stall_src_go;
		sender_send        : out std_logic   := '0';
		recver_recv        : out std_logic   := '0'
	);
end control;

architecture struct of control is

	signal wait_count : std_logic_vector(2 downto 0) := (others => '0');

begin

	gpr_write_enable <= '1'
		when   (opcode = "000010"					-- recv
			or  opcode = "100000"					-- ld
			or  opcode = "001110"					-- addi
			or  opcode = "001111"					-- addis
			or  opcode = "011100"					-- andi
			or  opcode = "011001"					-- ori
			or  opcode = "010110"					-- mfftg
			or (opcode = "011111"
				and (sub_opcode = "0000010111"		-- ldx
				or   sub_opcode = "0100001010"		-- add
				or   sub_opcode = "0001101000"		-- neg
				or   sub_opcode = "0000011100"		-- and
				or   sub_opcode = "0110111100"		-- or
				or   sub_opcode = "0101010011"		-- mflr
				or   sub_opcode = "0000011000"		-- sl
				or   sub_opcode = "1000011000")))	-- sr
		else '0';

	fpr_write_enable <= '1'
		when   (opcode = "110010"					-- ldf
			or  opcode = "010101"					-- mfgtf
			or (opcode = "011111"
				and  sub_opcode = "1001010111")		-- ldfx
			or (opcode = "111111"
				and (sub_opcode = "0001001000"		-- fmr
				or   sub_opcode = "0000010101"		-- fadd
				or   sub_opcode = "0000010100"		-- fsub
				or   sub_opcode = "0000011001"		-- fmul
				or   sub_opcode = "0000010010"		-- finv
				or   sub_opcode = "0000101000"		-- fneg
				or   sub_opcode = "0100001000")))	-- fabs
		else '0';

	--cache_write_enable <= '1'
	--	when  ((opcode = "100100"					-- st
	--		or  opcode = "110100"					-- stf
	--		or (opcode = "011111"
	--			and (sub_opcode = "0010010111"		-- stx
	--			or   sub_opcode = "1010010111")))	-- stfx
	--		or wait_count /= "000")
	--	else '0';

	dmem_write_enable <= '1'
		when   (opcode = "100100"					-- st
			or  opcode = "110100"					-- stf
			or (opcode = "011111"
				and (sub_opcode = "0010010111"		-- stx
				or   sub_opcode = "1010010111")))	-- stfx
		else '0';

	cr_g_write_enable <= '1'
		when   (opcode = "001011"	-- cmpi
			or  opcode = "011110")	-- cmp
		else '0';

	cr_f_write_enable <= '1'
		when (opcode = "111111" and sub_opcode = "0000000000")	-- fcmp
		else '0';

	lr_write_enable <= '1'
		when  ((opcode = "010010" and branch_op(3) = '1')																-- bl
			or (opcode = "010000" and cr(conv_integer(branch_op(1 downto 0))) = branch_op(2) and branch_op(3) = '1')	-- bcl
			or (opcode = "010100" and branch_op(3) = '1')																-- bctrl
			or (opcode = "011111" and sub_opcode = "0111010011"))														-- mtlr
		else '0';

	ctr_write_enable <= '1'
		when   (opcode = "011111" and sub_opcode = "0111010100")	-- mtctr
		else '0';

	ext_op <= ext_op_unsigned
			when   (opcode = "011100"	-- andi
				or  opcode = "011001"	-- ori
				or  opcode = "010010"	-- b, bl
				or  opcode = "010000")	-- bc, bcl
		else ext_op_signed
			when   (opcode = "100000"	-- ld
				or  opcode = "110010"	-- ldf
				or  opcode = "100100"	-- st
				or  opcode = "110100"	-- stf
				or  opcode = "001110"	-- addi
				or  opcode = "001011")	-- cmpi
		else ext_op_signed_shifted
			when   (opcode = "001111")	-- addis
		else ext_op_unsigned;

	alu_op <= alu_op_add
			when   (opcode = "100000"					-- ld
				or  opcode = "110010"					-- ldf
				or  opcode = "100100"					-- st
				or  opcode = "110100"					-- stf
				or  opcode = "001110"					-- addi
				or  opcode = "001111"					-- addis
				or (opcode = "011111"
					and (sub_opcode = "0000010111"		-- ldx
					or   sub_opcode = "1001010111"		-- ldfx
					or   sub_opcode = "0010010111"		-- stx
					or   sub_opcode = "1010010111"		-- stfx
					or   sub_opcode = "0100001010")))	-- add
		else alu_op_neg
			when   (opcode = "011111"
					and  sub_opcode = "0001101000")		-- neg

		else alu_op_and
			when   (opcode = "011100"					-- andi
				or (opcode = "011111"
					and sub_opcode = "0000011100"))		-- and
		else alu_op_or
			when   (opcode = "011001"					-- ori
				or  opcode = "010101"					-- mfgtf
				or (opcode = "011111"
					and (sub_opcode = "0110111100"		-- or
					or   sub_opcode = "0111010011"		-- mtlr
					or   sub_opcode = "0111010100")))	-- mtctr
		else alu_op_sl
			when   (opcode = "011111" and sub_opcode = "0000011000")				-- sl
		else alu_op_sr
			when   (opcode = "011111" and sub_opcode = "1000011000")				-- sr
		else alu_op_cmp
			when   (opcode = "001011"					-- cmpi
				or  opcode = "011110")					-- cmp
		else alu_op_add;

	alu_src <= alu_src_gpr
			when   (opcode = "011110"					-- cmp
				or  opcode = "010101"					-- mfgtf
				or (opcode = "011111"
					and (sub_opcode = "0000010111"		-- ldx
					or   sub_opcode = "1001010111"		-- ldfx
					or   sub_opcode = "0010010111"		-- stx
					or   sub_opcode = "1010010111"		-- stfx
					or   sub_opcode = "0100001010"		-- add
					or   sub_opcode = "0000011100"		-- and
					or   sub_opcode = "0110111100"		-- or
					or   sub_opcode = "0111010011"		-- mtlr
					or   sub_opcode = "0111010100"		-- mtctr
					or   sub_opcode = "0000011000"		-- sl
					or   sub_opcode = "1000011000")))	-- sr
		else alu_src_ext
			when   (opcode = "100000"					-- ld
				or  opcode = "110010"					-- ldf
				or  opcode = "100100"					-- st
				or  opcode = "110100"					-- stf
				or  opcode = "001110"					-- addi
				or  opcode = "001111"					-- addis
				or  opcode = "011100"					-- andi
				or  opcode = "011001"					-- ori
				or  opcode = "001011");					-- cmpi

	dmem_src <= dmem_src_gpr
			when   (opcode = "000001"					-- send
				or  opcode = "100100"					-- st
				or (opcode = "011111"
					and sub_opcode = "0010010111"))		-- stx
		else dmem_src_fpr
			when   (opcode = "110100"					-- stf
				or (opcode = "011111"
					and sub_opcode = "1010010111"));	-- stfx

	fpu_op <= fpu_op_bypass
			when   (opcode = "010110"					-- mfftg
				or (opcode = "111111"
					and  sub_opcode = "0001001000"))	-- fmr
		else fpu_op_neg
			when   (opcode = "111111"
					and  sub_opcode = "0000101000")		-- fneg
		else fpu_op_abs
			when   (opcode = "111111"
					and  sub_opcode = "0100001000")		-- fabs
		else fpu_op_cmp
			when   (opcode = "111111"
					and  sub_opcode = "0000000000")		-- fcmp
		else fpu_op_bypass;

	fadd_op <= fadd_op_add
			when (opcode = "111111" and sub_opcode = "0000010101")	-- fadd
		else fadd_op_sub
			when (opcode = "111111" and sub_opcode = "0000010100")	-- fsub
		else fadd_op_add;

	--cache_src <= cache_src_regs
	--		when (wait_count = "000"
	--				and (opcode = "100000"					-- ld
	--				or   opcode = "110010"					-- ldf
	--				or  (opcode = "011111"
	--					and (sub_opcode = "0000010111"		-- ldx
	--					or   sub_opcode = "1001010111"))))	-- ldfx
	--	else cache_src_dmem
	--		when (wait_count /= "000"
	--				and (opcode = "100000"					-- ld
	--				or   opcode = "110010"					-- ldf
	--				or  (opcode = "011111"
	--					and (sub_opcode = "0000010111"		-- ldx
	--					or   sub_opcode = "1001010111"))))	-- ldfx
	--	else cache_src_regs;

	data_src <= data_src_alu
			when   (opcode = "001110"					-- addi
				or  opcode = "001111"					-- addis
				or  opcode = "011100"					-- andi
				or  opcode = "011001"					-- ori
				or  opcode = "010101"					-- mfgtf
				or (opcode = "011111"
					and (sub_opcode = "0100001010"		-- add
					or   sub_opcode = "0001101000"		-- neg
					or   sub_opcode = "0000011100"		-- and
					or   sub_opcode = "0110111100"		-- or
					or   sub_opcode = "0000011000"		-- sl
					or   sub_opcode = "1000011000")))	-- sr
		----else data_src_cache
		----	when (wait_count = "000"
		----			and (opcode = "100000"					-- ld
		----			or   opcode = "110010"					-- ldf
		----			or  (opcode = "011111"
		----				and (sub_opcode = "0000010111"		-- ldx
		----				or   sub_opcode = "1001010111"))))	-- ldfx
		--else data_src_dmem
		--	when (wait_count /= "000"
		--			and (opcode = "100000"					-- ld
		--			or   opcode = "110010"					-- ldf
		--			or  (opcode = "011111"
		--				and (sub_opcode = "0000010111"		-- ldx
		--				or   sub_opcode = "1001010111"))))	-- ldfx
		else data_src_dmem
			when    (opcode = "100000"					-- ld
				or   opcode = "110010"					-- ldf
				or  (opcode = "011111"
					and (sub_opcode = "0000010111"		-- ldx
					or   sub_opcode = "1001010111")))	-- ldfx
		else data_src_lr
			when   (opcode = "011111"
					and  sub_opcode = "0101010011")		-- mflr
		else data_src_recv
			when   (opcode = "000010")					-- recv
		else data_src_fpu
			when   (opcode = "010110"					-- mfftg
				or (opcode = "111111"
					and (sub_opcode = "0001001000"		-- fmr
					or   sub_opcode = "0000101000"		-- fneg
					or   sub_opcode = "0100001000")))	-- fabs
		else data_src_fadd
			when   (opcode = "111111"
					and (sub_opcode = "0000010101"		-- fadd
					or   sub_opcode = "0000010100"))	-- fsub
		else data_src_fmul
			when   (opcode = "111111"
					and  sub_opcode = "0000011001")		-- fmul
		else data_src_finv
			when   (opcode = "111111"
					and  sub_opcode = "0000010010");	-- finv

	lr_src <= lr_src_pc
			when  ((opcode = "010010" and branch_op(3) = '1')			-- bl
				or (opcode = "010000" and branch_op(3) = '1')			-- bcl
				or (opcode = "010100" and branch_op(3) = '1'))			-- bctrl
		else lr_src_alu
			when   (opcode = "011111" and sub_opcode = "0111010011");	-- mtlr

	ia_src <= ia_src_lr
			when   (opcode = "010011")																-- blr
		else ia_src_ctr
			when   (opcode = "010100")																-- bctr, bctrl
		else ia_src_ext
			when   (opcode = "010010"																-- b, bl
				or (opcode = "010000" and cr(conv_integer(branch_op(1 downto 0))) = branch_op(2)))	-- bc, bcl
		else ia_src_pc;

	stall_src <= stall_src_stall
		when (opcode = "000001" and sender_full = '1')	-- send
		or   (opcode = "000010" and recver_empty = '1')	-- recv
		or (wait_count /= "100"	-- 5clk instructions
			and (opcode = "111111"
				and (sub_opcode = "0000010101"		-- fadd
				or   sub_opcode = "0000010100"		-- fsub
				or   sub_opcode = "0000011001"		-- fmul
				or   sub_opcode = "0000010010")))	-- finv
		--or (((wait_count = "000" and cache_hit_miss = '0') or (wait_count = "001"))
		or (wait_count /= "010"	-- 5clk instructions
			and (opcode = "100000"					-- ld
			or   opcode = "110010"					-- ldf
			or  (opcode = "011111"
				and (sub_opcode = "0000010111"		-- ldx
				or   sub_opcode = "1001010111"))))	-- ldfx
		else stall_src_go;

	process (clk, opcode, sub_opcode, branch_op, cr)
	begin
		if (rising_edge(clk)) then
			-- 5clk instructions
			if  (opcode = "111111"
				and (sub_opcode = "0000010101"			-- fadd
				or   sub_opcode = "0000010100"			-- fsub
				or   sub_opcode = "0000011001"			-- fmul
				or   sub_opcode = "0000010010")) then	-- finv

				if (wait_count = "100") then
						wait_count <= "000";
				else
						wait_count <= wait_count + 1;
				end if;
			-- 3clk instructions
			elsif (opcode = "100000"						-- ld
				or   opcode = "110010"						-- ldf
				or  (opcode = "011111"
					and (sub_opcode = "0000010111"			-- ldx
					or   sub_opcode = "1001010111"))) then	-- ldfx

				if (wait_count = "010") then
						wait_count <= "000";
				else
						wait_count <= wait_count + 1;
				end if;
			else
				wait_count <= "000";
			end if;
		end if;
	end process;

	sender_send <= '1' when (opcode = "000001")	-- send
		else '0';

	recver_recv <= '1' when (opcode = "000010")	-- recv
		else '0';

end;