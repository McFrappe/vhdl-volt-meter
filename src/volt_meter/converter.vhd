library ieee;
use work.config.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity converter is
  port (
    CLK, RESET, SPI_BUSY, LCD_BUSY : in std_logic;
    ADC_BITS : in ADC_RESOLUTION;
    LCD_ENABLE : out std_logic;
    VOLTAGE : out LCD_DATA_BUFFER
  );
end entity;

architecture rtl of converter is
  signal current_state, next_state : CONVERTER_STATE;
  signal current_time : Time := 0 ns;
  signal latched_voltage : ADC_RESOLUTION;

  -- TODO: probably doesnt work, loook over calculation (binary long division)
  function to_volt (adc_reading : in ADC_RESOLUTION) return integer is
    variable quotient : ADC_RESOLUTION := (others => '0');
    variable remainder : std_logic_vector(ADC_FULL_SCALE_VAL'length - 1 downto 0) := ADC_FULL_SCALE_VAL;
  begin
    -- store adc_reading/fullscaledata
    -- fullscaledata==2^12 = 4096
    quotient := (others => '0');
    remainder := (others => '0');
    for i in 0 to adc_reading'length - ADC_FULL_SCALE_VAL'length loop
        if remainder(remainder'length - 1 downto 0) >= ADC_FULL_SCALE_VAL then
            quotient(i) := '1';
            remainder := remainder - ADC_FULL_SCALE_VAL;
        end if;
        remainder := '0' & remainder(remainder'length - 1 downto 0);
    end loop;

    -- vref == 5v
    return conv_integer(quotient) * 5;
  end to_volt;

begin
  ---------------------------------------------------------
  -- Converts raw ADC readings into LCD characters that
  -- will be displayed on the LCD screen.
  ---------------------------------------------------------
  process (current_time, current_state, SPI_BUSY, LCD_BUSY, ADC_BITS) is
    variable bit_index : integer := 0;
  begin
    next_state <= current_state;

    case current_state is
      when CONVERTER_STATE_WAIT =>
        bit_index := 0;
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        -- Wait for the ADC controller to start reading
        if SPI_BUSY = '0' then
          next_state <= CONVERTER_STATE_READ;
        end if;

      when CONVERTER_STATE_READ =>
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        -- Wait for the ADC controller to finish reading
        if SPI_BUSY = '1' then
          -- Latch the current ADC value and display it
          latched_voltage <= ADC_BITS;
          next_state <= CONVERTER_STATE_CLEAR_SCREEN;
        end if;

      when CONVERTER_STATE_CLEAR_SCREEN =>
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        if LCD_BUSY = '0' then
          LCD_ENABLE <= '1';
          -- TODO: ADC controller does not support this
          VOLTAGE <= "0000000001";
          next_state <= CONVERTER_STATE_SHOW_VOLTAGE;
        end if;

      when CONVERTER_STATE_SHOW_VOLTAGE =>
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        if LCD_BUSY = '0' then
          LCD_ENABLE <= '1';

          -- TODO: Convert to list of integers
          if latched_voltage(bit_index) = '0' then
            VOLTAGE <= "100110000";
          else
            VOLTAGE <= "100110001";
          end if;

          if bit_index < 15 then
            bit_index := bit_index + 1;
          else
            next_state <= CONVERTER_STATE_WAIT;
          end if;
        end if;
    end case;
  end process;

  -- Update current state according to clock
  process (CLK, RESET) is
  begin
    if RESET = '1' then
      current_state <= CONVERTER_STATE_WAIT;
    elsif CLK'event and rising_edge(CLK) then
      if next_state /= current_state then
          current_time <= 0 ns;
      else
        current_time <= current_time + ADC_CLK_PERIOD;
      end if;
      current_state <= next_state;
    end if;
  end process;
end rtl;