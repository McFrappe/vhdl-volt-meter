library ieee;
use ieee.std_logic_1164.all;

package shared is
  constant SPI_CLOCK_FREQ : Time := 1 us;

  -- We use a shift register of 16 bits (though ADC has resolution of 12 bits).
  subtype ADC_RESOLUTION is std_logic_vector (15 downto 0);
end package shared;

package body shared is
end shared;