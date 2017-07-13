library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopModule is
    Port (
      clk_32 : in  STD_LOGIC;

      -- video
      hsync : OUT std_logic;
      vsync : OUT std_logic;
      red    : out  STD_LOGIC_VECTOR (3 downto 0);
      green  : out  STD_LOGIC_VECTOR (3 downto 0);
      blue   : out  STD_LOGIC_VECTOR (3 downto 0);

      -- Memory
      mem_nCE : OUT std_logic;
      mem_nWE : OUT std_logic;
      mem_nOE : OUT std_logic;
      mem_addr : OUT std_logic_vector(18 downto 0);
      mem_data : INOUT std_logic_vector(7 downto 0);

      -- User constrols
      btn_up           : in  STD_LOGIC;
      btn_down      : in  STD_LOGIC;
      btn_left      : in  STD_LOGIC;
      btn_right     : in  STD_LOGIC;
      btn_zoom      : in  STD_LOGIC;
      js1_up        : in  STD_LOGIC;
      js1_down      : in  STD_LOGIC;
      js1_left      : in  STD_LOGIC;
      js1_right     : in  STD_LOGIC;
      js1_zoom      : in  STD_LOGIC;
      ARD_RESET     : out STD_LOGIC;
      SW1           : in  STD_LOGIC

      );
end TopModule;

architecture Behavioral of TopModule is
   COMPONENT scheduler
   PORT(
      clk : IN std_logic;
      base_addr_word : out std_logic_vector(17 downto 0);
      accepted       : IN std_logic;
      x              : OUT std_logic_vector(9 downto 0);
      y              : OUT std_logic_vector(9 downto 0);
      vsync          : IN std_logic;
      btn_up         : in  STD_LOGIC;
      btn_down       : in  STD_LOGIC;
      btn_left       : in  STD_LOGIC;
      btn_right      : in  STD_LOGIC;
      btn_zoom       : in  STD_LOGIC;
      
      newvalue       : OUT std_logic_vector(35 downto 0);
      storex         : OUT std_logic;
      storey         : OUT std_logic
);

   END COMPONENT;

   COMPONENT loop_manager
   PORT(
      clk           : IN std_logic;

      x_new         : IN  std_logic_vector(9 downto 0);
      y_new         : IN  std_logic_vector(9 downto 0);
      constant_new  : IN  std_logic_vector(35 downto 0);
      storex_new    : IN  std_logic;
      storey_new    : IN  std_logic;
      new_point     : IN  std_logic;
      accepted_new  : OUT std_logic;

      output_fifo_full  : IN  std_logic;
      x_result          : OUT std_logic_vector(9 downto 0);
      y_result          : OUT std_logic_vector(9 downto 0);
      iterations_result : OUT std_logic_vector(7 downto 0);
      result_valid      : OUT std_logic;

      iterations_in     : IN std_logic_vector(7 downto 0);
      overflow_in       : IN std_logic;
      real_in           : IN std_logic_vector(35 downto 0);
      imaginary_in      : IN std_logic_vector(35 downto 0);
      x_in              : IN std_logic_vector(9 downto 0);
      y_in              : IN std_logic_vector(9 downto 0);
      active_in         : IN std_logic;

      iterations_out : OUT std_logic_vector(7 downto 0);
      overflow_out : OUT std_logic;
      real_out : OUT std_logic_vector(35 downto 0);
      imaginary_out : OUT std_logic_vector(35 downto 0);
      x_out : OUT std_logic_vector(9 downto 0);
      y_out : OUT std_logic_vector(9 downto 0);
      constant_out : OUT std_logic_vector(35 downto 0);
      storex_out : OUT std_logic;
      storey_out : OUT std_logic;
      active_out : OUT std_logic
      );
   END COMPONENT;

   COMPONENT mandelbrot_stage
   PORT(
      clk : IN std_logic;
      iterations_in : IN std_logic_vector(7 downto 0);
      overflow_in : IN std_logic;
      real_in : IN std_logic_vector(35 downto 0);
      imaginary_in : IN std_logic_vector(35 downto 0);
      x_in : IN std_logic_vector(9 downto 0);
      y_in : IN std_logic_vector(9 downto 0);
      constant_in : IN std_logic_vector(35 downto 0);
      storex_in : IN std_logic;
      storey_in : IN std_logic;
      active_in : IN std_logic;
      iterations_out : OUT std_logic_vector(7 downto 0);
      overflow_out : OUT std_logic;
      real_out : OUT std_logic_vector(35 downto 0);
      imaginary_out : OUT std_logic_vector(35 downto 0);
      x_out : OUT std_logic_vector(9 downto 0);
      y_out : OUT std_logic_vector(9 downto 0);
      constant_out : OUT std_logic_vector(35 downto 0);
      storex_out : OUT std_logic;
      storey_out : OUT std_logic;
      active_out : OUT std_logic
      );
   END COMPONENT;

   COMPONENT memory_video
   PORT(
      clk : IN std_logic;
      base_addr_word : in std_logic_vector(17 downto 0);
      write_ready : IN std_logic;
      write_addr : IN std_logic_vector(18 downto 0);
      write_byte : IN std_logic_vector(7 downto 0);
      write_taken : OUT std_logic;
      hsync : OUT std_logic;
      vsync : OUT std_logic;
      colour : OUT std_logic_vector(7 downto 0);
      mem_nCE : OUT std_logic;
      mem_nWE : OUT std_logic;
      mem_nOE : OUT std_logic;
      mem_addr : OUT std_logic_vector(18 downto 0);
      mem_data : INOUT std_logic_vector(7 downto 0)
   );
   END COMPONENT;

   COMPONENT core_mem_interface
   PORT(
      clk_core : IN std_logic;
      x_in : IN std_logic_vector(9 downto 0);
      y_in : IN std_logic_vector(9 downto 0);
      data_in : IN std_logic_vector(7 downto 0);
      clk_mem : IN std_logic;
      write_data : IN std_logic;
      fifo_full : out std_logic;
      read_data : IN std_logic;
      address_out : OUT std_logic_vector(18 downto 0);
      data_out : OUT std_logic_vector(7 downto 0);
      fifo_empty : OUT std_logic
      );
   END COMPONENT;


   component clocking
   port (-- Clock in ports
      CLK_32           : in     std_logic;
      -- Clock out ports
      CLK_mem          : out    std_logic;
      CLK_memn         : out    std_logic;
      CLK_core          : out    std_logic
   );
   end component;

   signal   current_colormap : unsigned (3 downto 0);
   signal   ctrl_left_old  : std_logic;
   signal   ctrl_right_old : std_logic;
   signal   vsync_sig_old  : std_logic;

   signal   real_1      : std_logic_vector(35 downto 0);
   signal   imaginary_1 : std_logic_vector(35 downto 0);
   signal   x_1         : std_logic_vector(9 downto 0);
   signal   y_1         : std_logic_vector(9 downto 0);
   signal   iterations_1: std_logic_vector(7 downto 0);
   signal   constant_1  : std_logic_vector(35 downto 0);
   signal   overflow_1  : std_logic;
   signal   storex_1    : std_logic;
   signal   storey_1    : std_logic;
   signal   active_1    : std_logic;

   signal   real_2      : std_logic_vector(35 downto 0);
   signal   imaginary_2 : std_logic_vector(35 downto 0);
   signal   x_2         : std_logic_vector(9 downto 0);
   signal   y_2         : std_logic_vector(9 downto 0);
   signal   iterations_2: std_logic_vector(7 downto 0);
   signal   overflow_2  : std_logic;
   signal   active_2    : std_logic;

   signal   clk_core        : std_logic;
   signal   clk_mem         : std_logic;
   signal   x_new           : std_logic_vector(9 downto 0) := (others => '0');
   signal   y_new           : std_logic_vector(9 downto 0) := (others => '0');
   signal   constant_new    : STD_LOGIC_VECTOR (35 downto 0) := (others => '0');
   signal   storex_new      : STD_LOGIC := '0';
   signal   storey_new      : STD_LOGIC := '0';
   signal   new_point       : STD_LOGIC := '0';
   signal   accepted        : STD_LOGIC := '0';

   signal   x_result          : std_logic_vector(9 downto 0);
   signal   y_result          : std_logic_vector(9 downto 0);
   signal   iterations_result : std_logic_vector(7 downto 0);

   signal   write_byte       : std_logic_vector(7 downto 0);
   signal   write_address    : std_logic_vector(18 downto 0);
   signal   write_taken      : std_logic;
   signal   write_ready      : std_logic;
   signal   output_fifo_full : std_logic;
   signal   base_addr_word   : std_logic_vector(17 downto 0);

   signal result_valid  : std_logic;
   signal colour:        std_logic_vector(7 downto 0);

   signal vsync_sig : std_logic;


   signal rgb, rgb_reg : std_logic_vector (11 downto 0);

   signal rgb_rainbow, rgb_caramel, rgb_anet, rgb_roygold, rgb_polar : std_logic_vector (11 downto 0);
   signal rgb_wild, rgb_tropic, rgb_stargate, rgb_rosewht : std_logic_vector (11 downto 0);
   signal rgb_rose1, rgb_flowers3, rgb_candy, rgb_candy1 : std_logic_vector (11 downto 0);

   signal ctrl_up         : std_logic;
   signal ctrl_down       : std_logic;
   signal ctrl_left       : std_logic;
   signal ctrl_right      : std_logic;
   signal ctrl_zoom       : std_logic;

begin

   ARD_RESET  <= SW1;

   ctrl_up    <= btn_up    or not(js1_up);
   ctrl_down  <= btn_down  or not(js1_down);
   ctrl_left  <= btn_left  or not(js1_left);
   ctrl_right <= btn_right or not(js1_right);
   ctrl_zoom  <= btn_zoom  or not(js1_zoom);
    
   red   <= rgb_reg(11 downto 8);
   green <= rgb_reg(7 downto 4);
   blue  <= rgb_reg(3 downto 0);
   vsync <= vsync_sig;

   clocking_inst : clocking port map (
      -- Clock in ports
      CLK_32  => CLK_32,
      -- Clock out ports
      CLK_mem  => CLK_mem,
      CLK_memn => open,
      CLK_core  => CLK_core
   );

   Inst_core_mem_interface: core_mem_interface PORT MAP(
      clk_core    => clk_core,
      x_in        => x_result,
      y_in        => y_result,
      data_in     => iterations_result ,
      clk_mem     => clk_mem,
      write_data  => result_valid,
      fifo_full   => output_fifo_full,
      address_out => write_address,
      data_out    => write_byte,
      fifo_empty  => write_ready,
      read_data   => write_taken
   );

   Inst_memory_video: memory_video PORT MAP(
      clk         => clk_mem,
      base_addr_word => base_addr_word,
      write_ready => write_ready,
      write_addr  => write_address,
      write_byte  => write_byte,
      write_taken => write_taken,
      hsync       => hsync,
      vsync       => vsync_sig,
      colour      => colour,
      mem_nCE     => mem_nCE,
      mem_nWE     => mem_nWE,
      mem_nOE     => mem_nOE,
      mem_addr    => mem_addr,
      mem_data    => mem_data
   );

   Inst_scheduler: scheduler PORT MAP(
      clk            => clk_core,
      base_addr_word => base_addr_word,
      x              => x_new,
      y              => y_new,
      accepted       => accepted,
      vsync          => vsync_sig,
      btn_up         => ctrl_up,
      btn_down       => ctrl_down,
      btn_left       => ctrl_left,
      btn_right      => ctrl_right,
      btn_zoom     => ctrl_zoom,
      newvalue       => constant_new,
      storex         => storex_new,
      storey         => storey_new
      );


   Inst_loop_manager: loop_manager PORT MAP(
      clk => clk_core,

      x_new        => x_new,
      y_new        => y_new,
      storex_new   => storex_new,
      storey_new   => storey_new,
      constant_new => constant_new,
      new_point    => new_point,
      accepted_new => accepted,

      x_result          => x_result,
      y_result          => y_result,
      iterations_result => iterations_result,
      result_valid      => result_valid,
      output_fifo_full  => output_fifo_full,

      iterations_in => iterations_2,
      overflow_in => overflow_2,
      real_in => real_2,
      imaginary_in => imaginary_2,
      x_in => x_2,
      y_in => y_2,
      active_in => active_2,


      iterations_out => iterations_1,
      overflow_out => overflow_1,
      real_out => real_1,
      imaginary_out => imaginary_1,
      x_out => x_1,
      y_out => y_1,
      constant_out => constant_1,
      storex_out => storex_1,
      storey_out => storey_1,
      active_out => active_1
   );

   Inst_mandelbrot_stage: mandelbrot_stage PORT MAP(
      clk => clk_core,
      iterations_in => iterations_1,
      overflow_in => overflow_1,
      real_in => real_1,
      imaginary_in => imaginary_1,
      x_in => x_1,
      y_in => y_1,
      constant_in => constant_1,
      storex_in => storex_1,
      storey_in => storey_1,
      active_in => active_1,

      iterations_out => iterations_2,
      overflow_out => overflow_2,
      real_out => real_2,
      imaginary_out => imaginary_2,
      x_out => x_2,
      y_out => y_2,
      constant_out => open,
      storex_out => open,
      storey_out => open,
      active_out => active_2
   );

   -- Color Maps

   colormap_rainbow : entity work.colormap_rainbow
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_rainbow
   );

   colormap_caramel : entity work.colormap_caramel
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_caramel
   );

   colormap_roygold : entity work.colormap_roygold
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_roygold
   );

   colormap_polar : entity work.colormap_polar
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_polar
   );

   colormap_wild : entity work.colormap_wild
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_wild
   );

   colormap_tropic : entity work.colormap_tropic
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_tropic
   );

   colormap_stargate : entity work.colormap_stargate
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_stargate
   );

   colormap_rosewht : entity work.colormap_rosewht
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_rosewht
   );

   colormap_rose1 : entity work.colormap_rose1
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_rose1
   );

   colormap_flowers3 : entity work.colormap_flowers3
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_flowers3
   );

   colormap_candy : entity work.colormap_candy
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_candy
   );

   colormap_candy1 : entity work.colormap_candy1
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_candy1
   );

   colormap_anet : entity work.colormap_anet
   port map (
     clk => CLK_mem,
     addr => colour,
     data => rgb_anet
   );

   rgb <=      rgb_rainbow when current_colormap = 0
          else rgb_roygold when current_colormap = 1
          else rgb_polar when current_colormap = 2
          else rgb_wild when current_colormap = 3
          else rgb_tropic when current_colormap = 4
          else rgb_stargate when current_colormap = 5
          else rgb_rosewht when current_colormap = 6
          else rgb_rose1 when current_colormap = 7
          else rgb_flowers3 when current_colormap = 8
          else rgb_candy when current_colormap = 9
          else rgb_candy1 when current_colormap = 10
          else rgb_anet    when current_colormap = 11
          else rgb_caramel    when current_colormap = 12
          else colour(7 downto 5) & '0' & colour(4 downto 2) & '0' & colour(1 downto 0) & "00";

    process(CLK_mem)
    begin
      if rising_edge(CLK_mem) then
        rgb_reg <= rgb;
        vsync_sig_old <= vsync_sig;
        -- Sample the controls on rising edge of vsync, for two reasons
        -- 1. It give some degree of switch de-bounding
        -- 2. It prevents a colour map change in the middle of the screen
        if vsync_sig_old = '0' and vsync_sig = '1' then
           ctrl_left_old <= ctrl_left;
           ctrl_right_old <= ctrl_right;
           if ctrl_zoom = '1' and ctrl_left = '1' and ctrl_left_old = '0' then
              if current_colormap = 0 then
                 current_colormap <= x"D";
              else
                 current_colormap <= current_colormap - 1;
              end if;
           end if;
           if ctrl_zoom = '1' and ctrl_right = '1' and ctrl_right_old = '0'  then
              if current_colormap = 13 then
                 current_colormap <= x"0";
              else
                 current_colormap <= current_colormap + 1;
              end if;
           end if;
         end if;
      end if;
    end process;

end Behavioral;

