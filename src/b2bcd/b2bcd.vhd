library ieee;
use work.config.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity b2bcd is
  port (
    CLK, RST : in std_logic;
    BINARY : in BCD_BINARY_RESOLUTION;
    BCD0 : out BCD_DECIMAL_RESOLUTION;
    BCD1 : out BCD_DECIMAL_RESOLUTION;
    BCD2 : out BCD_DECIMAL_RESOLUTION;
    BCD3 : out BCD_DECIMAL_RESOLUTION
  );
end entity;

architecture rtl of b2bcd is
  signal scratch : BCD_SCRATCH_BUFFER := (others => '0');
  signal counter : integer range 0 to 16 := 0;
begin
  process (CLK, RST, BINARY)
  begin
    if RST = '1' then
      scratch(BCD_BINARY_BITS-1 downto 0) <= unsigned (BINARY);
      scratch(BCD_SCRATCH_BITS-1 downto BCD_BINARY_BITS) <= (others => '0');
      counter <= 0;
    elsif rising_edge(CLK) then
			if counter < BCD_BINARY_BITS then
				if scratch (BCD_SCRATCH_BITS-2 downto BCD_SCRATCH_BITS-5) > 4 then
					scratch (BCD_SCRATCH_BITS-1 downto BCD_SCRATCH_BITS-5) <= scratch (BCD_SCRATCH_BITS-1 downto BCD_SCRATCH_BITS-5) + 3;
				end if;

				if scratch (BCD_SCRATCH_BITS-5 downto BCD_SCRATCH_BITS-8) > 4 then
					scratch (BCD_SCRATCH_BITS-1 downto BCD_SCRATCH_BITS-8) <= scratch (BCD_SCRATCH_BITS-1 downto BCD_SCRATCH_BITS-8) + 3;
				end if;

				if scratch (BCD_SCRATCH_BITS-9 downto BCD_SCRATCH_BITS-12) > 4 then
					scratch (BCD_SCRATCH_BITS-1 downto BCD_SCRATCH_BITS-12) <= scratch (BCD_SCRATCH_BITS-1 downto BCD_SCRATCH_BITS-12) + 3;
				end if;

				if scratch (BCD_SCRATCH_BITS-13 downto BCD_SCRATCH_BITS-16) > 4 then
					scratch (BCD_SCRATCH_BITS-1 downto BCD_SCRATCH_BITS-16) <= scratch (BCD_SCRATCH_BITS-1 downto BCD_SCRATCH_BITS-16) + 3;
				end if;

				scratch <= shift_left(scratch, 1);
				counter <= counter + 1;
        -- TODO: Add else, reset counter and read binary?
			end if;
    end if;
  end process;

  -- Split scratch buffer into 4 parts, one for each decimal number
  BCD3 <= std_logic_vector (scratch (BCD_SCRATCH_BITS-1 downto BCD_SCRATCH_BITS-4));
  BCD2 <= std_logic_vector (scratch (BCD_SCRATCH_BITS-5 downto BCD_SCRATCH_BITS-8));
  BCD1 <= std_logic_vector (scratch (BCD_SCRATCH_BITS-9 downto BCD_SCRATCH_BITS-12));
  BCD0 <= std_logic_vector (scratch (BCD_SCRATCH_BITS-13 downto BCD_SCRATCH_BITS-16));
end rtl;