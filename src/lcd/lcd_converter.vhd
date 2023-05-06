library ieee;
use work.config.all;
use ieee.std_logic_1164.all;

entity lcd_converter is
  port (
    CLK, LCD_BUSY : in std_logic;
    ADC_BITS : in ADC_BUFFER;
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
    variable character : integer range 0 to 10 := 0;
  begin
    if CLK'event and rising_edge(CLK) then
      if LCD_BUSY = '0' then
        ENABLE <= '1';

        case character is
          when 0  => VOLTAGE <= "100110000";
          when 1  => VOLTAGE <= "100110001";
          when 2  => VOLTAGE <= "100110010";
          when 3  => VOLTAGE <= "100110011";
          when 4  => VOLTAGE <= "100110100";
          when 5  => VOLTAGE <= "100110101";
          when 6  => VOLTAGE <= "100110110";
          when 7  => VOLTAGE <= "100110111";
          when 8  => VOLTAGE <= "100111000";
          when 9  => VOLTAGE <= "100111001";
          when others => ENABLE <= '0';
        end case;

        -- Go through all 9 characters and write to LCD
        if (character < 10) then
          character := character + 1;
        end if;
      else
        ENABLE <= '0';
      end if;
    end if;
  end process;

  -- See page 13 in datasheet:
  -- VIN = ADC_BITS * VDD / 4096 (VDD = 5?).
  -- VOLTAGE <= ADC_BITS(7 downto 0); -- FIXME
end rtl;