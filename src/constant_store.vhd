library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity constant_store is
    Port ( clk     : in  STD_LOGIC;
           address : in  STD_LOGIC_VECTOR (9 downto 0);
           din     : in  STD_LOGIC_VECTOR (35 downto 0);
			  we      : in  STD_LOGIC;
           value   : out STD_LOGIC_VECTOR (35 downto 0));
end constant_store;

architecture Behavioral of constant_store is
   COMPONENT ip_constant_store
   PORT (
       clka : IN STD_LOGIC;
       ena : IN STD_LOGIC;
       wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
       addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
       dina : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
       douta : OUT STD_LOGIC_VECTOR(35 DOWNTO 0)
     );
   END COMPONENT;

   signal wea : std_logic_vector(0 downto 0);
	
begin
 wea(0) <= we;

memory_block: ip_constant_store
  PORT MAP (
    clka => clk,
    ena => '1',
    wea => wea,
    addra => address,
    dina => din,
    douta => value
  );

end Behavioral;

