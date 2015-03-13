-------------------------------------------------------------------------------
-- Entity: rom
-- Author: Waj
-------------------------------------------------------------------------------
-- Description:
-- Program memory for simple von-Neumann MCU with registerd read data output.
-------------------------------------------------------------------------------
-- Total # of FFs: DW
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity rom is
  port(clk     : in    std_logic;
       -- ROM bus signals
       bus_in  : in  t_bus2ros;
       bus_out : out t_ros2bus
       );
end rom;

architecture rtl of rom is

  type t_rom is array (0 to 2**AWL-1) of std_logic_vector(DW-1 downto 0);
  constant rom_table : t_rom := (
    ---------------------------------------------------------------------------
    -- program code -----------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Opcode     Rdest    Rsrc1    Rsrc2                 description
    ---------------------------------------------------------------------------
       -- const A = 0xF001;
       -- const B = 0xF000; // sign(A) = sign(B)
       -- int x,y,z = 0;
       -- while(sign(z) == sign(x)){
       --    x += A;   // accumulate A
       --    y += B;   // accumulate B 
       --    z = x+y;  // N*(A+B)
       -- }
       --
       --
       -- set constant register values ---------------------------------------
       -- RAM address of variable x hold in reg0
16#00# => OPC(setil)& reg(0) & std_logic_vector(to_unsigned(16#40#,DW/2)), 
       -- RAM address of variable y hold in reg1
16#01# => OPC(setil)& reg(1) & std_logic_vector(to_unsigned(16#41#,DW/2)), 
       -- RAM address of variable z hold in reg2
16#02# => OPC(setil)& reg(2) & std_logic_vector(to_unsigned(16#42#,DW/2)),   
       -- const A (0xF001) hold in reg6 (or load from ROM)
16#03# => OPC(setil)& reg(6) & std_logic_vector(to_unsigned(16#01#,DW/2)),
16#04# => OPC(setih)& reg(6) & std_logic_vector(to_unsigned(16#F0#,DW/2)),
       -- const B (oxF000) hold in reg7 (or load from ROM)
16#05# => OPC(setil)& reg(7) & std_logic_vector(to_unsigned(16#00#,DW/2)),
16#06# => OPC(setih)& reg(7) & std_logic_vector(to_unsigned(16#F0#,DW/2)),
       -- while loop starts here --------------------------------------------
       --
       --
       -- ..... ToDo ..........
       --
       --
       -- while loop ends here -----------------------------------------------
       -- fill remaining addresses with NOP
others => (others => '1')                        
       );
  
begin

  -----------------------------------------------------------------------------
  -- sequential process: ROM table with registerd output
  -----------------------------------------------------------------------------  
  P_rom: process(clk)
  begin
    if rising_edge(clk) then
      bus_out.data <= rom_table(to_integer(unsigned(bus_in.addr)));
    end if;
  end process;
  
end rtl;
