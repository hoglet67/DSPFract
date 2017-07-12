library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity early_overflow is
    Port ( clk           : in  STD_LOGIC;
           real_in       : in  STD_LOGIC_VECTOR (35 downto 0);
           imaginary_in  : in  STD_LOGIC_VECTOR (35 downto 0);
           real_out      : out STD_LOGIC_VECTOR (34 downto 0);
           imaginary_out : out STD_LOGIC_VECTOR (34 downto 0);
			  early_overflow: out STD_LOGIC);
end early_overflow;

architecture Behavioral of early_overflow is

begin

   process(clk, real_in, imaginary_in)
   begin
	   if rising_edge(clk) then
			early_overflow <= (real_in(35) xor real_in(34)) or (imaginary_in(35) xor imaginary_in(34));
			real_out       <= real_in(34 downto 0);
			imaginary_out  <= imaginary_in(34 downto 0);
		end if;
   end process;

end Behavioral;

