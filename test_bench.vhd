library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity testbench is
end testbench;

architecture testbench of testbench is 

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

	component data_memory is
		port (
			clk               : in  std_logic;
			dmem_write_enable : in  std_logic;
			dmem_data_address : in  std_logic_vector (19 downto 0);
			dmem_write_data   : in  std_logic_vector (31 downto 0);
			dmem_read_data    : out std_logic_vector (31 downto 0);

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

	component sram_for_sim is
		port (
			ZD     : inout std_logic_vector (31 downto 0);	-- データ線
			ZA     : in    std_logic_vector (19 downto 0);	-- アドレス 
			XWA    : in    std_logic;						-- write enable 線
			XE1    : in    std_logic;						-- 0固定
			E2A    : in    std_logic;						-- 1固定
			XE3    : in    std_logic;						-- 0固定
			XGA    : in    std_logic;						-- 出力イネーブル 0固定
			XZCKE  : in    std_logic;						-- クロックイネーブル 0固定
			ADVA   : in    std_logic;						-- バーストアクセス 0固定
			XLBO   : in    std_logic;						-- バーストアクセスのアドレス順 1固定
			ZZA    : in    std_logic;						-- スリープモード 0固定
			XFT    : in    std_logic;						-- Flow Through Mode 1固定
			XZBE   : in    std_logic_vector (3 downto 0);	-- 書き込みマスク 0固定
			ZCLKMA : in    std_logic_vector (1 downto 0)	-- クロック
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

	component extend is
		port (
			ext_op  : in  std_logic_vector (1 downto 0);
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
			cr_in_f           : in  std_logic;
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

	component control is
		port (
			clk               : in  std_logic;
			opcode            : in  std_logic_vector (5 downto 0);
			sub_opcode        : in  std_logic_vector (9 downto 0);
			branch_op         : in  std_logic_vector (3 downto 0);
			cr                : in  std_logic_vector (3 downto 0);
			gpr_write_enable  : out std_logic;
			dmem_write_enable : out std_logic;
			cr_g_write_enable : out std_logic;
			lr_write_enable   : out std_logic;
			ctr_write_enable  : out std_logic;
			ext_op            : out std_logic_vector (1 downto 0);
			alu_op            : out std_logic_vector (2 downto 0);
			alu_src           : out std_logic;
			gpr_data_src      : out std_logic_vector (1 downto 0);
			lr_src            : out std_logic;
			ia_src            : out std_logic_vector (1 downto 0);
			stall_src           : out std_logic
		);
	end component;

	component adder is
		port (
			adder_a	: in  std_logic_vector (31 downto 0);
			adder_b	: in  std_logic_vector (31 downto 0);
			adder_s	: out std_logic_vector (31 downto 0)
		);
	end component;

	component multi_plexer2 is
		port (
			sel		: in  std_logic;
			mux_in0	: in  std_logic_vector (31 downto 0);
			mux_in1	: in  std_logic_vector (31 downto 0);
			mux_out	: out std_logic_vector (31 downto 0)
		);
	end component;

	component multi_plexer4 is
		port (
			sel		: in  std_logic_vector (1 downto 0);
			mux_in0	: in  std_logic_vector (31 downto 0);
			mux_in1	: in  std_logic_vector (31 downto 0);
			mux_in2	: in  std_logic_vector (31 downto 0);
			mux_in3	: in  std_logic_vector (31 downto 0);
			mux_out	: out std_logic_vector (31 downto 0)
		);
	end component;

	signal simclk : std_logic;

	signal pc_in  : std_logic_vector (31 downto 0) := (others => '0');
	signal pc_out : std_logic_vector (31 downto 0) := (others => '0');

	signal instruction_address : std_logic_vector (31 downto 0) := (others => '0');
	signal instruction         : std_logic_vector (31 downto 0) := (others => '0');
	
	signal selected_ia  : std_logic_vector (31 downto 0) := (others => '0');
	signal ia_minus_one : std_logic_vector (31 downto 0) := (others => '0');

	signal gpr_write_enable  : std_logic                      := '0';
	signal gpr_read_reg_num1 : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_read_reg_num2 : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_read_reg_num3 : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_write_reg_num : std_logic_vector (4 downto 0)  := (others => '0');
	signal gpr_write_data    : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_read_data1    : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_read_data2    : std_logic_vector (31 downto 0) := (others => '0');
	signal gpr_read_data3    : std_logic_vector (31 downto 0) := (others => '0');

	signal dmem_write_enable : std_logic                      := '0';
	signal dmem_data_address : std_logic_vector (19 downto 0) := (others => '0');
	signal dmem_write_data   : std_logic_vector (31 downto 0) := (others => '0');
	signal dmem_read_data    : std_logic_vector (31 downto 0) := (others => '0');

	signal ZD     : std_logic_vector (31 downto 0);	-- データ線
	signal ZA     : std_logic_vector (19 downto 0);	-- アドレス 
	signal XWA    : std_logic;						-- write enable 線
	signal XE1    : std_logic;						-- 0固定
	signal E2A    : std_logic;						-- 1固定
	signal XE3    : std_logic;						-- 0固定
	signal XGA    : std_logic;						-- 出力イネーブル 0固定
	signal XZCKE  : std_logic;						-- クロックイネーブル 0固定
	signal ADVA   : std_logic;						-- バーストアクセス 0固定
	signal XLBO   : std_logic;						-- バーストアクセスのアドレス順 1固定
	signal ZZA    : std_logic;						-- スリープモード 0固定
	signal XFT    : std_logic;						-- Flow Through Mode 1固定
	signal XZBE   : std_logic_vector (3 downto 0);	-- 書き込みマスク 0固定
	signal ZCLKMA : std_logic_vector (1 downto 0);	-- クロック

	signal alu_op   : std_logic_vector (2 downto 0)  := (others => '0');
	signal alu_in1  : std_logic_vector (31 downto 0) := (others => '0');
	signal alu_in2  : std_logic_vector (31 downto 0) := (others => '0');
	signal alu_cond : std_logic_vector (2 downto 0)  := (others => '0');
	signal alu_out  : std_logic_vector (31 downto 0) := (others => '0');

	signal ext_op  : std_logic_vector (1 downto 0)  := (others => '0');
	signal ext_in  : std_logic_vector (15 downto 0) := (others => '0');
	signal ext_out : std_logic_vector (31 downto 0) := (others => '0');

	signal cr_g_write_enable : std_logic                     := '0';
	signal cr_f_write_enable : std_logic                     := '0';
	signal cr_in_g           : std_logic_vector (2 downto 0) := (others => '0');
	signal cr_in_f           : std_logic                     := '0';
	signal cr_out            : std_logic_vector (3 downto 0) := (others => '0');

	signal lr_write_enable : std_logic                      := '0';
	signal lr_in           : std_logic_vector (31 downto 0) := (others => '0');
	signal lr_out          : std_logic_vector (31 downto 0) := (others => '0');

	signal ctr_write_enable : std_logic                      := '0';
	signal ctr_in           : std_logic_vector (31 downto 0) := (others => '0');
	signal ctr_out          : std_logic_vector (31 downto 0) := (others => '0');

	signal alu_src      : std_logic                     := '0';
	signal gpr_data_src : std_logic_vector (1 downto 0) := (others => '0');
	signal lr_src       : std_logic                     := '0';
	signal ia_src       : std_logic_vector (1 downto 0) := (others => '0');
	signal stall_src    : std_logic                     := '0';

begin

	-- port map
	pc : program_counter port map (
		clk    => simclk,
		pc_in  => pc_in,
		pc_out => pc_out
	);

	imem : instruction_memory port map (
		clk					=> simclk,
		instruction_address	=> instruction_address,
		instruction			=> instruction
	);

	gpr : general_purpose_registers port map (
		clk               => simclk,
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

	dmem : data_memory port map (
		clk               => simclk,
		dmem_write_enable => dmem_write_enable,
		dmem_data_address => dmem_data_address,
		dmem_write_data   => dmem_write_data,
		dmem_read_data    => dmem_read_data,

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

	sram : sram_for_sim port map (
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

	ext : extend port map (
		ext_op  => ext_op,
		ext_in  => ext_in,
		ext_out => ext_out
	);

	cr : condition_register port map (
		clk               => simclk,
		cr_g_write_enable => cr_g_write_enable,
		cr_f_write_enable => cr_f_write_enable,
		cr_in_g           => cr_in_g,
		cr_in_f           => cr_in_f,
		cr_out            => cr_out
	);

	lr : link_register port map (
		clk             => simclk,
		lr_write_enable => lr_write_enable,
		lr_in           => lr_in,
		lr_out          => lr_out
	);

	ctr : count_register port map (
		clk              => simclk,
		ctr_write_enable => ctr_write_enable,
		ctr_in           => ctr_in,
		ctr_out          => ctr_out
	);

	cont : control port map (
		clk               => simclk,
		opcode            => instruction(31 downto 26),
		sub_opcode        => instruction(10 downto 1),
		branch_op         => instruction(25 downto 22),
		cr                => cr_out,
		gpr_write_enable  => gpr_write_enable,
		dmem_write_enable => dmem_write_enable,
		cr_g_write_enable => cr_g_write_enable,
		lr_write_enable   => lr_write_enable,
		ctr_write_enable  => ctr_write_enable,
		ext_op            => ext_op,
		alu_op            => alu_op,
		alu_src           => alu_src,
		gpr_data_src      => gpr_data_src,
		lr_src            => lr_src,
		ia_src            => ia_src,
		stall_src         => stall_src
	);

	-- data path

	mux_alu_src : multi_plexer2 port map (
		sel		=> alu_src,
		mux_in0	=> gpr_read_data2,
		mux_in1	=> ext_out,
		mux_out	=> alu_in2
	);

	mux_gpr_data_src : multi_plexer4 port map (
		sel		=> gpr_data_src,
		mux_in0	=> alu_out,
		mux_in1	=> dmem_read_data,
		mux_in2	=> lr_out,
		mux_in3	=> alu_out,
		mux_out	=> gpr_write_data
	);

	mux_lr_src : multi_plexer2 port map (
		sel		=> lr_src,
		mux_in0	=> pc_out,
		mux_in1	=> alu_out,
		mux_out	=> lr_in
	);

	mux_ia_src : multi_plexer4 port map (
		sel		=> ia_src,
		mux_in0	=> pc_out,
		mux_in1	=> lr_out,
		mux_in2	=> ctr_out,
		mux_in3	=> ext_out,
		mux_out	=> selected_ia
	);

	mux_stall : multi_plexer2 port map (
		sel		=> stall_src,
		mux_in0	=> selected_ia,
		mux_in1	=> ia_minus_one,
		mux_out	=> instruction_address
	);

	inclementer_for_pc : adder port map (
		adder_a	=> instruction_address,
		adder_b	=> "00000000000000000000000000000001",
		adder_s	=> pc_in
	);

	ia_minus_one <= selected_ia - 1;

	gpr_read_reg_num1 <= instruction(20 downto 16);
	gpr_read_reg_num2 <= instruction(15 downto 11);
	gpr_read_reg_num3 <= instruction(25 downto 21);
	gpr_write_reg_num <= instruction(25 downto 21);
	ext_in <= instruction(15 downto 0);
	alu_in1 <= gpr_read_data1;
	cr_in_g <= alu_cond;
	ctr_in <= alu_out;
	dmem_data_address <= alu_out(19 downto 0);
	dmem_write_data <= gpr_read_data3;

	-- generate clock for the simulation
	clockgen : process
	begin
		simclk <= '0';
		wait for 5 ns;
		simclk <= '1';
		wait for 5 ns;
	end process;

end;