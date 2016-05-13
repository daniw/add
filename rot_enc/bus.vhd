-------------------------------------------------------------------------------
-- Entity: ram
-- Author: Waj
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 9)
-- Data/address/control bus for simple von-Neumann MCU.
-- The bus master (CPU) can read/write in every cycle. The bus slaves are
-- assumed to have registerd read data output with an address-in to data-out
-- latency of 1 cc. The read data muxing from bus slaves to the bus master is
-- done combinationally. Thus, at the bus master interface, there results a
-- read data latency of 1 cc.
-------------------------------------------------------------------------------
-- Note on code portability:
-------------------------------------------------------------------------------
-- The address decoding logic as implemented in process P_dec below, shows how
-- to write portable code by means of a user-defined enumaration type which is
-- used as the index range for a constant array, see mcu_pkg. This allows to
-- leave the local code (in process P_dec) unchanged when the number and/or
-- base addresses of the bus slaves in the system change. Such changes then
-- need only to be made in the global definition package.
-- To generate such portable code for the rest of the functionality (e.g. for
-- the read data mux) would require to organize all data input vectors in a
-- signal array first. This would destroy the portability of the code, since it
-- requires manual code adaption when design parameter change. 
-------------------------------------------------------------------------------
-- Total # of FFs: 3
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity buss is
  port(rst     : in    std_logic;
       clk     : in    std_logic;
       -- CPU bus signals
       cpu_in  : in  t_cpu2bus;
       cpu_out : out t_bus2cpu;
       -- ROM bus signals
       rom_in  : in  t_ros2bus;
       rom_out : out t_bus2ros;
       -- RAM bus signals
       ram_in  : in  t_rws2bus;
       ram_out : out t_bus2rws;
       -- GPIO bus signals
       gpio_in  : in  t_rws2bus;
       gpio_out : out t_bus2rws
       );
end buss;

architecture rtl of buss is 

  -- currently addressed bus slave
  signal bus_slave, bus_slave_reg : t_bus_slave;
  
begin

  -----------------------------------------------------------------------------
  -- address decoding
  -----------------------------------------------------------------------------
  -- convey lower address bist from CPU to all bus slaves
  rom_out.addr  <= cpu_in.addr(AWL-1 downto 0);
  ram_out.addr  <= cpu_in.addr(AWL-1 downto 0);
  gpio_out.addr <= cpu_in.addr(AWL-1 downto 0);
  -- combinational process:
  -- determine addressed slave by decoding higher address bits
  -----------------------------------------------------------------------------
  P_dec: process(cpu_in)
  begin
    bus_slave <= ROM; -- default assignment
    for k in t_bus_slave loop
      if cpu_in.addr(AW-1 downto AW-AWH) = HBA(k) then
        bus_slave <= k;
      end if;
    end loop;
  end process;

  -----------------------------------------------------------------------------
  -- write transfer logic
  -----------------------------------------------------------------------------
  -- convey write data from CPU to all bus slaves 
  -- rom is read-only slave
  ram_out.data  <= cpu_in.data;
  gpio_out.data <= cpu_in.data;
  -- convey write enable from CPU to addressed slave only
  ram_out.wr_enb  <= cpu_in.wr_enb when bus_slave = RAM  else '0';
  gpio_out.wr_enb <= cpu_in.wr_enb when bus_slave = GPIO else '0';
 
  -----------------------------------------------------------------------------
  -- read transfer logic
  -----------------------------------------------------------------------------
  -- read data mux
  with bus_slave_reg select cpu_out.data <= rom_in.data      when ROM,
                                            ram_in.data      when RAM,
                                            gpio_in.data     when GPIO,
                                            (others => '-')  when others;
  -- convey read enable from CPU to addressed slave only
  ram_out.rd_enb  <= cpu_in.rd_enb when bus_slave = RAM  else '0';
  gpio_out.rd_enb <= cpu_in.rd_enb when bus_slave = GPIO else '0';
  -- sequential process:
  -- register decode information to compensate read-latency of slaves
  -----------------------------------------------------------------------------  
  P_reg: process(rst, clk)
  begin
    if rst = '1' then
       bus_slave_reg <= ROM;
    elsif rising_edge(clk) then
       bus_slave_reg <= bus_slave;
    end if;
  end process;
  
end rtl;
