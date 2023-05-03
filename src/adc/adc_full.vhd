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
-- CREATED		"Wed May 03 09:46:20 2023"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY adc_full IS 
	PORT
	(
		SPI_MISO :  IN  STD_LOGIC;
		RESET :  IN  STD_LOGIC;
		CLK :  IN  STD_LOGIC;
		SPI_MOSI :  OUT  STD_LOGIC;
		SPI_SS :  OUT  STD_LOGIC;
		SPI_CLK :  OUT  STD_LOGIC;
		SPI_BUSY :  OUT  STD_LOGIC;
		VOLTAGE :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END adc_full;

ARCHITECTURE bdf_type OF adc_full IS 

COMPONENT adc_clk_divider
	PORT(CLK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 CLK_OUT : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT adc_controller
	PORT(CLK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 SPI_MISO : IN STD_LOGIC;
		 SPI_CLK : OUT STD_LOGIC;
		 SPI_MOSI : OUT STD_LOGIC;
		 SPI_SS : OUT STD_LOGIC;
		 SPI_BUSY : OUT STD_LOGIC;
		 ADC_BIT : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT shift_register
	PORT(CLK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 SR_IN : IN STD_LOGIC;
		 SPI_BUSY : IN STD_LOGIC;
		 SR_OUT : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;


BEGIN 
SPI_BUSY <= SYNTHESIZED_WIRE_3;



b2v_inst : adc_clk_divider
PORT MAP(CLK => CLK,
		 RESET => RESET,
		 CLK_OUT => SYNTHESIZED_WIRE_4);


b2v_inst1 : adc_controller
PORT MAP(CLK => SYNTHESIZED_WIRE_4,
		 RESET => RESET,
		 SPI_MISO => SPI_MISO,
		 SPI_CLK => SPI_CLK,
		 SPI_MOSI => SPI_MOSI,
		 SPI_SS => SPI_SS,
		 SPI_BUSY => SYNTHESIZED_WIRE_3,
		 ADC_BIT => SYNTHESIZED_WIRE_2);


b2v_inst2 : shift_register
PORT MAP(CLK => SYNTHESIZED_WIRE_4,
		 RESET => RESET,
		 SR_IN => SYNTHESIZED_WIRE_2,
		 SPI_BUSY => SYNTHESIZED_WIRE_3,
		 SR_OUT => VOLTAGE);


END bdf_type;