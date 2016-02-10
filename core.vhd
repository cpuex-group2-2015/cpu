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
			clk		: in  std_logic;
			pc_in	: in  std_logic_vector (31 downto 0);
			pc_out	: out std_logic_vector (31 downto 0)
		);
	end component;

	component instruction_memory is
		port (
			clk					: in  std_logic;
			instruction_address	: in  std_logic_vector (31 downto 0);
			instruction			: out std_logic_vector (31 downto 0)
		);
	end component;

	component general_purpose_registers is
		port (
			clk				    : in  std_logic;
			gpr_write_enable	: in  std_logic;
			gpr_read_reg_num1	: in  std_logic_vector (4 downto 0);
			gpr_read_reg_num2	: in  std_logic_vector (4 downto 0);
			gpr_read_reg_num3	: in  std_logic_vector (4 downto 0);
			gpr_write_reg_num	: in  std_logic_vector (4 downto 0);
			gpr_write_data	    : in  std_logic_vector (31 downto 0);
			gpr_read_data1		: out std_logic_vector (31 downto 0);
			gpr_read_data2		: out std_logic_vector (31 downto 0);
			gpr_read_data3		: out std_logic_vector (31 downto 0)
		);
	end component;

	component floating_point_registers is
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

	component arithmetic_logic_unit is
		port (
			alu_op   : in  alu_op_t;
			alu_in1  : in  std_logic_vector (31 downto 0);
			alu_in2  : in  std_logic_vector (31 downto 0);
			alu_cond : out std_logic_vector (2 downto 0);
			alu_out  : out std_logic_vector (31 downto 0)
		);
	end component;

	component floating_point_unit is
		port (
			fpu_op   : in  fpu_op_t;
			fpu_in1  : in  std_logic_vector (31 downto 0);
			fpu_in2  : in  std_logic_vector (31 downto 0);
			fpu_cond : out std_logic_vector (3 downto 0);
			fpu_out  : out std_logic_vector (31 downto 0)
		);
	end component;

	component fadd_fsub is
		port (
			clk       : in  std_logic;
			fadd_op   : in  fadd_op_t;
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

	component extend is
		port (
			ext_op  : ext_op_t;
			ext_in  : in  std_logic_vector (15 downto 0);
			ext_out : out std_logic_vector (31 downto 0)
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
			ext_op            : out ext_op_t;
			alu_op            : out alu_op_t;
			fpu_op            : out fpu_op_t;
			fadd_op           : out fadd_op_t;
			alu_src           : out alu_src_t;
			dmem_src          : out dmem_src_t;
			data_src          : out data_src_t;
			lr_src            : out lr_src_t;
			ia_src            : out ia_src_t;
			stall_src         : out stall_src_t;
			sender_send       : out std_logic;
			recver_recv       : out std_logic
		);
	end component;

	signal pc_in  : std_logic_vector (31 downto 0) := (others => '0');
	signal pc_out : std_logic_vector (31 downto 0) := (others => '0');

	signal instruction_address : std_logic_vector (31 downto 0) := (others => '0');
	signal instruction         : std_logic_vector (31 downto 0) := (others => '0');
	
	signal selected_ia  : std_logic_vector (31 downto 0) := (others => '0');

	signal gpr_write_enable  : std_logic                      := '0';
	signal gpr_read_reg_num1 : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_read_reg_num2 : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_read_reg_num3 : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_write_reg_num : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_write_data    : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_read_data1    : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_read_data2    : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_read_data3    : std_logic_vector (31 downto 0) := (others => '0');

	signal fpr_write_enable  : std_logic                      := '0';
	signal fpr_read_reg_num1 : std_logic_vector (4 downto 0)  := (others => '0');
	signal fpr_read_reg_num2 : std_logic_vector (4 downto 0)  := (others => '0');
	signal fpr_read_reg_num3 : std_logic_vector (4 downto 0)  := (others => '0');
	signal fpr_write_reg_num : std_logic_vector (4 downto 0)  := (others => '0');
	signal fpr_write_data    : std_logic_vector (31 downto 0) := (others => '0');
	signal fpr_read_data1    : std_logic_vector (31 downto 0) := (others => '0');
	signal fpr_read_data2    : std_logic_vector (31 downto 0) := (others => '0');
	signal fpr_read_data3    : std_logic_vector (31 downto 0) := (others => '0');

	signal dmem_write_enable : std_logic                      := '0';
	signal dmem_address      : std_logic_vector (19 downto 0) := (others => '0');
	signal dmem_data_in      : std_logic_vector (31 downto 0) := (others => '0');
	signal dmem_data_out     : std_logic_vector (31 downto 0) := (others => '0');

	signal alu_op   : alu_op_t                       := alu_op_add;
	signal alu_in1  : std_logic_vector (31 downto 0) := (others => '0');
	signal alu_in2  : std_logic_vector (31 downto 0) := (others => '0');
	signal alu_cond : std_logic_vector (2 downto 0)  := (others => '0');
	signal alu_out  : std_logic_vector (31 downto 0) := (others => '0');

	signal fpu_op   : fpu_op_t                       := fpu_op_bypass;
	signal fpu_in1  : std_logic_vector (31 downto 0) := (others => '0');
	signal fpu_in2  : std_logic_vector (31 downto 0) := (others => '0');
	signal fpu_cond : std_logic_vector (3 downto 0)  := (others => '0');
	signal fpu_out  : std_logic_vector (31 downto 0) := (others => '0');

	signal fadd_op   : fadd_op_t                      := fadd_op_add;
	signal fadd_in1  : std_logic_vector (31 downto 0) := (others => '0');
	signal fadd_in2  : std_logic_vector (31 downto 0) := (others => '0');
	signal fadd_out  : std_logic_vector (31 downto 0) := (others => '0');

	signal fmul_in1  : std_logic_vector (31 downto 0) := (others => '0');
	signal fmul_in2  : std_logic_vector (31 downto 0) := (others => '0');
	signal fmul_out  : std_logic_vector (31 downto 0) := (others => '0');

	signal finv_in   : std_logic_vector (31 downto 0) := (others => '0');
	signal finv_out  : std_logic_vector (31 downto 0) := (others => '0');

	signal ext_op  : ext_op_t                       := ext_op_unsigned;
	signal ext_in  : std_logic_vector (15 downto 0) := (others => '0');
	signal ext_out : std_logic_vector (31 downto 0) := (others => '0');

	signal cr_g_write_enable : std_logic                     := '0';
	signal cr_f_write_enable : std_logic                     := '0';
	signal cr_in_g           : std_logic_vector (2 downto 0) := (others => '0');
	signal cr_in_f           : std_logic_vector (3 downto 0) := (others => '0');
	signal cr_out            : std_logic_vector (3 downto 0) := (others => '0');

	signal lr_write_enable : std_logic                      := '0';
	signal lr_in           : std_logic_vector (31 downto 0) := (others => '0');
	signal lr_out          : std_logic_vector (31 downto 0) := (others => '0');

	signal ctr_write_enable : std_logic                      := '0';
	signal ctr_in           : std_logic_vector (31 downto 0) := (others => '0');
	signal ctr_out          : std_logic_vector (31 downto 0) := (others => '0');

	signal sender_send : std_logic                      := '0';
	signal sender_in   : std_logic_vector (31 downto 0) := (others => '0');
	signal sender_full : std_logic                      := '0';
	signal sender_out  : std_logic                      := '0';

	signal recver_recv  : std_logic                      := '0';
	signal recver_in    : std_logic                      := '0';
	signal recver_empty : std_logic                      := '0';
	signal recver_out   : std_logic_vector (31 downto 0) := (others => '0');

	signal alu_src      : alu_src_t   := alu_src_gpr;
	signal dmem_src     : dmem_src_t  := dmem_src_gpr;
	signal data_src     : data_src_t  := data_src_alu;
	signal lr_src       : lr_src_t    := lr_src_pc;
	signal ia_src       : ia_src_t    := ia_src_pc;
	signal stall_src    : stall_src_t := stall_src_go;

	signal selected_data : std_logic_vector (31 downto 0) := (others => '0');

begin

	-- port map
	pc : program_counter port map (
		clk    => clk,
		pc_in  => pc_in,
		pc_out => pc_out
	);

	imem : instruction_memory port map (
		clk					=> clk,
		instruction_address	=> instruction_address,
		instruction			=> instruction
	);

	gpr : general_purpose_registers port map (
		clk               => clk,
		gpr_write_enable  => gpr_write_enable,
		gpr_read_reg_num1 => gpr_read_reg_num1,
		gpr_read_reg_num2 => gpr_read_reg_num2,
		gpr_read_reg_num3 => gpr_read_reg_num3,
		gpr_write_reg_num => gpr_write_reg_num,
		gpr_write_data	  => gpr_write_data,
		gpr_read_data1    => gpr_read_data1,
		gpr_read_data2    => gpr_read_data2,
		gpr_read_data3    => gpr_read_data3
	);

	fpr : floating_point_registers port map (
		clk               => clk,
		fpr_write_enable  => fpr_write_enable,
		fpr_read_reg_num1 => fpr_read_reg_num1,
		fpr_read_reg_num2 => fpr_read_reg_num2,
		fpr_read_reg_num3 => fpr_read_reg_num3,
		fpr_write_reg_num => fpr_write_reg_num,
		fpr_write_data	  => fpr_write_data,
		fpr_read_data1    => fpr_read_data1,
		fpr_read_data2    => fpr_read_data2,
		fpr_read_data3    => fpr_read_data3
	);

	dmem : data_memory port map (
		clk               => clk,
		dmem_write_enable => dmem_write_enable,
		dmem_address      => dmem_address,
		dmem_data_in      => dmem_data_in,
		dmem_data_out     => dmem_data_out,

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

	alu : arithmetic_logic_unit port map (
		alu_op   => alu_op,
		alu_in1  => alu_in1,
		alu_in2  => alu_in2,
		alu_cond => alu_cond,
		alu_out  => alu_out
	);

	fpu : floating_point_unit port map (
		fpu_op   => fpu_op,
		fpu_in1  => fpu_in1,
		fpu_in2  => fpu_in2,
		fpu_cond => fpu_cond,
		fpu_out  => fpu_out
	);

	fa : fadd_fsub port map (
		clk       => clk,
		fadd_op   => fadd_op,
		fadd_in1  => fadd_in1,
		fadd_in2  => fadd_in2,
		fadd_out  => fadd_out
	);

	fm : fmul port map (
		clk     => clk,
		input_a => fmul_in1,
		input_b => fmul_in2,
		output  => fmul_out
	);

	fi : finv port map (
		clk    => clk,
		input  => finv_in,
		output => finv_out
	);

	ext : extend port map (
		ext_op  => ext_op,
		ext_in  => ext_in,
		ext_out => ext_out
	);

	cr : condition_register port map (
		clk               => clk,
		cr_g_write_enable => cr_g_write_enable,
		cr_f_write_enable => cr_f_write_enable,
		cr_in_g           => cr_in_g,
		cr_in_f           => cr_in_f,
		cr_out            => cr_out
	);

	lr : link_register port map (
		clk             => clk,
		lr_write_enable => lr_write_enable,
		lr_in           => lr_in,
		lr_out          => lr_out
	);

	ctr : count_register port map (
		clk              => clk,
		ctr_write_enable => ctr_write_enable,
		ctr_in           => ctr_in,
		ctr_out          => ctr_out
	);

	send : sender port map (
		clk         => clk,
		sender_send => sender_send,
		sender_in   => sender_in,
		sender_full => sender_full,
		sender_out  => sender_out
	);

	recv : recver port map (
		clk          => clk,
		recver_recv  => recver_recv,
		recver_in    => recver_in,
		recver_empty => recver_empty,
		recver_out   => recver_out
	);

	cont : control port map (
		clk               => clk,
		opcode            => instruction(31 downto 26),
		sub_opcode        => instruction(10 downto 1),
		branch_op         => instruction(25 downto 22),
		cr                => cr_out,
		sender_full       => sender_full,
		recver_empty      => recver_empty,
		gpr_write_enable  => gpr_write_enable,
		fpr_write_enable  => fpr_write_enable,
		dmem_write_enable => dmem_write_enable,
		cr_g_write_enable => cr_g_write_enable,
		cr_f_write_enable => cr_f_write_enable,
		lr_write_enable   => lr_write_enable,
		ctr_write_enable  => ctr_write_enable,
		ext_op            => ext_op,
		alu_op            => alu_op,
		fpu_op            => fpu_op,
		fadd_op           => fadd_op,
		alu_src           => alu_src,
		dmem_src          => dmem_src,
		data_src          => data_src,
		lr_src            => lr_src,
		ia_src            => ia_src,
		stall_src         => stall_src,
		sender_send       => sender_send,
		recver_recv       => recver_recv
	);

	-- data path

	alu_in2 <= gpr_read_data2 when alu_src = alu_src_gpr else
	           ext_out        when alu_src = alu_src_ext;

	dmem_data_in <= gpr_read_data3 when dmem_src = dmem_src_gpr else
	                fpr_read_data3 when dmem_src = dmem_src_fpr;

	selected_data <= alu_out       when data_src = data_src_alu  else
		             dmem_data_out when data_src = data_src_dmem else
		             lr_out        when data_src = data_src_lr   else
		             recver_out    when data_src = data_src_recv else
		             fpu_out       when data_src = data_src_fpu  else
		             fadd_out      when data_src = data_src_fadd else
		             fmul_out      when data_src = data_src_fmul else
		             finv_out      when data_src = data_src_finv;

	lr_in <= pc_out  when lr_src = lr_src_pc else
	         alu_out when lr_src = lr_src_alu;

	selected_ia <= pc_out  when ia_src = ia_src_pc  else
	               lr_out  when ia_src = ia_src_lr  else
	               ctr_out when ia_src = ia_src_ctr else
	               ext_out when ia_src = ia_src_ext;

	instruction_address <= selected_ia - 1 when stall_src = stall_src_stall else
	                       selected_ia;

	pc_in <= instruction_address when (instruction_address = "11111111111111") else
	         instruction_address + 1;

	gpr_read_reg_num1 <= instruction(20 downto 16);
	gpr_read_reg_num2 <= instruction(15 downto 11);
	gpr_read_reg_num3 <= instruction(25 downto 21);
	gpr_write_reg_num <= instruction(25 downto 21);
	gpr_write_data    <= selected_data;

	fpr_read_reg_num1 <= instruction(20 downto 16);
	fpr_read_reg_num2 <= instruction(15 downto 11);
	fpr_read_reg_num3 <= instruction(25 downto 21);
	fpr_write_reg_num <= instruction(25 downto 21);
	fpr_write_data    <= selected_data;

	ext_in <= instruction(15 downto 0);

	alu_in1 <= gpr_read_data1;

	fpu_in1 <= fpr_read_data1;
	fpu_in2 <= fpr_read_data2;

	fadd_in1 <= fpr_read_data1;
	fadd_in2 <= fpr_read_data2;

	fmul_in1 <= fpr_read_data1;
	fmul_in2 <= fpr_read_data2;

	finv_in <= fpr_read_data2;

	cr_in_g <= alu_cond;
	cr_in_f <= fpu_cond;

	ctr_in <= alu_out;

	dmem_address <= alu_out(19 downto 0);

	sender_in <= dmem_data_in;
	RS_TX     <= sender_out;
	recver_in <= RS_RX;

end;