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
  process (current_time, current_state, ENABLE, DATA) is
  begin
    next_state <= current_state;

    -- TODO: Remove compilation warnings by always
    -- setting every out pin in each state and branch.
    case current_state is
      when LCD_STATE_POWER_ON =>
        LCD_BUSY <= '1';
        -- Wait for quite a while in order to make sure that
        -- the LCD display has power, etc.
        if current_time < LCD_POWER_ON_WAIT_TIME then
          -- Initialize signals
          LCD_RS <= '0';
          LCD_ENABLE <= '0';
          LCD_BUS <= (others => '0');
        else
          next_state <= LCD_STATE_RESET;
        end if;

      when LCD_STATE_RESET =>
        LCD_BUSY <= '1';
        if current_time < LCD_RESET_TIME + LCD_TC then
          if current_time < LCD_TSP1 then
            LCD_RS <= '0';
            LCD_BUS <= LCD_RESET_CMD;
            LCD_ENABLE <= '0';
          elsif current_time < LCD_TSP1 + LCD_TPW then
            LCD_ENABLE <= '1';
          else
            LCD_ENABLE <= '0';
          end if;
        else
          LCD_BUS <= (others => '0');
          next_state <= LCD_STATE_RESET_2;
        end if;

      when LCD_STATE_RESET_2 =>
        LCD_BUSY <= '1';
        if current_time < LCD_RESET_2_TIME + LCD_TC then
          if current_time < LCD_TSP1 then
            LCD_RS <= '0';
            LCD_BUS <= LCD_RESET_CMD;
            LCD_ENABLE <= '0';
          elsif current_time < LCD_TSP1 + LCD_TPW then
            LCD_ENABLE <= '1';
          else
            LCD_ENABLE <= '0';
          end if;
        else
          LCD_BUS <= (others => '0');
          next_state <= LCD_STATE_RESET_3;
        end if;

      when LCD_STATE_RESET_3 =>
        LCD_BUSY <= '1';
        if current_time < LCD_RESET_CMD_TIME + LCD_TC then
          if current_time < LCD_TSP1 then
            LCD_RS <= '0';
            LCD_BUS <= LCD_RESET_CMD;
            LCD_ENABLE <= '0';
          elsif current_time < LCD_TSP1 + LCD_TPW then
            LCD_ENABLE <= '1';
          else
            LCD_ENABLE <= '0';
          end if;
        else
          LCD_BUS <= (others => '0');
          next_state <= LCD_STATE_FN_SET;
        end if;

      when LCD_STATE_FN_SET =>
        LCD_BUSY <= '1';
        if current_time < LCD_CMD_TIME + LCD_TC then
          if current_time < LCD_TSP1 then
            LCD_RS <= '0';
            LCD_BUS <= LCD_FN_SET_CMD;
            LCD_ENABLE <= '0';
          elsif current_time < LCD_TSP1 + LCD_TPW then
            LCD_ENABLE <= '1';
          else
            LCD_ENABLE <= '0';
          end if;
        else
          LCD_BUS <= (others => '0');
          next_state <= LCD_STATE_CONFIGURE;
        end if;

      when LCD_STATE_CONFIGURE =>
        LCD_BUSY <= '1';
        if current_time < LCD_CMD_TIME + LCD_TC then
          if current_time < LCD_TSP1 then
            LCD_RS <= '0';
            LCD_BUS <= LCD_CONFIGURE_CMD;
            LCD_ENABLE <= '0';
          elsif current_time < LCD_TSP1 + LCD_TPW then
            LCD_ENABLE <= '1';
          else
            LCD_ENABLE <= '0';
          end if;
        else
          LCD_BUS <= (others => '0');
          next_state <= LCD_STATE_DISP_SWITCH;
        end if;

      when LCD_STATE_DISP_SWITCH =>
        LCD_BUSY <= '1';
        if current_time < LCD_CMD_TIME + LCD_TC then
          if current_time < LCD_TSP1 then
            LCD_RS <= '0';
            LCD_BUS <= LCD_DISP_SWITCH_CMD;
            LCD_ENABLE <= '0';
          elsif current_time < LCD_TSP1 + LCD_TPW then
            LCD_ENABLE <= '1';
          else
            LCD_ENABLE <= '0';
          end if;
        else
          LCD_BUS <= (others => '0');
          next_state <= LCD_STATE_DISP_CLEAR;
        end if;

      when LCD_STATE_DISP_CLEAR =>
        LCD_BUSY <= '1';
        if current_time < LCD_RESET_CMD_TIME + LCD_TC then
          if current_time < LCD_TSP1 then
            LCD_RS <= '0';
            LCD_BUS <= LCD_DISP_CLEAR_CMD;
            LCD_ENABLE <= '0';
          elsif current_time < LCD_TSP1 + LCD_TPW then
            LCD_ENABLE <= '1';
          else
            LCD_ENABLE <= '0';
          end if;
        else
          LCD_BUS <= (others => '0');
          next_state <= LCD_STATE_ENTRY_MODE_SET;
        end if;

      when LCD_STATE_ENTRY_MODE_SET =>
        LCD_BUSY <= '1';
        if current_time < LCD_CMD_TIME + LCD_TC then
          if current_time < LCD_TSP1 then
            LCD_RS <= '0';
            LCD_BUS <= LCD_ENTRY_MODE_SET_CMD;
            LCD_ENABLE <= '0';
          elsif current_time < LCD_TSP1 + LCD_TPW then
            LCD_ENABLE <= '1';
          else
            LCD_ENABLE <= '0';
          end if;
        else
          LCD_BUS <= (others => '0');
          next_state <= LCD_STATE_DISP_ON;
        end if;

      when LCD_STATE_DISP_ON =>
        LCD_BUSY <= '1';
        if current_time < LCD_CMD_TIME + LCD_TC then
          if current_time < LCD_TSP1 then
            LCD_RS <= '0';
            LCD_BUS <= LCD_DISP_ON_CMD;
            LCD_ENABLE <= '0';
          elsif current_time < LCD_TSP1 + LCD_TPW then
            LCD_ENABLE <= '1';
          else
            LCD_ENABLE <= '0';
          end if;
        else
          LCD_BUS <= (others => '0');
          next_state <= LCD_STATE_READY;
        end if;

      when LCD_STATE_READY =>
        LCD_RS <= '0';
        LCD_BUS <= (others => '0');
        LCD_BUSY <= '0';

        if ENABLE = '1' then
          LCD_RS <= DATA(DATA'left);
          LCD_BUS <= DATA((DATA'left - 1) downto 0);
          next_state <= LCD_STATE_WRITE;
        end if;

      when LCD_STATE_WRITE =>
        LCD_BUSY <= '1';
        if current_time < LCD_RESET_TIME + LCD_TC then
          if current_time < LCD_TSP1 then
            LCD_ENABLE <= '0';
          elsif current_time < LCD_TSP1 + LCD_TPW then
            LCD_ENABLE <= '1';
          else
            LCD_ENABLE <= '0';
          end if;
        else
          LCD_BUS <= (others => '0');
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

  -- We never ready anything from the display, so we
  -- just keep the RW pin grounded constantly.
  LCD_RW <= '0';
end rtl;