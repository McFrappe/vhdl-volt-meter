library ieee;
use ieee.std_logic_1164.all;

entity encoder_clk_divider is
    port (
        CLK, RST : in std_logic;
        CLK_OUT  : out std_logic
    );
end entity;

architecture rtl of encoder_clk_divider is
	signal feedback : std_logic;
begin
	DIVIDER:process (CLK, RST)
	begin
		if RST = '1' then
			feedback <= '0';
		elsif rising_edge(CLK) then
			feedback <= not feedback;
		end if;
	end process;
	CLK_OUT <= feedback;
end rtl;