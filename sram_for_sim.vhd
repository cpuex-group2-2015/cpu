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

	signal ZDdebug : std_logic_vector (31 downto 0) := (others => 'Z');

	type ram_t is array(1048575 downto 0) of std_logic_vector (31 downto 0);	-- 1048576
	signal mem : ram_t := (others => (others => '0'));

	signal state : std_logic_vector (2 downto 0) := (others => '0');

	type addr_mem is array(2 downto 0) of std_logic_vector (19 downto 0);
	signal address : addr_mem := (others => (others => '0'));

begin

	--process (ZCLKMA(0), ZD, ZA, XWA)
	--begin
	--	if rising_edge(ZCLKMA(0)) then
	--		if (state(0) = '1') then						-- 2clk 前は read だった
	--			ZD <= mem(conv_integer(address(0)));		-- 2clk 前に受け取った address の data を出力する
	--		else											-- 2clk 前は write だった
	--			mem(conv_integer(address(0))) <= ZD;		-- 今与えられている data を 2clk 前に受け取った address に書き込む
	--		end if;

	--		-- 更新
	--		state(0) <= state(1);		-- 1clk 後の state
	--		state(1) <= XWA;			-- 2clk 後の state

	--		address(0) <= address(1);	-- 1clk 後に使う address
	--		address(1) <= ZA;			-- 2clk 後に使う address
	--	end if;
	--end process;

	process (ZCLKMA(0), ZD, ZA, XWA)
		variable ZDtmp : std_logic_vector (31 downto 0);
	begin
		if rising_edge(ZCLKMA(0)) then
			state(0) <= state(1);
			state(1) <= state(2);
			state(2) <= XWA;

			address(0)  <= address(1);
			address(1)  <= address(2);
			address(2)  <= ZA;

			--zdbi(1) <= ZD;

			ZDtmp := (others => 'Z');

			if (state(2) = '0') then
				mem(conv_integer(address(2))) <= ZD;
			else
				ZDtmp := mem(conv_integer(address(2)));
			end if;

			ZD <= ZDtmp;
			ZDdebug <= ZDtmp;
		end if;
	end process;

	--process (ZCLKMA(0), ZD, ZA, XWA)
	--	variable ZDtmp : std_logic_vector (31 downto 0);
	--begin
	--	if rising_edge(ZCLKMA(0)) then
	--		state(0) <= state(1);
	--		state(1) <= state(2);
	--		state(2) <= XWA;

	--		address(0)  <= address(1);
	--		address(1)  <= address(2);
	--		address(2)  <= ZA;

	--		--zdbi(1) <= ZD;

	--		ZDtmp := (others => 'Z');

	--		if state(1 downto 0) = "10" then
	--			mem(conv_integer(address(1))) <= ZD;
	--			ZDtmp := ZD;
	--		elsif state(1 downto 0) = "11" then
	--			ZDtmp := mem(conv_integer(address(2)));
	--		else
	--			mem(conv_integer(address(1))) <= ZD;
	--			ZDtmp := (others => 'Z');
	--		end if;

	--		ZD <= ZDtmp;
	--		ZDdebug <= ZDtmp;
	--	end if;
	--end process;

end;