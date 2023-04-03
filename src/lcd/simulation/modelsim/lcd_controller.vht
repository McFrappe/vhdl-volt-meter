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
-- Generated on "04/03/2023 20:54:38"

-- Vhdl Test Bench template for design  :  lcd_controller
--
-- Simulation tool : ModelSim-Altera (VHDL)
--

LIBRARY ieee;
USE work.config.all;
USE ieee.std_logic_1164.all;

ENTITY lcd_controller_vhd_tst IS
END lcd_controller_vhd_tst;
ARCHITECTURE lcd_controller_arch OF lcd_controller_vhd_tst IS
  SIGNAL CLK : STD_LOGIC;
  SIGNAL ENABLE : STD_LOGIC;
  SIGNAL DATA : LCD_DATA_BUFFER;
  SIGNAL LCD_BUS : LCD_DATA_BUS;
  SIGNAL LCD_CS1 : STD_LOGIC;
  SIGNAL LCD_CS2 : STD_LOGIC;
  SIGNAL LCD_ENABLE : STD_LOGIC;
  SIGNAL LCD_RESET : STD_LOGIC;
  SIGNAL LCD_RS : STD_LOGIC;
  SIGNAL LCD_RW : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;

  COMPONENT lcd_controller
    PORT (
      CLK : IN STD_LOGIC;
      ENABLE : IN STD_LOGIC;
      DATA : IN LCD_DATA_BUFFER;
      LCD_BUS : OUT LCD_DATA_BUS;
      LCD_CS1 : OUT STD_LOGIC;
      LCD_CS2 : OUT STD_LOGIC;
      LCD_ENABLE : OUT STD_LOGIC;
      LCD_RESET : OUT STD_LOGIC;
      LCD_RS : OUT STD_LOGIC;
      LCD_RW : OUT STD_LOGIC;
      RESET : IN STD_LOGIC
    );
  END COMPONENT;
BEGIN
  i1 : lcd_controller
  PORT MAP (
    CLK => CLK,
    DATA => DATA,
    ENABLE => ENABLE,
    LCD_BUS => LCD_BUS,
    LCD_CS1 => LCD_CS1,
    LCD_CS2 => LCD_CS2,
    LCD_ENABLE => LCD_ENABLE,
    LCD_RESET => LCD_RESET,
    LCD_RS => LCD_RS,
    LCD_RW => LCD_RW,
    RESET => RESET
  );

  clock : PROCESS
  BEGIN
    CLK <= '1';
    WAIT FOR CLK_FREQ / 2;
    CLK <= '0';
    WAIT FOR CLK_FREQ / 2;
  END PROCESS clock;

  test : PROCESS
  BEGIN
    ENABLE <= '0';
    DATA <= (others => '0');

    RESET <= '1';
    WAIT FOR CLK_FREQ;
    RESET <= '0';

    WAIT FOR LCD_RESET_TIME;
    WAIT FOR LCD_INIT_TIME * 2;
  WAIT;
  END PROCESS test;
END lcd_controller_arch;