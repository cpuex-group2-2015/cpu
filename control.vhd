library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control is
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
		pc_src            : out std_logic_vector (1 downto 0);
		pc_src2           : out std_logic
	);
end control;

architecture struct of control is

	signal wait_count : std_logic_vector(1 downto 0) := "00";

begin

	process (clk, opcode, sub_opcode, branch_op, cr)
	begin
		case opcode is
		when "001011" =>										-- 11 cmpi

			-- a <- (RA)
			-- if a < EXTS(SI) then c <- 0b100
			-- else if a > EXTS(SI) then c <- 0b010
			-- else c <- 0b001
			-- CR <- c || XER_SO

			gpr_write_enable  <= '0';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '1';
			lr_write_enable   <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "01";
			alu_op            <= "110";	-- cmp
			alu_src           <= '1';
			gpr_data_src      <= "--";
			lr_src            <= '-';
			pc_src            <= "00";
			pc_src2           <= '0';

		when "001110" =>										-- 14 addi

			-- RT <- (RA) + EXTS(SI)

			gpr_write_enable  <= '1';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '0';
			lr_write_enable   <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "01";
			alu_op            <= "000";	-- add
			alu_src           <= '1';
			gpr_data_src      <= "00";
			lr_src            <= '-';
			pc_src            <= "00";
			pc_src2           <= '0';

		when "001111" =>										-- 15 addis

			-- RT <- (RA) + EXTS(SI || 0000)

			gpr_write_enable  <= '1';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '0';
			lr_write_enable   <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "11";
			alu_op            <= "000";	-- add
			alu_src           <= '1';
			gpr_data_src      <= "00";
			lr_src            <= '-';
			pc_src            <= "00";
			pc_src2           <= '0';

		when "010000" =>										-- 16 bc, bcl

			-- if CR_BI = BO then NIA <-_iea EXTS(BD || 0b00)
			-- LR <-_iea CIA + 4

			gpr_write_enable  <= '0';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "00";
			alu_op            <= "---";
			alu_src           <= '-';
			gpr_data_src      <= "--";

			if (cr(conv_integer(branch_op(1 downto 0))) = branch_op(2)) then
				pc_src <= "11";
			else
				pc_src <= "00";
			end if;

			if (branch_op(3) = '0') then
				lr_write_enable <= '0';
				lr_src          <= '-';				
			else
				lr_write_enable <= '1';
				lr_src          <= '0';
			end if;

			if (rising_edge(clk)) then
				if (wait_count = "01") then			-- 2clk 目
					wait_count <= "00";
					pc_src2    <= '0';
				else								-- 1clk 目
					wait_count <= wait_count + 1;
					pc_src2    <= '1';
				end if;
			end if;

		when "010010" =>										-- 18 b, bl

			-- NIA <-_iea EXTS(LI || 0b00)
			-- LR <-_iea CIA + 4

			gpr_write_enable  <= '0';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "00";
			alu_op            <= "---";
			alu_src           <= '-';
			gpr_data_src      <= "--";
			pc_src            <= "11";

			if (branch_op(3) = '0') then
				lr_write_enable <= '0';
				lr_src          <= '-';				
			else
				lr_write_enable <= '1';
				lr_src          <= '0';
			end if;

			if (rising_edge(clk)) then
				if (wait_count = "01") then			-- 2clk 目
					wait_count <= "00";
					pc_src2    <= '0';
				else								-- 1clk 目
					wait_count <= wait_count + 1;
					pc_src2    <= '1';
				end if;
			end if;

		when "010011" =>										-- 19 blr

			-- NIA <- (LR)

			gpr_write_enable  <= '0';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '0';
			lr_write_enable   <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "--";
			alu_op            <= "---";
			alu_src           <= '-';
			gpr_data_src      <= "--";
			lr_src            <= '-';
			pc_src            <= "01";

			if (rising_edge(clk)) then
				if (wait_count = "01") then			-- 2clk 目
					wait_count <= "00";
					pc_src2    <= '0';
				else								-- 1clk 目
					wait_count <= wait_count + 1;
					pc_src2    <= '1';
				end if;
			end if;

		when "010100" =>										-- 20 bctr, bctrl

			-- NIA <-_(CTR)
			-- LR <-_iea CIA + 4

			gpr_write_enable  <= '0';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "00";
			alu_op            <= "---";
			alu_src           <= '-';
			gpr_data_src      <= "--";
			pc_src            <= "10";

			if (branch_op(3) = '0') then
				lr_write_enable <= '0';
				lr_src          <= '-';				
			else
				lr_write_enable <= '1';
				lr_src          <= '0';
			end if;

			if (rising_edge(clk)) then
				if (wait_count = "01") then			-- 2clk 目
					wait_count <= "00";
					pc_src2    <= '0';
				else								-- 1clk 目
					wait_count <= wait_count + 1;
					pc_src2    <= '1';
				end if;
			end if;

		when "011001" =>										-- 25 ori

			-- RS <- (RA) | (0 || UI)

			gpr_write_enable  <= '1';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '0';
			lr_write_enable   <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "00";
			alu_op            <= "011";	-- or
			alu_src           <= '1';
			gpr_data_src      <= "00";
			lr_src            <= '-';
			pc_src            <= "00";
			pc_src2           <= '0';

		when "011100" =>										-- 28 andi

			-- RS <- (RA) & (0 || UI)

			gpr_write_enable  <= '1';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '0';
			lr_write_enable   <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "00";
			alu_op            <= "010";	-- and
			alu_src           <= '1';
			gpr_data_src      <= "00";
			lr_src            <= '-';
			pc_src            <= "00";
			pc_src2           <= '0';

		when "011110" =>										-- 30 cmp

			-- a <- (RA)
			-- b <- (RB)
			-- if a < b then c <- 0b100
			-- else if a > b then c <- 0b010
			-- else c <- 0b001
			-- CR <- c || XER_SO

			gpr_write_enable  <= '0';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '1';
			lr_write_enable   <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "01";
			alu_op            <= "110";	-- cmp
			alu_src           <= '0';
			gpr_data_src      <= "--";
			lr_src            <= '-';
			pc_src            <= "00";
			pc_src2           <= '0';

		when "100000" =>										-- 32 ld

			-- ea <- (RA) + EXTS(D)
			-- RT <- MEM(ea, 4)

			gpr_write_enable  <= '1';
			dmem_write_enable <= '0';
			cr_g_write_enable <= '0';
			lr_write_enable   <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "01";
			alu_op            <= "000";	-- add
			alu_src           <= '1';
			gpr_data_src      <= "01";
			lr_src            <= '-';
			pc_src            <= "00";

			if (wait_count = "10") then
				wait_count <= "00";
				pc_src2    <= '0';
			else
				wait_count <= wait_count + 1;
				pc_src2    <= '1';
			end if;

		when "100100" =>										-- 36 st

			-- ea <- (RA) + EXTS(D)
			-- MEM(ea, 4) <- (RS)

			gpr_write_enable  <= '0';
			dmem_write_enable <= '1';
			cr_g_write_enable <= '0';
			lr_write_enable   <= '0';
			ctr_write_enable  <= '0';
			ext_op            <= "01";
			alu_op            <= "000";	-- add
			alu_src           <= '1';
			gpr_data_src      <= "--";
			lr_src            <= '-';
			pc_src            <= "00";

			if (wait_count = "10") then
				wait_count <= "00";
				pc_src2    <= '0';
			else
				wait_count <= wait_count + 1;
				pc_src2    <= '1';
			end if;

		when "011111" =>

			case sub_opcode is
			when "0000010111" =>								-- 31 - 23 ldx

				-- ea <- (RA) + (RB)
				-- RT <- MEM(ea, 4)

				gpr_write_enable  <= '1';
				dmem_write_enable <= '0';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '0';
				ctr_write_enable  <= '0';
				ext_op            <= "--";
				alu_op            <= "000";	-- add
				alu_src           <= '0';
				gpr_data_src      <= "01";
				lr_src            <= '-';
				pc_src            <= "00";

				if (wait_count = "10") then
					wait_count <= "00";
					pc_src2    <= '0';
				else
					wait_count <= wait_count + 1;
					pc_src2    <= '1';
				end if;

			when "0010010111" =>								-- 31 - 151 stx

				-- ea <- (RA) + (RB)
				-- MEM(ea, 4) <- (RS)

				gpr_write_enable  <= '0';
				dmem_write_enable <= '1';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '0';
				ctr_write_enable  <= '0';
				ext_op            <= "--";
				alu_op            <= "000";	-- add
				alu_src           <= '0';
				gpr_data_src      <= "--";
				lr_src            <= '-';
				pc_src            <= "00";

				if (wait_count = "10") then
					wait_count <= "00";
					pc_src2    <= '0';
				else
					wait_count <= wait_count + 1;
					pc_src2    <= '1';
				end if;

			when "0100001010" =>								-- 31 - 266 add

				-- RT <- (RA) + (RB)

				gpr_write_enable  <= '1';
				dmem_write_enable <= '0';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '0';
				ctr_write_enable  <= '0';
				ext_op            <= "--";
				alu_op            <= "000";	-- add
				alu_src           <= '0';
				gpr_data_src      <= "00";
				lr_src            <= '-';
				pc_src            <= "00";
				pc_src2           <= '0';

			when "0001101000" =>								-- 31 - 104 neg

				-- RT <- ¬(RA) + 1

				gpr_write_enable  <= '1';
				dmem_write_enable <= '0';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '0';
				ctr_write_enable  <= '0';
				ext_op            <= "--";
				alu_op            <= "001";	-- neg
				alu_src           <= '-';
				gpr_data_src      <= "00";
				lr_src            <= '-';
				pc_src            <= "00";
				pc_src2           <= '0';

			when "0000011100" =>								-- 31 - 28 and

				-- RT <- (RA) & (RB)

				gpr_write_enable  <= '1';
				dmem_write_enable <= '0';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '0';
				ctr_write_enable  <= '0';
				ext_op            <= "--";
				alu_op            <= "010";	-- and
				alu_src           <= '0';
				gpr_data_src      <= "00";
				lr_src            <= '-';
				pc_src            <= "00";
				pc_src2           <= '0';

			when "0110111100" =>								-- 31 - 444 or

				-- RT <- (RA) | (RB)

				gpr_write_enable  <= '1';
				dmem_write_enable <= '0';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '0';
				ctr_write_enable  <= '0';
				ext_op            <= "--";
				alu_op            <= "011";	-- or
				alu_src           <= '0';
				gpr_data_src      <= "00";
				lr_src            <= '-';
				pc_src            <= "00";
				pc_src2           <= '0';

			when "0000011000" =>								-- 31 - 24 sl

				-- RT <- sl((RA), (RB)[4 - 0])

				gpr_write_enable  <= '1';
				dmem_write_enable <= '0';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '0';
				ctr_write_enable  <= '0';
				ext_op            <= "--";
				alu_op            <= "100";	-- sl
				alu_src           <= '0';
				gpr_data_src      <= "00";
				lr_src            <= '-';
				pc_src            <= "00";
				pc_src2           <= '0';

			when "1000011000" =>								-- 31 - 536 sr

				-- RT <- sr((RA), (RB)[4 - 0])

				gpr_write_enable  <= '1';
				dmem_write_enable <= '0';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '0';
				ctr_write_enable  <= '0';
				ext_op            <= "--";
				alu_op            <= "101";	-- sr
				alu_src           <= '0';
				gpr_data_src      <= "00";
				lr_src            <= '-';
				pc_src            <= "00";
				pc_src2           <= '0';

			when "0111010011" =>								-- 31 - 467 mtlr

				-- LR <- (RS) | (R0)

				gpr_write_enable  <= '0';
				dmem_write_enable <= '0';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '1';
				ctr_write_enable  <= '0';
				ext_op            <= "--";
				alu_op            <= "011";	-- or
				alu_src           <= '0';
				gpr_data_src      <= "--";
				lr_src            <= '1';
				pc_src            <= "00";
				pc_src2           <= '0';

			when "0101010011" =>								-- 31 - 339 mflr

				-- RT <- (LR)

				gpr_write_enable  <= '1';
				dmem_write_enable <= '0';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '0';
				ctr_write_enable  <= '0';
				ext_op            <= "--";
				alu_op            <= "---";
				alu_src           <= '-';
				gpr_data_src      <= "10";
				lr_src            <= '-';
				pc_src            <= "00";
				pc_src2           <= '0';

			when "0111010100" =>								-- 31 - 468 mtctr

				-- CTR <- (RS) | (R0)

				gpr_write_enable  <= '0';
				dmem_write_enable <= '0';
				cr_g_write_enable <= '0';
				lr_write_enable   <= '0';
				ctr_write_enable  <= '1';
				ext_op            <= "--";
				alu_op            <= "011";	-- or
				alu_src           <= '0';
				gpr_data_src      <= "--";
				lr_src            <= '-';
				pc_src            <= "00";
				pc_src2           <= '0';

			when others =>										-- NOP
			end case;

		when others =>											-- NOP
		end case;

	end process;

end;