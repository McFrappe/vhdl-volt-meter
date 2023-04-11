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
-- Generated on "04/11/2023 14:57:07"

-- Vhdl Test Bench template for design  :  adc_test
--
-- Simulation tool : ModelSim-Altera (VHDL)
--

LIBRARY ieee;
USE work.config.all;
USE ieee.std_logic_1164.all;

ENTITY adc_test_vhd_tst IS
END adc_test_vhd_tst;

ARCHITECTURE adc_test_arch OF adc_test_vhd_tst IS
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;
  SIGNAL SPI_MISO : STD_LOGIC;
  SIGNAL SPI_MOSI : STD_LOGIC;
  SIGNAL SPI_BUSY : STD_LOGIC;
  SIGNAL SPI_SS : STD_LOGIC;
  SIGNAL VOLTAGE : ADC_RESOLUTION;

  COMPONENT adc_test
    PORT (
      CLK : IN STD_LOGIC;
      RESET : IN STD_LOGIC;
      SPI_MISO : IN STD_LOGIC;
      SPI_MOSI : OUT STD_LOGIC;
      SPI_BUSY : OUT STD_LOGIC;
      SPI_SS : OUT STD_LOGIC;
      VOLTAGE : OUT ADC_RESOLUTION
    );
  END COMPONENT;
BEGIN
  i1 : adc_test
  PORT MAP (
    CLK => CLK,
    RESET => RESET,
    SPI_MISO => SPI_MISO,
    SPI_MOSI => SPI_MOSI,
    SPI_BUSY => SPI_BUSY,
    SPI_SS => SPI_SS,
    VOLTAGE => VOLTAGE
  );

  clock : PROCESS
  BEGIN
    -- We use the normal 50 MHz clock here since
    -- a clock divider is used to convert the system clock
    -- into the clock required by the ADC chip.
    CLK <= '1';
    WAIT FOR CLK_PERIOD / 2;
    CLK <= '0';
    WAIT FOR CLK_PERIOD / 2;
  END PROCESS clock;

  test : PROCESS
  BEGIN
    RESET <= '1';
    SPI_MISO <= '1';

    WAIT FOR CLK_PERIOD;
    RESET <= '0';

    -- Test a total of 3 conversions
    WAIT UNTIL SPI_BUSY = '0';
    WAIT UNTIL SPI_BUSY = '1';
    WAIT UNTIL SPI_BUSY = '0';
    WAIT UNTIL SPI_BUSY = '1';
    WAIT UNTIL SPI_BUSY = '0';
  WAIT;
  END PROCESS test;
END adc_test_arch;