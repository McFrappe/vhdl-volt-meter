LIBRARY ieee;
USE work.config.all;
USE ieee.std_logic_1164.all;

ENTITY adc_converter_vhd_tst IS
END adc_converter_vhd_tst;

ARCHITECTURE adc_converter_arch OF adc_converter_vhd_tst IS
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;
  SIGNAL RESULT : ADC_CONVERTER_BUFFER;
  SIGNAL VALUE : ADC_BUFFER;
  COMPONENT adc_converter
    PORT (
      CLK : IN STD_LOGIC;
      RESET : IN STD_LOGIC;
      RESULT : OUT ADC_CONVERTER_BUFFER;
      VALUE : IN ADC_BUFFER
    );
  END COMPONENT;
BEGIN
  i1 : adc_converter
  PORT MAP (
    CLK => CLK,
    RESET => RESET,
    RESULT => RESULT,
    VALUE => VALUE
  );

  clock : PROCESS
  BEGIN
    CLK <= '1';
    WAIT FOR CLK_PERIOD / 2;
    CLK <= '0';
    WAIT FOR CLK_PERIOD / 2;
  END PROCESS;

  test : PROCESS
  BEGIN
    RESET <= '0';
    WAIT FOR CLK_PERIOD;
    RESET <= '1';
    WAIT FOR CLK_PERIOD;

    -- Input is the raw value from the ADC.
    -- Resolution is 12 bits, i.e. 4095 is the maximum value,
    -- which corresponds to 5V.
    VALUE <= x"000"; -- 0
    WAIT FOR CLK_PERIOD;

    VALUE <= x"7D0"; -- 2000
    WAIT FOR CLK_PERIOD;

    VALUE <= x"FFF"; -- 4095
    WAIT FOR CLK_PERIOD;
  WAIT;
  END PROCESS;
END adc_converter_arch;