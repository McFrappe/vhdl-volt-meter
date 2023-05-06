LIBRARY ieee;
USE work.config.all;
USE ieee.std_logic_1164.all;

ENTITY adc_converter_vhd_tst IS
END adc_converter_vhd_tst;

ARCHITECTURE adc_converter_arch OF adc_converter_vhd_tst IS
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;
  SIGNAL RESULT : ADC_CONVERTER_BUFFER;
  SIGNAL VALUE : ADC_CONVERTER_BUFFER;
  COMPONENT simple_converter
    PORT (
      CLK : IN STD_LOGIC;
      RESET : IN STD_LOGIC;
      RESULT : OUT ADC_CONVERTER_BUFFER;
      VALUE : IN ADC_CONVERTER_BUFFER
    );
  END COMPONENT;
BEGIN
  i1 : simple_converter
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

    VALUE <= x"00001000"; -- 4096
    WAIT FOR CLK_PERIOD * 10;

    VALUE <= x"000007D0"; -- 2000
    WAIT FOR CLK_PERIOD * 10;
  WAIT;
  END PROCESS;
END adc_converter_arch;