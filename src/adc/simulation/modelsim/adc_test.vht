LIBRARY ieee;
USE work.config.all;
USE ieee.std_logic_1164.all;

ENTITY adc_test_vhd_tst IS
END adc_test_vhd_tst;

ARCHITECTURE adc_test_arch OF adc_test_vhd_tst IS
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;
  SIGNAL SPI_MISO : STD_LOGIC;
  SIGNAL SPI_MOSI : STD_LOGIC;
  SIGNAL SPI_BUSY : STD_LOGIC;
  SIGNAL SPI_SS : STD_LOGIC;
  SIGNAL ADC_BIT : STD_LOGIC;

  COMPONENT adc_controller
    PORT (
      CLK : IN STD_LOGIC;
      RESET : IN STD_LOGIC;
      SPI_MISO : IN STD_LOGIC;
      SPI_MOSI : OUT STD_LOGIC;
      SPI_BUSY : OUT STD_LOGIC;
      SPI_SS : OUT STD_LOGIC;
      ADC_BIT : OUT STD_LOGIC
    );
  END COMPONENT;
BEGIN
  i1 : adc_controller
  PORT MAP (
    CLK => CLK,
    RESET => RESET,
    SPI_MISO => SPI_MISO,
    SPI_MOSI => SPI_MOSI,
    SPI_BUSY => SPI_BUSY,
    SPI_SS => SPI_SS,
    ADC_BIT => ADC_BIT
  );

  clock : PROCESS
  BEGIN
    -- We use the normal 50 MHz clock here since
    -- a clock divider is used to convert the system clock
    -- into the clock required by the ADC chip.
    CLK <= '1';
    WAIT FOR ADC_CLK_PERIOD / 2;
    CLK <= '0';
    WAIT FOR ADC_CLK_PERIOD / 2;
  END PROCESS clock;

  test : PROCESS
  BEGIN
    RESET <= '1';
    SPI_MISO <= '1';

    WAIT FOR CLK_PERIOD;
    RESET <= '0';

    -- Test a total of 3 conversions
    WAIT UNTIL SPI_BUSY = '0';
    WAIT UNTIL SPI_BUSY = '1';
    WAIT UNTIL SPI_BUSY = '0';
    WAIT UNTIL SPI_BUSY = '1';
    WAIT UNTIL SPI_BUSY = '0';
  WAIT;
  END PROCESS test;
END adc_test_arch;