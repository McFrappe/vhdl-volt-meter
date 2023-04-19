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

  function to_volt (adc_reading : in ADC_RESOLUTION) return ufixed is
      variable left : ufixed (3 downto 0);
      variable decimals : ufixed (0 downto -3);
      variable result : ufixed (3 downto -3);
  begin
    left := to_ufixed(shift_right((unsigned(adc_reading) * 4) + unsigned(adc_reading), 12));
    decimals := to_ufixed(unsigned(adc_reading) / 4096);
    result := left + decimals;
    return result;
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
          VOLTAGE <= "000000001";
          next_state <= CONVERTER_STATE_SHOW_VOLTAGE;
        end if;

      when CONVERTER_STATE_SHOW_VOLTAGE =>
        if LCD_BUSY = '0' and bit_index < 15 then
          LCD_ENABLE <= '1';

          -- TODO: Convert to list of integers
          if latched_voltage(bit_index) = '0' then
            VOLTAGE <= "100110000";
          else
            VOLTAGE <= "100110001";
          end if;

          bit_index := bit_index + 1;
        else
          LCD_ENABLE <= '0';
          VOLTAGE <= (others => '0');

          if current_time >= 4000 ms then
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