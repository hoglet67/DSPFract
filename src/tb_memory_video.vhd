--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:39:54 01/11/2012
-- Design Name:   
-- Module Name:   C:/Users/Hamster/Projects/FPGA/dspfactal/tb_memory_video.vhd
-- Project Name:  dspfactal
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: memory_video
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_memory_video IS
END tb_memory_video;
 
ARCHITECTURE behavior OF tb_memory_video IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT memory_video
    PORT(
         clk : IN  std_logic;
         nclk : IN  std_logic;
			
         write_ready : IN  std_logic;
         write_addr  : IN  std_logic_vector(18 downto 0);
         write_byte  : IN  std_logic_vector( 7 downto 0);
         write_taken : OUT  std_logic;
			
         hsync : OUT  std_logic;
         vsync : OUT  std_logic;
         colour : OUT  std_logic_vector(7 downto 0);

			-- Memory Interface
			mem_nCE          : out   STD_LOGIC;
			mem_nWE			  : out   STD_LOGIC;
			mem_nOE			  : out   STD_LOGIC;
			mem_data         : inout STD_LOGIC_VECTOR(15 downto 0);
			mem_addr         : out   STD_LOGIC_VECTOR(17 downto 0)
			);
    END COMPONENT;
    

   --Inputs
   signal clk         : std_logic := '0';
   signal nclk        : std_logic := '0';
   signal write_ready : std_logic := '1';
   signal write_addr  : std_logic_vector(18 downto 0) := "1010101010101010101";
   signal write_byte  : std_logic_vector(7 downto 0) := "10011001";

 	--Outputs
   signal write_taken : std_logic;
   signal hsync       : std_logic;
   signal vsync       : std_logic;
   signal colour      : std_logic_vector(7 downto 0);
   signal mem_addr    : std_logic_vector(17 downto 0);
   signal mem_data    : std_logic_vector(15 downto 0);
   signal mem_nCE     : STD_LOGIC;
	signal mem_nWE		 : STD_LOGIC;
	signal mem_nOE		 : STD_LOGIC;


   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant nclk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memory_video PORT MAP (
          clk => clk,
          nclk => nclk,
          write_ready => write_ready,
          write_addr  => write_addr,
          write_byte  => write_byte,
          write_taken => write_taken,
          hsync => hsync,
          vsync => vsync,
          colour => colour,
			 mem_nCE => mem_nCE,
			 mem_nWE => mem_nWE,
	       mem_nOE => mem_nOE,
	       mem_data => mem_data,
	       mem_addr => mem_addr
			 );
			 
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		nclk <= '1';
		wait for clk_period/2;
		clk <= '1';
		nclk <= '0';
		wait for clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
