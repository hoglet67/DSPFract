library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity core_mem_interface is
    Port ( clk_core : in  STD_LOGIC;
           -- Write interface
           x_in : in  STD_LOGIC_VECTOR (9 downto 0);
           y_in : in  STD_LOGIC_VECTOR (9 downto 0);
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           write_data : in  STD_LOGIC;
           fifo_full : out  STD_LOGIC;
           
           -- Read interface
           clk_mem : in  STD_LOGIC;
           address_out : out  STD_LOGIC_VECTOR (18 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0);
           fifo_empty : out  STD_LOGIC;
           read_data : in  STD_LOGIC);
end core_mem_interface;

architecture Behavioral of core_mem_interface is
   COMPONENT core_mem_fifo
   PORT (
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
      full : OUT STD_LOGIC;
      prog_full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC
   );
   END COMPONENT;

   signal din   : std_logic_vector(27 downto 0);
   signal dout  : std_logic_vector(27 downto 0);
   signal x_out : std_logic_vector(9 downto 0);
   signal y_out   : std_logic_vector(9 downto 0);
begin

  din( 9 downto  0) <= x_in;
  din(19 downto 10) <= y_in;
  din(27 downto 20) <= data_in;

  x_out    <= dout( 9 downto  0);
  y_out    <= dout(19 downto 10);
  data_out <= dout(27 downto 20);

  address_out <= (y_out & "000000000")  -- * 512
               + (y_out & "00000000")   -- * 256
               + (y_out & "00000")      -- *  32
               + (y_out & "0000")       -- *  16
               + (y_out & "000")        -- *   8
               + (y_out & "00")         -- *   4
               + x_out;                 ---= 828

fifo_calc_mem : core_mem_fifo
   PORT MAP (
      wr_clk      => clk_core,
      rd_clk      => clk_mem,
      din         => din,
      wr_en       => write_data,
      rd_en       => read_data,
      dout        => dout,
      full        => open,
      prog_full   => fifo_full,
      empty       => fifo_empty
   );

end Behavioral;
