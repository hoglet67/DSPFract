library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity small_sqr35 is
    Port ( clk : in  STD_LOGIC;
           x : in  STD_LOGIC_VECTOR (34 downto 0);
           result : out  STD_LOGIC_VECTOR (37 downto 0));
end small_sqr35;

architecture Behavioral of small_sqr35 is

signal pa2 : std_logic_vector(35 downto 0);
signal pb2 : std_logic_vector(35 downto 0);
signal pb3 : std_logic_vector(35 downto 0);
signal pc1 : std_logic_vector(3 downto 0);
signal pc2 : std_logic_vector(3 downto 0);
signal pc3 : std_logic_vector(3 downto 0);
signal pc4 : std_logic_vector(3 downto 0);

signal xh : std_logic_vector(17 downto 0);
signal xl : std_logic_vector(17 downto 0);

signal sum3 : std_logic_vector(37 downto 0);
signal sum4 : std_logic_vector(37 downto 0);
signal sum5 : std_logic_vector(37 downto 0);
signal sum6 : std_logic_vector(37 downto 0);
signal sum7 : std_logic_vector(37 downto 0);

signal padb3 : std_logic_vector(15 downto 0); -- 16 bits

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
    p => pa2
  );

multiplierb : entity work.ip_mult18
  PORT MAP (
    clk => clk,
    a => xh,
    b => xl,
    p => pb2
  );


padb3 <= (others => pb3(35));

process(clk)
begin
    if rising_edge(clk) then
        case xl(16 downto 12) is
            when "01000" => pc1 <= x"1";
            when "01001" => pc1 <= x"1";
            when "01010" => pc1 <= x"1";
            when "01011" => pc1 <= x"1";
            when "01100" => pc1 <= x"2";
            when "01101" => pc1 <= x"2";
            when "01110" => pc1 <= x"3";
            when "01111" => pc1 <= x"3";
            when "10000" => pc1 <= x"4";
            when "10001" => pc1 <= x"4";
            when "10010" => pc1 <= x"5";
            when "10011" => pc1 <= x"5";
            when "10100" => pc1 <= x"6";
            when "10101" => pc1 <= x"6";
            when "10110" => pc1 <= x"7";
            when "10111" => pc1 <= x"8";
            when "11000" => pc1 <= x"9";
            when "11001" => pc1 <= x"9";
            when "11010" => pc1 <= x"A";
            when "11011" => pc1 <= x"B";
            when "11100" => pc1 <= x"C";
            when "11101" => pc1 <= x"D";
            when "11110" => pc1 <= x"E";
            when "11111" => pc1 <= x"F";
            when others  => pc1 <= x"0";
        end case;

        -- stage 2
        pc2 <= pc1;

        -- statge 3
        pb3 <= pb2;
        pc3 <= pc2;
        sum3 <= pa2 & "00";

        -- stage 4
        pc4 <= pc3;
        sum4 <= sum3 + (padb3 & pb3(35 downto 14));

        -- stage 5
        sum5 <= sum4 + pc4;

        -- stage 6
        sum6 <= sum5;

        -- stage 7
        sum7 <= sum6;

        -- stage 8
        result <= sum7;

    end if;
end process;

end Behavioral;
