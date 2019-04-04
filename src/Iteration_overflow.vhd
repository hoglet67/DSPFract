library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.dsp_fractal_defs.all;

entity Iteration_overflow is
    Port ( clk : in  STD_LOGIC;
           max_iters_in : in  iterations_type;
           Iterations_in : in  iterations_type;
           Overflow_in : in  STD_LOGIC;
           Overflow_this : in  STD_LOGIC;
           Iterations_out : out  iterations_type;
           Overflow_out : out  STD_LOGIC);
end Iteration_overflow;

architecture Behavioral of Iteration_overflow is
  signal already_overflowed : std_logic := '0';
  signal max_iters_reached : std_logic := '0';
  signal iterations_last : iterations_type;
begin

update_proc: process (clk, Iterations_in,overflow_in, overflow_this)
  begin
      if rising_edge(clk) then
         if max_iters_reached = '1' then
            iterations_out <= (others => '1');
            overflow_out   <= '1';
         elsif already_overflowed = '1' or overflow_this = '1' then
            overflow_out   <= '1';
            iterations_out <= iterations_last;
         else
            overflow_out   <= '0';
            iterations_out <= iterations_last+1;
         end if;

         if overflow_in = '1' then
            already_overflowed <= '1';
         else
            already_overflowed <= '0';
         end if;

         if iterations_in = max_iters_in then
            max_iters_reached <= '1';
         else
            max_iters_reached <= '0';
         end if;

         iterations_last <= iterations_in;
      end if;
  end process;

end Behavioral;
