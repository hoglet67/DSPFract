
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity memory_video is
    Port ( clk : in  STD_LOGIC;
           base_addr_word : in STD_LOGIC_VECTOR (17 downto 0);
           
           -- Interface for writes
           write_ready : in  STD_LOGIC;
           write_addr  : in  STD_LOGIC_VECTOR (18 downto 0);
           write_byte  : in  STD_LOGIC_VECTOR (7 downto 0);
           write_taken : out  STD_LOGIC;
           
           -- Video interface
           hsync       : out  STD_LOGIC;
           vsync       : out  STD_LOGIC;
           colour      : out  STD_LOGIC_VECTOR (7 downto 0);
           
           -- Memory Interface
           mem_nCE      : out   STD_LOGIC;
           mem_nWE      : out   STD_LOGIC;
           mem_nOE      : out   STD_LOGIC;
           mem_addr     : out   STD_LOGIC_VECTOR (17 downto 0);
           mem_data     : inout STD_LOGIC_VECTOR (15 downto 0));
end memory_video;

architecture Behavioral of memory_video is
   -- State vectors and memory controll signals                  
   constant state_0    : STD_LOGIC_VECTOR(2 downto 0) := "000";
   constant state_25   : STD_LOGIC_VECTOR(2 downto 0) := "001";
   constant state_50   : STD_LOGIC_VECTOR(2 downto 0) := "010";
   constant state_75   : STD_LOGIC_VECTOR(2 downto 0) := "011";
   constant state_100  : STD_LOGIC_VECTOR(2 downto 0) := "100";
   constant state_125  : STD_LOGIC_VECTOR(2 downto 0) := "101";
   constant state_150  : STD_LOGIC_VECTOR(2 downto 0) := "110";
   constant state_175  : STD_LOGIC_VECTOR(2 downto 0) := "111";

   type regv is record
      colour      : std_logic_vector( 7 downto 0);
      hCounter    : std_logic_vector(10 downto 0); -- 0 -> hMax-1
      vCounter    : std_logic_vector( 9 downto 0); -- 0 -> vMax-1
      read_addr   : std_logic_vector(17 downto 0);
      increment   : std_logic;
      display     : std_logic;
      hSync       : std_logic;
      vSync       : std_logic;
   end record;

   signal nv : regv;
   signal rv : regv := ((others => '1'),(others => '0'),(others => '0'),(others => '0'),'0','0','0','0');

   type regm is record
      state       : std_logic_vector( 2 downto 0);
      address     : std_logic_vector(17 downto 0);
      newValue    : std_logic_vector(15 downto 0);
      latch       : std_logic_vector(15 downto 0);
      hold_byte   : std_logic_vector( 7 downto 0);
      hold_addr   : std_logic_vector(18 downto 0);
      write_taken : std_logic;
      nOE         : std_logic;
      nWE         : std_logic;
   end record;

   signal nm : regm;
   signal rm : regm := (state_0,(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),
                         '0', '0', '0');

   -- VGA timings for 800x600 @ 60Hz
   constant hVisible    : natural := 800;
   constant hFrameWidth : natural := 828;
   constant hStartSync  : natural := 840;
   constant hEndSync    : natural := 928;
   constant hMax        : natural := 1056;

   constant vVisible   : natural := 600;
   constant vStartSync : natural := 601;
   constant vEndSync   : natural := 605;
   constant vMax       : natural := 628;
begin
   -- Mapping through output signals
   mem_nCE     <= '0';
   mem_nOE     <= rm.nOE;
   mem_nWE     <= rm.nWE;
   write_taken <= rm.write_taken;
   mem_addr    <= rm.address; 

   hsync       <= rv.hsync;
   vsync       <= rv.vsync;
   colour      <= rv.colour+1;
  
   
   -- This process controls when data gets presented to the data bus
tristate_proc: process(rm)
   begin
      if rm.state = state_150 or rm.state = state_175 then 
         mem_data    <= rm.newValue;
      else
         mem_data    <= "ZZZZZZZZZZZZZZZZ";
      end if;
   end process;

  -- This process does all the VGA output
vga_proc: process(rv, rm.latch, rm.state,  base_addr_word)
   begin
      nv           <= rv;
      nv.hsync     <= '0';
      nv.vsync     <= '0';
      nv.increment <= '0';
      
      -- Sync pulse generation
      if rv.hCounter >= hStartSync and rv.hCounter < hEndSync  then
         nv.hsync <= '1';   
      end if;
      if rv.vCounter >= vStartSync and rv.vCounter < vEndSync  then
         nv.vsync <= '1';
      end if;

      -- Will the next pass thorugh be in the blanking interval?
      if rv.hcounter < hFrameWidth and rv.vcounter < vVisible then 
         nv.increment  <= '1';
      end if;

      if rm.state(0) = '1' then
         -- Update the counters every other cycle
         if rv.hCounter = hMax-1 then
            nv.hCounter <= (others => '0');
            if rv.vcounter = vMax-1 then 
               nv.vCounter  <= (others => '0');
               nv.read_addr <= base_addr_word + (14 * hFrameWidth + 14)/2;
            else
               nv.vCounter <= rv.vCounter+1;
            end if;
         else
            nv.hCounter <= rv.hCounter + 1; 
         end if;
      else
         -- Update the display RGB values every other cycle
         if rv.display = '1' then
            if rm.state(1) = '0' then 
               nv.colour  <= rm.latch(15 downto 8);
            else
              nv.colour  <= rm.latch(7 downto 0);
            end if;
         else
            nv.colour  <= (others => '0');
         end if;
      end if;

      -- Decide if we display colour this time
      if rm.state(1 downto 0) = "11" then
      
         if rv.hCounter < hVisible and rv.vCounter < vVisible then
            nv.display    <= '1';
         else
            nv.display    <= '0';         
         end if;
         
         if rv.increment = '1' then
            nv.read_addr  <= rv.read_addr+1;
         end if;
      end if;
   end process;

   -- This process updates the SRAM
mem_proc: process(rm, rv.read_addr, write_ready, write_addr, write_byte, mem_data, base_addr_word)
   begin
      nm <= rm;
      nm.write_taken <= '0';  -- Only set in one state
      nm.nOE         <= '0';
      nm.nWE         <= '1';

      case rm.state is 
      when state_0 =>
         nm.state     <= state_25;
         -- Waiting for the read to settle

         -- capture the adderss and value of the new write
         if write_ready = '0' then
           nm.hold_addr   <= write_Addr+(base_addr_word&'0');
           nm.hold_byte   <= write_byte;
           nm.write_taken <= '1';
         end if;
         
      when state_25 =>
         nm.state   <= state_50;
         -- Finish the read 
         nm.latch     <= mem_data; 
         
         -- Setting up the read of the byte to be updated
         nm.address     <= rm.hold_addr(18 downto 1);

      when state_50 =>
         nm.state   <= state_75;
         -- Waiting for the read to settle
         
      when state_75 =>
         -- The second half od the write cycle, and setting up for the data read
         nm.state      <= state_100;

         -- Capturing the value which will be written into the memory location
         if rm.hold_addr(0) = '0' then
            nm.newValue <= mem_data(15 downto 8) & rm.hold_byte;
         else
            nm.newValue <= rm.hold_byte & mem_data(7 downto 0);
         end if;
         
         -- Setting up for the read for video memory
         nm.address    <= rv.read_addr;

      when state_100 =>
         nm.state      <= state_125;
         -- Waiting for the read to settle

      when state_125 =>
         nm.state      <= state_150;
         -- Latching the read
         nm.latch     <= mem_data; 
         
         -- Setting up the write of the byte to be updated
         nm.address  <= rm.hold_addr(18 downto 1);
         nm.noe      <= '1';
         nm.nWE      <= '0';

      when state_150 =>
         nm.state      <= state_175;
         -- and MEM_DATA is set by the 'tristate' process
         nm.noe      <= '1';

      when state_175 =>
         nm.state      <= state_0;

         -- Setting up for the read for video memory
         nm.address    <= rv.read_addr;
         
      when others =>
      end case;
   end process;
   
clk_proc: process (clk)
   begin
      if rising_edge(clk) then
         rm <= nm;
         rv <= nv;
      end if;
   end process;
end Behavioral;