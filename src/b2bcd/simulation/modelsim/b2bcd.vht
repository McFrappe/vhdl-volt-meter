-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions
-- and other software and tools, and its AMPP partner logic
-- functions, and any output files from any of the foregoing
-- (including device programming or simulation files), and any
-- associated documentation or information are expressly subject
-- to the terms and conditions of the Intel Program License
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to
-- suit user's needs .Comments are provided in each section to help the user
-- fill out necessary details.
-- ***************************************************************************
-- Generated on "05/03/2023 11:38:22"

-- Vhdl Test Bench template for design  :  b2bcd
--
-- Simulation tool : ModelSim-Altera (VHDL)
--

LIBRARY ieee;
USE work.config.all;
USE ieee.std_logic_1164.all;

ENTITY b2bcd_vhd_tst IS
END b2bcd_vhd_tst;

ARCHITECTURE b2bcd_arch OF b2bcd_vhd_tst IS
  SIGNAL BCD0 : BCD_DECIMAL_BUFFER;
  SIGNAL BCD1 : BCD_DECIMAL_BUFFER;
  SIGNAL BCD2 : BCD_DECIMAL_BUFFER;
  SIGNAL BCD3 : BCD_DECIMAL_BUFFER;
  SIGNAL BINARY : BCD_BINARY_BUFFER;
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;

  COMPONENT b2bcd
    PORT (
      BCD0 : OUT BCD_DECIMAL_BUFFER;
      BCD1 : OUT BCD_DECIMAL_BUFFER;
      BCD2 : OUT BCD_DECIMAL_BUFFER;
      BCD3 : OUT BCD_DECIMAL_BUFFER;
      BINARY_IN : IN BCD_BINARY_BUFFER;
      CLK : IN STD_LOGIC;
      RESET : IN STD_LOGIC
    );
  END COMPONENT;
BEGIN
  i1 : b2bcd
  PORT MAP (
    BCD0 => BCD0,
    BCD1 => BCD1,
    BCD2 => BCD2,
    BCD3 => BCD3,
    BINARY_IN => BINARY,
    CLK => CLK,
    RESET => RESET
  );

  clock : PROCESS
  BEGIN
    CLK <= '0';
    WAIT FOR CLK_PERIOD / 2;
    CLK <= '1';
    WAIT FOR CLK_PERIOD / 2;
  END PROCESS clock;

  test : PROCESS
  BEGIN
    RESET <= '1';
    WAIT FOR CLK_PERIOD;
    RESET <= '0'; -- start conversion

    BINARY <= "0110111101100"; -- 3564
    WAIT FOR 1 us;

    BINARY <= "0000001100100"; -- 100
    WAIT FOR 1 us;

    BINARY <= "0000001000000"; -- 64
    WAIT FOR 1 us;

    BINARY <= "0000000000011"; -- 3
    WAIT FOR 1 us;
  WAIT;
  END PROCESS test;
END b2bcd_arch;
