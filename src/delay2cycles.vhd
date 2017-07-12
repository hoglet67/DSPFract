library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity delay2cycles is
    Port ( clk : in  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (38 downto 0);
           dout : out  STD_LOGIC_VECTOR (38 downto 0));
end delay2cycles;

architecture Behavioral of delay2cycles is
  signal d1 : STD_LOGIC_VECTOR (38 downto 0) := (others => '0');
begin
process (clk,din)
begin
   if rising_edge(clk) then
		dout <= d1;
	   d1 <= din;
	end if;
end process;

end Behavioral;

