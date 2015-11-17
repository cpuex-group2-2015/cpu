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
--1048576
	type ram_t is array(0 to 1048575) of std_logic_vector (31 downto 0);
	signal tb_ram : ram_t;

	signal state : std_logic_vector (1 downto 0);

	type data_mem is array(0 to 1) of std_logic_vector (31 downto 0);
	signal data_to_write : data_mem := ("00000000000000000000000000000000", "00000000000000000000000000000000");

	type addr_mem is array(0 to 1) of std_logic_vector (19 downto 0);
	signal address : addr_mem := ("00000000000000000000", "00000000000000000000");

begin

	process (ZCLKMA(0))
	begin
		if rising_edge(ZCLKMA(0)) then
			if (state(0) = '0') then	-- 2clk 前は read だった
				ZD <= tb_ram(conv_integer(address(0)));					-- 2clk 前に受け取った address の data を出力する
			else						-- 2clk 前は write だった
				ZD <= "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL";
				tb_ram(conv_integer(address(0))) <= data_to_write(0);	-- 2clk 前に write 用として受け取った data を 2clk 前に受け取った address に書き込む
			end if;

			-- state の更新
			state(0) <= state(1);	-- 1clk 後の state
			state(1) <= XWA;		-- 2clk 後の state

			data_to_write(0) <= data_to_write(1);	-- 1clk 後に書き込む data
			data_to_write(1) <= ZD;					-- 2clk 後に書き込む data

			address(0) <= address(1);		-- 1clk 後に使う address
			address(1) <= ZA;	-- 2clk 後に使う address

		end if;
	end process;

end;