-------------------------------------------------------------------------------
-- Entity: ram
-- Author: Waj
-- Date  : 11-May-13
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 9)
-- Data memory for simple von-Neumann MCU with registered read data output.
-------------------------------------------------------------------------------
-- Total # of FFs: (2**AW)*DW + DW (or equivalent BRAM/distr. memory)
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity ram is
  port(clk     : in    std_logic;
       -- RAM bus signals
       bus_in  : in  t_bus2rws;
       bus_out : out t_rws2bus
       );
end ram;

architecture rtl of ram is

  type t_ram is array (0 to 2**AWL-1) of std_logic_vector(DW-1 downto 0);
  signal ram_array : t_ram := (
                     -- prelimenary RAM initialization
                     0      => std_logic_vector(to_unsigned(16#00_FF#, DW)),
                     1      => std_logic_vector(to_unsigned(16#FF_01#, DW)),
                     2      => std_logic_vector(to_unsigned(16#7F_FF#, DW)),
                     3      => std_logic_vector(to_unsigned(16#7F_FE#, DW)),
                     others => (others => '0'));
  
begin

  -----------------------------------------------------------------------------
  -- sequential process: RAM (read before write)
  ----------------------------------------------------------------------------- 
  P_ram: process(clk)
  begin
    if rising_edge(clk) then
      if bus_in.wr_enb = '1' then
        ram_array(to_integer(unsigned(bus_in.addr))) <= bus_in.data;
      end if;
      bus_out.data <= ram_array(to_integer(unsigned(bus_in.addr)));
    end if;
  end process;
  
end rtl;

