LIBRARY ieee;
USE work.config.all;
USE ieee.std_logic_1164.all;

ENTITY encoder_vhd_tst IS
END encoder_vhd_tst;

ARCHITECTURE encoder_arch OF encoder_vhd_tst IS
  SIGNAL CLK : STD_LOGIC;
  SIGNAL DECIMALS : BCD_DECIMALS_BUFFER;
  SIGNAL LCD_BUSY : STD_LOGIC;
  SIGNAL LCD_ENABLE : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;
  SIGNAL SPI_BUSY : STD_LOGIC;
  SIGNAL VOLTAGE : LCD_DATA_BUFFER;
  COMPONENT encoder
    PORT (
      CLK : IN STD_LOGIC;
      DECIMALS : IN BCD_DECIMALS_BUFFER;
      LCD_BUSY : IN STD_LOGIC;
      LCD_ENABLE : OUT STD_LOGIC;
      RESET : IN STD_LOGIC;
      SPI_BUSY : IN STD_LOGIC;
      VOLTAGE : OUT LCD_DATA_BUFFER
    );
  END COMPONENT;
BEGIN
  i1 : encoder
  PORT MAP (
    CLK => CLK,
    DECIMALS => DECIMALS,
    LCD_BUSY => LCD_BUSY,
    LCD_ENABLE => LCD_ENABLE,
    RESET => RESET,
    SPI_BUSY => SPI_BUSY,
    VOLTAGE => VOLTAGE
  );

  clock : PROCESS
  BEGIN
  	CLK <= '0';
  	WAIT FOR ENCODER_CLK_PERIOD / 2;
  	CLK <= '1';
  	WAIT FOR ENCODER_CLK_PERIOD / 2;
  END PROCESS;

  test : PROCESS
  BEGIN
	  RESET <= '1';
	  WAIT FOR ENCODER_CLK_PERIOD / 2;
	  RESET <= '0';
	  WAIT FOR ENCODER_CLK_PERIOD / 2;

    DECIMALS <= (others => '0'); -- 3
    LCD_BUSY <= '0';
	  SPI_BUSY <= '0'; -- Should go to CONV_END
	  WAIT FOR ADC_TCONV;
	  SPI_BUSY <= '1'; -- Should get in state STATE_READ

    WAIT FOR BCD_CONV_TIME;
	  SPI_BUSY <= '0';
    DECIMALS <= x"3564";

    -- Wait until encoder attempts to clear LCD
    WAIT UNTIL LCD_ENABLE = '1';
    LCD_BUSY <= '1';
    WAIT FOR LCD_RESET_CMD_TIME;
    LCD_BUSY <= '0';

    for i in 0 to 3 loop
      -- Wait until encoder attempts to write char LCD
      WAIT UNTIL LCD_ENABLE = '1';
      LCD_BUSY <= '1';
      WAIT FOR LCD_RESET_CMD_TIME;
      LCD_BUSY <= '0';
    end loop;


    -- BINARY <= x"00000064"; -- 100

    -- BINARY <= x"00000040"; -- 64

    -- BINARY <= x"00000003"; -- 3
  WAIT;
  END PROCESS;
END encoder_arch;