library ieee;
use work.config.all;
use ieee.std_logic_1164.all;

entity lcd_controller is
  port (
    CLK, RESET, ENABLE : in std_logic;
    DATA : in LCD_DATA_BUFFER;
    LCD_RS, LCD_RW, LCD_ENABLE, LCD_BL, LCD_ON : out std_logic;
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
  process (current_time, current_state, ENABLE, DATA, RESET) is
  begin
    next_state <= current_state;

    case current_state is
      when LCD_STATE_POWER_ON =>
        -- Wait for quite a while in order to make sure that
        -- the LCD display has power, etc.
        if current_time < LCD_POWER_ON_WAIT_TIME then
          -- Initialize signals
          LCD_RS <= '0';
          LCD_RW <= '0';
          LCD_ENABLE <= '0';
          LCD_BUSY <= '1';
          LCD_BUS <= (others => '0');
        else
          next_state <= LCD_STATE_RESET;
        end if;

      when LCD_STATE_RESET =>
        LCD_RS <= '0';
        LCD_RW <= '0';

        if current_time < LCD_RESET_TIME then
          if current_time < LCD_ENABLE_PULSE_WIDTH then
            LCD_BUS <= "00110000";
            LCD_ENABLE <= '1';
          elsif current_time < (2 * LCD_ENABLE_PULSE_WIDTH) then
            LCD_ENABLE <= '0';
            LCD_BUS <= (others => '0');
          end if;
        else
          next_state <= LCD_STATE_CLEAR;
        end if;

      when LCD_STATE_CLEAR =>
        if current_time < LCD_CLEAR_TIME then
          if current_time < LCD_ENABLE_PULSE_WIDTH then
            LCD_BUS <= "00110000";
            LCD_ENABLE <= '1';
          elsif current_time < (2 * LCD_ENABLE_PULSE_WIDTH) then
            LCD_ENABLE <= '0';
            LCD_BUS <= (others => '0');
          end if;
        else
          next_state <= LCD_STATE_INIT;
        end if;

      when LCD_STATE_INIT =>
        if current_time < LCD_ENABLE_PULSE_WIDTH then
          -- Reset for a third time
          LCD_BUS <= LCD_RESET_CMD;
          LCD_ENABLE <= '1';
        elsif current_time < (2 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_ENABLE <= '0';
          LCD_BUS <= (others => '0');
        elsif current_time < (3 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_BUS <= LCD_SET_INTERFACE_CMD;
          LCD_ENABLE <= '1';
        elsif current_time < (4 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_ENABLE <= '0';
          LCD_BUS <= (others => '0');
        elsif current_time < (5 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_BUS <= LCD_CONFIGURE_CMD;
          LCD_ENABLE <= '1';
        elsif current_time < (6 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_ENABLE <= '0';
          LCD_BUS <= (others => '0');
        elsif current_time < (7 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_BUS <= LCD_DISP_OFF_CMD;
          LCD_ENABLE <= '1';
        elsif current_time < (8 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_ENABLE <= '0';
          LCD_BUS <= (others => '0');
        elsif current_time < (9 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_BUS <= LCD_DISP_CLEAR_CMD;
          LCD_ENABLE <= '1';
        elsif current_time < (10 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_ENABLE <= '0';
          LCD_BUS <= (others => '0');
        elsif current_time < (11 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_BUS <= LCD_ENTRY_MODE_CMD;
          LCD_ENABLE <= '1';
        elsif current_time < (12 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_ENABLE <= '0';
          LCD_BUS <= (others => '0');
        else
          next_state <= LCD_STATE_READY;
        end if;

      when LCD_STATE_READY =>
        LCD_BUSY <= '0';
        if ENABLE = '1' then
          LCD_RS <= DATA(DATA'left);
          LCD_RW <= DATA(DATA'left - 1);
          LCD_BUS <= DATA((DATA'left - 2) downto 0);
          next_state <= LCD_STATE_WRITE;
        else
          LCD_RS <= '0';
          LCD_RW <= '0';
          LCD_BUS <= (others => '0');
        end if;

      when LCD_STATE_WRITE =>
        LCD_BUSY <= '1';
        if current_time < LCD_ENABLE_PULSE_WIDTH then
          LCD_ENABLE <= '1';
        elsif current_time < (2 * LCD_ENABLE_PULSE_WIDTH) then
          LCD_ENABLE <= '0';
          LCD_RS <= '0';
          LCD_RW <= '0';
          LCD_BUS <= (others => '0');
        else
          next_state <= LCD_STATE_READY;
        end if;
    end case;
  end process;

  -- Update current state according to clock
  process (CLK, RESET) is
  begin
    if RESET = '1' then
      current_state <= LCD_STATE_RESET;
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

  -- Turn on backlight and power on LCD display
  LCD_BL <= '1';
  LCD_ON <= '1';
end rtl;