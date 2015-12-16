library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control is
	port (
		clk               : in  std_logic;
		opcode            : in  std_logic_vector (5 downto 0);
		sub_opcode        : in  std_logic_vector (9 downto 0);
		branch_op         : in  std_logic_vector (3 downto 0);
		cr                : in  std_logic_vector (3 downto 0);
		sender_full       : in  std_logic;
		recver_empty      : in  std_logic;
		gpr_write_enable  : out std_logic                     := '0';
		fpr_write_enable  : out std_logic                     := '0';
		dmem_write_enable : out std_logic                     := '0';
		cr_g_write_enable : out std_logic                     := '0';
		cr_f_write_enable : out std_logic                     := '0';
		lr_write_enable   : out std_logic                     := '0';
		ctr_write_enable  : out std_logic                     := '0';
		ext_op            : out std_logic_vector (1 downto 0) := (others => '0');
		alu_op            : out std_logic_vector (2 downto 0) := (others => '0');
		alu_src           : out std_logic                     := '0';
		dmem_src          : out std_logic                     := '0';
		fpu_op            : out std_logic_vector (1 downto 0) := (others => '0');
		fadd_op           : out std_logic                     := '0';
		data_src          : out std_logic_vector (2 downto 0) := (others => '0');
		lr_src            : out std_logic                     := '0';
		ia_src            : out std_logic_vector (1 downto 0) := (others => '0');
		stall_src         : out std_logic                     := '0';
		sender_send       : out std_logic                     := '0';
		recver_recv       : out std_logic                     := '0'
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
		when   (opcode = "110010"					-- lf
			or  opcode = "010101"					-- mfgtf
			or (opcode = "011111"
				and  sub_opcode = "1001010111")		-- lfx
			or (opcode = "111111"
				and (sub_opcode = "0001001000"		-- fmr
				or   sub_opcode = "0000010101"		-- fadd
				or   sub_opcode = "0000010100"		-- fsub
				or   sub_opcode = "0000011001"		-- fmul
				or   sub_opcode = "0000010010"		-- fdiv
				or   sub_opcode = "0000101000"		-- fneg
				or   sub_opcode = "0100001000")))	-- fabs
		else '0';

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

	ext_op <= "00"
			when   (opcode = "011100"	-- andi
				or  opcode = "011001"	-- ori
				or  opcode = "010010"	-- b, bl
				or  opcode = "010000")	-- bc, bcl
		else "01"
			when   (opcode = "100000"	-- ld
				or  opcode = "110010"	-- lf
				or  opcode = "100100"	-- st
				or  opcode = "110100"	-- stf
				or  opcode = "001110"	-- addi
				or  opcode = "001011"	-- cmpi
				or  opcode = "011110")	-- cmp
		else "11"
			when   (opcode = "001111")	-- addis
		else "--";

	alu_op <= "000"
			when   (opcode = "100000"					-- ld
				or  opcode = "110010"					-- lf
				or  opcode = "100100"					-- st
				or  opcode = "110100"					-- stf
				or  opcode = "001110"					-- addi
				or  opcode = "001111"					-- addis
				or (opcode = "011111"
					and (sub_opcode = "0000010111"		-- ldx
					or   sub_opcode = "1001010111"		-- lfx
					or   sub_opcode = "0010010111"		-- stx
					or   sub_opcode = "1010010111"		-- stfx
					or   sub_opcode = "0100001010")))	-- add
		else "001"
			when   (opcode = "011111"
					and  sub_opcode = "0001101000")		-- neg

		else "010"
			when   (opcode = "011100"					-- andi
				or (opcode = "011111"
					and sub_opcode = "0000011100"))		-- and
		else "011"
			when   (opcode = "011001"					-- ori
				or  opcode = "010101"					-- mfgtf
				or (opcode = "011111"
					and (sub_opcode = "0110111100"		-- or
					or   sub_opcode = "0111010011"		-- mtlr
					or   sub_opcode = "0111010100")))	-- mtctr
		else "100"
			when   (opcode = "0000011000")				-- sl
		else "101"
			when   (opcode = "1000011000")				-- sr
		else "110"
			when   (opcode = "001011"					-- cmpi
				or  opcode = "011110")					-- cmp
		else "---";

	alu_src <= '1'
			when   (opcode = "100000"					-- ld
				or  opcode = "110010"					-- lf
				or  opcode = "100100"					-- st
				or  opcode = "110100"					-- stf
				or  opcode = "001110"					-- addi
				or  opcode = "001111"					-- addis
				or  opcode = "011100"					-- andi
				or  opcode = "011001"					-- ori
				or  opcode = "001011")					-- cmpi
		else '0'
			when   (opcode = "011110"					-- cmp
				or  opcode = "010101"					-- mfgtf
				or (opcode = "011111"
					and (sub_opcode = "0000010111"		-- ldx
					or   sub_opcode = "1001010111"		-- lfx
					or   sub_opcode = "0010010111"		-- stx
					or   sub_opcode = "1010010111"		-- stfx
					or   sub_opcode = "0100001010"		-- add
					or   sub_opcode = "0000011100"		-- and
					or   sub_opcode = "0110111100"		-- or
					or   sub_opcode = "0111010011"		-- mtlr
					or   sub_opcode = "0111010100"		-- mtctr
					or   sub_opcode = "0000011000"		-- sl
					or   sub_opcode = "1000011000")))	-- sr
		else '-';

	dmem_src <= '0'
			when   (opcode = "000001"					-- send
				or  opcode = "100100"					-- st
				or (opcode = "011111"
					and sub_opcode = "0010010111"))		-- stx
		else '1'
			when   (opcode = "110100"					-- stf
				or (opcode = "011111"
					and sub_opcode = "1010010111"))		-- stfx
		else '-';

	fpu_op <= "00"
			when   (opcode = "010110"					-- mfftg
				or (opcode = "111111"
					and  sub_opcode = "0001001000"))	-- fmr
		else "01"
			when   (opcode = "111111"
					and  sub_opcode = "0000101000")		-- fneg
		else "10"
			when   (opcode = "111111"
					and  sub_opcode = "0100001000")		-- fabs
		else "11"
			when   (opcode = "111111"
					and  sub_opcode = "0000000000")		-- fcmp
		else "--";

	fadd_op <= '0'
			when (opcode = "111111" and sub_opcode = "0000010101")	-- fadd
		else '1'
			when (opcode = "111111" and sub_opcode = "0000010100")	-- fsub
		else '-';

	data_src <= "000"
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
		else "001"
			when   (opcode = "100000"					-- ld
				or  opcode = "110010"					-- lf
				or (opcode = "011111"
					and (sub_opcode = "0000010111"		-- ldx
					or   sub_opcode = "1001010111")))	-- lfx
		else "010"
			when   (opcode = "011111"
					and  sub_opcode = "0101010011")		-- mflr
		else "011"
			when   (opcode = "000010")					-- recv
		else "100"
			when   (opcode = "010110"					-- mfftg
				or (opcode = "111111"
					and (sub_opcode = "0001001000"		-- fmr
					or   sub_opcode = "0000101000"		-- fneg
					or   sub_opcode = "0100001000")))	-- fabs
		else "101"
			when   (opcode = "111111"
					and (sub_opcode = "0000010101"		-- fadd
					or   sub_opcode = "0000010100"))	-- fsub
		else "110"
			when   (opcode = "111111"
					and  sub_opcode = "0000011001")		-- fmul
		else "111"
			when   (opcode = "111111"
					and  sub_opcode = "0000010010")		-- fdiv
		else "---";

	lr_src <= '1'
			when   (opcode = "011111" and sub_opcode = "0111010011")	-- mtlr
		else '0'
			when  ((opcode = "010010" and branch_op(3) = '1')			-- bl
				or (opcode = "010000" and branch_op(3) = '1')			-- bcl
				or (opcode = "010100" and branch_op(3) = '1'))			-- bctrl
		else '-';

	ia_src <= "01"
			when   (opcode = "010011")																-- blr
		else "10"
			when   (opcode = "010100")																-- bctr, bctrl
		else "11"
			when   (opcode = "010010"																-- b, bl
				or (opcode = "010000" and cr(conv_integer(branch_op(1 downto 0))) = branch_op(2)))	-- bc, bcl
		else "00";

	stall_src <= '1'
		when (opcode = "000010" and recver_empty = '1')	-- recv
		or (wait_count /= "100"	-- 5clk instructions
			and (opcode = "111111"
				and (sub_opcode = "0000010101"		-- fadd
				or   sub_opcode = "0000010100"		-- fsub
				or   sub_opcode = "0000011001")))	-- fmul
		or (wait_count /= "010"	-- 3clk instructions
			and (opcode = "100000"					-- ld
			or   opcode = "110010"					-- lf
			or   opcode = "100100"					-- st
			or   opcode = "110100"					-- stf
			or  (opcode = "011111"
				and (sub_opcode = "0000010111"		-- ldx
				or   sub_opcode = "1001010111"		-- lfx
				or   sub_opcode = "0010010111"		-- stx
				or   sub_opcode = "1010010111"))))	-- stfx
		else '0';

	process (clk, opcode, sub_opcode, branch_op, cr)
	begin
		if (rising_edge(clk)) then
			-- 5clk instructions
			if  (opcode = "111111"
				and (sub_opcode = "0000010101"			-- fadd
				or   sub_opcode = "0000010100"			-- fsub
				or   sub_opcode = "0000011001")) then	-- fmul

				if (wait_count = "100") then
						wait_count <= "000";
				else
						wait_count <= wait_count + 1;
				end if;
			-- 3clk instructions
			elsif      (opcode = "100000"						-- ld
				or   opcode = "110010"						-- lf
				or   opcode = "100100"						-- st
				or   opcode = "110100"						-- stf
				or  (opcode = "011111"
					and (sub_opcode = "0000010111"			-- ldx
					or   sub_opcode = "1001010111"			-- lfx
					or   sub_opcode = "0010010111"			-- stx
					or   sub_opcode = "1010010111"))) then	-- stfx

				if (wait_count = "010") then
						wait_count <= "000";
				else
						wait_count <= wait_count + 1;
				end if;
			end if;
		end if;
	end process;

	sender_send <= '1' when (opcode = "000001")	-- send
		else '0';

	recver_recv <= '1' when (opcode = "000010")	-- recv
		else '0';

end;