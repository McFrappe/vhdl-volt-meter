library ieee;
use work.config.all;
use ieee.std_logic_1164.all;

entity shift_register is
  port (
    CLK, RESET : in std_logic;
    SR_IN : in std_logic;
    SR_OUT : out ADC_RESOLUTION
  );
end entity;

architecture rtl of shift_register is
	signal bits : ADC_RESOLUTION := (others => '0');
begin
  ---------------------------------------------------------
  -- Accepts a single bit input and shifts the existing
  -- bits in the register to the left.
  ---------------------------------------------------------
	process (CLK, RESET)
	begin
		if RESET = '1' then
			bits <= (others => '0');
		elsif rising_edge(CLK) then
			bits <= bits(bits'left - 1 downto 0) & SR_IN;
		end if;
	end process;
	SR_OUT <= bits;
end rtl;