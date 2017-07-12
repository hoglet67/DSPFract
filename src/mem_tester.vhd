
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mem_tester is
    Port ( clk : in  STD_LOGIC;
           address : out  STD_LOGIC_VECTOR (18 downto 0);
           data : out  STD_LOGIC_VECTOR (7 downto 0);
           write_taken : in  STD_LOGIC);
end mem_tester;

architecture Behavioral of mem_tester is
   signal counter: std_logic_vector(18 downto 0) := (others => '0');
   signal value: std_logic_vector(9 downto 0) := (others => '0');
begin
   address <= counter;
   data    <= value(7 downto 0);
   
   process (clk)
   begin
      if rising_edge(clk) then
         if write_taken = '1' and not(counter  = "111" & x"FFFF") then
            counter <= counter+1;
				if value = 827 then 
					value <= (others => '0');
				else
					value <= value+1;
				end if;
         end if;
      end if;
   end process;
end Behavioral;

