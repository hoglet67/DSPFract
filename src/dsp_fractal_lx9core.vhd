library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.dsp_fractal_defs.all;

entity dsp_fractal_lx9core is
    Port (
        -- System oscillator
        clk50        : in    std_logic;
        -- BBC 1MHZ Bus
        clke         : in    std_logic;
        rnw          : in    std_logic;
        rst_n        : in    std_logic;
        pgfc_n       : in    std_logic;
        pgfd_n       : in    std_logic;
        bus_addr     : in    std_logic_vector (7 downto 0);
        bus_data     : inout std_logic_vector (7 downto 0);
        bus_data_dir : out   std_logic;
        bus_data_oel : out   std_logic;
        nmi          : out   std_logic;
        irq          : out   std_logic;
        -- SPI DAC
        --dac_cs_n     : out   std_logic;
        --dac_sck      : out   std_logic;
        --dac_sdi      : out   std_logic;
        --dac_ldac_n   : out   std_logic;
        -- RAM
        ram_addr     : out   std_logic_vector(18 downto 0);
        ram_data     : inout std_logic_vector(7 downto 0);
        ram_cel      : out   std_logic;
        ram_oel      : out   std_logic;
        ram_wel      : out   std_logic;
        -- Misc
        pmod0        : out   std_logic_vector(7 downto 0);
        pmod1        : out   std_logic_vector(7 downto 0);
        pmod2        : out   std_logic_vector(7 downto 0);
        sw1          : in    std_logic;
        sw2          : in    std_logic;
        led          : out   std_logic
      );
end dsp_fractal_lx9core;

architecture Behavioral of dsp_fractal_lx9core is

    signal clk_core   : std_logic;
    signal clk_mem    : std_logic;

    signal ctrl_up    : std_logic;
    signal ctrl_down  : std_logic;
    signal ctrl_left  : std_logic;
    signal ctrl_right : std_logic;
    signal ctrl_zoom  : std_logic;

    signal ctrl_reg   : std_logic_vector(7 downto 0);
    signal bank_reg   : std_logic_vector(7 downto 0);
    signal rom_dout   : std_logic_vector(7 downto 0);

    signal red        : std_logic_vector(3 downto 0);
    signal green      : std_logic_vector(3 downto 0);
    signal blue       : std_logic_vector(3 downto 0);
    signal hsync      : std_logic;
    signal vsync      : std_logic;

    signal reg_sel    : std_logic;
    signal rom_sel    : std_logic;
    signal bank_sel   : std_logic;
    signal booting    : std_logic;

    signal clkin_buf  : std_logic;
    signal clkfb_buf  : std_logic;
    signal clkfb      : std_logic;
    signal clk0       : std_logic;
    signal clk1       : std_logic;

    signal max_iters  : std_logic_vector(15 downto 0);

begin

    ------------------------------------------------
    -- Clocking
    ------------------------------------------------

    inst_clkin_buf : IBUFG
        port map (
            I => clk50,
            O => clkin_buf
            );

    inst_PLL : PLL_BASE
        generic map (
            BANDWIDTH            => "OPTIMIZED",
            CLK_FEEDBACK         => "CLKFBOUT",
            COMPENSATION         => "SYSTEM_SYNCHRONOUS",
            DIVCLK_DIVIDE        => 1,
            CLKFBOUT_MULT        => 19,      -- 50 * 19 = 950
            CLKFBOUT_PHASE       => 0.000,
            CLKOUT0_DIVIDE       => 12,      -- 950 / 12 = 79.16MHz
            CLKOUT0_PHASE        => 0.000,
            CLKOUT0_DUTY_CYCLE   => 0.500,
            CLKOUT1_DIVIDE       => 6,       -- 950 / 4 = 237.5MHz; 950 / 6 = 158.3MHz
            CLKOUT1_PHASE        => 0.000,
            CLKOUT1_DUTY_CYCLE   => 0.500,
            CLKIN_PERIOD         => 20.000,
            REF_JITTER           => 0.010
            )
        port map (
            -- Output clocks
            CLKFBOUT            => clkfb,
            CLKOUT0             => clk0,
            CLKOUT1             => clk1,
            RST                 => '0',
            -- Input clock control
            CLKFBIN             => clkfb_buf,
            CLKIN               => clkin_buf
            );

    inst_clkfb_buf : BUFG
        port map (
            I => clkfb,
            O => clkfb_buf
            );

    inst_clk0_buf : BUFG
        port map (
            I => clk0,
            O => clk_mem
            );

    inst_clk1_buf : BUFG
        port map (
            I => clk1,
            O => clk_core
            );

    ------------------------------------------------
    -- DSP Fractal Core
    ------------------------------------------------

    core_inst : entity work.dsp_fractal_core
        generic map (
            use_two_mandelbrot_stages => true,
            sqr35_impl                => SQR35_IMPL_SMALL
            )
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
            mem_nCE    => ram_cel,
            mem_nWE    => ram_wel,
            mem_nOE    => ram_oel,
            mem_addr   => ram_addr,
            mem_data   => ram_data,
            -- User constrols
            max_iters  => max_iters(iterations_type'range),
            ctrl_up    => ctrl_up,
            ctrl_down  => ctrl_down,
            ctrl_left  => ctrl_left,
            ctrl_right => ctrl_right,
            ctrl_zoom  => ctrl_zoom
            );

    inst_support_rom : entity work.support_rom
        port map (
            clock   => clke,     -- rising edge
            address => bank_reg(3 downto 0) & bus_addr,
            data    => rom_dout
            );


    ------------------------------------------------
    -- Bus Interface
    ------------------------------------------------

    -- Decode 0xFCA8-0xFCAB
    reg_sel  <= '1' when pgfc_n = '0' and bus_addr(7 downto 2) & "00" = x"A8" else '0';

    -- Decode 0xFCFF
    bank_sel <= '1' when pgfc_n = '0' and bus_addr = x"FF" else '0';

    -- Decode 0xFDxx during boot
    rom_sel  <= '1' when pgfd_n = '0' else '0';

    -- Writes to the control register
    bus_interface_fc : process(clke)
    begin
        if falling_edge(clke) then
            if rst_n = '0' then
                ctrl_reg     <= x"00";
                max_iters    <= x"00FF";
                booting      <= sw1 or sw2;
                bank_reg     <= (others => '0');
            elsif rnw = '0' then
                if reg_sel = '1' then
                    case bus_addr(1 downto 0) is
                        when "10"   => max_iters(7 downto 0)  <= bus_data;
                        when "11"   => max_iters(15 downto 8) <= bus_data;
                        when others => ctrl_reg  <= bus_data;
                    end case;
                elsif bank_sel = '1' then
                    bank_reg <= bus_data;
                elsif rom_sel = '1' then
                    booting <= '0';
                end if;
            end if;
        end if;
    end process;

    ctrl_up      <= ctrl_reg(0);
    ctrl_down    <= ctrl_reg(1);
    ctrl_left    <= ctrl_reg(2);
    ctrl_right   <= ctrl_reg(3);
    ctrl_zoom    <= ctrl_reg(4);
    led          <= ctrl_reg(7) or booting;

    nmi          <= '0';
    irq          <= booting;

    bus_data_oel <= not (reg_sel or bank_sel or rom_sel);
    bus_data_dir <= rnw;
    bus_data     <= rom_dout                when rnw = '1' and rom_sel = '1'                       else
                    bank_reg                when rnw = '1' and bank_sel = '1'                      else
                    ctrl_reg                when rnw = '1' and reg_sel = '1' and bus_addr(1) = '1' else
                    max_iters(15 downto 8)  when rnw = '1' and reg_sel = '1' and bus_addr(0) = '1' else
                    max_iters( 7 downto 0)  when rnw = '1' and reg_sel = '1'                       else
                    (others => 'Z');

    pmod0        <= blue & red;
    pmod1        <= '0' & '0' & vsync & hsync & green ;
    pmod2        <= (others => '1');

end Behavioral;
