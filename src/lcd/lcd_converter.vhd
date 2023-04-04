library ieee;
use work.config.all;
use ieee.std_logic_1164.all;

entity lcd_converter is
  port (
    CLK, LCD_BUSY : in std_logic;
    ADC_BITS : in ADC_RESOLUTION;
    ENABLE : out std_logic;
    VOLTAGE : out LCD_DATA_BUFFER
  );
end entity;

architecture rtl of lcd_converter is
begin
  ---------------------------------------------------------
  -- Converts a 16-bit ADC input into a voltage level in
  -- decimal form that will be displayed on the LCD display.
  -- Since only a single character/instruction can be sent
  -- to the display via the data bus at once, conversion of
  -- the input ADC bits takes multiple clock cycles.
  ---------------------------------------------------------
  process (CLK, LCD_BUSY)
    variable character : integer range 0 to 12 := 0;
  begin
    if CLK'event and rising_edge(CLK) then
      if LCD_BUSY = '0' then
        ENABLE <= '1';

        -- Go through all 12 characters and write to LCD
        if (character < 12) then
          character := character + 1;
        end if;

        case character is
          when 1  => VOLTAGE <= "1000000000";
          when 2  => VOLTAGE <= "1000000001";
          when 3  => VOLTAGE <= "1000000010";
          when 4  => VOLTAGE <= "1000000011";
          when 5  => VOLTAGE <= "1000000100";
          when 6  => VOLTAGE <= "1000000101";
          when 7  => VOLTAGE <= "1000000110";
          when 8  => VOLTAGE <= "1000000111";
          when 9  => VOLTAGE <= "1000001001";
          when 10 => VOLTAGE <= "1000001010";
          when 11 => VOLTAGE <= "1000001011";
          when 12 => VOLTAGE <= "1000001100";
          when others => ENABLE <= '0';
        end case;
      else
        ENABLE <= '0';
      end if;
    end if;
  end process;

  -- See page 13 in datasheet:
  -- VIN = ADC_BITS * VDD / 4096 (VDD = 5?).
  -- VOLTAGE <= ADC_BITS(7 downto 0); -- FIXME
end rtl;