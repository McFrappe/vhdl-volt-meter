library ieee;
use work.config.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity b2bcd is
  port(
    CLK, RESET, SPI_BUSY : in std_logic;
    BINARY_IN : in ADC_CONVERTER_BUFFER;
    DECIMALS : out BCD_DECIMALS_BUFFER
  );
end b2bcd;

architecture rtl of b2bcd is
  signal state, state_next : BCD_STATE;
  signal binary, binary_next : BCD_BINARY_BUFFER;
  signal bcds, bcds_reg, bcds_next : BCD_DECIMALS_BUFFER;
  signal shift_counter, shift_counter_next : natural range 0 to BCD_BINARY_BITS;
begin
  process (CLK, RESET)
  begin
    if RESET = '1' then
      binary <= (others => '0');
      bcds <= (others => '0');
      state <= BCD_STATE_START;
      shift_counter <= 0;
    elsif rising_edge(CLK) then
      binary <= binary_next;
      bcds <= bcds_next;
      state <= state_next;
      shift_counter <= shift_counter_next;
    end if;
  end process;

  convert:
  process(state, binary, BINARY_IN, SPI_BUSY, bcds, bcds_reg, shift_counter)
  begin
    state_next <= state;
    bcds_next <= bcds;
    binary_next <= binary;
    shift_counter_next <= shift_counter;

    case state is
      when BCD_STATE_START =>
        binary_next <= BINARY_IN (BCD_BINARY_BITS-1 downto 0);
        bcds_next <= (others => '0');
        shift_counter_next <= 0;

        -- Wait for ADC conversion to be done
        if SPI_BUSY = '1' then
          -- TODO: We need to wait at least an additional cycle, since
          --       the ADC value has not been converted into decimal yet.
          state_next <= BCD_STATE_SHIFT;
        end if;

      when BCD_STATE_SHIFT =>
        if shift_counter = BCD_BINARY_BITS then
          state_next <= BCD_STATE_DONE;
        else
          binary_next <= binary (BCD_BINARY_BITS-2 downto 0) & 'L';
          bcds_next <= bcds_reg (BCD_DECIMAL_BITS-2 downto 0) & binary (BCD_BINARY_BITS-1);
          shift_counter_next <= shift_counter + 1;
        end if;

      when BCD_STATE_DONE =>
        -- Wait until next ADC conversion starts before continuing
        if SPI_BUSY = '0' then
          state_next <= BCD_STATE_START;
        end if;
    end case;
  end process;

  bcds_reg (15 downto 12) <= bcds(15 downto 12) + 3 when bcds(15 downto 12) > 4
                             else bcds(15 downto 12);
  bcds_reg (11 downto 8) <= bcds(11 downto 8) + 3 when bcds(11 downto 8) > 4
                            else bcds(11 downto 8);
  bcds_reg (7 downto 4) <= bcds(7 downto 4) + 3 when bcds(7 downto 4) > 4
                           else bcds(7 downto 4);
  bcds_reg (3 downto 0) <= bcds(3 downto 0) + 3 when bcds(3 downto 0) > 4
                           else bcds(3 downto 0);

  DECIMALS <= bcds;
end rtl;