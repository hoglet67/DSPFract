LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tm_topmodule IS
END tm_topmodule;
 
ARCHITECTURE behavior OF tm_topmodule IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TopModule
    PORT(
         clk_32 : IN  std_logic;
         hsync : OUT  std_logic;
         vsync : OUT  std_logic;
         red   : OUT  std_logic_vector(3 downto 0);
         green : OUT  std_logic_vector(3 downto 0);
         blue  : OUT  std_logic_vector(3 downto 0);
         mem_nCE : OUT  std_logic;
         mem_nWE : OUT  std_logic;
         mem_nOE : OUT  std_logic;
         mem_nBE : OUT  std_logic;
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
   signal red   : std_logic_vector(3 downto 0);
   signal blue  : std_logic_vector(3 downto 0);
   signal green : std_logic_vector(3 downto 0);
   signal mem_nCE : std_logic;
   signal mem_nWE : std_logic;
   signal mem_nOE : std_logic;
   signal mem_nBE : std_logic;
   signal mem_addr : std_logic_vector(17 downto 0);

   -- Clock period definitions
   constant clk_32_period : time := 31.25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TopModule PORT MAP (
          clk_32 => clk_32,
          hsync => hsync,
          vsync => vsync,
          red   => red,
          blue  => blue,
          green => green,
          mem_nCE => mem_nCE,
          mem_nWE => mem_nWE,
          mem_nOE => mem_nOE,
          mem_nBE => mem_nBE,
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
