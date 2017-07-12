library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mult35 is
    Port ( clk : in  STD_LOGIC;
           x : in  STD_LOGIC_VECTOR (34 downto 0);
           y : in  STD_LOGIC_VECTOR (34 downto 0);
           result : out  STD_LOGIC_VECTOR (37 downto 0));
end mult35;

architecture Behavioral of mult35 is
  COMPONENT ip_mult35
    PORT (
      clk : IN  STD_LOGIC;
      a   : IN  STD_LOGIC_VECTOR(34 DOWNTO 0);
      b   : IN  STD_LOGIC_VECTOR(34 DOWNTO 0);
      p   : OUT STD_LOGIC_VECTOR(37 DOWNTO 0)
    );
  END COMPONENT;
begin

multiplier : ip_mult35
  PORT MAP (
    clk => clk,
    a   => x,
    b   => y,
    p   => result
  );

end Behavioral;

