library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity data_memory is
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
end data_memory;

architecture struct of data_memory is

	signal ZDdebug : std_logic_vector (31 downto 0) := (others => 'Z');

	signal state : std_logic_vector (1 downto 0) := (others => '0');

	type data_mem is array(0 to 1) of std_logic_vector (31 downto 0);
	signal data : data_mem := ("00000000000000000000000000000000", "00000000000000000000000000000000");

begin

	-- 固定
	XWA <= not dmem_write_enable;
	XE1 <= '0';
	E2A <= '1';
	XE3 <= '0';
	XGA <= '0';
	XZCKE <= '0';
	ADVA <= '0';
	XLBO <= '1';
	ZZA <= '0';
	XFT <= '1';
	XZBE <= "0000";
	ZCLKMA(0) <= clk;
	ZCLKMA(1) <= clk;
	ZA <= dmem_data_address;

	dmem_read_data <= ZD;

	process (clk, dmem_write_enable, dmem_data_address, dmem_write_data, ZD)
	begin
		if (rising_edge(clk)) then
			if (state(1) = '0') then	-- 2clk 前は read だった
				ZD <= (others => 'Z');
				ZDdebug <= (others => 'Z');
			else						-- 2clk 前は write だった
				ZD <= data(1);
				ZDdebug <= data(1);
			end if;

			-- 更新
			state(0) <= state(1);			-- 1clk 後の state
			state(1) <= dmem_write_enable;	-- 2clk 後の state

			data(0) <= data(1);				-- 1clk 後に送る data
			data(1) <= dmem_write_data;		-- 2clk 後に送る data
		end if;
	end process;

end;