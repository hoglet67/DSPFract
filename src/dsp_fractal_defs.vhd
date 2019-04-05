library ieee;
use ieee.std_logic_1164.all;

package dsp_fractal_defs is

    subtype iterations_type is std_logic_vector(11 downto 0);

    constant SQR35_IMPL_ORIG  : integer := 0;
    constant SQR35_IMPL_TEST  : integer := 1;
    constant SQR35_IMPL_SMALL : integer := 2;
    constant SQR35_IMPL_LUT   : integer := 3;

end package dsp_fractal_defs;
