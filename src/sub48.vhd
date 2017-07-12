library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sub48 is
    Port ( clk : in  STD_LOGIC;
           x : in  STD_LOGIC_VECTOR (47 downto 0);
           y : in  STD_LOGIC_VECTOR (47 downto 0);
           result : out  STD_LOGIC_VECTOR (47 downto 0));
end sub48;

architecture Behavioral of sub48 is
  signal r_x : STD_LOGIC_VECTOR (47 downto 0);
  signal r_y : STD_LOGIC_VECTOR (47 downto 0);
begin

sub_proc : process(x,y,clk, r_x, r_y)
   begin
      if rising_edge(clk) then
         
         result <= r_x - r_y;
         r_x <= x;
         r_y <= y;
      end if; 
   end process;

end Behavioral;

