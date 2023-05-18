LIBRARY ieee;
USE work.config.all;
USE ieee.std_logic_1164.all;

ENTITY b2bcd_vhd_tst IS
END b2bcd_vhd_tst;

ARCHITECTURE b2bcd_arch OF b2bcd_vhd_tst IS
  SIGNAL DECIMALS : BCD_DECIMALS_BUFFER;
  SIGNAL BINARY : ADC_CONVERTER_BUFFER;
  SIGNAL SPI_BUSY : STD_LOGIC;
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;

  COMPONENT b2bcd
    PORT (
      DECIMALS : OUT BCD_DECIMALS_BUFFER;
      BINARY_IN : IN ADC_CONVERTER_BUFFER;
      SPI_BUSY : IN STD_LOGIC;
      CLK : IN STD_LOGIC;
      RESET : IN STD_LOGIC
    );
  END COMPONENT;
BEGIN
  i1 : b2bcd
  PORT MAP (
    DECIMALS => DECIMALS,
    BINARY_IN => BINARY,
    SPI_BUSY => SPI_BUSY,
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
    -- ADC conversion is being done
    SPI_BUSY <= '0';

    RESET <= '1';
    WAIT FOR CLK_PERIOD;
    RESET <= '0';

    -- Wait until ADC conversion is done
    WAIT FOR CLK_PERIOD;
    SPI_BUSY <= '1';

    BINARY <= x"00000DEC"; -- 3564
    WAIT FOR CLK_PERIOD * 14;

    -- Start a new ADC conversion.
    -- Normally, the time for a conversion is of course much longer.
    SPI_BUSY <= '0';
    WAIT FOR CLK_PERIOD * 2;
    SPI_BUSY <= '1';

    BINARY <= x"00000064"; -- 100
    WAIT FOR CLK_PERIOD * 14;
  WAIT;
  END PROCESS test;
END b2bcd_arch;
