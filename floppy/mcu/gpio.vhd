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
       -- pin_in  : in  t_gpio_pin_in;
       -- pin_out : out t_gpio_pin_out;
		 -- LED, Switches and Buttons
		 to_LED : out std_logic_vector(7 downto 0);
		 from_SW : in std_logic_vector(3 downto 0);
		 from_BTN_ROT_C : in std_logic;
		 from_BTN_EAST : in std_logic;
		 from_BTN_WEST : in std_logic;
		 from_BTN_NORTH : in std_logic
       );
end gpio;

architecture rtl of gpio is
  
		signal in_1, in_2 : std_logic_vector(7 downto 0);
		signal next_out, current_out : std_logic_vector(7 downto 0);
		
		
begin

  -----------------------------------------------------------------------------
  -- sequential process: DUMMY to avoid logic optimization
  -- To be replaced.....
  -- # of FFs: ......
  -----------------------------------------------------------------------------  
--  to_LED(7 downto 4) <= from_SW;
--  to_LED(3) <= from_BTN_ROT_C;
--  to_LED(2) <= from_BTN_EAST;
--  to_LED(1) <= from_BTN_WEST;
--  to_LED(7) <= from_BTN_NORTH;
  
  

  
  P_synch : process(rst,clk)
  begin
	  if rst = '1' then
			in_1 <= (others => '0');
			in_2 <= (others => '0');
		elsif rising_edge(clk) then
			in_1(3 downto 0) <= from_SW;
			in_1(4) <= from_BTN_EAST;
			in_1(5) <= from_BTN_NORTH;
			in_1(6) <= from_BTN_WEST;
			in_1(7) <= from_BTN_ROT_C;
			in_2 <= in_1;
		end if;
	end process;
	
	to_LED <= current_out;
	current_out <= next_out;
	
--	P_outsave : process(rst, clk)
--	begin
--		if rst = '1' then
--			current_out <= (others => '0');
--		elsif rising_edge(clk) then
--			current_out <= next_out; 
--		end if;
--	end process;
	
  
  P_busaccess : process(rst, clk)
  begin
    if rst = '1' then
      bus_out.data <= (others => '0');
    elsif rising_edge(clk) then
		next_out <= current_out;
		bus_out.data(7 downto 0) <= in_2;
		bus_out.data(15 downto 8) <= (others => '0');
      if bus_in.we = '1' then -- write to register
        if unsigned(bus_in.addr) = to_unsigned(16#01#,AWL) then
				next_out <= bus_in.data(7 downto 0);--<= "01010111";
        end if;
		  
      end if;
    end if;
  end process;

end rtl;
