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
       -- General-Purpose I/O ports
       GPIO_0 : inout std_logic_vector(DW-1 downto 0);
       GPIO_1 : inout std_logic_vector(DW-1 downto 0);
       GPIO_2 : inout std_logic_vector(DW-1 downto 0);
       GPIO_3 : inout std_logic_vector(DW-1 downto 0);
       -- Dedicated LCD port
       LCD    : out   std_logic_vector(LCD_PW-1 downto 0)
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
  signal bus2gpio : t_bus2rws;
  signal gpio2bus : t_rws2bus;
  signal gpio_in  : t_gpio_pin_in;
  signal gpio_out : t_gpio_pin_out;
  -- LCD signals
  signal bus2lcd : t_bus2rws;
  signal lcd2bus : t_rws2bus;
  signal lcd_out : std_logic_vector(LCD_PW-1 downto 0);

begin

  -----------------------------------------------------------------------------
  -- Tri-state buffers for GPIO pins
  -----------------------------------------------------------------------------
  gpio_in.in_0 <= GPIO_0;
  gpio_in.in_1 <= GPIO_1;
  gpio_in.in_2 <= GPIO_2;
  gpio_in.in_3 <= GPIO_3;
  gen_gpin: for k in 0 to DW-1 generate
    GPIO_0(k) <= gpio_out.out_0(k) when gpio_out.enb_0(k) = '1' else 'Z';
    GPIO_1(k) <= gpio_out.out_1(k) when gpio_out.enb_1(k) = '1' else 'Z';
    GPIO_2(k) <= gpio_out.out_2(k) when gpio_out.enb_2(k) = '1' else 'Z';
    GPIO_3(k) <= gpio_out.out_3(k) when gpio_out.enb_3(k) = '1' else 'Z';
  end generate;

  -----------------------------------------------------------------------------
  -- LCD interface pins
  -----------------------------------------------------------------------------
  LCD <= lcd_out;
 
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
      gpio_out => bus2gpio,
      lcd_in   => lcd2bus,
      lcd_out  => bus2lcd
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
      rst     => rst,
      clk     => clk,
      bus_in  => bus2gpio,
      bus_out => gpio2bus,
      pin_in  => gpio_in,
      pin_out => gpio_out
    );
  
  -- LCD ----------------------------------------------------------------------
  i_lcd: entity work.lcd
    port map(
      rst     => rst,
      clk     => clk,
      bus_in  => bus2lcd,
      bus_out => lcd2bus,
      lcd_out => lcd_out
    );
  
end rtl;
