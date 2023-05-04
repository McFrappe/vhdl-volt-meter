library ieee;
use work.config.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
    port(
        CLK, RESET: in std_logic;
        DIRECTION : in std_logic;
        SHIFTS : in std_logic_vector (3 downto 0);
        VALUE : in CONVERTER_IN_BUFFER;
        RESULT : out CONVERTER_OUT_BUFFER
    );
end shifter;

architecture rtl of shifter is
  signal counter : integer := 0;
  signal shift : CONVERTER_OUT_BUFFER := (others => '0');
begin
  process (CLK, RESET)
  begin
      if RESET = '1' then
        counter <= 0;
        shift (CONVERTER_IN_BUFFER'left downto 0) <= VALUE;
        shift (shift'left downto CONVERTER_IN_BUFFER'left+1) <= (others => '0');
      elsif rising_edge(CLK) then
        if counter < unsigned (SHIFTS) then
          if DIRECTION = '0' then
            shift <= shift (shift'left-1 downto 0) & '0';
          else
            shift <= '0' & shift (shift'left downto 1);
          end if;
          counter <= counter + 1;
        end if;
      end if;
  end process;
end rtl;