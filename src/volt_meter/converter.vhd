library ieee;
use work.config.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity converter is
  port (
    CLK, RESET, SPI_BUSY, LCD_BUSY : in std_logic;
    DECIMALS : in BCD_DECIMAL_BUFFER;
    LCD_ENABLE : out std_logic;
    VOLTAGE : out LCD_DATA_BUFFER
  );
end entity;

architecture rtl of converter is
  signal current_state, next_state : CONVERTER_STATE;
  signal current_time : Time := 0 ns;
  signal latched_decimals : BCD_DECIMAL_BUFFER;
  signal decimal_index : integer range 0 to 4 := 0;

  ---------------------------------------------------------
  -- Function to lookup what a specific decimal is
  -- represented on the LCD display.
  --------------------------------------------------------------
  function font_lookup (decimal : in std_logic_vector(3 downto 0)) return LCD_DATA_BUFFER is
    variable result : LCD_DATA_BUFFER;
  begin
    case decimal is
      when "0001" => result := "100110001"; -- 1
      when "0010" => result := "100110010"; -- 2
      when "0011" => result := "100110011"; -- 3
      when "0100" => result := "100110100"; -- 4
      when "0101" => result := "100110101"; -- 5
      when "0110" => result := "100110110"; -- 6
      when "0111" => result := "100110111"; -- 7
      when "1000" => result := "100111000"; -- 8
      when "1001" => result := "100111001"; -- 9
      when others => result := "100110000"; -- 0
    end case;
    return result;
  end font_lookup;
begin
  ---------------------------------------------------------
  -- Converts raw ADC readings into LCD characters that
  -- will be displayed on the LCD screen.
  ---------------------------------------------------------
  process (current_time, current_state, decimal_index, SPI_BUSY, LCD_BUSY, DECIMALS) is
  begin
    next_state <= current_state;

    case current_state is
      when CONVERTER_STATE_WAIT_CONV_START =>
        decimal_index <= 0;
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        -- Wait for the ADC controller to start reading
        if SPI_BUSY = '0' then
          next_state <= CONVERTER_STATE_WAIT_CONV_END;
        end if;

      when CONVERTER_STATE_WAIT_CONV_END =>
        decimal_index <= 0;
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        -- Wait for the ADC controller to finish reading
        if SPI_BUSY = '1' then
          next_state <= CONVERTER_STATE_READ;
        end if;

      when CONVERTER_STATE_READ =>
        decimal_index <= 0;
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        if current_time >= BCD_CONV_TIME then
          -- Latch the current voltage and display it
          latched_decimals <= DECIMALS;
          next_state <= CONVERTER_STATE_CLEAR_SCREEN;
        end if;

      when CONVERTER_STATE_CLEAR_SCREEN =>
        decimal_index <= 0;
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        if LCD_BUSY = '0' then
          LCD_ENABLE <= '1';
          VOLTAGE <= "000000001";
          next_state <= CONVERTER_STATE_SHOW_VOLTAGE;
        end if;

      when CONVERTER_STATE_SHOW_VOLTAGE =>
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        if LCD_BUSY = '0' then
          LCD_ENABLE <= '1';
          case decimal_index is
            when 0 => VOLTAGE <= font_lookup (latched_decimals (latched_decimals'left downto latched_decimals'left-3));
            when 1 => VOLTAGE <= font_lookup (latched_decimals (latched_decimals'left-4 downto latched_decimals'left-7));
            when 2 => VOLTAGE <= font_lookup (latched_decimals (latched_decimals'left-8 downto latched_decimals'left-11));
            when 3 => VOLTAGE <= font_lookup (latched_decimals (latched_decimals'left-12 downto latched_decimals'left-15));
            when others => LCD_ENABLE <= '0';
          end case;
				  decimal_index <= decimal_index + 1;
        end if;

        if decimal_index = 4 then
			    decimal_index <= 0;
          next_state <= CONVERTER_STATE_WAIT_CONV_START;
        end if;
    end case;
  end process;

  -- Update current state according to clock
  process (CLK, RESET) is
  begin
    if RESET = '1' then
      current_state <= CONVERTER_STATE_WAIT_CONV_START;
    elsif CLK'event and rising_edge(CLK) then
      if next_state /= current_state then
        current_time <= 0 ns;
      else
        current_time <= current_time + (LCD_CLK_PERIOD * 2);
      end if;
      current_state <= next_state;
    end if;
  end process;
end rtl;