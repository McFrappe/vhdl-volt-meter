library ieee;
use work.config.all;
use ieee.std_logic_1164.all;

entity adc_controller is
  port (
    CLK, RESET : in std_logic;
    SPI_MISO : in std_logic;
    SPI_MOSI, SPI_SS : out std_logic;
    ADC_BIT : out std_logic
  );
end entity;

architecture rtl of adc_controller is
  signal current_state, next_state : ADC_STATE;
  signal current_time : Time := 0 ns;
begin
  ---------------------------------------------------------
  -- Starts a voltage conversion on the ADC chip using SPI
  -- and reads the (12-bit) result into a 16-bit shift reg.
  ---------------------------------------------------------
  process (current_time, current_state, SPI_MISO, RESET) is
  begin
    next_state <= current_state;

    -- TODO: We actually need busy flag to ensure that
    -- we do not read anything until a conversion has been completed
    -- and we are in ADC_STATE_READ_DATA;
    case current_state is
      when ADC_STATE_POWER_ON =>
        -- Initialize
        SPI_MOSI <= '0';
        SPI_SS <= '1';
        ADC_BIT <= '0';
        if current_time >= ADC_POWER_ON_WAIT_TIME then
          next_state <= ADC_STATE_RESET;
        end if;

      when ADC_STATE_RESET =>
        SPI_SS <= '1';
        SPI_MOSI <= '1';
        ADC_BIT <= '0';
        if current_time >= ADC_RESET_TIME then
          next_state <= ADC_STATE_START_CONVERSION;
        end if;

      when ADC_STATE_START_CONVERSION =>
        ADC_BIT <= '0';
        SPI_SS <= '0';

        -- Use Single-Ended mode with channel 0.
        if current_time < ADC_CLK_PERIOD then
          -- Wait before starting conversion
          SPI_MOSI <= '0';
        elsif current_time < (2 * ADC_CLK_PERIOD) then
          -- Start bit
          SPI_MOSI <= '1';
        elsif current_time < (3 * ADC_CLK_PERIOD) then
          -- SGL/DIFF
          SPI_MOSI <= '1';
        elsif current_time < (4 * ADC_CLK_PERIOD) then
          -- ODD/SIGN
          SPI_MOSI <= '0';
        elsif current_time < (5 * ADC_CLK_PERIOD) then
          -- MS/BF
          SPI_MOSI <= '1';
        else
          -- TODO: Does a state change require a clock cycle to complete?
          -- Will we start reading at the NULL-bit or at B11?
          SPI_MOSI <= '0';
          next_state <= ADC_STATE_READ_DATA;
        end if;

      when ADC_STATE_READ_DATA =>
        SPI_SS <= '0'; -- Keep SS low until all data has been read
        SPI_MOSI <= '0'; -- Dont care

        if current_time < ADC_TCONV + ADC_ZERO_PADDING_TIME then
          -- Read a total of 16 bits, 12-bits ADC value and 4 zeros.
          ADC_BIT <= SPI_MISO;
        else
          ADC_BIT <= '0';
          next_state <= ADC_STATE_START_CONVERSION;
        end if;
    end case;
  end process;

  -- Update current state according to clock
  process (CLK, RESET) is
  begin
    if RESET = '1' then
      current_state <= ADC_STATE_RESET;
    elsif CLK'event and rising_edge(CLK) then
      if next_state /= current_state then
          current_time <= 0 ns;
      else
        -- Increase current_time for each clock cycle so that we
        -- can keep track of timings for reset, etc (based on datasheet).
        current_time <= current_time + ADC_CLK_PERIOD;
      end if;
      current_state <= next_state;
    end if;
  end process;
end rtl;