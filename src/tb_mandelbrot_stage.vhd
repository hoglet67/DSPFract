LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_mandelbrot_stage IS
END tb_mandelbrot_stage;
 
ARCHITECTURE behavior OF tb_mandelbrot_stage IS 
 
    COMPONENT mandelbrot_stage
    PORT(
         clk : IN  std_logic;
         iterations_in : IN  std_logic_vector(7 downto 0);
         overflow_in : IN  std_logic;
         real_in : IN  std_logic_vector(35 downto 0);
         imaginary_in : IN  std_logic_vector(35 downto 0);
         x_in : IN  std_logic_vector(9 downto 0);
         y_in : IN  std_logic_vector(9 downto 0);
         constant_in : IN  std_logic_vector(35 downto 0);
         storex_in : IN  std_logic;
         storey_in : IN  std_logic;
         active_in : in  std_logic;
         iterations_out : OUT  std_logic_vector(7 downto 0);
         overflow_out : OUT  std_logic;
         real_out : OUT  std_logic_vector(35 downto 0);
         imaginary_out : OUT  std_logic_vector(35 downto 0);
         x_out : OUT  std_logic_vector(9 downto 0);
         y_out : OUT  std_logic_vector(9 downto 0);
         constant_out : OUT  std_logic_vector(35 downto 0);
         storex_out : OUT  std_logic;
         storey_out : OUT  std_logic;
         active_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk           : std_logic := '0';
   signal iterations_in : std_logic_vector(7 downto 0)  := (others => '0');
   signal overflow_in   : std_logic                     := '0';
   signal real_in       : std_logic_vector(35 downto 0) := (others => '0');
   signal imaginary_in  : std_logic_vector(35 downto 0) := (others => '0');
   signal x_in          : std_logic_vector( 9 downto 0) := (others => '0');
   signal y_in          : std_logic_vector( 9 downto 0) := (others => '0');
   signal constant_in   : std_logic_vector(35 downto 0) := (others => '0');
   signal storex_in     : std_logic                     := '0';
   signal storey_in     : std_logic                     := '0';
   signal active_in     : std_logic                     := '0';
   --Outputs
   signal iterations_out : std_logic_vector(7 downto 0);
   signal overflow_out   : std_logic;
   signal real_out       : std_logic_vector(35 downto 0);
   signal imaginary_out  : std_logic_vector(35 downto 0);
   signal x_out          : std_logic_vector(9 downto 0);
   signal y_out          : std_logic_vector(9 downto 0);
   signal constant_out   : std_logic_vector(35 downto 0);
   signal storex_out     : std_logic;
   signal storey_out     : std_logic;
   signal active_out     : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
   
   -- Instantiate the Unit Under Test (UUT)
   uut: mandelbrot_stage PORT MAP (
          clk => clk,
          iterations_in => iterations_in,
          overflow_in => overflow_in,
          real_in => real_in,
          imaginary_in => imaginary_in,
          x_in => x_in,
          y_in => y_in,
          constant_in => constant_in,
          storex_in => storex_in,
          storey_in => storey_in,
          active_in => active_in,
          iterations_out => iterations_out,
          overflow_out => overflow_out,
          real_out => real_out,
          imaginary_out => imaginary_out,
          x_out => x_out,
          y_out => y_out,
          constant_out => constant_out,
          storex_out => storex_out,
          storey_out => storey_out,
          active_out => active_out
        );

   -- Clock process definitions
   clk_process :process
   begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin    
      -- hold reset state for 100 ns.
      wait for 200 ns;  
      
      -- Test vecor 1
      iterations_in <= x"44";
      overflow_in   <= '1';
      real_in       <= x"000000000";
      imaginary_in  <= x"000000000";
      x_in          <= "0000000101";
      y_in          <= "0000000101";
      constant_in   <= x"FFFFFFFFF";
      storex_in     <= '1';
      storey_in     <= '1';
      active_in     <= '1';
      wait for 10 ns;   
      iterations_in <= (others => '0');
      overflow_in   <= '0';
      real_in       <= (others => '0');
      imaginary_in  <= (others => '0');
      x_in          <= (others => '0');
      y_in          <= (others => '0');
      constant_in   <= (others => '0');
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '0';
      wait for 150 ns;  

      -- Test vecor 2
      iterations_in <= x"44";
      overflow_in   <= '0';
      real_in       <= x"000000000";
      imaginary_in  <= x"000000000";
      x_in          <= "0000000001";
      y_in          <= "0000000001";
      constant_in   <= x"000000000";
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '1';
      wait for 10 ns;   
      iterations_in <= (others => '0');
      overflow_in   <= '0';
      real_in       <= (others => '0');
      imaginary_in  <= (others => '0');
      x_in          <= (others => '0');
      y_in          <= (others => '0');
      constant_in   <= (others => '0');
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '0';
      wait for 150 ns;  

      -- Test vecor 3
      iterations_in <= x"44";
      overflow_in   <= '0';
      real_in       <= x"555555555";
      imaginary_in  <= x"555555555";
      x_in          <= "0000000000";
      y_in          <= "0000000000";
      constant_in   <= x"000000000";
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '1';
      wait for 10 ns;   
      iterations_in <= (others => '0');
      overflow_in   <= '0';
      real_in       <= (others => '0');
      imaginary_in  <= (others => '0');
      x_in          <= (others => '0');
      y_in          <= (others => '0');
      constant_in   <= (others => '0');
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '0';
      wait for 150 ns;  

      -- Test vecor 4
      iterations_in <= x"44";
      overflow_in   <= '0';
      real_in       <= x"3FFFFFFFF";
      imaginary_in  <= x"3FFFFFFFF";
      x_in          <= "0000000000";
      y_in          <= "0000000000";
      constant_in   <= x"000000000";
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '1';
      wait for 10 ns;   
      iterations_in <= (others => '0');
      overflow_in   <= '0';
      real_in       <= (others => '0');
      imaginary_in  <= (others => '0');
      x_in          <= (others => '0');
      y_in          <= (others => '0');
      constant_in   <= (others => '0');
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '0';
      wait for 150 ns;  

      -- Test vecor 5
      iterations_in <= x"44";
      overflow_in   <= '0';
      real_in       <= x"100000000";
      imaginary_in  <= x"080000000";
      x_in          <= "0000000000";
      y_in          <= "0000000000";
      constant_in   <= x"000000000";
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '1';
      wait for 10 ns;   
      iterations_in <= (others => '0');
      overflow_in   <= '0';
      real_in       <= (others => '0');
      imaginary_in  <= (others => '0');
      x_in          <= (others => '0');
      y_in          <= (others => '0');
      constant_in   <= (others => '0');
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '0';
      wait for 150 ns;  
      
      -- Test vecor 6
      iterations_in <= x"44";
      overflow_in   <= '0';
      real_in       <= x"100000000";
      imaginary_in  <= x"080000000";
      x_in          <= "0000000001";
      y_in          <= "0000000001";
      constant_in   <= x"000000000";
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '1';
      wait for 10 ns;   
      iterations_in <= (others => '0');
      overflow_in   <= '0';
      real_in       <= (others => '0');
      imaginary_in  <= (others => '0');
      x_in          <= (others => '0');
      y_in          <= (others => '0');
      constant_in   <= (others => '0');
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '0';
      wait for 150 ns;  

      -- Test vecor 7
      iterations_in <= x"FF";
      overflow_in   <= '0';
      real_in       <= x"180000000";
      imaginary_in  <= x"180000000";
      x_in          <= "0000000000";
      y_in          <= "0000000000";
      constant_in   <= x"000000000";
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '1';
      wait for 10 ns;   
      iterations_in <= (others => '0');
      overflow_in   <= '0';
      real_in       <= (others => '0');
      imaginary_in  <= (others => '0');
      x_in          <= (others => '0');
      y_in          <= (others => '0');
      constant_in   <= (others => '0');
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '0';
      wait for 150 ns;  

      -- Test vecor 8
      iterations_in <= x"FF";
      overflow_in   <= '0';
      real_in       <= x"980000000";
      imaginary_in  <= x"980000000";
      x_in          <= "0000000000";
      y_in          <= "0000000000";
      constant_in   <= x"000000000";
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '1';
      wait for 10 ns;   
      iterations_in <= (others => '0');
      overflow_in   <= '0';
      real_in       <= (others => '0');
      imaginary_in  <= (others => '0');
      x_in          <= (others => '0');
      y_in          <= (others => '0');
      constant_in   <= (others => '0');
      storex_in     <= '0';
      storey_in     <= '0';
      active_in     <= '0';
      wait for 150 ns;  

      wait;
   end process;

END;
