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

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
-- CREATED		"Wed May 03 09:55:05 2023"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY lcd_full IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		RESET :  IN  STD_LOGIC;
		ENABLE :  IN  STD_LOGIC;
		DATA :  IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
		LCD_RS :  OUT  STD_LOGIC;
		LCD_RW :  OUT  STD_LOGIC;
		LCD_ENABLE :  OUT  STD_LOGIC;
		LCD_BL :  OUT  STD_LOGIC;
		LCD_ON :  OUT  STD_LOGIC;
		LCD_BUSY :  OUT  STD_LOGIC;
		LCD_BUS :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END lcd_full;

ARCHITECTURE bdf_type OF lcd_full IS 

COMPONENT lcd_controller
	PORT(CLK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 ENABLE : IN STD_LOGIC;
		 DATA : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 LCD_RS : OUT STD_LOGIC;
		 LCD_RW : OUT STD_LOGIC;
		 LCD_ENABLE : OUT STD_LOGIC;
		 LCD_BL : OUT STD_LOGIC;
		 LCD_ON : OUT STD_LOGIC;
		 LCD_BUSY : OUT STD_LOGIC;
		 LCD_BUS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;



BEGIN 



b2v_inst : lcd_controller
PORT MAP(CLK => CLK,
		 RESET => RESET,
		 ENABLE => ENABLE,
		 DATA => DATA,
		 LCD_RS => LCD_RS,
		 LCD_RW => LCD_RW,
		 LCD_ENABLE => LCD_ENABLE,
		 LCD_BL => LCD_BL,
		 LCD_ON => LCD_ON,
		 LCD_BUSY => LCD_BUSY,
		 LCD_BUS => LCD_BUS);


END bdf_type;