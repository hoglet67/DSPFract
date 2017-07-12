--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:48:08 01/20/2012
-- Design Name:   
-- Module Name:   C:/Users/Hamster/Projects/FPGA/dspfactal/tbtopmodule.vhd
-- Project Name:  dspfactal
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TopModule
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
 
ENTITY tbtopmodule IS
END tbtopmodule;
 
ARCHITECTURE behavior OF tbtopmodule IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TopModule
    PORT(
         clk_32 : IN  std_logic;
         hsync : OUT  std_logic;
         vsync : OUT  std_logic;
         colour : OUT  std_logic_vector(7 downto 0);
         mem_nCE : OUT  std_logic;
         mem_nWE : OUT  std_logic;
         mem_nOE : OUT  std_logic;
         mem_nUB : OUT  std_logic;
         mem_nLB : OUT  std_logic;
         mem_addr : OUT  std_logic_vector(17 downto 0);
         mem_data : INOUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_32 : std_logic := '0';

   --BiDirs
   signal mem_data : std_logic_vector(15 downto 0);

   --Outputs
   signal hsync : std_logic;
   signal vsync : std_logic;
   signal colour : std_logic_vector(7 downto 0);
   signal mem_nCE : std_logic;
   signal mem_nWE : std_logic;
   signal mem_nOE : std_logic;
   signal mem_nUB : std_logic;
   signal mem_nLB : std_logic;
   signal mem_addr : std_logic_vector(17 downto 0);

   -- Clock period definitions
   constant clk_32_period : time := 10 ns;
 
BEGIN
 
   -- Instantiate the Unit Under Test (UUT)
   uut: TopModule PORT MAP (
          clk_32 => clk_32,
          hsync => hsync,
          vsync => vsync,
          colour => colour,
          mem_nCE => mem_nCE,
          mem_nWE => mem_nWE,
          mem_nOE => mem_nOE,
          mem_nUB => mem_nUB,
          mem_nLB => mem_nLB,
          mem_addr => mem_addr,
          mem_data => mem_data
        );

   -- Clock process definitions
   clk_32_process :process
   begin
      clk_32 <= '0';
      wait for clk_32_period/2;
      clk_32 <= '1';
      wait for clk_32_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin    
      -- hold reset state for 100 ns.
      wait for 100 ns;  

      wait for clk_32_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
