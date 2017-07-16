
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity colormap_flowers3 is
   port(
      clk: in std_logic;
      addr: in std_logic_vector(7 downto 0);
      data: out std_logic_vector(11 downto 0)
   );
end colormap_flowers3;

architecture arch of colormap_flowers3 is
   constant ADDR_WIDTH: integer:=8;
   constant DATA_WIDTH: integer:=12;
   type rom_type is array (0 to 2**ADDR_WIDTH-1)
        of std_logic_vector(DATA_WIDTH-1 downto 0);
   -- ROM definition
   constant colormap: rom_type:=(  -- 2^4-by-12
      x"000",
      x"a9b",
      x"b9b",
      x"b9b",
      x"b9b",
      x"c9b",
      x"c8b",
      x"c8b",
      x"d8b",
      x"d8b",
      x"d8b",
      x"d8b",
      x"d8b",
      x"d8b",
      x"d8c",
      x"d9c",
      x"d9c",
      x"d9c",
      x"d9c",
      x"d9c",
      x"d9c",
      x"dac",
      x"dac",
      x"dac",
      x"dad",
      x"cad",
      x"aad",
      x"9ad",
      x"7ad",
      x"6ad",
      x"f0c",
      x"e1c",
      x"e2b",
      x"d2b",
      x"d3a",
      x"c49",
      x"c49",
      x"b58",
      x"b68",
      x"a67",
      x"a76",
      x"976",
      x"985",
      x"895",
      x"894",
      x"7a3",
      x"7b3",
      x"6b2",
      x"6c2",
      x"5d1",
      x"4b2",
      x"4a3",
      x"384",
      x"275",
      x"156",
      x"147",
      x"137",
      x"236",
      x"336",
      x"435",
      x"525",
      x"524",
      x"624",
      x"723",
      x"813",
      x"912",
      x"912",
      x"a11",
      x"b01",
      x"c00",
      x"d00",
      x"c00",
      x"c00",
      x"c10",
      x"b10",
      x"b10",
      x"b20",
      x"a20",
      x"a21",
      x"a31",
      x"931",
      x"931",
      x"841",
      x"841",
      x"841",
      x"752",
      x"752",
      x"752",
      x"652",
      x"662",
      x"662",
      x"562",
      x"573",
      x"573",
      x"473",
      x"483",
      x"383",
      x"383",
      x"393",
      x"294",
      x"294",
      x"294",
      x"394",
      x"4a3",
      x"4a3",
      x"5a3",
      x"5a3",
      x"6a3",
      x"6a3",
      x"7a2",
      x"8a2",
      x"8a2",
      x"9b2",
      x"9b2",
      x"ab2",
      x"bb1",
      x"bb1",
      x"cb1",
      x"cb1",
      x"db1",
      x"db1",
      x"ec0",
      x"fc0",
      x"fc0",
      x"fb0",
      x"fb0",
      x"fa1",
      x"e91",
      x"e91",
      x"e81",
      x"e72",
      x"d72",
      x"d62",
      x"d52",
      x"d53",
      x"c43",
      x"c33",
      x"b43",
      x"b43",
      x"a53",
      x"a63",
      x"963",
      x"974",
      x"874",
      x"884",
      x"794",
      x"694",
      x"6a4",
      x"5a4",
      x"5b4",
      x"4c4",
      x"4c4",
      x"3d4",
      x"3d4",
      x"2e5",
      x"2f5",
      x"1f5",
      x"1f5",
      x"1e5",
      x"1e5",
      x"2d4",
      x"2d4",
      x"2c4",
      x"2c4",
      x"3b4",
      x"3a4",
      x"3a4",
      x"393",
      x"393",
      x"483",
      x"483",
      x"473",
      x"463",
      x"563",
      x"552",
      x"552",
      x"542",
      x"542",
      x"632",
      x"622",
      x"622",
      x"611",
      x"711",
      x"612",
      x"613",
      x"514",
      x"415",
      x"416",
      x"317",
      x"318",
      x"229",
      x"12a",
      x"12b",
      x"12b",
      x"12b",
      x"22b",
      x"22b",
      x"32b",
      x"32b",
      x"42b",
      x"42b",
      x"41b",
      x"51b",
      x"51b",
      x"61a",
      x"61a",
      x"71a",
      x"71a",
      x"81a",
      x"81a",
      x"91a",
      x"92a",
      x"a3a",
      x"a4a",
      x"b4b",
      x"b5b",
      x"c6b",
      x"c6b",
      x"d7b",
      x"d9e",
      x"77c",
      x"169",
      x"269",
      x"369",
      x"469",
      x"579",
      x"67a",
      x"77a",
      x"97a",
      x"a8a",
      x"b8a",
      x"c8a",
      x"d8a",
      x"d9b",
      x"dab",
      x"dac",
      x"dbc",
      x"dbc",
      x"dcd",
      x"ddd",
      x"dcd",
      x"ccc",
      x"cbb",
      x"bba",
      x"ba9",
      x"ba9",
      x"a98",
      x"a97",
      x"986",
      x"985",
      x"875",
      x"874",
      x"763",
      x"762",
      x"651",
      x"752"
	  );
   signal addr_reg: std_logic_vector(ADDR_WIDTH-1 downto 0);
begin
   -- addr register to infer block RAM
   process (clk)
   begin
      if (clk'event and clk = '1') then
        addr_reg <= addr;
      end if;
   end process;
   data <= colormap(to_integer(unsigned(addr_reg)));
end arch;