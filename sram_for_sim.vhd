library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sram_for_sim is
	port (
		ZD     : inout std_logic_vector (31 downto 0) := (others => 'Z');	-- データ線
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

	type ram_t is array(0 to 1048575) of std_logic_vector (31 downto 0);
	signal mem : ram_t := (others => (others => '0'));

	signal xwa_array : std_logic_vector (1 downto 0) := (others => '1');

	type addr_t is array (1 downto 0) of std_logic_vector (19 downto 0);
	signal addr_array : addr_t := (others => (others => '0'));

	type data_t is array (1 downto 0) of std_logic_vector (31 downto 0);
	signal data_array : data_t := (others => (others => '0'));

	signal ZDdebug : std_logic_vector (31 downto 0) := (others => '0');

	signal hey : std_logic := '0';

begin

	hey <= '1' when (ZD = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ") else '0';

	process (ZCLKMA(0))
		variable ZDtmp : std_logic_vector (31 downto 0) := (others => 'Z');
		variable ZDdebugtmp : std_logic_vector (31 downto 0) := (others => 'Z');
	begin
		if rising_edge(ZCLKMA(0)) then
			xwa_array(0) <= XWA;
			xwa_array(1) <= xwa_array(0);

			addr_array(0) <= ZA;
			addr_array(1) <= addr_array(0);

			ZDtmp := (others => 'Z');
			ZDdebugtmp := (others => 'Z');

			if xwa_array (1 downto 0) = "01" then
				mem(conv_integer(addr_array(1))) <= ZD;
				if (addr_array(1) = ZA) then
					ZDtmp := ZD;
					ZDdebugtmp := ZD;
				else
					ZDtmp := mem(conv_integer(addr_array(0)));
					ZDdebugtmp := mem(conv_integer(addr_array(0)));
				end if;
			elsif xwa_array (1 downto 0) = "11" then
				ZDtmp := mem(conv_integer(addr_array(0)));
				ZDdebugtmp := mem(conv_integer(addr_array(0)));
			else
				mem(conv_integer(addr_array(0))) <= ZD;
				ZDtmp := (others => 'Z');
				ZDdebugtmp := (others => 'Z');
			end if;

			--if (xwa_array(0) = '0') then
			--	mem(conv_integer(addr_array(0))) <= ZD;
			--	ZDtmp := (others => 'Z');
			--	ZDdebugtmp := (others => 'Z');
			--else
			--	if (xwa_array(1) = '0') then
			--		mem(conv_integer(addr_array(1))) <= ZD;
			--		ZDtmp := ZD;
			--		ZDdebugtmp := ZD;
			--	else
			--		ZDtmp := mem(conv_integer(addr_array(0)));
			--		ZDdebugtmp := mem(conv_integer(addr_array(0)));
			--	end if;
			--end if;

			ZD <= ZDtmp;
			ZDdebug <= ZDdebugtmp;

		end if;
	end process;

end;