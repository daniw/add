-------------------------------------------------------------------------------
-- Entity: rom
-- Author: Waj
-- Date  : 11-May-13, 26-May-13
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 9)
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
    -- addr    Opcode     Rdest    Rsrc1    Rsrc2              description
    ---------------------------------------------------------------------------
         0  => OPC(ld)    & reg(4) & reg(0) & "---"  & "--",    -- r4 = *r0
         1  => OPC(ld)    & reg(5) & reg(1) & "---"  & "--",    -- r5 = *r1
         2  => OPC(ld)    & reg(6) & reg(2) & "---"  & "--",    -- r6 = *r2
         3  => OPC(ld)    & reg(7) & reg(3) & "---"  & "--",    -- r7 = *r3
         4  => OPC(add)   & reg(0) & reg(5) & reg(4) & "--",    -- r0 = r5 + r4
         5  => OPC(st)    & reg(0) & reg(1) & "---"  & "--",    -- *r1 = r0
         6  => OPC(sub)   & reg(0) & reg(5) & reg(4) & "--",    -- r0 = r5 - r4
         7  => OPC(st)    & reg(0) & reg(2) & "---"  & "--",    -- *r2 = r0
         8  => OPC(add)   & reg(0) & reg(7) & reg(6) & "--",    -- r0 = r7 + r6
         9  => OPC(st)    & reg(0) & reg(3) & "---"  & "--",    -- *r3 = r0
         10  => OPC(sub)   & reg(0) & reg(7) & reg(6) & "--",    -- r0 = r7 - r6
         11  => OPC(st)    & reg(0) & reg(0) & "---"  & "--",    -- *r0 = r0
         12  => OPC(ld)    & reg(4) & reg(1) & "---"  & "--",    -- r4 = *r1
         13  => OPC(ld)    & reg(5) & reg(2) & "---"  & "--",    -- r5 = *r2
         14  => OPC(ld)    & reg(6) & reg(3) & "---"  & "--",    -- r6 = *r3
         15  => OPC(ld)    & reg(7) & reg(0) & "---"  & "--",    -- r7 = *r0
         others    => (others => '1')
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
