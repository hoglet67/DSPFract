library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mem_tester_top is
    Port ( clk_32 : in  STD_LOGIC;
           hsync  : out  STD_LOGIC;
           vsync  : out  STD_LOGIC;
           red    : out  STD_LOGIC_VECTOR (3 downto 0);
           green  : out  STD_LOGIC_VECTOR (3 downto 0);
           blue   : out  STD_LOGIC_VECTOR (3 downto 0);
                      -- Memory Interface
           mem_nBE      : out   STD_LOGIC;
           mem_nCE      : out   STD_LOGIC;
           mem_nWE      : out   STD_LOGIC;
           mem_nOE      : out   STD_LOGIC;
           mem_addr     : out   STD_LOGIC_VECTOR (17 downto 0);
           mem_data     : inout STD_LOGIC_VECTOR (15 downto 0);
           -- User constrols
         btn_up           : in  STD_LOGIC;
         btn_down      : in  STD_LOGIC;
         btn_left      : in  STD_LOGIC;
         btn_right        : in  STD_LOGIC;
         btn_zoomin     : in  STD_LOGIC;
         btn_zoomout     : in  STD_LOGIC);
end mem_tester_top;

architecture Behavioral of mem_tester_top is
component clocking
   port
   (-- Clock in ports
      CLK_32           : in     std_logic;
      -- Clock out ports
      CLK_mem          : out    std_logic; -- Memory / Video clock (40MHz)
      CLK_memn         : out    std_logic; -- Inverted Memory / Video clock (40MHz)
      CLK_core          : out    std_logic -- Clock for other use.
   );
   end component;

   COMPONENT mem_tester
   PORT(
      clk : IN std_logic;
      write_taken : IN std_logic;          
      address : OUT std_logic_vector(18 downto 0);
      data : OUT std_logic_vector(7 downto 0)
      );
   END COMPONENT;

   COMPONENT memory_video
   PORT(
      clk : IN std_logic;
      base_addr_word : in STD_LOGIC_VECTOR (17 downto 0);

      write_ready : IN std_logic;
      write_addr : IN std_logic_vector(18 downto 0);
      write_byte : IN std_logic_vector(7 downto 0);    
      mem_data : INOUT std_logic_vector(15 downto 0);      
      write_taken : OUT std_logic;
      hsync : OUT std_logic;
      vsync : OUT std_logic;
      colour : OUT std_logic_vector(7 downto 0);
      mem_nCE : OUT std_logic;
      mem_nWE : OUT std_logic;
      mem_nOE : OUT std_logic;
      mem_addr : OUT std_logic_vector(17 downto 0)
      );
   END COMPONENT;


   signal write_address: std_logic_vector(18 downto 0);
   signal write_data:    std_logic_vector(7 downto 0);
   signal colour:        std_logic_vector(7 downto 0);
   signal write_taken:   std_logic;
   signal clk_mem:        std_logic;
   signal clk_memn:       std_logic;
   signal clk_core:       std_logic;
   
begin
   mem_nBE <= '0';
   red   <= colour(7 downto 5) & 'Z';
   green <= colour(4 downto 2) & 'Z';
   blue  <= colour(1 downto 0) & "ZZ";

   clocking_inst : clocking port map (
      -- Clock in ports
      CLK_32  => CLK_32,
      -- Clock out ports
      CLK_mem  => CLK_mem,
      CLK_memn => CLK_memn,
      CLK_core  => CLK_core
   );
   
   Inst_mem_tester: mem_tester PORT MAP(
      clk         => clk_mem,
      address     => write_address,
      data        => write_data,
      write_taken => write_taken
   );

   Inst_memory_video: memory_video PORT MAP(
      clk  => clk_mem,
      base_addr_word => (others => '0'),
      write_ready => '1',
      write_addr => write_address,
      write_byte => write_data,
      write_taken => write_taken,
      hsync => hsync,
      vsync => vsync,
      colour => colour,
      mem_nCE => mem_nCE,
      mem_nWE => mem_nWE,
      mem_nOE => mem_nOE,
      mem_addr => mem_addr,
      mem_data => mem_data
   );

end Behavioral;

