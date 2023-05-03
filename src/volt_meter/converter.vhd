library ieee;
use work.config.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity converter is
  port (
    CLK, RESET, SPI_BUSY, LCD_BUSY : in std_logic;
    ADC_VALUE : in ADC_RESOLUTION;
    LCD_ENABLE : out std_logic;
    VOLTAGE : out LCD_DATA_BUFFER
  );
end entity;

architecture rtl of converter is
  signal current_state, next_state : CONVERTER_STATE;
  signal current_time : Time := 0 ns;
  signal latched_voltage : ADC_RESOLUTION;
  signal bit_index : integer range 0 to ADC_BITS := 0;
begin
  ---------------------------------------------------------
  -- Converts raw ADC readings into LCD characters that
  -- will be displayed on the LCD screen.
  ---------------------------------------------------------
  process (current_time, current_state, bit_index, SPI_BUSY, LCD_BUSY, ADC_VALUE) is
  begin
    next_state <= current_state;

    case current_state is
      when CONVERTER_STATE_WAIT =>
        bit_index <= 0;
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        -- Wait for the ADC controller to start reading
        if SPI_BUSY = '0' then
          next_state <= CONVERTER_STATE_READ;
        end if;

      when CONVERTER_STATE_READ =>
        bit_index <= 0;
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        -- Wait for the ADC controller to finish reading
        if SPI_BUSY = '1' then
          -- Latch the current ADC value and display it
          latched_voltage <= ADC_VALUE;
          next_state <= CONVERTER_STATE_CLEAR_SCREEN;
        end if;

      when CONVERTER_STATE_CLEAR_SCREEN =>
        bit_index <= 0;
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        if LCD_BUSY = '0' then
          LCD_ENABLE <= '1';
          VOLTAGE <= "000000001";
          next_state <= CONVERTER_STATE_SHOW_VOLTAGE;
        end if;

      when CONVERTER_STATE_SHOW_VOLTAGE =>
        if LCD_BUSY = '0' and bit_index < ADC_BITS then
          LCD_ENABLE <= '1';

          if latched_voltage (bit_index) = '0' then
            VOLTAGE <= "100110000";
          else
            VOLTAGE <= "100110001";
          end if;

				  bit_index <= bit_index + 1;
        else
          LCD_ENABLE <= '0';
          VOLTAGE <= (others => '0');

          if bit_index = ADC_BITS then
			      bit_index <= 0;
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
        current_time <= current_time + LCD_CLK_PERIOD;
      end if;
      current_state <= next_state;
    end if;
  end process;
end rtl;