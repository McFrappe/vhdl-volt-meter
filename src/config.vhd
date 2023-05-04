library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package config is
  ---------------------------------------------------------
  -- General
  ---------------------------------------------------------
  -- System clock. For DE1-SoC, this will be 50 MHz.
  constant CLK_PERIOD : Time := 20 ns;

  ---------------------------------------------------------
  -- Converter
  ---------------------------------------------------------
  type CONVERTER_STATE is (
    CONVERTER_STATE_WAIT,
    CONVERTER_STATE_READ,
    CONVERTER_STATE_CLEAR_SCREEN,
    CONVERTER_STATE_SHOW_VOLTAGE
  );

  ---------------------------------------------------------
  -- ADC (MCP3202)
  ---------------------------------------------------------
  type ADC_STATE is (
    ADC_STATE_POWER_ON,
    ADC_STATE_RESET,
    ADC_STATE_START_CONVERSION,
    ADC_STATE_READ_DATA
  );

  -- Internal ADC resolution is only 12 bits, but it will
  -- be stored in a 16-bit shift register.
  constant ADC_BITS : integer := 12;
  subtype ADC_RESOLUTION is std_logic_vector (ADC_BITS - 1 downto 0);

  -- Clock period for the serial interface
  constant ADC_CLK_PERIOD : Time := CLK_PERIOD * 50;

  -- Timing constraints for ADC
  constant ADC_POWER_ON_WAIT_TIME : Time := 10 ms;
  constant ADC_RESET_TIME : Time := ADC_CLK_PERIOD * 10;
  constant ADC_CONV_WAIT_TIME : Time := ADC_CLK_PERIOD * 2; -- Min 1 period
  constant ADC_TCONV : Time := ADC_CLK_PERIOD * ADC_BITS;

  ---------------------------------------------------------
  -- LCD (ATM12864D)
  ---------------------------------------------------------
  -- States for state machine used to initialize the LCD
  -- display.
  type LCD_STATE is (
    LCD_STATE_POWER_ON,
    LCD_STATE_RESET,
    LCD_STATE_RESET_2,
    LCD_STATE_RESET_3,
    LCD_STATE_FN_SET,
    LCD_STATE_CONFIGURE,
    LCD_STATE_DISP_SWITCH,
    LCD_STATE_DISP_CLEAR,
    LCD_STATE_ENTRY_MODE_SET,
    LCD_STATE_DISP_ON,
    LCD_STATE_READY,
    LCD_STATE_WRITE
  );

  -- The bidirectional data bus used to read/write data
  -- to and from the LCD display.
  subtype LCD_DATA_BUS is std_logic_vector (7 downto 0);

  -- Buffer used to send instructions to the LCD display
  -- via the LCD controller. The two left-most bits in this
  -- buffer correspond to the RS and RW pins, exactly as shown
  -- in the datasheet.
  subtype LCD_DATA_BUFFER is std_logic_vector (8 downto 0);

  -- Clock frequency of the LCD display controller.
  -- This is used to ensure that we fulfill with the timing
  -- constraints defined below.
  constant LCD_CLK_PERIOD : Time := CLK_PERIOD;

  -- Timing constraints of the LCD display.
  -- In order for the display to be able to fully execute
  -- the actions needed for a certain action, we need to wait
  -- for a specific amount of time (according to the datasheet).
  constant LCD_POWER_ON_WAIT_TIME : Time := 15 ms; -- Min 15 ms
  constant LCD_RESET_TIME : Time := 4.1 ms; -- Min 4.1 ms
  constant LCD_RESET_2_TIME : Time := 100 us; -- Min 100 us
  constant LCD_CMD_TIME : Time := 40 us; -- Min 40 us
  constant LCD_RESET_CMD_TIME : Time := 2 ms; -- Min 1.64 ms

  -- ENABLE pin timings. See the "Write operation" timing diagram
  -- in the LCD display datasheet.
  constant LCD_TSP1 : Time := 60 ns;
  constant LCD_TPW : Time := 450 ns;
  constant LCD_THD2 : Time := 10 ns;
  constant LCD_TC : Time := 1 us;

  -- LCD commands
  constant LCD_RESET_CMD          : LCD_DATA_BUS := "00110000";
  constant LCD_FN_SET_CMD         : LCD_DATA_BUS := "00110000";
  constant LCD_CONFIGURE_CMD      : LCD_DATA_BUS := "00111000";
  constant LCD_DISP_SWITCH_CMD    : LCD_DATA_BUS := "00001100";
  constant LCD_DISP_CLEAR_CMD     : LCD_DATA_BUS := "00000001";
  constant LCD_ENTRY_MODE_SET_CMD : LCD_DATA_BUS := "00000110";
  constant LCD_DISP_ON_CMD        : LCD_DATA_BUS := "00001100";

  ---------------------------------------------------------
  -- ADC to decimal converter
  ---------------------------------------------------------
  subtype CONVERTER_IN_BUFFER is std_logic_vector (24 downto 0);
  subtype CONVERTER_OUT_BUFFER is std_logic_vector (31 downto 0);

  ---------------------------------------------------------
  -- Binary to BCD converter
  ---------------------------------------------------------
  type BCD_STATE is (
    BCD_STATE_START,
    BCD_STATE_SHIFT,
    BCD_STATE_DONE
  );

  constant BCD_BINARY_BITS : integer := 13; -- Maximum value is 5000
  constant BCD_DECIMAL_BITS : integer := 4; -- 0 to 9
  constant BCD_SCRATCH_BITS : integer := 29; -- N + 4*ceil(N/3)

  subtype BCD_BINARY_BUFFER is std_logic_vector (BCD_BINARY_BITS-1 downto 0);
  subtype BCD_DECIMAL_BUFFER is std_logic_vector (BCD_DECIMAL_BITS-1 downto 0);
  subtype BCD_SCRATCH_BUFFER is unsigned (BCD_SCRATCH_BITS-1 downto 0);
end package config;