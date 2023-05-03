library ieee;
use work.config.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity b2bcd is
    port(
        CLK, RESET: in std_logic;
        BINARY_IN: in BCD_BINARY_BUFFER;
        BCD3, BCD2, BCD1, BCD0 : out BCD_DECIMAL_BUFFER
    );
end b2bcd;

architecture rtl of b2bcd is
    signal state, state_next: BCD_STATE;
    signal binary, binary_next: std_logic_vector (BCD_BINARY_BITS-1 downto 0);
    signal bcds, bcds_reg, bcds_next: std_logic_vector (19 downto 0);
    signal shift_counter, shift_counter_next: natural range 0 to BCD_BINARY_BITS;
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
  process(state, binary, BINARY_IN, bcds, bcds_reg, shift_counter)
  begin
      state_next <= state;
      bcds_next <= bcds;
      binary_next <= binary;
      shift_counter_next <= shift_counter;

      case state is
          when BCD_STATE_START =>
              state_next <= BCD_STATE_SHIFT;
              binary_next <= binary_in;
              bcds_next <= (others => '0');
              shift_counter_next <= 0;
          when BCD_STATE_SHIFT =>
              if shift_counter = BCD_BINARY_BITS then
                  state_next <= BCD_STATE_DONE;
              else
                  binary_next <= binary (BCD_BINARY_BITS-2 downto 0) & 'L';
                  bcds_next <= bcds_reg (18 downto 0) & binary (BCD_BINARY_BITS-1);
                  shift_counter_next <= shift_counter + 1;
              end if;
          when BCD_STATE_DONE =>
              state_next <= BCD_STATE_START;
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

  BCD3 <= bcds (15 downto 12);
  BCD2 <= bcds (11 downto 8);
  BCD1 <= bcds (7 downto 4);
  BCD0 <= bcds (3 downto 0);
end rtl;