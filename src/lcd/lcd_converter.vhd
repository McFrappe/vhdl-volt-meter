library ieee;
use work.config.all;
use ieee.std_logic_1164.all;

entity lcd_converter is
  port (
    CLK : in std_logic;
    ADC_BITS : in ADC_RESOLUTION;
    VOLTAGE : out LCD_DATA_BUFFER
  );
end entity;

architecture rtl of lcd_converter is
begin
  ---------------------------------------------------------
  -- Converts a 16-bit ADC input into a voltage level in
  -- decimal form that will be displayed on the LCD display.
  -- Since only a single character/instruction can be sent
  -- to the display via the data bus at once, conversion of
  -- the input ADC bits takes multiple clock cycles.
  ---------------------------------------------------------

  -- See page 13 in datasheet:
  -- VIN = ADC_BITS * VDD / 4096 (VDD = 5?).
  VOLTAGE <= ADC_BITS(7 downto 0); -- FIXME
end rtl;