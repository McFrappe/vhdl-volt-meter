LIBRARY ieee;
USE work.config.all;
USE ieee.std_logic_1164.all;

ENTITY b2bcd_vhd_tst IS
END b2bcd_vhd_tst;

ARCHITECTURE b2bcd_arch OF b2bcd_vhd_tst IS
  SIGNAL DECIMALS : BCD_DECIMALS_BUFFER;
  SIGNAL BINARY : ADC_CONVERTER_BUFFER;
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;

  COMPONENT b2bcd
    PORT (
      DECIMALS : OUT BCD_DECIMALS_BUFFER;
      BINARY_IN : IN ADC_CONVERTER_BUFFER;
      CLK : IN STD_LOGIC;
      RESET : IN STD_LOGIC
    );
  END COMPONENT;
BEGIN
  i1 : b2bcd
  PORT MAP (
    DECIMALS => DECIMALS,
    BINARY_IN => BINARY,
    CLK => CLK,
    RESET => RESET
  );

  clock : PROCESS
  BEGIN
    CLK <= '0';
    WAIT FOR CLK_PERIOD / 2;
    CLK <= '1';
    WAIT FOR CLK_PERIOD / 2;
  END PROCESS clock;

  test : PROCESS
  BEGIN
    RESET <= '1';
    WAIT FOR CLK_PERIOD;
    RESET <= '0'; -- start conversion

    BINARY <= x"00000DEC"; -- 3564
    WAIT FOR 1 us;

    BINARY <= x"00000064"; -- 100
    WAIT FOR 1 us;

    BINARY <= x"00000040"; -- 64
    WAIT FOR 1 us;

    BINARY <= x"00000003"; -- 3
    WAIT FOR 1 us;
  WAIT;
  END PROCESS test;
END b2bcd_arch;
