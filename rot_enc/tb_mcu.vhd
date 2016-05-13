library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity tb_mcu is
end tb_mcu;

architecture TB of tb_mcu is

  signal rst    : std_logic;
  signal clk    : std_logic := '0';
  signal Switch : std_logic_vector(3 downto 0);
  signal LED    : std_logic_vector(7 downto 0);
   
begin

  -- instantiate MUT
  MUT : entity work.mcu
    port map(
      rst    => rst,
      clk    => clk,
      LED    => LED,
      Switch => Switch
      );

  -- generate reset
  rst   <= '1', '0' after 5us;

  -- clock generation
  p_clk: process
  begin
    wait for 1 sec / CF/2;
    clk <= not clk;
  end process;
 
end TB;
