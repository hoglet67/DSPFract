library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity sqr35_small is
    port (
           clk : in  std_logic;
             x : in  std_logic_vector (34 downto 0);
        result : out std_logic_vector (37 downto 0)
    );
end sqr35_small;

architecture Behavioral of sqr35_small is

-- note: cross artifacts start appearing when sum_type < 52 bits wide
subtype  mul_in_type is std_logic_vector(17 downto 0); -- fixed
subtype mul_out_type is std_logic_vector(35 downto 0); -- fixed
subtype    prod_type is std_logic_vector(69 downto 0); -- fixed
subtype     sum_type is std_logic_vector(51 downto 0); -- this can be adjusted
subtype  result_type is std_logic_vector(37 downto 0); -- fixed

-- define a 10-bit squarer (with 16 bit output), implemented as a block RAM
type squarer_type is array(0 to 1023) of std_logic_vector(15 downto 0);

function squarer_init return squarer_type is
  variable temp : squarer_type;
begin
  forLoop: for i in 0 to 1022 loop
    temp(i) := std_logic_vector(to_unsigned((i + 1) * (i + 1) / 16, 16));
  end loop;
  temp(1023) := x"FFFF";
  return temp;
end function;

signal squarer       : squarer_type := squarer_init;

signal            xh : mul_in_type;
signal            xl : mul_in_type;
signal           xl1 : mul_in_type;

signal           ma2 : mul_out_type;
signal           mb2 : mul_out_type;
signal           mc2 : mul_out_type;

signal      pad_zero : prod_type;
signal      pad_sign : prod_type;
signal           pa2 : prod_type;
signal           pb2 : prod_type;
signal           pc2 : prod_type;
signal           pb3 : prod_type;
signal           pc3 : prod_type;
signal           pc4 : prod_type;

signal          sum3 : sum_type;
signal          sum4 : sum_type;
signal          sum5 : sum_type;

signal          res6 : result_type;
signal          res7 : result_type;

begin

-- segment the input into two halves
xh <= x(34 downto 17);
xl <= '0' & x(16 downto 0);

-- multiply XH * XH with a smaller 18x18 multiplier
multipliera : entity work.ip_mult18
  port map (
    clk => clk,
    a => xh,
    b => xh,
    p => ma2
  );

-- multiply XH * XL with a smaller 18x18 multiplier
multiplierb : entity work.ip_mult18
  port map (
    clk => clk,
    a => xh,
    b => xl,
    p => mb2
  );

-- multiply XL * XL with a smaller 18x18 multiplier (based on a block RAM)

-- padding at this point is the full product width
pad_zero <= (others => '0');
pad_sign <= (others => mb2(mb2'left));

-- carefully align the three results (as per UG389 page 28) to form 70-bit padded products
pa2 <=                         ma2               & pad_zero(33 downto 0); -- XH*XH aligned to the LHS of 70-bit product
pb2 <= pad_sign(15 downto 0) & mb2               & pad_zero(17 downto 0); -- offset right by 17 - 1 = 16 bits
pc2 <= pad_zero(35 downto 0) & mc2(33 downto 18) & pad_zero(17 downto 0); -- offset right by 34 bits

process(clk)
begin
    if rising_edge(clk) then

        -- original 35-bit multiplier had 8 pipeline stages
        -- new 18-bit multiplier has only 2 pipeline stages, so we need 6 more here

        -- stages 1 & 2
        xl1 <= xl;
        mc2 <= "00" & squarer(to_integer(unsigned(xl1(16 downto 7)))) & pad_zero(17 downto 0);

        -- stage 3
        pb3 <= pb2;
        pc3 <= pc2;
        sum3 <= pa2(prod_type'left downto prod_type'left - sum_type'length + 1);

        -- stage 4
        pc4 <= pc3;
        sum4 <= sum3 + pb3(prod_type'left downto prod_type'left - sum_type'length + 1);

        -- stage 5
        sum5 <= sum4 + pc4(prod_type'left downto prod_type'left - sum_type'length + 1);

        -- stage 6
        res6 <= sum5(sum_type'left downto sum_type'left - result_type'length + 1);

        -- stage 7
        res7 <= res6;

        -- stage 8
        result <= res7;

    end if;
end process;

end Behavioral;
