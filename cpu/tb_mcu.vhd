library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity tb_mcu is
end tb_mcu;

architecture TB of tb_mcu is

  signal rst    : std_logic;
  signal clk    : std_logic := '0';
  signal GPIO_0 : std_logic_vector(DW-1 downto 0);
  signal GPIO_1 : std_logic_vector(DW-1 downto 0);
  signal GPIO_2 : std_logic_vector(DW-1 downto 0);
  signal GPIO_3 : std_logic_vector(DW-1 downto 0);
  signal LCD    : std_logic_vector(LCD_PW-1 downto 0);
   
begin

  -- instantiate MUT
  MUT : entity work.mcu
    port map(
      rst    => rst,
      clk    => clk,
      GPIO_0 => GPIO_0,
      GPIO_1 => GPIO_1,
      GPIO_2 => GPIO_2,
      GPIO_3 => GPIO_3,
      LCD    => LCD
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
