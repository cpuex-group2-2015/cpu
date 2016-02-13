library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.types.all;

entity core is
	port (
		clk    : in    std_logic;
		RS_RX  : in    std_logic;
		RS_TX  : out   std_logic;
		ZD     : inout std_logic_vector (31 downto 0);
		ZA     : out   std_logic_vector (19 downto 0);
		XWA    : out   std_logic;
		XE1    : out   std_logic;
		E2A    : out   std_logic;
		XE3    : out   std_logic;
		XGA    : out   std_logic;
		XZCKE  : out   std_logic;
		ADVA   : out   std_logic;
		XLBO   : out   std_logic;
		ZZA    : out   std_logic;
		XFT    : out   std_logic;
		XZBE   : out   std_logic_vector (3 downto 0);
		ZCLKMA : out   std_logic_vector (1 downto 0)
	);
end core;

architecture struct of core is

	component program_counter is
		port (
			clk    : in  std_logic;
			pc_in  : in  std_logic_vector (31 downto 0);
			pc_out : out std_logic_vector (31 downto 0)
		);
	end component;

	component instruction_memory is
		port (
			clk                 : in  std_logic;
			instruction_address : in  std_logic_vector (31 downto 0);
			instruction         : out std_logic_vector (31 downto 0)
		);
	end component;

	component control is
		port (
			clk               : in  std_logic;
			opcode            : in  std_logic_vector (5 downto 0);
			sub_opcode        : in  std_logic_vector (9 downto 0);
			branch_op         : in  std_logic_vector (3 downto 0);
			cr                : in  std_logic_vector (3 downto 0);
			sender_full       : in  std_logic;
			recver_empty      : in  std_logic;
			gpr_write_enable  : out std_logic;
			fpr_write_enable  : out std_logic;
			dmem_write_enable : out std_logic;
			cr_g_write_enable : out std_logic;
			cr_f_write_enable : out std_logic;
			lr_write_enable   : out std_logic;
			ctr_write_enable  : out std_logic;
			ext_op            : out std_logic_vector (1 downto 0);
			alu_op            : out std_logic_vector (2 downto 0);
			fpu_op            : out std_logic_vector (1 downto 0);
			fadd_op           : out std_logic;
			alu_src           : out std_logic;
			dmem_src          : out std_logic;
			regs_src          : out std_logic_vector (2 downto 0);
			lr_src            : out std_logic;
			ia_src            : out std_logic_vector (1 downto 0);
			stall             : out std_logic;
			sender_send       : out std_logic;
			recver_recv       : out std_logic
		);
	end component;

	component extend is
		port (
			ext_op  : in  std_logic_vector (1 downto 0);
			ext_in  : in  std_logic_vector (15 downto 0);
			ext_out : out std_logic_vector (31 downto 0)
		);
	end component;

	component general_purpose_registers is
		port (
			clk              : in  std_logic;
			gpr_write_enable : in  std_logic;
			gpr_reg_num1     : in  std_logic_vector (4 downto 0);
			gpr_reg_num2     : in  std_logic_vector (4 downto 0);
			gpr_reg_num3     : in  std_logic_vector (4 downto 0);
			gpr_data_in      : in  std_logic_vector (31 downto 0);
			gpr_data_out1    : out std_logic_vector (31 downto 0);
			gpr_data_out2    : out std_logic_vector (31 downto 0);
			gpr_data_out3    : out std_logic_vector (31 downto 0)
		);
	end component;

	component floating_point_registers is
		port (
			clk              : in  std_logic;
			fpr_write_enable : in  std_logic;
			fpr_reg_num1     : in  std_logic_vector (4 downto 0);
			fpr_reg_num2     : in  std_logic_vector (4 downto 0);
			fpr_reg_num3     : in  std_logic_vector (4 downto 0);
			fpr_data_in      : in  std_logic_vector (31 downto 0);
			fpr_data_out1    : out std_logic_vector (31 downto 0);
			fpr_data_out2    : out std_logic_vector (31 downto 0);
			fpr_data_out3    : out std_logic_vector (31 downto 0)
		);
	end component;

	component arithmetic_logic_unit is
		port (
			alu_op   : in  std_logic_vector (2 downto 0);
			alu_in1  : in  std_logic_vector (31 downto 0);
			alu_in2  : in  std_logic_vector (31 downto 0);
			alu_cond : out std_logic_vector (2 downto 0);
			alu_out  : out std_logic_vector (31 downto 0)
		);
	end component;

	component floating_point_unit is
		port (
			fpu_op   : in  std_logic_vector (1 downto 0);
			fpu_in1  : in  std_logic_vector (31 downto 0);
			fpu_in2  : in  std_logic_vector (31 downto 0);
			fpu_cond : out std_logic_vector (3 downto 0);
			fpu_out  : out std_logic_vector (31 downto 0)
		);
	end component;

	component fadd_fsub is
		port (
			clk       : in  std_logic;
			fadd_op   : in  std_logic;
			fadd_in1  : in  std_logic_vector (31 downto 0);
			fadd_in2  : in  std_logic_vector (31 downto 0);
			fadd_out  : out std_logic_vector (31 downto 0)
		);
	end component;

	component fmul is
		port (
			clk     : in  std_logic;
			input_a : in  std_logic_vector (31 downto 0);
			input_b : in  std_logic_vector (31 downto 0);
			output  : out std_logic_vector (31 downto 0)
		);
	end component;

	component finv is
		port (
			clk    : in  std_logic;
			input  : in  std_logic_vector (31 downto 0);
			output : out std_logic_vector (31 downto 0)
		);
	end component;

	component data_memory is
		port (
			clk               : in  std_logic;
			dmem_write_enable : in  std_logic;
			dmem_address      : in  std_logic_vector (19 downto 0);
			dmem_data_in      : in  std_logic_vector (31 downto 0);
			dmem_data_out     : out std_logic_vector (31 downto 0);

			ZD     : inout std_logic_vector (31 downto 0);	-- データ線
			ZA     : out   std_logic_vector (19 downto 0);	-- アドレス
			XWA    : out   std_logic;						-- write enable 線
			XE1    : out   std_logic;						-- 0固定
			E2A    : out   std_logic;						-- 1固定
			XE3    : out   std_logic;						-- 0固定
			XGA    : out   std_logic;						-- 出力イネーブル 0固定
			XZCKE  : out   std_logic;						-- クロックイネーブル 0固定
			ADVA   : out   std_logic;						-- バーストアクセス 0固定
			XLBO   : out   std_logic;						-- バーストアクセスのアドレス順 1固定
			ZZA    : out   std_logic;						-- スリープモード 0固定
			XFT    : out   std_logic;						-- Flow Through Mode 1固定
			XZBE   : out   std_logic_vector (3 downto 0);	-- 書き込みマスク 0固定
			ZCLKMA : out   std_logic_vector (1 downto 0)	-- クロック
		);
	end component;

	component condition_register is
		port (
			clk               : in  std_logic;
			cr_g_write_enable : in  std_logic;
			cr_f_write_enable : in  std_logic;
			cr_in_g           : in  std_logic_vector (2 downto 0);
			cr_in_f           : in  std_logic_vector (3 downto 0);
			cr_out            : out std_logic_vector (3 downto 0)
		);
	end component;

	component link_register is
		port (
			clk             : in  std_logic;
			lr_write_enable : in  std_logic;
			lr_in           : in  std_logic_vector (31 downto 0);
			lr_out          : out std_logic_vector (31 downto 0)
		);
	end component;

	component count_register is
		port (
			clk              : in  std_logic;
			ctr_write_enable : in  std_logic;
			ctr_in           : in  std_logic_vector (31 downto 0);
			ctr_out          : out std_logic_vector (31 downto 0)
		);
	end component;

	component sender is
		port (
			clk         : in  std_logic;
			sender_send : in  std_logic;
			sender_in   : in  std_logic_vector (31 downto 0);
			sender_full : out std_logic;
			sender_out  : out std_logic
		);
	end component;

	component recver is
		port (
			clk          : in  std_logic;
			recver_recv  : in  std_logic;
			recver_in    : in  std_logic;
			recver_empty : out std_logic;
			recver_out   : out std_logic_vector (31 downto 0)
		);
	end component;

	signal pc_in_if   : std_logic_vector (31 downto 0) := (others => '0');
	signal pc_out_if  : std_logic_vector (31 downto 0) := (others => '0');
	signal pc_out_id  : std_logic_vector (31 downto 0) := (others => '0');
	signal pc_out_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal pc_out_mem : std_logic_vector (31 downto 0) := (others => '0');

	signal instruction_address_if : std_logic_vector (31 downto 0) := (others => '0');
	signal instruction_if         : std_logic_vector (31 downto 0) := (others => '0');
	signal instruction_id         : std_logic_vector (31 downto 0) := (others => '0');

	signal ext_op_id   : std_logic_vector (1 downto 0)  := EXT_OP_UNSIGNED;
	signal ext_in_id   : std_logic_vector (15 downto 0) := (others => '0');
	signal ext_out_id  : std_logic_vector (31 downto 0) := (others => '0');
	signal ext_out_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal ext_out_mem : std_logic_vector (31 downto 0) := (others => '0');
	signal ext_out_wb  : std_logic_vector (31 downto 0) := (others => '0');

	signal gpr_write_enable_id  : std_logic                      := '0';
	signal gpr_write_enable_ex  : std_logic                      := '0';
	signal gpr_write_enable_mem : std_logic                      := '0';
	signal gpr_write_enable_wb  : std_logic                      := '0';
	signal gpr_reg_num1_id      : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_reg_num2_id      : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_reg_num3_id      : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_data_in_wb       : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_data_out1_id     : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_data_out2_id     : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_data_out3_id     : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_data_out1_ex     : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_data_out2_ex     : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_data_out3_ex     : std_logic_vector (31 downto 0) := (others => '0');

	signal fpr_write_enable_id  : std_logic                      := '0';
	signal fpr_write_enable_ex  : std_logic                      := '0';
	signal fpr_write_enable_mem : std_logic                      := '0';
	signal fpr_write_enable_wb  : std_logic                      := '0';
	signal fpr_reg_num1_id      : std_logic_vector (4 downto 0)  := (others => '0');
	signal fpr_reg_num2_id      : std_logic_vector (4 downto 0)  := (others => '0');
	signal fpr_reg_num3_id      : std_logic_vector (4 downto 0)  := (others => '0');
	signal fpr_data_in_wb       : std_logic_vector (31 downto 0) := (others => '0');
	signal fpr_data_out1_id     : std_logic_vector (31 downto 0) := (others => '0');
	signal fpr_data_out2_id     : std_logic_vector (31 downto 0) := (others => '0');
	signal fpr_data_out3_id     : std_logic_vector (31 downto 0) := (others => '0');
	signal fpr_data_out1_ex     : std_logic_vector (31 downto 0) := (others => '0');
	signal fpr_data_out2_ex     : std_logic_vector (31 downto 0) := (others => '0');
	signal fpr_data_out3_ex     : std_logic_vector (31 downto 0) := (others => '0');

	signal alu_op_id   : std_logic_vector (2 downto 0)  := ALU_OP_ADD;
	signal alu_op_ex   : std_logic_vector (2 downto 0)  := ALU_OP_ADD;
	signal alu_in1_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal alu_in2_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal alu_cond_ex : std_logic_vector (2 downto 0)  := (others => '0');
	signal alu_out_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal alu_out_mem : std_logic_vector (31 downto 0) := (others => '0');
	signal alu_out_wb  : std_logic_vector (31 downto 0) := (others => '0');

	signal fpu_op_id   : std_logic_vector (1 downto 0)  := FPU_OP_BYPASS;
	signal fpu_op_ex   : std_logic_vector (1 downto 0)  := FPU_OP_BYPASS;
	signal fpu_in1_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal fpu_in2_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal fpu_cond_ex : std_logic_vector (3 downto 0)  := (others => '0');
	signal fpu_out_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal fpu_out_mem : std_logic_vector (31 downto 0) := (others => '0');
	signal fpu_out_wb  : std_logic_vector (31 downto 0) := (others => '0');

	signal fadd_op_id   : std_logic                      := FADD_OP_ADD;
	signal fadd_op_ex   : std_logic                      := FADD_OP_ADD;
	signal fadd_in1_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal fadd_in2_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal fadd_out_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal fadd_out_mem : std_logic_vector (31 downto 0) := (others => '0');
	signal fadd_out_wb  : std_logic_vector (31 downto 0) := (others => '0');

	signal fmul_in1_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal fmul_in2_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal fmul_out_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal fmul_out_mem : std_logic_vector (31 downto 0) := (others => '0');
	signal fmul_out_wb  : std_logic_vector (31 downto 0) := (others => '0');

	signal finv_in_ex   : std_logic_vector (31 downto 0) := (others => '0');
	signal finv_out_ex  : std_logic_vector (31 downto 0) := (others => '0');
	signal finv_out_mem : std_logic_vector (31 downto 0) := (others => '0');
	signal finv_out_wb  : std_logic_vector (31 downto 0) := (others => '0');

	signal dmem_write_enable_id  : std_logic                      := '0';
	signal dmem_write_enable_ex  : std_logic                      := '0';
	signal dmem_write_enable_mem : std_logic                      := '0';
	signal dmem_address_mem      : std_logic_vector (19 downto 0) := (others => '0');
	signal dmem_data_in_mem      : std_logic_vector (31 downto 0) := (others => '0');
	signal dmem_data_out_mem     : std_logic_vector (31 downto 0) := (others => '0');
	signal dmem_data_out_wb      : std_logic_vector (31 downto 0) := (others => '0');

	signal mem_data_in_ex : std_logic_vector (31 downto 0) := (others => '0');

	signal cr_g_write_enable_id  : std_logic                     := '0';
	signal cr_g_write_enable_ex  : std_logic                     := '0';
	signal cr_g_write_enable_mem : std_logic                     := '0';
	signal cr_f_write_enable_id  : std_logic                     := '0';
	signal cr_f_write_enable_ex  : std_logic                     := '0';
	signal cr_f_write_enable_mem : std_logic                     := '0';
	signal cr_in_g_mem           : std_logic_vector (2 downto 0) := (others => '0');
	signal cr_in_f_mem           : std_logic_vector (3 downto 0) := (others => '0');
	signal cr_out_mem            : std_logic_vector (3 downto 0) := (others => '0');

	signal lr_write_enable_id  : std_logic                      := '0';
	signal lr_write_enable_ex  : std_logic                      := '0';
	signal lr_write_enable_mem : std_logic                      := '0';
	signal lr_in_mem           : std_logic_vector (31 downto 0) := (others => '0');
	signal lr_out_mem          : std_logic_vector (31 downto 0) := (others => '0');
	signal lr_out_wb           : std_logic_vector (31 downto 0) := (others => '0');

	signal ctr_write_enable_id  : std_logic                      := '0';
	signal ctr_write_enable_ex  : std_logic                      := '0';
	signal ctr_write_enable_mem : std_logic                      := '0';
	signal ctr_in_mem           : std_logic_vector (31 downto 0) := (others => '0');
	signal ctr_out_mem          : std_logic_vector (31 downto 0) := (others => '0');
	signal ctr_out_wb           : std_logic_vector (31 downto 0) := (others => '0');

	signal sender_send_id  : std_logic                      := '0';
	signal sender_send_ex  : std_logic                      := '0';
	signal sender_send_mem : std_logic                      := '0';
	signal sender_in_mem   : std_logic_vector (31 downto 0) := (others => '0');
	signal sender_full     : std_logic                      := '0';

	signal recver_recv_id  : std_logic                      := '0';
	signal recver_recv_ex  : std_logic                      := '0';
	signal recver_recv_mem : std_logic                      := '0';
	signal recver_empty    : std_logic                      := '0';
	signal recver_out_mem  : std_logic_vector (31 downto 0) := (others => '0');
	signal recver_out_wb   : std_logic_vector (31 downto 0) := (others => '0');

	signal alu_src_id   : std_logic                     := ALU_SRC_GPR;
	signal alu_src_ex   : std_logic                     := ALU_SRC_GPR;
	signal dmem_src_id  : std_logic                     := DMEM_SRC_GPR;
	signal dmem_src_ex  : std_logic                     := DMEM_SRC_GPR;
	signal regs_src_id  : std_logic_vector (2 downto 0) := REGS_SRC_ALU;
	signal regs_src_ex  : std_logic_vector (2 downto 0) := REGS_SRC_ALU;
	signal regs_src_mem : std_logic_vector (2 downto 0) := REGS_SRC_ALU;
	signal regs_src_wb  : std_logic_vector (2 downto 0) := REGS_SRC_ALU;
	signal lr_src_id    : std_logic                     := LR_SRC_PC;
	signal lr_src_ex    : std_logic                     := LR_SRC_PC;
	signal lr_src_mem   : std_logic                     := LR_SRC_PC;
	signal ia_src_id    : std_logic_vector (1 downto 0) := IA_SRC_PC;
	signal ia_src_ex    : std_logic_vector (1 downto 0) := IA_SRC_PC;
	signal ia_src_mem   : std_logic_vector (1 downto 0) := IA_SRC_PC;
	signal ia_src_wb    : std_logic_vector (1 downto 0) := IA_SRC_PC;
	--signal stall    : std_logic                     := '0';

	signal selected_ia  : std_logic_vector (31 downto 0) := (others => '0');
	signal selected_data : std_logic_vector (31 downto 0) := (others => '0');

begin

	-- port map
	pc : program_counter port map (
		clk    => clk,
		pc_in  => pc_in_if,
		pc_out => pc_out_if
	);

	imem : instruction_memory port map (
		clk                 => clk,
		instruction_address => instruction_address_if,
		instruction         => instruction_if
	);

	cont : control port map (
		clk               => clk,
		opcode            => instruction_id(31 downto 26),
		sub_opcode        => instruction_id(10 downto 1),
		branch_op         => instruction_id(25 downto 22),
		cr                => cr_out_mem,
		sender_full       => sender_full,
		recver_empty      => recver_empty,
		gpr_write_enable  => gpr_write_enable_id,
		fpr_write_enable  => fpr_write_enable_id,
		dmem_write_enable => dmem_write_enable_id,
		cr_g_write_enable => cr_g_write_enable_id,
		cr_f_write_enable => cr_f_write_enable_id,
		lr_write_enable   => lr_write_enable_id,
		ctr_write_enable  => ctr_write_enable_id,
		ext_op            => ext_op_id,
		alu_op            => alu_op_id,
		fpu_op            => fpu_op_id,
		fadd_op           => fadd_op_id,
		alu_src           => alu_src_id,
		dmem_src          => dmem_src_id,
		regs_src          => regs_src_id,
		lr_src            => lr_src_id,
		ia_src            => ia_src_id,
		--stall             => stall,
		sender_send       => sender_send_id,
		recver_recv       => recver_recv_id
	);

	ext : extend port map (
		ext_op  => ext_op_id,
		ext_in  => ext_in_id,
		ext_out => ext_out_id
	);

	gpr : general_purpose_registers port map (
		clk              => clk,
		gpr_write_enable => gpr_write_enable_wb,
		gpr_reg_num1     => gpr_reg_num1_id,
		gpr_reg_num2     => gpr_reg_num2_id,
		gpr_reg_num3     => gpr_reg_num3_id,
		gpr_data_in      => gpr_data_in_wb,
		gpr_data_out1    => gpr_data_out1_id,
		gpr_data_out2    => gpr_data_out2_id,
		gpr_data_out3    => gpr_data_out3_id
	);

	fpr : floating_point_registers port map (
		clk              => clk,
		fpr_write_enable => fpr_write_enable_wb,
		fpr_reg_num1     => fpr_reg_num1_id,
		fpr_reg_num2     => fpr_reg_num2_id,
		fpr_reg_num3     => fpr_reg_num3_id,
		fpr_data_in      => fpr_data_in_wb,
		fpr_data_out1    => fpr_data_out1_id,
		fpr_data_out2    => fpr_data_out2_id,
		fpr_data_out3    => fpr_data_out3_id
	);

	alu : arithmetic_logic_unit port map (
		alu_op   => alu_op_ex,
		alu_in1  => alu_in1_ex,
		alu_in2  => alu_in2_ex,
		alu_cond => alu_cond_ex,
		alu_out  => alu_out_ex
	);

	fpu : floating_point_unit port map (
		fpu_op   => fpu_op_ex,
		fpu_in1  => fpu_in1_ex,
		fpu_in2  => fpu_in2_ex,
		fpu_cond => fpu_cond_ex,
		fpu_out  => fpu_out_ex
	);

	fa : fadd_fsub port map (
		clk       => clk,
		fadd_op   => fadd_op_ex,
		fadd_in1  => fadd_in1_ex,
		fadd_in2  => fadd_in2_ex,
		fadd_out  => fadd_out_ex
	);

	fm : fmul port map (
		clk     => clk,
		input_a => fmul_in1_ex,
		input_b => fmul_in2_ex,
		output  => fmul_out_ex
	);

	fi : finv port map (
		clk    => clk,
		input  => finv_in_ex,
		output => finv_out_ex
	);

	dmem : data_memory port map (
		clk               => clk,
		dmem_write_enable => dmem_write_enable_mem,
		dmem_address      => dmem_address_mem,
		dmem_data_in      => dmem_data_in_mem,
		dmem_data_out     => dmem_data_out_mem,

		ZD     => ZD,
		ZA     => ZA,
		XWA    => XWA,
		XE1    => XE1,
		E2A    => E2A,
		XE3    => XE3,
		XGA    => XGA,
		XZCKE  => XZCKE,
		ADVA   => ADVA,
		XLBO   => XLBO,
		ZZA    => ZZA,
		XFT    => XFT,
		XZBE   => XZBE,
		ZCLKMA => ZCLKMA
	);

	cr : condition_register port map (
		clk               => clk,
		cr_g_write_enable => cr_g_write_enable_mem,
		cr_f_write_enable => cr_f_write_enable_mem,
		cr_in_g           => cr_in_g_mem,
		cr_in_f           => cr_in_f_mem,
		cr_out            => cr_out_mem
	);

	lr : link_register port map (
		clk             => clk,
		lr_write_enable => lr_write_enable_mem,
		lr_in           => lr_in_mem,
		lr_out          => lr_out_mem
	);

	ctr : count_register port map (
		clk              => clk,
		ctr_write_enable => ctr_write_enable_mem,
		ctr_in           => ctr_in_mem,
		ctr_out          => ctr_out_mem
	);

	send : sender port map (
		clk         => clk,
		sender_send => sender_send_mem,
		sender_in   => sender_in_mem,
		sender_full => sender_full,
		sender_out  => RS_TX
	);

	recv : recver port map (
		clk          => clk,
		recver_recv  => recver_recv_mem,
		recver_in    => RS_RX,
		recver_empty => recver_empty,
		recver_out   => recver_out_mem
	);

	-- data path

	pc_in_if <= instruction_address_if + 1;

	instruction_address_if <= pc_out_if  when ia_src_wb = IA_SRC_PC else
	                          lr_out_wb  when ia_src_wb = IA_SRC_LR else
	                          ctr_out_wb when ia_src_wb = IA_SRC_CTR else
	                          ext_out_wb;

	if_id : process (clk)
	begin
		if rising_edge(clk) then
			pc_out_id       <= pc_out_if;
			instruction_id  <= instruction_if;
			ext_in_id       <= instruction_if(15 downto 0);
			gpr_reg_num1_id <= instruction_if(20 downto 16);
			gpr_reg_num2_id <= instruction_if(15 downto 11);
			gpr_reg_num3_id <= instruction_if(25 downto 21);
			fpr_reg_num1_id <= instruction_if(20 downto 16);
			fpr_reg_num2_id <= instruction_if(15 downto 11);
			fpr_reg_num3_id <= instruction_if(25 downto 21);
		end if;
	end process;

	id_ex : process (clk)
	begin
		if rising_edge(clk) then
			pc_out_ex           <= pc_out_id;
			ext_out_ex          <= ext_out_id;
			gpr_data_out1_ex    <= gpr_data_out1_id;
			gpr_data_out2_ex    <= gpr_data_out2_id;
			gpr_data_out3_ex    <= gpr_data_out3_id;
			fpr_data_out1_ex    <= fpr_data_out1_id;
			fpr_data_out2_ex    <= fpr_data_out2_id;
			fpr_data_out3_ex    <= fpr_data_out3_id;
			alu_in1_ex          <= gpr_data_out1_id;
			fpu_in1_ex          <= fpr_data_out1_id;
			fpu_in2_ex          <= fpr_data_out2_id;
			fadd_in1_ex         <= fpr_data_out1_id;
			fadd_in2_ex         <= fpr_data_out2_id;
			fmul_in1_ex         <= fpr_data_out1_id;
			fmul_in2_ex         <= fpr_data_out2_id;
			finv_in_ex          <= fpr_data_out2_id;
			gpr_write_enable_ex <= gpr_write_enable_id;
			fpr_write_enable_ex <= fpr_write_enable_id;
			dmem_write_enable_ex <= dmem_write_enable_id;
			cr_g_write_enable_ex <= cr_g_write_enable_id;
			cr_f_write_enable_ex <= cr_f_write_enable_id;
			lr_write_enable_ex  <= lr_write_enable_id;
			ctr_write_enable_ex <= ctr_write_enable_id;
			fpu_op_ex           <= fpu_op_id;
			fadd_op_ex          <= fadd_op_id;
			alu_src_ex          <= alu_src_id;
			dmem_src_ex         <= dmem_src_id;
			regs_src_ex         <= regs_src_id;
			ia_src_ex           <= ia_src_id;
			sender_send_ex      <= sender_send_id;
			recver_recv_ex      <= recver_recv_id;
		end if;
	end process;

	alu_in2_ex <= ext_out_ex when alu_src_ex = ALU_SRC_EXT else gpr_data_out2_ex;

	mem_data_in_ex <= fpr_data_out3_ex when dmem_src_ex = DMEM_SRC_FPR else gpr_data_out3_ex;

	ex_mem : process (clk)
	begin
		if rising_edge(clk) then
			pc_out_mem           <= pc_out_ex;
			cr_in_g_mem          <= alu_cond_ex;
			cr_in_f_mem          <= fpu_cond_ex;
			ctr_in_mem           <= alu_out_ex;
			ext_out_mem          <= ext_out_ex;
			alu_out_mem          <= alu_out_ex;
			fpu_out_mem          <= fpu_out_ex;
			fadd_out_mem         <= fadd_out_ex;
			fmul_out_mem         <= fmul_out_ex;
			finv_out_mem         <= finv_out_ex;
			dmem_address_mem     <= alu_out_ex(19 downto 0);
			dmem_data_in_mem     <= mem_data_in_ex;
			sender_in_mem        <= mem_data_in_ex;
			gpr_write_enable_mem <= gpr_write_enable_ex;
			fpr_write_enable_mem <= fpr_write_enable_ex;
			dmem_write_enable_mem <= dmem_write_enable_ex;
			cr_g_write_enable_mem <= cr_g_write_enable_ex;
			cr_f_write_enable_mem <= cr_f_write_enable_ex;
			lr_write_enable_mem  <= lr_write_enable_ex;
			ctr_write_enable_mem <= ctr_write_enable_ex;
			regs_src_mem         <= regs_src_ex;
			ia_src_mem           <= ia_src_ex;
			sender_send_mem      <= sender_send_ex;
			recver_recv_mem      <= recver_recv_ex;
		end if;
	end process;

	lr_in_mem <= alu_out_mem when lr_src_mem = LR_SRC_ALU else pc_out_mem;

	mem_wb : process (clk)
	begin
		if rising_edge(clk) then
			lr_out_wb           <= lr_out_mem;
			ctr_out_wb          <= ctr_out_mem;
			ext_out_wb          <= ext_out_mem;
			alu_out_wb          <= alu_out_mem;
			dmem_data_out_wb    <= dmem_data_out_mem;
			recver_out_wb       <= recver_out_mem;
			fpu_out_wb          <= fpu_out_mem;
			fadd_out_wb         <= fadd_out_mem;
			fmul_out_wb         <= fmul_out_mem;
			finv_out_wb         <= finv_out_mem;
			gpr_write_enable_wb <= gpr_write_enable_mem;
			fpr_write_enable_wb <= fpr_write_enable_mem;
			regs_src_wb         <= regs_src_mem;
			ia_src_wb           <= ia_src_mem;
		end if;
	end process;

	selected_data <= alu_out_wb       when regs_src_wb = REGS_SRC_ALU  else
		             dmem_data_out_wb when regs_src_wb = REGS_SRC_DMEM else
		             lr_out_wb        when regs_src_wb = REGS_SRC_LR   else
		             recver_out_wb    when regs_src_wb = REGS_SRC_RECV else
		             fpu_out_wb       when regs_src_wb = REGS_SRC_FPU  else
		             fadd_out_wb      when regs_src_wb = REGS_SRC_FADD else
		             fmul_out_wb      when regs_src_wb = REGS_SRC_FMUL else
		             finv_out_wb;

	gpr_data_in_wb  <= selected_data;
	fpr_data_in_wb  <= selected_data;

end;
