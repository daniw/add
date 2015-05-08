-------------------------------------------------------------------------------
-- Entity: ram
-- Author: Waj
-- Date  : 11-May-13
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 9)
-- GPIO block for simple von-Neumann MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: ... tbd ...
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity gpio is
  port(rst     : in    std_logic;
       clk     : in    std_logic;
       -- GPIO bus signals
       bus_in  : in  t_bus2rws;
       bus_out : out t_rws2bus;
       -- GPIO pin signals
       pin_in  : in  t_gpio_pin_in;
       pin_out : out t_gpio_pin_out
       );
end gpio;

architecture rtl of gpio is
  
  
begin

  -----------------------------------------------------------------------------
  -- sequential process: DUMMY to avoid logic optimization
  -- To be replaced.....
  -- # of FFs: ......
  -----------------------------------------------------------------------------  
  P_dummy: process(rst, clk)
  begin
    if rst = '1' then
      bus_out.data <= (others => '0');
    elsif rising_edge(clk) then
      if bus_in.we = '1' then
        if unsigned(bus_in.addr) > 0 then
          bus_out.data <= bus_in.data;
          pin_out.out_0 <= pin_in.in_0;
          pin_out.out_1 <= pin_in.in_1;
          pin_out.out_2 <= pin_in.in_2;
          pin_out.out_3 <= pin_in.in_3;
          pin_out.enb_0 <= pin_in.in_3 and pin_in.in_0;
          pin_out.enb_1 <= pin_in.in_0 and pin_in.in_1;
          pin_out.enb_2 <= pin_in.in_1 and pin_in.in_2;
          pin_out.enb_3 <= pin_in.in_2 and pin_in.in_3;
        end if;
      end if;
    end if;
  end process;

end rtl;
