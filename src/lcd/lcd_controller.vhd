library ieee;
use work.config.all;
use ieee.std_logic_1164.all;

entity lcd_controller is
  port (
    CLK, RESET, ENABLE : in std_logic;
    DATA : in LCD_DATA_BUFFER;
    LCD_RS, LCD_RW, LCD_ENABLE : out std_logic;
    LCD_CS1, LCD_CS2, LCD_RESET : out std_logic;
    LCD_BUS : out LCD_DATA_BUS;
    LCD_BUSY : out std_logic
  );
end entity;

architecture rtl of lcd_controller is
  signal current_state, next_state : LCD_STATE;
  signal current_time : Time := 0 ns;
begin
  ---------------------------------------------------------
  -- Accepts an instruction to execute, or data to write to
  -- the LCD display RAM.
  ---------------------------------------------------------
  -- TODO: What should CS1 and CS2 be? Constant?
  process (current_time, current_state, ENABLE, DATA, RESET) is
  begin
    next_state <= current_state;

    case current_state is
      when LCD_STATE_START =>
        if current_time < LCD_RESET_TIME then
          -- Initialize signals
          LCD_RS <= '0';
          LCD_RW <= '0';
          LCD_ENABLE <= '0';
          LCD_BUSY <= '1';
          LCD_BUS <= (others => '0');
          LCD_RESET <= '1';
        else
          LCD_RESET <= '0';
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
          next_state <= LCD_STATE_READY;
        end if;
      when LCD_STATE_READY =>
        LCD_BUSY <= '0';
        if ENABLE = '1' then
          LCD_RS <= DATA(DATA'left);
          LCD_RW <= DATA(DATA'left - 1);
          LCD_BUS <= DATA((DATA'left - 2) downto 0);
          next_state <= LCD_STATE_SEND;
        else
          LCD_RS <= '0';
          LCD_RW <= '0';
          LCD_BUS <= DATA((DATA'left - 2) downto 0);
        end if;
      when LCD_STATE_SEND =>
        -- TODO: What timings is needed here? And do we really
        -- need to cycle between on and off?
        LCD_BUSY <= '1';
        if current_time < LCD_ENABLE_CYCLE_TIME then
          LCD_ENABLE <= '0';
        elsif current_time < (2 * LCD_ENABLE_CYCLE_TIME) then
          LCD_ENABLE <= '1';
        elsif current_time < (5 * LCD_ENABLE_CYCLE_TIME) then
          LCD_ENABLE <= '0';
        else
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
      if next_state /= current_state then
          current_time <= 0 ns;
      else
        -- Increase current_time for each clock cycle so that we
        -- can keep track of timings for reset, etc (based on datasheet).
        current_time <= current_time + LCD_CLK_PERIOD;
      end if;
      current_state <= next_state;
    end if;
  end process;

  -- FIXME: Keep constant? But what value?
  LCD_CS1 <= '0';
  LCD_CS2 <= '0';
end rtl;