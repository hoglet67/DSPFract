library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity addn is
   Generic (width : natural);
	
   Port ( clk : in  STD_LOGIC;
          x : in  STD_LOGIC_VECTOR (width-1 downto 0);
          y : in  STD_LOGIC_VECTOR (width-1 downto 0);
          result : out  STD_LOGIC_VECTOR (width downto 0));
end addn;

architecture Behavioral of addn is
  signal r_x : STD_LOGIC_VECTOR (width downto 0);
  signal r_y : STD_LOGIC_VECTOR (width downto 0);
begin

add_proc : process(clk)
   begin
	   if rising_edge(clk) then
			result <= r_x + r_y;
			r_x <= x(width-1) & x;
			r_y <= y(width-1) & y;
		end if; 
	end process;

end Behavioral;

