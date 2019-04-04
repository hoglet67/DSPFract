library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sqr35 is
    Port ( clk : in  STD_LOGIC;
           x : in  STD_LOGIC_VECTOR (34 downto 0);
           result : out  STD_LOGIC_VECTOR (37 downto 0));
end sqr35;

architecture Behavioral of sqr35 is

begin

multiplier : entity work.ip_mult35
  PORT MAP (
    clk => clk,
    a => x,
    b => x,
    p => result
  );

end Behavioral;
