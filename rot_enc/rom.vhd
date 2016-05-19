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
    -- Opcode    Rdest    Rsrc1    Rsrc2               description
    ---------------------------------------------------------------------------
    -- Prepare Ctrl to set capture flag
    OPC(setil) & reg(0) & n2slv(16#01#, DW/2),         -- setil r0, 0x01
    OPC(setih) & reg(0) & n2slv(16#00#, DW/2),         -- setih r0, 0x00
    -- Prepare ctrl address
    OPC(setil) & reg(1) & n2slv(16#03#, DW/2),         -- setil r1, 0x03
    OPC(setih) & reg(1) & n2slv(16#03#, DW/2),         -- setih r1, 0x30
    -- Prepare counter address
    OPC(setil) & reg(2) & n2slv(16#04#, DW/2),         -- setil r2, 0x04
    OPC(setih) & reg(2) & n2slv(16#03#, DW/2),         -- setih r2, 0x30
    -- Endless loop
        -- set capture flag
        OPC(st)    & reg(0) & reg(1) & "-----",            -- st r0, r1
        -- read counter
        OPC(ld)    & reg(3) & reg(2) & "-----",            -- st r4, r2
    -- End of endless loop
    OPC(jmp)   & "-00" & n2slv(16#06#, AW-2),             -- jmp 0x006
    ---------------------------------------------------------------------------
    others => OPC(nop)  & "-----------"                   -- NOP
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
