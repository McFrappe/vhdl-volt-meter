library ieee;
use ieee.std_logic_1164.all;

package config is
  ---------------------------------------------------------
  -- General
  ---------------------------------------------------------
  -- System clock. For DE1-SoC, this will be 50 MHz.
  constant CLK_PERIOD : Time := 20 ns;

  ---------------------------------------------------------
  -- ADC (MCP3202)
  ---------------------------------------------------------
  -- Internal ADC resolution is only 12 bits, but it will
  -- be stored in a 16-bit shift register.
  subtype ADC_RESOLUTION is std_logic_vector (15 downto 0);

  -- Clock period for the serial interface
  constant SPI_CLOCK_PERIOD : Time := CLK_PERIOD;

  ---------------------------------------------------------
  -- LCD (ATM12864D)
  ---------------------------------------------------------
  -- States for state machine used to initialize the LCD
  -- display.
  type LCD_STATE is (
    LCD_STATE_START,
    LCD_STATE_INIT,
    LCD_STATE_READY,
    LCD_STATE_SEND
  );

  -- The bidirectional data bus used to read/write data
  -- to and from the LCD display.
  subtype LCD_DATA_BUS is std_logic_vector (7 downto 0);

  -- Buffer used to send instructions to the LCD display
  -- via the LCD controller. The two left-most bits in this
  -- buffer correspond to the RS and RW pins, exactly as shown
  -- in the datasheet.
  subtype LCD_DATA_BUFFER is std_logic_vector (9 downto 0);

  -- Clock frequency of the LCD display controller.
  -- This is used to ensure that we fulfill with the timing
  -- constraints defined below.
  constant LCD_CLK_PERIOD : Time := (CLK_PERIOD * 1); -- FIXME: clock divider

  -- Timing constraints of the LCD display.
  -- In order for the display to be able to fully execute
  -- the actions needed for a certain action, we need to wait
  -- for a specific amount of time (according to the datasheet).
  constant LCD_RESET_TIME : Time := 10 us; -- Min is 1 us
  constant LCD_INIT_TIME : Time := 50 us;
  constant LCD_ENABLE_CYCLE_TIME : Time := 500 ns;
end package config;