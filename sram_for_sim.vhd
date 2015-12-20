library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sram_for_sim is
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
end sram_for_sim;

architecture struct of sram_for_sim is

	type ram_t is array(0 to 262143) of std_logic_vector (31 downto 0);
	signal mem : ram_t := (others => (others => '0'));

	signal state   : std_logic                      := '1';
	signal address : std_logic_vector (17 downto 0) := (others => '0');

begin

	process (ZCLKMA(0), ZD, ZA, XWA)
		variable ZDtmp : std_logic_vector (31 downto 0) := (others => 'Z');
	begin
		if rising_edge(ZCLKMA(0)) then
			ZDtmp := (others => 'Z');

			if (state = '0') then
				mem(conv_integer(address)) <= ZD;
			else
				ZDtmp := mem(conv_integer(address));
			end if;

			ZD <= ZDtmp;

			state   <= XWA;
			address <= ZA(19 downto 2);
		end if;
	end process;

end;