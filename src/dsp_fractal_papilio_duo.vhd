library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dsp_fractal_papilio_duo is
    Port (
        clk_32    : in    std_logic;

        -- video
        hsync     : out   std_logic;
        vsync     : out   std_logic;
        red       : out   std_logic_vector (3 downto 0);
        green     : out   std_logic_vector (3 downto 0);
        blue      : out   std_logic_vector (3 downto 0);

        -- Memory
        mem_nCE   : out   std_logic;
        mem_nWE   : out   std_logic;
        mem_nOE   : out   std_logic;
        mem_addr  : out   std_logic_vector(18 downto 0);
        mem_data  : inout std_logic_vector(7 downto 0);

        -- User constrols
        btn_up    : in    std_logic;
        btn_down  : in    std_logic;
        btn_left  : in    std_logic;
        btn_right : in    std_logic;
        btn_zoom  : in    std_logic;
        js1_up    : in    std_logic;
        js1_down  : in    std_logic;
        js1_left  : in    std_logic;
        js1_right : in    std_logic;
        js1_zoom  : in    std_logic;
        ARD_RESET : out   std_logic;
        SW1       : in    std_logic
        );
end dsp_fractal_papilio_duo;

architecture Behavioral of dsp_fractal_papilio_duo is

    signal clk_core   : std_logic;
    signal clk_mem    : std_logic;

    signal ctrl_up    : std_logic;
    signal ctrl_down  : std_logic;
    signal ctrl_left  : std_logic;
    signal ctrl_right : std_logic;
    signal ctrl_zoom  : std_logic;

begin

    ARD_RESET  <= SW1;

    ctrl_up    <= btn_up    or not(js1_up);
    ctrl_down  <= btn_down  or not(js1_down);
    ctrl_left  <= btn_left  or not(js1_left);
    ctrl_right <= btn_right or not(js1_right);
    ctrl_zoom  <= btn_zoom  or not(js1_zoom);

    clocking_inst : entity work.clocking
        port map (
            -- Clock in ports
            CLK_32   => clk_32,
            -- Clock out ports
            CLK_mem  => clk_mem,
            CLK_memn => open,
            CLK_core => clk_core
            );

    core_inst : entity work.dsp_fractal_core
        port map (
            -- Clocks
            clk_mem    => clk_mem,
            clk_core   => clk_core,
            -- Video
            hsync      => hsync,
            vsync      => vsync,
            red        => red,
            green      => green,
            blue       => blue,
            -- Memory
            mem_nCE    => mem_nCE,
            mem_nWE    => mem_nWE,
            mem_nOE    => mem_nOE,
            mem_addr   => mem_addr,
            mem_data   => mem_data,
            -- User constrols
            ctrl_up    => ctrl_up,
            ctrl_down  => ctrl_down,
            ctrl_left  => ctrl_left,
            ctrl_right => ctrl_right,
            ctrl_zoom  => ctrl_zoom
            );

end Behavioral;
