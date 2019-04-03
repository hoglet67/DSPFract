library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sqr35 is
    Port ( clk : in  STD_LOGIC;
           x : in  STD_LOGIC_VECTOR (34 downto 0);
           result : out  STD_LOGIC_VECTOR (37 downto 0));
end sqr35;

architecture Behavioral of sqr35 is

--  COMPONENT ip_mult35
--    PORT (
--      clk : IN  STD_LOGIC;
--      a   : IN  STD_LOGIC_VECTOR(34 DOWNTO 0);
--      b   : IN  STD_LOGIC_VECTOR(34 DOWNTO 0);
--      p   : OUT STD_LOGIC_VECTOR(37 DOWNTO 0)
--    );
--  END COMPONENT;

signal pa0 : std_logic_vector(35 downto 0);
signal pb0 : std_logic_vector(35 downto 0);
signal pb1 : std_logic_vector(35 downto 0);
signal pc0 : std_logic_vector(35 downto 0);
signal pc1 : std_logic_vector(35 downto 0);
signal pc2 : std_logic_vector(35 downto 0);

signal xh : std_logic_vector(17 downto 0);
signal xl : std_logic_vector(17 downto 0);

signal sum1 : std_logic_vector(37 downto 0);
signal sum2 : std_logic_vector(37 downto 0);
signal sum3 : std_logic_vector(37 downto 0);
signal sum4 : std_logic_vector(37 downto 0);
signal sum5 : std_logic_vector(37 downto 0);

signal padb1 : std_logic_vector(15 downto 0); -- 16 bits
signal padc2 : std_logic_vector(33 downto 0); -- 34 bits

begin

-- multiplier : entity work.ip_mult35
--   PORT MAP (
--     clk => clk,
--     a => x,
--     b => x,
--     p => result
--   );

xh <= x(34 downto 17);
xl <= '0' & x(16 downto 0);

-- original 35-bit multiplier had 8 pipeline stages
-- new 18-bit multiplier has 2 pipeline stages, so we need 6 more

multipliera : entity work.ip_mult18
  PORT MAP (
    clk => clk,
    a => xh,
    b => xh,
    p => pa0
  );

multiplierb : entity work.ip_mult18
  PORT MAP (
    clk => clk,
    a => xh,
    b => xl,
    p => pb0
  );

multiplierc : entity work.ip_mult18
  PORT MAP (
    clk => clk,
    a => xl,
    b => xl,
    p => pc0
  );

padb1 <= (others => pb1(35));
padc2 <= (others => pc2(35));

process(clk)
begin
    if rising_edge(clk) then
        pb1 <= pb0;
        pc1 <= pc0;
        pc2 <= pc1;
        sum1 <= pa0 & "00";
        sum2 <= sum1 + (padb1 & pb1(35 downto 14));
        sum3 <= sum2 + pc2(33 downto 30);  -- 35..29 looks perfect (with 2 bits of eounding)
        sum4 <= sum3;
        sum5 <= sum4;
        result <= sum5;
    end if;
end process;

end Behavioral;
