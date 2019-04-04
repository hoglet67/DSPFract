library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.dsp_fractal_defs.all;

entity dsp_fractal_core is
    Port (
        -- Clocks
        clk_mem    : in    std_logic; -- 80MHz
        clk_core   : in    std_logic; -- 240MHz

        -- Video
        hsync      : out   std_logic;
        vsync      : out   std_logic;
        red        : out   std_logic_vector (3 downto 0);
        green      : out   std_logic_vector (3 downto 0);
        blue       : out   std_logic_vector (3 downto 0);

        -- Memory
        mem_nCE    : out   std_logic;
        mem_nWE    : out   std_logic;
        mem_nOE    : out   std_logic;
        mem_addr   : out   std_logic_vector(18 downto 0);
        mem_data   : inout std_logic_vector(7 downto 0);

        -- User constrols
        max_iters  : in    iterations_type;
        ctrl_up    : in    std_logic;
        ctrl_down  : in    std_logic;
        ctrl_left  : in    std_logic;
        ctrl_right : in    std_logic;
        ctrl_zoom  : in    std_logic
        );
end dsp_fractal_core;

architecture Behavioral of dsp_fractal_core is

    signal current_colormap    : unsigned (3 downto 0);
    signal ctrl_left_old       : std_logic;
    signal ctrl_right_old      : std_logic;
    signal vsync_sig_old       : std_logic;

    signal real_1              : std_logic_vector(35 downto 0);
    signal imaginary_1         : std_logic_vector(35 downto 0);
    signal x_1                 : std_logic_vector(9 downto 0);
    signal y_1                 : std_logic_vector(9 downto 0);
    signal iterations_1        : iterations_type;
    signal constant_1          : std_logic_vector(35 downto 0);
    signal overflow_1          : std_logic;
    signal storex_1            : std_logic;
    signal storey_1            : std_logic;
    signal active_1            : std_logic;

    signal real_2              : std_logic_vector(35 downto 0);
    signal imaginary_2         : std_logic_vector(35 downto 0);
    signal x_2                 : std_logic_vector(9 downto 0);
    signal y_2                 : std_logic_vector(9 downto 0);
    signal iterations_2        : iterations_type;
    signal constant_2          : std_logic_vector(35 downto 0);
    signal overflow_2          : std_logic;
    signal storex_2            : std_logic;
    signal storey_2            : std_logic;
    signal active_2            : std_logic;

    signal real_3              : std_logic_vector(35 downto 0);
    signal imaginary_3         : std_logic_vector(35 downto 0);
    signal x_3                 : std_logic_vector(9 downto 0);
    signal y_3                 : std_logic_vector(9 downto 0);
    signal iterations_3        : iterations_type;
    signal overflow_3          : std_logic;
    signal active_3            : std_logic;

    signal x_new               : std_logic_vector(9 downto 0) := (others => '0');
    signal y_new               : std_logic_vector(9 downto 0) := (others => '0');
    signal constant_new        : std_logic_vector (35 downto 0) := (others => '0');
    signal storex_new          : std_logic := '0';
    signal storey_new          : std_logic := '0';
    signal new_point           : std_logic := '0';
    signal accepted            : std_logic := '0';

    signal x_result            : std_logic_vector(9 downto 0);
    signal y_result            : std_logic_vector(9 downto 0);
    signal iterations_result   : iterations_type;

    signal write_byte          : std_logic_vector(7 downto 0);
    signal write_address       : std_logic_vector(18 downto 0);
    signal write_taken         : std_logic;
    signal write_ready         : std_logic;
    signal output_fifo_full    : std_logic;
    signal base_addr_word      : std_logic_vector(17 downto 0);

    signal result_valid        : std_logic;
    signal colour              : std_logic_vector(7 downto 0);

    signal vsync_sig           : std_logic;

    signal rgb                 : std_logic_vector (11 downto 0);
    signal rgb_reg             : std_logic_vector (11 downto 0);
    signal rgb_rainbow         : std_logic_vector (11 downto 0);
    signal rgb_caramel         : std_logic_vector (11 downto 0);
    signal rgb_anet            : std_logic_vector (11 downto 0);
    signal rgb_roygold         : std_logic_vector (11 downto 0);
    signal rgb_polar           : std_logic_vector (11 downto 0);
    signal rgb_wild            : std_logic_vector (11 downto 0);
    signal rgb_tropic          : std_logic_vector (11 downto 0);
    signal rgb_stargate        : std_logic_vector (11 downto 0);
    signal rgb_rosewht         : std_logic_vector (11 downto 0);
    signal rgb_rose1           : std_logic_vector (11 downto 0);
    signal rgb_flowers3        : std_logic_vector (11 downto 0);
    signal rgb_candy           : std_logic_vector (11 downto 0);
    signal rgb_candy1          : std_logic_vector (11 downto 0);

begin

    red   <= rgb_reg(11 downto 8);
    green <= rgb_reg(7 downto 4);
    blue  <= rgb_reg(3 downto 0);
    vsync <= vsync_sig;

    Inst_core_mem_interface: entity work.core_mem_interface
        port map (
            clk_core    => clk_core,
            x_in        => x_result,
            y_in        => y_result,
            data_in     => iterations_result(7 downto 0) ,
            clk_mem     => clk_mem,
            write_data  => result_valid,
            fifo_full   => output_fifo_full,
            address_out => write_address,
            data_out    => write_byte,
            fifo_empty  => write_ready,
            read_data   => write_taken
            );

    Inst_memory_video: entity work.memory_video
        port map (
            clk            => clk_mem,
            base_addr_word => base_addr_word,
            write_ready    => write_ready,
            write_addr     => write_address,
            write_byte     => write_byte,
            write_taken    => write_taken,
            hsync          => hsync,
            vsync          => vsync_sig,
            colour         => colour,
            mem_nCE        => mem_nCE,
            mem_nWE        => mem_nWE,
            mem_nOE        => mem_nOE,
            mem_addr       => mem_addr,
            mem_data       => mem_data
            );

    Inst_scheduler: entity work.scheduler
        port map (
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
            btn_zoom       => ctrl_zoom,
            newvalue       => constant_new,
            storex         => storex_new,
            storey         => storey_new
            );


    Inst_loop_manager: entity work.loop_manager
        port map (
            clk               => clk_core,

            x_new             => x_new,
            y_new             => y_new,
            storex_new        => storex_new,
            storey_new        => storey_new,
            constant_new      => constant_new,
            new_point         => new_point,
            accepted_new      => accepted,

            x_result          => x_result,
            y_result          => y_result,
            iterations_result => iterations_result,
            result_valid      => result_valid,
            output_fifo_full  => output_fifo_full,

            iterations_in     => iterations_3,
            overflow_in       => overflow_3,
            real_in           => real_3,
            imaginary_in      => imaginary_3,
            x_in              => x_3,
            y_in              => y_3,
            active_in         => active_3,

            iterations_out    => iterations_1,
            overflow_out      => overflow_1,
            real_out          => real_1,
            imaginary_out     => imaginary_1,
            x_out             => x_1,
            y_out             => y_1,
            constant_out      => constant_1,
            storex_out        => storex_1,
            storey_out        => storey_1,
            active_out        => active_1
            );

    Inst_mandelbrot_stage1: entity work.mandelbrot_stage
        port map (
            clk               => clk_core,
            max_iters_in      => max_iters,

            iterations_in     => iterations_1,
            overflow_in       => overflow_1,
            real_in           => real_1,
            imaginary_in      => imaginary_1,
            x_in              => x_1,
            y_in              => y_1,
            constant_in       => constant_1,
            storex_in         => storex_1,
            storey_in         => storey_1,
            active_in         => active_1,

            iterations_out    => iterations_2,
            overflow_out      => overflow_2,
            real_out          => real_2,
            imaginary_out     => imaginary_2,
            x_out             => x_2,
            y_out             => y_2,
            constant_out      => constant_2,
            storex_out        => storex_2,
            storey_out        => storey_2,
            active_out        => active_2
            );

    Inst_mandelbrot_stage2: entity work.mandelbrot_stage
        port map (
            clk               => clk_core,
            max_iters_in      => max_iters,

            iterations_in     => iterations_2,
            overflow_in       => overflow_2,
            real_in           => real_2,
            imaginary_in      => imaginary_2,
            x_in              => x_2,
            y_in              => y_2,
            constant_in       => constant_2,
            storex_in         => storex_2,
            storey_in         => storey_2,
            active_in         => active_2,

            iterations_out    => iterations_3,
            overflow_out      => overflow_3,
            real_out          => real_3,
            imaginary_out     => imaginary_3,
            x_out             => x_3,
            y_out             => y_3,
            constant_out      => open,
            storex_out        => open,
            storey_out        => open,
            active_out        => active_3
            );

    -- Color Maps

    colormap_rainbow : entity work.colormap_rainbow
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_rainbow
            );

    colormap_caramel : entity work.colormap_caramel
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_caramel
            );

    colormap_roygold : entity work.colormap_roygold
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_roygold
            );

    colormap_polar : entity work.colormap_polar
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_polar
            );

    colormap_wild : entity work.colormap_wild
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_wild
            );

    colormap_tropic : entity work.colormap_tropic
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_tropic
            );

    colormap_stargate : entity work.colormap_stargate
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_stargate
            );

    colormap_rosewht : entity work.colormap_rosewht
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_rosewht
            );

    colormap_rose1 : entity work.colormap_rose1
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_rose1
            );

    colormap_flowers3 : entity work.colormap_flowers3
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_flowers3
            );

    colormap_candy : entity work.colormap_candy
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_candy
            );

    colormap_candy1 : entity work.colormap_candy1
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_candy1
            );

    colormap_anet : entity work.colormap_anet
        port map (
            clk  => clk_mem,
            addr => colour,
            data => rgb_anet
            );

    rgb <= rgb_rainbow  when current_colormap =  0 else
           rgb_roygold  when current_colormap =  1 else
           rgb_polar    when current_colormap =  2 else
           rgb_wild     when current_colormap =  3 else
           rgb_tropic   when current_colormap =  4 else
           rgb_stargate when current_colormap =  5 else
           rgb_rosewht  when current_colormap =  6 else
           rgb_rose1    when current_colormap =  7 else
           rgb_flowers3 when current_colormap =  8 else
           rgb_candy    when current_colormap =  9 else
           rgb_candy1   when current_colormap = 10 else
           rgb_anet     when current_colormap = 11 else
           rgb_caramel  when current_colormap = 12 else
           colour(7 downto 5) & '0' & colour(4 downto 2) & '0' & colour(1 downto 0) & "00";

    process(clk_mem)
    begin
        if rising_edge(clk_mem) then
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
