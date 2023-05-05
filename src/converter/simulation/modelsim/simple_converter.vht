LIBRARY ieee;
USE work.config.all;
USE ieee.std_logic_1164.all;

ENTITY simple_converter_vhd_tst IS
END simple_converter_vhd_tst;

ARCHITECTURE simple_converter_arch OF simple_converter_vhd_tst IS
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;
  SIGNAL RESULT : CONVERTER_BUFFER;
  SIGNAL VALUE : CONVERTER_BUFFER;
  COMPONENT simple_converter
    PORT (
      CLK : IN STD_LOGIC;
      RESET : IN STD_LOGIC;
      RESULT : OUT CONVERTER_BUFFER;
      VALUE : IN CONVERTER_BUFFER
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
    RESET <= '1';
    WAIT FOR CLK_PERIOD;
    RESET <= '0';
    WAIT FOR CLK_PERIOD;

    VALUE <= x"00001000"; -- 4096
    WAIT FOR CLK_PERIOD * 10;

    VALUE <= x"000007D0"; -- 2000
    WAIT FOR CLK_PERIOD * 10;
  WAIT;
  END PROCESS;
END simple_converter_arch;