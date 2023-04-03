library ieee;
use ieee.std_logic_1164.all;

package shared is
  ---------------------------------------------------------
  -- ADC (MCP3202)
  ---------------------------------------------------------
  constant SPI_CLOCK_FREQ : Time := 1 us;

  -- Internal ADC resolution is only 12 bits, but it will
  -- be stored in a 16-bit shift register.
  subtype ADC_RESOLUTION is std_logic_vector (15 downto 0);

  ---------------------------------------------------------
  -- LCD (ATM12864D)
  ---------------------------------------------------------
  -- The bidirectional data bus used to read/write data
  -- to and from the LCD display.
  subtype LCD_DATA_BUS is std_logic_vector (7 downto 0);

  -- Buffer used to send instructions to the LCD display
  -- via the LCD controller. The two left-most bits in this
  -- buffer correspond to the RS and RW pins, exactly as shown
  -- in the datasheet.
  subtype LCD_DATA_BUFFER is std_logic_vector (9 downto 0);
end package shared;

package body shared is
end shared;