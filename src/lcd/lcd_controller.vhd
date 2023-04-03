library ieee;
use ieee.std_logic_1164.all;

entity lcd_controller is
  port (
    CLK, RESET, LCD_E : in std_logic;
    DATA : in LCD_DATA_BUFFER;
    -- TODO: What pins do we need as output?
    LCD_CS1, LCD_CS2, LCD_RESET: out std_logic;
    LCD_BUS : out LCD_DATA_BUS
  );
end entity;

architecture rtl of lcd_controller is
begin
  --------------------------------------------
  -- Accepts an instruction to execute, or data
  -- to write to the LCD display RAM.
  --------------------------------------------
  -- TODO: Implement state machine
end rtl;