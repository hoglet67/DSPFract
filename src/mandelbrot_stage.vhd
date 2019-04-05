library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.dsp_fractal_defs.all;

entity mandelbrot_stage is
    generic (
        sqr35_impl     : integer
        );
    port (
        clk            : in  STD_LOGIC;

        max_iters_in   : in  iterations_type;

        iterations_in  : in  iterations_type;
        overflow_in    : in  STD_LOGIC;
        real_in        : in  STD_LOGIC_VECTOR (35 downto 0);
        imaginary_in   : in  STD_LOGIC_VECTOR (35 downto 0);
        x_in           : in  STD_LOGIC_VECTOR (9 downto 0);
        y_in           : in  STD_LOGIC_VECTOR (9 downto 0);
        constant_in    : in  STD_LOGIC_VECTOR (35 downto 0);
        storex_in      : in  STD_LOGIC;
        storey_in      : in  STD_LOGIC;
        active_in      : in  STD_LOGIC;

        iterations_out : out iterations_type;
        overflow_out   : out STD_LOGIC;
        real_out       : out STD_LOGIC_VECTOR (35 downto 0);
        imaginary_out  : out STD_LOGIC_VECTOR (35 downto 0);
        x_out          : out STD_LOGIC_VECTOR (9 downto 0);
        y_out          : out STD_LOGIC_VECTOR (9 downto 0);
        constant_out   : out STD_LOGIC_VECTOR (35 downto 0);
        storex_out     : out STD_LOGIC;
        storey_out     : out STD_LOGIC;
        active_out     : out STD_LOGIC);
end mandelbrot_stage;

architecture Behavioral of mandelbrot_stage is
   signal real_post_check      : std_logic_vector(34 downto 0) := (others => '0');
   signal imaginary_post_check : std_logic_vector(34 downto 0) := (others => '0');

   signal new_real           : std_logic_vector(38 downto 0) := (others => '0');
   signal magnitude          : std_logic_vector(38 downto 0) := (others => '0');
   signal real_squared       : std_logic_vector(37 downto 0) := (others => '0');
   signal imaginary_squared  : std_logic_vector(37 downto 0) := (others => '0');
   signal real_imaginary     : std_logic_vector(37 downto 0) := (others => '0');
   signal real_imaginary_two : std_logic_vector(38 downto 0) := (others => '0');
   signal real_imaginary_two_delayed : std_logic_vector(38 downto 0) := (others => '0');
   signal real_const         : std_logic_vector(35 downto 0) := (others => '0');
   signal imaginary_const    : std_logic_vector(35 downto 0) := (others => '0');
   signal real_const_ex      : std_logic_vector(38 downto 0) := (others => '0');
   signal imaginary_const_ex : std_logic_vector(38 downto 0) := (others => '0');
   signal const_to_write     : std_logic_vector(35 downto 0) := (others => '0');
   signal real_result        : std_logic_vector(39 downto 0) := (others => '0');
   signal imaginary_result     : std_logic_vector(39 downto 0) := (others => '0');

   signal iterations_out_predelay : iterations_type;
   signal iterations_in_delayed   : iterations_type;

   signal x_addr                : STD_LOGIC_VECTOR (9 downto 0);
   signal y_addr                : STD_LOGIC_VECTOR (9 downto 0);

   signal active_in_v           : std_logic_vector(0 downto 0);
   signal active_out_v          : std_logic_vector(0 downto 0);

   signal storex_in_v           : std_logic_vector(0 downto 0);
   signal storex_out_v          : std_logic_vector(0 downto 0);

   signal storey_in_v           : std_logic_vector(0 downto 0);
   signal storey_out_v          : std_logic_vector(0 downto 0);

   signal storex_tap            : std_logic_vector(0 downto 0);
   signal storey_tap            : std_logic_vector(0 downto 0);

   signal overflow_in_v         : std_logic_vector(0 downto 0);
   signal overflow_in_delayed   : std_logic_vector(0 downto 0);

   signal overflow_out_v        : std_logic_vector(0 downto 0);
   signal overflow_out_delayed  : std_logic_vector(0 downto 0);

   signal early_overflow_result : std_logic_vector(0 downto 0);
   signal early_overflow_delayed: std_logic_vector(0 downto 0);

   signal overflow_this      : std_logic := '0';
begin
   overflow_this      <= magnitude(38) or magnitude(37) or magnitude(36) or magnitude(35) or magnitude(34) or early_overflow_delayed(0);

   overflow_in_v(0)   <= overflow_in;
   overflow_out       <= overflow_out_delayed(0);

   active_in_v(0)     <= active_in;
   active_out         <= active_out_v(0);

   storex_in_v(0)     <= storex_in;
   storex_out         <= storex_out_v(0);

   storey_in_v(0)     <= storey_in;
   storey_out         <= storey_out_v(0);

   real_out           <= real_result(35 downto 0);
   imaginary_out      <= imaginary_result(35 downto 0);

   real_imaginary_two <= real_imaginary(37 downto 0) & '0';

   real_const_ex      <= real_const(35)      & real_const(35)      & real_const(35)      & real_const;
   imaginary_const_ex <= imaginary_const(35) & imaginary_const(35) & imaginary_const(35) & imaginary_const;

   early_overflow_check: entity work.early_overflow PORT MAP(
     clk           => clk,
     real_in       => real_in,
     imaginary_in  => imaginary_in,
     real_out      => real_post_check,
     imaginary_out => imaginary_post_check,
     early_overflow=> early_overflow_result(0)
   );

   Inst_delay2cycles: entity work.delay2cycles PORT MAP(
      clk => clk,
      din => real_imaginary_two,
      dout => real_imaginary_two_delayed
   );

   mult35_ab2: entity work.mult35 PORT MAP(
      clk => clk,
      x   => real_post_check,
      y   => imaginary_post_check,
      result => real_imaginary
   );

   sqr35_orig: if sqr35_impl = SQR35_IMPL_ORIG generate

       sqr35_real: entity work.sqr35 PORT MAP(
           clk    => clk,
           x      => real_post_check,
           result => real_squared
           );

       sqr35_imaginary: entity work.sqr35 PORT MAP(
           clk    => clk,
           x      => imaginary_post_check,
           result => imaginary_squared
           );

   end generate;

   sqr35_test: if sqr35_impl = SQR35_IMPL_TEST generate

       sqr35_real: entity work.sqr35_test PORT MAP(
           clk    => clk,
           x      => real_post_check,
           result => real_squared
           );

       sqr35_imaginary: entity work.sqr35_test PORT MAP(
           clk    => clk,
           x      => imaginary_post_check,
           result => imaginary_squared
           );

   end generate;

   sqr35_small: if sqr35_impl = SQR35_IMPL_SMALL generate

       sqr35_real: entity work.sqr35_small PORT MAP(
           clk    => clk,
           x      => real_post_check,
           result => real_squared
           );

       sqr35_imaginary: entity work.sqr35_small PORT MAP(
           clk    => clk,
           x      => imaginary_post_check,
           result => imaginary_squared
           );

   end generate;

   sqr35_lut: if sqr35_impl = SQR35_IMPL_LUT generate

       sqr35_real: entity work.sqr35_lut PORT MAP(
           clk    => clk,
           x      => real_post_check,
           result => real_squared
           );

       sqr35_imaginary: entity work.sqr35_lut PORT MAP(
           clk    => clk,
           x      => imaginary_post_check,
           result => imaginary_squared
           );

   end generate;

   addn_magnitude: entity work.addn GENERIC MAP (
      width => 38
   ) PORT MAP (
      clk => clk,
      x => real_squared,
      y => imaginary_squared,
      result => magnitude
   );

   subn_newreal: entity work.subn GENERIC MAP (
      width => 38
   )PORT MAP(
      clk => clk,
      x => real_squared,
      y => imaginary_squared,
      result => new_real
   );

   addn_real_out: entity work.addn GENERIC MAP (
      width => 39
   )PORT MAP(
      clk => clk,
      x => new_real,
      y => real_const_ex,
      result => real_result
   );

   add_new_imaginary: entity work.addn GENERIC MAP (
      width => 39
   )PORT MAP(
      clk => clk,
      x => real_imaginary_two_delayed,
      y => imaginary_const_ex,
      result => imaginary_result
   );

   Iteration_overflow_test: entity work.Iteration_overflow PORT MAP(
      clk => clk,
      max_iters_in => max_iters_in,
      Iterations_in => Iterations_in_delayed,
      Overflow_in => Overflow_in_delayed(0),
      Overflow_this => Overflow_this,
      Iterations_out => iterations_out_predelay,
      Overflow_out => Overflow_out_v(0)
   );

   real_constant_store: entity work.constant_store PORT MAP(
      clk     => clk,
      address => x_addr,
      din     => const_to_write,
      we      => storex_tap(0),
      value   => real_const
   );

   imaginary_constant_store: entity work.constant_store PORT MAP(
      clk     => clk,
      address => y_addr,
      din     => const_to_write,
      we      => storey_tap(0),
      value   => imaginary_const
   );

   x_tapped_delay: entity work.tapped_delay GENERIC MAP (width => 10, depth => 12, tap => 7)
   PORT MAP(
      clk => clk,
      n_in => x_in,
      tap_out => x_addr,
      n_out => x_out
   );

   y_tapped_delay: entity work.tapped_delay GENERIC MAP (width => 10, depth => 12, tap => 7)
   PORT MAP(
      clk => clk,
      n_in => y_in,
      tap_out => y_addr,
      n_out => y_out
   );

   const_tapped_delay: entity work.tapped_delay GENERIC MAP (width => 36, depth => 12, tap => 7)
   PORT MAP(
      clk => clk,
      n_in => constant_in,
      tap_out => const_to_write,
      n_out => constant_out
   );

   active_delay: entity work.untapped_delay GENERIC MAP (width => 1, depth => 12)
   PORT MAP(
      clk => clk,
      n_in => active_in_v,
      n_out =>active_out_v
   );

   early_overflow_untapped_delay: entity work.untapped_delay GENERIC MAP (width => 1, depth => 9)
   PORT MAP(
      clk => clk,
      n_in => early_overflow_result,
      n_out => early_overflow_delayed
   );

   overflow_in_untapped_delay: entity work.untapped_delay GENERIC MAP (width => 1, depth => 9)
   PORT MAP(
      clk => clk,
      n_in => overflow_in_v,
      n_out => overflow_in_delayed
   );

   overflow_out_untapped_delay: entity work.untapped_delay GENERIC MAP (width => 1, depth => 0)
   PORT MAP(
      clk => clk,
      n_in => overflow_out_v,
      n_out => overflow_out_delayed
   );

   iterations_in_untapped_delay: entity work.untapped_delay GENERIC MAP (width => iterations_type'length, depth => 9)
   PORT MAP(
      clk => clk,
      n_in => iterations_in,
      n_out => iterations_in_delayed
   );

   iterations_out_untapped_delay: entity work.untapped_delay GENERIC MAP (width => iterations_type'length, depth => 0)
   PORT MAP(
      clk => clk,
      n_in => iterations_out_predelay,
      n_out => iterations_out
   );

   storex_tapped_delay: entity work.tapped_delay GENERIC MAP (width => 1, depth => 12, tap => 7)
   PORT MAP(
      clk => clk,
      n_in => storex_in_v,
      tap_out => storex_tap,
      n_out => storex_out_v
   );

   storey_tapped_delay: entity work.tapped_delay GENERIC MAP (width => 1, depth => 12, tap => 7)
   PORT MAP(
      clk => clk,
      n_in => storey_in_v,
      tap_out => storey_tap,
      n_out =>storey_out_v
   );
end Behavioral;
