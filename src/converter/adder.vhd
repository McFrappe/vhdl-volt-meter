library ieee;
use work.config.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    port(
        CLK, RESET: in std_logic;
        IN0, IN1, IN2, IN3, IN4 : in CONVERTER_IN_BUFFER;
        RESULT : out CONVERTER_OUT_BUFFER
    );
end adder;

architecture rtl of adder is
  signal res : CONVERTER_OUT_BUFFER := (others => '0');
begin
  process (CLK, RESET)
  begin
      if RESET = '1' then
        res <= (others => '0');
        RESULT <= (others => '0');
      elsif rising_edge(CLK) then
        res <= std_logic_vector (
                unsigned (IN0) +
                unsigned (IN1) +
                unsigned (IN2) +
                unsigned (IN3) +
                unsigned (IN4)
               );
      end if;
  end process;
  RESULT <= res;
end rtl;