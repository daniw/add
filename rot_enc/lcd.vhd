-------------------------------------------------------------------------------
-- Entity: lcd
-- Author: Waj
-- Date  : 11-May-13
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 9)
-- LCD controller with bus interface and 4-bit data interface.
-------------------------------------------------------------------------------
-- Total # of FFs: ... tbd ...
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity lcd is
  port(rst     : in    std_logic;
       clk     : in    std_logic;
       -- LCD bus signals
       bus_in  : in  t_bus2rws;
       bus_out : out t_rws2bus;
       -- LCD control/data interface
       lcd_out : out std_logic_vector(LCD_PW-1 downto 0)
       );
end lcd;

architecture rtl of lcd is
  
begin
  
  -----------------------------------------------------------------------------
  -- sequential process: DUMMY to avoid logic optimization
  -- To be replaced.....
  -- # of FFs: ......
  -----------------------------------------------------------------------------  
  P_dummy: process(rst, clk)
  begin
    if rst = '1' then
      lcd_out <= (others => '0');
    elsif rising_edge(clk) then
      if bus_in.wr_enb = '1' then
        if unsigned(bus_in.addr) > 0 then
          bus_out.data <= bus_in.data;
          lcd_out <= bus_in.addr &  bus_in.data(3);
        end if;
      end if;
    end if;
  end process;
  
end rtl;
