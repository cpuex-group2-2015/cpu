library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity testbench is
end testbench;

architecture testbench of testbench is

	component core is
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

	component recver_for_sim is
		port (
			clk          : in  std_logic;
			recver_in    : in  std_logic
		);
	end component;

	signal simclk : std_logic;

	signal RS_RX : std_logic;
	signal RS_TX : std_logic;

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

begin

	-- port map

	cpu : core port map (
		clk    => simclk,
		RS_RX  => RS_RX,
		RS_TX  => RS_TX,
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

	recv : recver_for_sim port map (
		clk       => simclk,
		recver_in => RS_TX
	);

	-- generate clock for the simulation
	clockgen : process
	begin
		simclk <= '0';
		wait for 5 ns;
		simclk <= '1';
		wait for 5 ns;
	end process;

end;