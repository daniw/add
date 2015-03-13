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
         0  => OPC(setil) & reg(0) & "01000000",                -- r0 = r0 + "01000000"
         1  => OPC(setil) & reg(1) & "01000001",                -- r1 = r1 + "01000001"
         2  => OPC(setil) & reg(2) & "01000010",                -- r2 = r2 + "01000010"
         3  => OPC(setil) & reg(6) & "00000001",                -- r6 = r6 + "00000001"
         4  => OPC(setih) & reg(6) & "11110000",                -- r6 = r6 + "11110000"
         5  => OPC(setil) & reg(7) & "00000000",                -- r7 = r7 + "00000000"
         6  => OPC(setih) & reg(7) & "11110000",                -- r7 = r7 + "11110000"
         7  => OPC(ld)    & reg(3) & reg(0) & "---"  & "--",    -- r3 = *r0
         8  => OPC(add)   & reg(3) & reg(3) & reg(6) & "--",    -- r3 = r3 + r6
         9  => OPC(st)    & reg(3) & reg(0) & "---"  & "--",    -- *r0 = r3
         10  => OPC(ld)    & reg(4) & reg(1) & "---"  & "--",    -- r4 = *r1
         11  => OPC(add)   & reg(4) & reg(4) & reg(7) & "--",    -- r4 = r4 + r7
         12  => OPC(st)    & reg(4) & reg(1) & "---"  & "--",    -- *r1 = r4
         13  => OPC(add)   & reg(5) & reg(3) & reg(4) & "--",    -- r5 = r3 + r4
         14  => OPC(st)    & reg(5) & reg(2) & "---"  & "--",    -- *r2 = r5
         15  => OPC(bov)   & "---"  & "00000010",                -- bov "00000010"
         16  => OPC(jmp)   & "---"  & "00000111",                -- jmp "00000111"
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
