library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
	port (
		MCLK1  : in    std_logic;
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
end top;

architecture struct of top is

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

	signal clk, iclk: std_logic;

begin
	ib: IBUFG port map (
		i=>MCLK1,
		o=>iclk
	);

	bg: BUFG port map (
		i=>iclk,
		o=>clk
	);

	cpu : core port map (
		clk    => clk,
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

end;