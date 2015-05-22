library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity tb_mcu is
end tb_mcu;

architecture TB of tb_mcu is

  signal rst    : std_logic;
  signal clk    : std_logic := '0';
  signal LED : std_logic_vector(7 downto 0);
  signal SW : std_logic_vector(3 downto 0);
  signal ROT_C : std_logic;
  signal BTN_EAST : std_logic;
  signal BTN_WEST : std_logic;
  signal BTN_NORTH : std_logic;
  signal LCD    : std_logic_vector(LCD_PW-1 downto 0);

  signal step_to_floppy : std_logic;
  signal dir_to_floppy  : std_logic;
   
begin

  -- instantiate MUT
  MUT : entity work.mcu
    port map(
      rst    => rst,
      clk    => clk,
      LED => LED,
      SW => SW,
      ROT_C => ROT_C,
      BTN_EAST => BTN_EAST,
		BTN_WEST => BTN_WEST,
		BTN_NORTH => BTN_NORTH,
      LCD    => LCD,
      step_to_floppy => step_to_floppy,
      dir_to_floppy  => dir_to_floppy
      );

  -- generate reset
  rst   <= '1', '0' after 5us;
  ROT_C <= '1', '0' after 1ms;
  SW <= "0011";
  BTN_EAST <= '0';
  BTN_WEST <= '0';
  BTN_NORTH <= '0';

  -- clock generation
  p_clk: process
  begin
    wait for 1 sec / CF/2;
    clk <= not clk;
  end process;
 
end TB;
