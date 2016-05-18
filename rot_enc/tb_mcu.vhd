library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity tb_mcu is
end tb_mcu;

architecture TB of tb_mcu is

  signal rst          : std_logic;
  signal clk          : std_logic := '0';
  signal Switch       : std_logic_vector(3 downto 0);
  signal LED          : std_logic_vector(7 downto 0);
  signal ROT_A        : std_logic;
  signal ROT_B        : std_logic;
  signal ROT_CENTER   : std_logic;
   
begin

  -- instantiate MUT
  MUT : entity work.mcu
    port map(
      rst        => rst,
      clk        => clk,
      LED        => LED,
      Switch     => Switch,
      ROT_A      => ROT_A,
      ROT_B      => ROT_B,
      ROT_CENTER => ROT_CENTER
      );

  -- generate reset
  rst   <= '1', '0' after 5us;

  -- clock generation
  p_clk: process
  begin
    wait for 1 sec / CF/2;
    clk <= not clk;
  end process;

  -- encoder signal generation
  p_encoder: process
  begin
    ROT_A <= '0';
    ROT_B <= '0';
    wait for 1 sec / CF/2 * 5;
    ROT_A <= '0';
    ROT_B <= '1';
    wait for 1 sec / CF/2 * 5;
    ROT_A <= '1';
    ROT_B <= '1';
    wait for 1 sec / CF/2 * 5;
    ROT_A <= '1';
    ROT_B <= '0';
    wait for 1 sec / CF/2 * 5;
  end process;
 
end TB;
