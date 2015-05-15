-------------------------------------------------------------------------------
-- Entity: rom
-- Author: Waj
-- Date  : 11-May-13, 26-May-13
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
         -- auto generated by asmtovhd from testFloppy.asm
      0 => OPC(setil)   & reg(0) & std_logic_vector(to_unsigned(16#84#,DW/2)),            -- 
      1 => OPC(setil)   & reg(1) & std_logic_vector(to_unsigned(0,DW/2)),            -- 
      2 => OPC(ld)      & reg(3) & reg(0) & "---"  & "--",            -- 
      3 => OPC(add)     & reg(3) & reg(3) & reg(1) & "--",            -- 
      4 => OPC(bne)     & "---"  & std_logic_vector(to_unsigned(16#02#,DW/2)),            -- 
      5 => OPC(setil)   & reg(0) & std_logic_vector(to_unsigned(16#86#,DW/2)),            -- 
      6 => OPC(setil)   & reg(1) & std_logic_vector(to_unsigned(69,DW/2)),            -- 
      7 => OPC(st)      & reg(1) & reg(0) & "---"  & "--",            -- 
      8 => OPC(setil)   & reg(0) & std_logic_vector(to_unsigned(16#82#,DW/2)),            -- 
      9 => OPC(setil)   & reg(1) & std_logic_vector(to_unsigned(16#FF#,DW/2)),            -- 
      10 => OPC(st)      & reg(1) & reg(0) & "---"  & "--",            -- 
      11 => OPC(jmp)     & "---"  & std_logic_vector(to_unsigned(11,DW/2)),            -- 
      12 => OPC(nop)     & "---"  & "---"  & "---"  & "--",            -- 
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
