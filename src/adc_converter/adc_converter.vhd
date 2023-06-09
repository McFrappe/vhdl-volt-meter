library ieee;
use work.config.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_converter is
  port(
    CLK, RESET: in std_logic;
    VALUE : in ADC_BUFFER;
    RESULT : out ADC_CONVERTER_BUFFER
  );
end adc_converter;

architecture rtl of adc_converter is
  signal res : unsigned (ADC_CONVERTER_BUFFER'left downto 0) := (others => '0');
  signal padding : ADC_CONVERTER_BUFFER := (others => '0');
begin
  process (CLK, RESET)
  begin
    if RESET = '0' then
      res <= (others => '0');
    elsif rising_edge(CLK) then
      res <=  shift_left (resize (unsigned (VALUE), ADC_CONVERTER_BUFFER'length), 12) +
              shift_left (resize (unsigned (VALUE), ADC_CONVERTER_BUFFER'length), 9) +
              shift_left (resize (unsigned (VALUE), ADC_CONVERTER_BUFFER'length), 8) +
              shift_left (resize (unsigned (VALUE), ADC_CONVERTER_BUFFER'length), 7) +
              shift_left (resize (unsigned (VALUE), ADC_CONVERTER_BUFFER'length), 3);
    end if;
  end process;
  RESULT <= std_logic_vector (shift_right (res, 12));
end rtl;