library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity scheduler is
    Port ( clk : in  STD_LOGIC;
           base_addr_word : out std_logic_vector(17 downto 0);
           x              : out STD_LOGIC_VECTOR (9 downto 0);
           y              : out STD_LOGIC_VECTOR (9 downto 0);
           --
           newvalue       : out STD_LOGIC_VECTOR (35 downto 0);
           storex         : out STD_LOGIC;
           storey         : out STD_LOGIC;

           accepted       : in  STD_LOGIC;
           vsync          : in  STD_LOGIC;
           btn_up         : in  STD_LOGIC;
           btn_down       : in  STD_LOGIC;
           btn_left       : in  STD_LOGIC;
           btn_right      : in  STD_LOGIC;
           btn_zoom       : in  STD_LOGIC);
end scheduler;

architecture Behavioral of scheduler is
   type fsm_state is ( idle, update_constants_x_start, update_constants_x,
                             update_constants_y_start, update_constants_y,
                             start_redraw, redraw);
   signal mode                : fsm_state := update_constants_x_start;
   signal x_counter           : std_logic_vector(9 downto 0) := (others => '0');
   signal y_counter           : std_logic_vector(9 downto 0) := (others => '0');
   signal vsync_reclock       : std_logic_vector(1 downto 0) := (others => '0');
   signal base_addr_word_sig  : std_logic_vector(17 downto 0) := (others => '0');
   signal base_addr_word_next : std_logic_vector(17 downto 0) := (others => '0');

   -- where we are on the screen
   signal redraw_right          : std_logic_vector(9 downto 0) := "1001110011";
   signal redraw_bottom         : std_logic_vector(9 downto 0) := "1100111011";
   signal current_top           : std_logic_vector(35 downto 0) := x"E00000000";
   signal current_left          : std_logic_vector(35 downto 0) := x"D00000000";
   signal current_scale         : std_logic_vector(27 downto 0) := x"2000000";
   signal zoom_x_offset         : std_logic_vector(35 downto 0) := x"33C000000";
   signal zoom_y_offset         : std_logic_vector(35 downto 0) := x"272000000";
   signal current_scale_add     : std_logic_vector(32 downto 0) := (others => '0');
   signal current_scale_add_reg : std_logic_vector(32 downto 0) := (others => '0');
   signal current_top_zoom_out  : std_logic_vector(35 downto 0) := (others => '0');
   signal current_left_zoom_out : std_logic_vector(35 downto 0) := (others => '0');
   signal current_top_zoom_in   : std_logic_vector(35 downto 0) := (others => '0');
   signal current_left_zoom_in  : std_logic_vector(35 downto 0) := (others => '0');

   signal redraw_top         : std_logic_vector(9 downto 0) := (others => '0');
   signal redraw_left        : std_logic_vector(9 downto 0) := (others => '0');

   signal buttons : STD_LOGIC_VECTOR (4 downto 0);
   signal buttons_old : STD_LOGIC_VECTOR (4 downto 0);
   -- Used for setting the constants
   signal storex_sig         : std_logic := '0';
   signal storey_sig         : std_logic := '0';
   signal newvalue_sig       : STD_LOGIC_VECTOR (35 downto 0);
begin
   x               <= x_counter;
   y               <= y_counter;
   storex          <= storex_sig;
   storey          <= storey_sig;
   newvalue        <= newvalue_sig;
   base_addr_word  <= base_addr_word_sig;
   buttons         <= btn_down & btn_up & btn_left & btn_right & btn_zoom;

   process (clk)
   begin
      if rising_edge(clk) then
         base_addr_word_sig <= base_addr_word_next;
         case mode is
            when update_constants_x_start =>
               mode         <= update_constants_x;
               x_counter    <= (others => '0');
               newvalue_sig <= current_left;
               storex_sig   <= '1';

            when update_constants_x =>
               if accepted = '1' then
                  if x_counter = 827 then
                     mode         <= update_constants_y_start;
                  end if;
                  storex_sig   <= '1';
                  x_counter    <= x_counter+1;
                  newvalue_sig <= newvalue_sig + current_scale;
               end if;

            when update_constants_y_start =>
               mode         <= update_constants_y;
               storex_sig   <= '0';
               storey_sig   <= '1';
               newvalue_sig <= current_top;
               y_counter    <= (others => '0');

            when update_constants_y =>
               if accepted = '1' then
                  newvalue_sig <= newvalue_sig + current_scale;
                  storey_sig <= '1';
                  if y_counter = 627 then
                     mode <= start_redraw;
                  end if;
                  y_counter  <= y_counter+1;
               end if;

            when start_redraw =>
               mode         <= redraw;
               storey_sig   <= '0';
               x_counter    <= redraw_left;
               y_counter    <= redraw_top;

            when redraw =>
               if accepted = '1' then
                  if x_counter = redraw_right then
                     x_counter <= redraw_left;
                     if y_counter = redraw_bottom then
                        mode      <= idle;
                     else
                        y_counter <= y_counter + 1;
                     end if;
                  else
                     x_counter <= x_counter+1;
                  end if;
               end if;

            when others =>      -- idle
               if vsync_reclock = "01" then

                  buttons_old   <= buttons;

                  redraw_top    <= (others => '0');
                  redraw_left   <= (others => '0');
                  redraw_right  <= "0000000000"+827;
                  redraw_bottom <= "0000000000"+627;


                  case buttons is
                  when "10000" =>
                       base_addr_word_next <= base_addr_word_sig + (14 * 828)/2;
                       current_top         <= current_top + current_scale_add_reg;
                       redraw_top <= "0000000000"+614;
                  when "01000" =>
                       base_addr_word_next <= base_addr_word_sig - (14 * 828)/2;
                       current_top         <= current_top - current_scale_add_reg;
                        redraw_bottom <= "0000000000"+13;
                  when "00100" =>
                        base_addr_word_next <= base_addr_word_sig - 14/2;
                        current_left        <= current_left - current_scale_add_reg;
                        redraw_right <= "0000000000"+13;
                  when "00010" =>
                        base_addr_word_next <= base_addr_word_sig + 14/2;
                        current_left        <= current_left + current_scale_add_reg;
                        redraw_left <= "0000000000"+814;

                  when "10001" =>
                        if  current_scale(27) = '0' and buttons_old(4) = '0' then
                           current_top   <= current_top_zoom_out;
                           current_left  <= current_left_zoom_out;
                           current_scale <= current_scale(26 downto 0) & '0';
                           zoom_x_offset <= zoom_x_offset(34 downto 0) & '0';
                           zoom_y_offset <= zoom_y_offset(34 downto 0) & '0';
                        end if;

                  when "01001" =>
                        if current_scale(0) = '0' and buttons_old(3) = '0' then
                           current_top   <= current_top_zoom_in;
                           current_left  <= current_left_zoom_in;
                           current_scale <= '0' & current_scale(27 downto 1);
                           zoom_x_offset <= '0' & zoom_x_offset(35 downto 1);
                           zoom_y_offset <= '0' & zoom_y_offset(35 downto 1);
                        end if;
                  when others =>
                  end case;

                  if (btn_down or btn_up or btn_left or btn_right) = '1' then
                     mode                <= update_constants_x_start;
                  end if;
               end if;
         end case;

         current_scale_add_reg <= current_scale_add;
         current_scale_add <= ("0" & current_scale & "0000") - (current_scale & "0");

         current_top_zoom_out  <= current_top  - zoom_y_offset(34 downto 0);
         current_left_zoom_out <= current_left - zoom_x_offset(34 downto 0);
         current_top_zoom_in   <= current_top  + zoom_y_offset(35 downto 1);
         current_left_zoom_in  <= current_left + zoom_x_offset(35 downto 1);
         vsync_reclock <= vsync_reclock(0) & vsync;
      end if;
   end process;
end Behavioral;
