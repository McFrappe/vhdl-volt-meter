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
	begin
		if RESET = '1' then
			feedback <= '0';
		elsif CLK'event and rising_edge(CLK) then
			feedback <= not feedback;
		end if;
	end process;

	CLK_OUT <= feedback;
end rtl;