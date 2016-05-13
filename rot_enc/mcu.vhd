-------------------------------------------------------------------------------
-- Entity: mcu
-- Author: Waj
-- Date  : 11-May-13
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 9)
-- Top-level description of a simple von-Neumann MCU.
-- All top-level component are instantiated here. Also, tri-state buffers for
-- bi-directional GPIO pins are described here.
-------------------------------------------------------------------------------
-- Total # of FFs: 0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity mcu is
  port(rst     : in    std_logic;
       clk     : in    std_logic;
       -- LED(8:0) on S3E-Board (demonstrate tri-state buffers)
       LED     : inout std_logic_vector(7 downto 0);
       -- SW(3:0) on S3E-Board
       Switch  : in std_logic_vector(3 downto 0)
       );
end mcu;

architecture rtl of mcu is

  -- CPU signals
  signal cpu2bus : t_cpu2bus;
  signal bus2cpu : t_bus2cpu;
  -- ROM signals
  signal bus2rom : t_bus2ros;
  signal rom2bus : t_ros2bus;
  -- ROM signals
  signal bus2ram : t_bus2rws;
  signal ram2bus : t_rws2bus;
  -- GPIO signals
  signal bus2gpio     : t_bus2rws;
  signal gpio2bus     : t_rws2bus;
  signal gpio_in      : std_logic_vector(DW-1 downto 0);
  signal gpio_out     : std_logic_vector(DW-1 downto 0);
  signal gpio_out_enb : std_logic_vector(DW-1 downto 0);

begin

  -----------------------------------------------------------------------------
  -- Connect GPIO(7:0) to LED(7:0)
  -- Demonstrates the usage of tri-state buffers although this not required for
  -- LED functionality.
  -----------------------------------------------------------------------------
  gpio_in(7 downto 0) <= LED;
  gen_led_3state: for k in 0 to 7 generate
    LED(k) <= gpio_out(k) when gpio_out_enb(k) = '1' else 'Z';
  end generate;

  -----------------------------------------------------------------------------
  -- Connect SW(3:0) to GPIO(11:8)
  -- NOTE: GPIO(11:8) is only connected as input, since the SITE TYPE of the 4
  --       Switch pins is IBUF, which prevents the usage of tri-state IOBs.
  --       Furthermore, even if IOBs were available, it would be dangerous to
  --       use them here, since a wrong SW configuration could then cause
  --       driver conflicts on these pins!!
  -----------------------------------------------------------------------------
  gpio_in(11 downto 8) <= Switch;
  -- gen_sw_3state: for k in 8 to 11 generate
  --   SW(k-8) <= gpio_out(k) when gpio_out_enb(k) = '1' else 'Z';
  -- end generate;
 
  -----------------------------------------------------------------------------
  -- Instantiation of top-level components (assumed to be in library work)
  -----------------------------------------------------------------------------
  -- CPU ----------------------------------------------------------------------
  i_cpu: entity work.cpu
    port map(
      rst     => rst,
      clk     => clk,
      bus_in  => bus2cpu,
      bus_out => cpu2bus
    );

  -- BUS ----------------------------------------------------------------------
  i_bus: entity work.buss
    port map(
      rst      => rst,
      clk      => clk,
      cpu_in   => cpu2bus,
      cpu_out  => bus2cpu,
      rom_in   => rom2bus,
      rom_out  => bus2rom,
      ram_in   => ram2bus,
      ram_out  => bus2ram,
      gpio_in  => gpio2bus,
      gpio_out => bus2gpio
    );

  -- ROM ----------------------------------------------------------------------
  i_rom: entity work.rom
    port map(
      clk     => clk,
      bus_in  => bus2rom,
      bus_out => rom2bus
    );

  -- RAM ----------------------------------------------------------------------
  i_ram: entity work.ram
    port map(
      clk     => clk,
      bus_in  => bus2ram,
      bus_out => ram2bus
    );
  
  -- GPIO ---------------------------------------------------------------------
  i_gpio: entity work.gpio
    port map(
      rst          => rst,
      clk          => clk,
      bus_in       => bus2gpio,
      bus_out      => gpio2bus,
      gpio_in      => gpio_in,
      gpio_out     => gpio_out,
      gpio_out_enb => gpio_out_enb
    );
    
end rtl;
