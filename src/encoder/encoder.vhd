library ieee;
use work.config.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity encoder is
  port (
    CLK, RESET, SPI_BUSY, LCD_BUSY : in std_logic;
    DECIMALS : in BCD_DECIMALS_BUFFER;
    LCD_ENABLE : out std_logic;
    VOLTAGE : out LCD_DATA_BUFFER
  );
end entity;

architecture rtl of encoder is
  signal current_state, next_state : ENCODER_STATE;
  signal current_time : Time := 0 ns;
  signal latched_decimals : BCD_DECIMALS_BUFFER;
  signal decimal_index : integer range 0 to 6 := 0;

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
  -- Encodes raw ADC readings into LCD characters that
  -- will be displayed on the LCD screen. The encoding follow the font table of
  -- LCD 'jhd162a'.
  ---------------------------------------------------------
  process (current_time, current_state, decimal_index, SPI_BUSY, LCD_BUSY, DECIMALS) is
  begin
    next_state <= current_state;

    case current_state is
      when ENCODER_STATE_WAIT_CONV_START =>
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');
        latched_decimals <= (others => '0');

        -- Wait for the ADC controller to start reading
        if SPI_BUSY = '0' then
          next_state <= ENCODER_STATE_WAIT_CONV_END;
        end if;

      when ENCODER_STATE_WAIT_CONV_END =>
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');
        latched_decimals <= (others => '0');

        -- Wait for the ADC controller to finish reading
        if SPI_BUSY = '1' then
          next_state <= ENCODER_STATE_READ;
        end if;

      when ENCODER_STATE_READ =>
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        if current_time < BCD_CONV_TIME then
          -- Latch the current voltage and display it
          latched_decimals <= DECIMALS;
        elsif LCD_BUSY = '0' then
          next_state <= ENCODER_STATE_CLEAR_SCREEN;
        end if;

      when ENCODER_STATE_CLEAR_SCREEN =>
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        if current_time < ENCODER_CLK_PERIOD then
          LCD_ENABLE <= '1';
          VOLTAGE <= "000000001";
        elsif current_time < ENCODER_CLK_PERIOD * 3 then
          LCD_ENABLE <= '0';
          VOLTAGE <= (others => '0');
        else
          next_state <= ENCODER_STATE_SHOW_VOLTAGE;
        end if;

      when ENCODER_STATE_SHOW_VOLTAGE =>
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        if decimal_index >= 6 then
          -- We must limit the amount of times that we write to the LCD.
          if current_time >= ENCODER_UPDATE_WAIT_TIME then
            next_state <= ENCODER_STATE_WAIT_CONV_START;
          end if;
        elsif LCD_BUSY = '0' then
          next_state <= ENCODER_STATE_SHOW_DECIMAL;
        end if;

      when ENCODER_STATE_SHOW_DECIMAL =>
        LCD_ENABLE <= '0';
        VOLTAGE <= (others => '0');

        if current_time < ENCODER_CLK_PERIOD then
          LCD_ENABLE <= '1';
          case decimal_index is
            when 0 => VOLTAGE <= font_lookup (latched_decimals (latched_decimals'left downto latched_decimals'left-3));
            when 1 => VOLTAGE <= LCD_CHAR_COMMA;
            when 2 => VOLTAGE <= font_lookup (latched_decimals (latched_decimals'left-4 downto latched_decimals'left-7));
            when 3 => VOLTAGE <= font_lookup (latched_decimals (latched_decimals'left-8 downto latched_decimals'left-11));
            when 4 => VOLTAGE <= font_lookup (latched_decimals (latched_decimals'left-12 downto latched_decimals'left-15));
            when 5 => VOLTAGE <= LCD_CHAR_V;
            when others => LCD_ENABLE <= '0';
          end case;
        elsif current_time < ENCODER_CLK_PERIOD * 3 then
          LCD_ENABLE <= '0';
          VOLTAGE <= (others => '0');
        else
          next_state <= ENCODER_STATE_SHOW_VOLTAGE;
        end if;
    end case;
  end process;

  -- Update current state according to clock
  process (CLK, RESET) is
  begin
    if RESET = '1' then
      current_state <= ENCODER_STATE_WAIT_CONV_START;
    elsif CLK'event and rising_edge(CLK) then
      if next_state /= current_state then
        current_time <= 0 ns;
      else
        current_time <= current_time + ENCODER_CLK_PERIOD;
      end if;

      if current_state = ENCODER_STATE_SHOW_DECIMAL and next_state = ENCODER_STATE_SHOW_VOLTAGE then
        decimal_index <= decimal_index + 1;
      elsif current_state /= ENCODER_STATE_SHOW_VOLTAGE and current_state /= ENCODER_STATE_SHOW_DECIMAL then
        decimal_index <= 0;
      end if;

      current_state <= next_state;
    end if;
  end process;
end rtl;