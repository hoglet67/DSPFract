library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity loop_manager is
   port (clk            : in  STD_LOGIC;
		-- New point to be iterated
           x_new          : in  STD_LOGIC_VECTOR (9 downto 0);
           y_new          : in  STD_LOGIC_VECTOR (9 downto 0);
           constant_new   : in  STD_LOGIC_VECTOR (35 downto 0);
           storex_new     : in  STD_LOGIC;
           storey_new     : in  STD_LOGIC;
           new_point      : in  STD_LOGIC;
			  accepted_new   : out STD_LOGIC;

		-- Results
           x_result           : out STD_LOGIC_VECTOR (9 downto 0);
           y_result           : out STD_LOGIC_VECTOR (9 downto 0);
           iterations_result  : out  STD_LOGIC_VECTOR (7 downto 0);
			  result_valid       : out STD_LOGIC;
			  output_fifo_full   : in STD_LOGIC;
	 
		-- Signals to the first stage
           iterations_in  : in  STD_LOGIC_VECTOR (7 downto 0);
           overflow_in    : in  STD_LOGIC;
           real_in        : in  STD_LOGIC_VECTOR (35 downto 0);
           imaginary_in   : in  STD_LOGIC_VECTOR (35 downto 0);
           x_in           : in  STD_LOGIC_VECTOR (9 downto 0);
           y_in           : in  STD_LOGIC_VECTOR (9 downto 0);
           active_in      : in  STD_LOGIC;
			  
		-- Signals from the last stage
           iterations_out : out STD_LOGIC_VECTOR (7 downto 0);
           overflow_out   : out STD_LOGIC;
           real_out       : out STD_LOGIC_VECTOR (35 downto 0);
           imaginary_out  : out STD_LOGIC_VECTOR (35 downto 0);
           x_out          : out STD_LOGIC_VECTOR (9 downto 0);
           y_out          : out STD_LOGIC_VECTOR (9 downto 0);
           constant_out   : out STD_LOGIC_VECTOR (35 downto 0);
           storex_out     : out STD_LOGIC;
           storey_out     : out STD_LOGIC;
			  active_out     : out STD_LOGIC);
end loop_manager;

architecture Behavioral of loop_manager is
  signal unload_result    : std_logic;
  signal accepted_new_sig : std_logic;
begin
  
  -- When there is nothing of use on the inpute
  unload_result    <= overflow_in and not output_fifo_full;
  accepted_new_sig <= NOT active_in or unload_result;
  accepted_new     <= accepted_new_sig;
  
clk_proc: process(clk)
   begin
   	if rising_edge(clk) then
			-- Present the result on the output if completed and we have space in the output FIFO.
			if unload_result = '1' then
           x_result           <= x_in;
           y_result           <= y_in;
           iterations_result  <= iterations_in;
			  result_valid       <= '1';
			else
			   result_valid       <= '0';
			end if;
			
			if unload_result = '1' then
			   if accepted_new_sig = '1' then
					-- unloaded and slot filled
					active_out         <= (not storex_new) and (not storey_new);
				else
					-- unloaded and slot idle
					active_out         <= '0';
				end if;
			else 
				active_out <= active_in or (accepted_new_sig and (not storex_new) and (not storey_new));
			end if;

	   	if accepted_new_sig = '0' then
				-- looping the old result around again
	         iterations_out <= iterations_in;			 
            overflow_out   <= overflow_in;
            real_out       <= real_in;
            imaginary_out  <= imaginary_in;
            x_out          <= x_in;
            y_out          <= y_in;
            constant_out   <= (others => '0');
            storex_out     <= '0';
			   storey_out     <= '0';
		   else
				-- pushing a new signal into the pipe
	         iterations_out <= (others => '0');			 
            overflow_out   <= ('0');
            real_out       <= (others => '0');
            imaginary_out  <= (others => '0');
            x_out          <= x_new;
            y_out          <= y_new;
            storex_out     <= storex_new;
			   storey_out     <= storey_new;
				constant_out   <= constant_new;
		   end if;
	   end if;
   end process;
	
end Behavioral;

