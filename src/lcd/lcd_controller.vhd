library ieee;
library work;
use work.all;
use ieee.std_logic_1164.all;

entity lcd_controller is
  port (
    CLK, RESET, ENABLE : in std_logic;
    DATA : in LCD_DATA_BUFFER;
    -- TODO: What pins do we need as output?
    LCD_RS, LCD_RW, LCD_ENABLE : out std_logic;
    LCD_CS1, LCD_CS2, LCD_RESET : out std_logic;
    LCD_BUS : out LCD_DATA_BUS
  );
end entity;

architecture rtl of lcd_controller is
  signal current_state, next_state : LCD_STATE;
  signal current_time : Time := 0;
begin
  ---------------------------------------------------------
  -- Accepts an instruction to execute, or data to write to
  -- the LCD display RAM.
  ---------------------------------------------------------
  -- TODO: What should CS1 and CS2 be? Constant?
  process (current_state, ENABLE, DATA) is
  begin
    next_state <= current_state;

    case current_state is
      when LCD_STATE_START =>
        if current_time < LCD_RESET_TIME then
          RESET <= '1';
        else
          RESET <= '0';
          current_time <= 0;
          next_state <= LCD_STATE_INIT;
        end if;

      when LCD_STATE_INIT =>
        if current_time < LCD_INIT_TIME then
          LCD_RS <= '0';
          LCD_RW <= '0';
          LCD_BUS <= "00111111"; -- Start the display
          LCD_ENABLE <= '1';
        else
          LCD_ENABLE <= '0';
          LCD_BUS <= "00000000";
          current_time <= 0;
          next_state <= LCD_STATE_READY;
        end if;
      when LCD_STATE_READY =>
        if ENABLE = '1' then
          LCD_RS <= DATA(DATA'left);
          LCD_RW <= DATA(DATA'left - 1);
          LCD_BUS <= DATA((DATA'left - 2) downto 0);
          current_time <= 0;
          next_state <= LCD_STATE_SEND;
        else
          LCD_RS <= '0';
          LCD_RW <= '0';
          LCD_BUS <= DATA((DATA'left - 2) downto 0);
        end if;
      when LCD_STATE_SEND =>
        if current_time < LCD_ENABLE_CYCLE_TIME then
          LCD_ENABLE <= '0';
        elsif current_time < (2 * LCD_ENABLE_CYCLE_TIME) then
          LCD_ENABLE <= '1';
        elsif current_time < (3 * LCD_ENABLE_CYCLE_TIME) then
          LCD_ENABLE <= '0';
        elsif current_time < (5 * LCD_ENABLE_CYCLE_TIME) then
          current_time <= 0;
          next_state <= LCD_STATE_READY;
        end if;
    end case;
  end process;

  -- Update current state according to clock
  process (CLK, RESET) is
  begin
    if RESET = '1' then
      current_state <= LCD_STATE_START;
    elsif CLK'event and rising_edge(CLK) then
      current_state <= next_state;
    end if;

    -- Increase current_time for each clock cycle so that we
    -- can keep track of timings for reset, etc (based on datasheet).
    current_time <= current_time + LCD_CLK_FREQ;
  end process;
end rtl;