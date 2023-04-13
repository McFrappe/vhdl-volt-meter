library ieee;
use work.config.all;
use ieee.std_logic_1164.all;

entity adc_clk_divider is
  port (
    CLK, RESET : in std_logic;
    CLK_OUT : out std_logic
  );
end;

architecture rtl of adc_clk_divider is
	signal feedback : std_logic;
begin
  ---------------------------------------------------------
  -- Divides the clock frequency of 50 MHz down to the freq
  -- required by the ADC chip (max 1.8 MHz on 5V).
  ---------------------------------------------------------
	DIVIDER : process (CLK, RESET)
		variable counter : integer := 0;
	begin
		if RESET = '1' then
			counter := 0;
			feedback <= '0';
		elsif rising_edge(CLK) then
			counter := counter + 1;
			if counter >= ((ADC_CLK_PERIOD / CLK_PERIOD) / 2) then
				feedback <= not feedback;
				counter := 0;
			end if;
		end if;
	end process;

	CLK_OUT <= feedback;
end rtl;