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
         -- auto generated by asmtovhd from floppy.asm
      0 => OPC(setih)   & reg(0) & std_logic_vector(to_unsigned(0,DW/2)),            -- 
      1 => OPC(setih)   & reg(1) & std_logic_vector(to_unsigned(0,DW/2)),            -- 
      2 => OPC(setih)   & reg(2) & std_logic_vector(to_unsigned(0,DW/2)),            -- 
      3 => OPC(setih)   & reg(3) & std_logic_vector(to_unsigned(0,DW/2)),            -- 
      4 => OPC(setih)   & reg(4) & std_logic_vector(to_unsigned(16#FF#,DW/2)),            -- 
      5 => OPC(setil)   & reg(4) & std_logic_vector(to_unsigned(16#FF#,DW/2)),            -- 
      6 => OPC(setih)   & reg(5) & std_logic_vector(to_unsigned(0,DW/2)),            -- 
      7 => OPC(setih)   & reg(6) & std_logic_vector(to_unsigned(0,DW/2)),            -- 
      8 => OPC(setih)   & reg(7) & std_logic_vector(to_unsigned(0,DW/2)),            -- 
      9 => OPC(setil)   & reg(0) & std_logic_vector(to_unsigned(16#84#,DW/2)),            -- 
      10 => OPC(ld)      & reg(1) & reg(0) & "---"  & "--",            -- 
      11 => OPC(add)     & reg(1) & reg(1) & reg(3) & "--",            -- 
      12 => OPC(bne)     & "---"  & std_logic_vector(to_signed(-3,DW/2)),            -- 
      13 => OPC(setil)   & reg(2) & std_logic_vector(to_unsigned(16#86#,DW/2)),            -- 
      14 => OPC(setil)   & reg(0) & std_logic_vector(to_unsigned(69,DW/2)),            -- 
      15 => OPC(st)      & reg(0) & reg(2) & "---"  & "--",            -- 
      16 => OPC(add)     & reg(6) & reg(5) & reg(3) & "--",            -- 
      17 => OPC(setil)   & reg(0) & std_logic_vector(to_unsigned(16#80#,DW/2)),            -- 
      18 => OPC(ld)      & reg(5) & reg(0) & "---"  & "--",            -- 
      19 => OPC(add)     & reg(0) & reg(3) & reg(4) & "--",            -- 
      20 => OPC(add)     & reg(1) & reg(3) & reg(3) & "--",            -- 
      21 => OPC(setil)   & reg(1) & std_logic_vector(to_unsigned(1,DW/2)),            -- 
      22 => OPC(andi)    & reg(1) & reg(1) & reg(5) & "--",            -- 
      23 => OPC(bne)     & "---"  & std_logic_vector(to_signed(+2,DW/2)),            -- 
      24 => OPC(add)     & reg(0) & reg(3) & reg(3) & "--",            -- 
      25 => OPC(setil)   & reg(2) & std_logic_vector(to_unsigned(16#82#,DW/2)),            -- 
      26 => OPC(st)      & reg(0) & reg(2) & "---"  & "--",            -- 
      27 => OPC(add)     & reg(0) & reg(3) & reg(4) & "--",            -- 
      28 => OPC(add)     & reg(1) & reg(3) & reg(3) & "--",            -- 
      29 => OPC(setil)   & reg(1) & std_logic_vector(to_unsigned(2,DW/2)),            -- 
      30 => OPC(andi)    & reg(1) & reg(1) & reg(5) & "--",            -- 
      31 => OPC(bne)     & "---"  & std_logic_vector(to_signed(+2,DW/2)),            -- 
      32 => OPC(add)     & reg(0) & reg(3) & reg(3) & "--",            -- 
      33 => OPC(setil)   & reg(2) & std_logic_vector(to_unsigned(16#83#,DW/2)),            -- 
      34 => OPC(st)      & reg(0) & reg(2) & "---"  & "--",            -- 
      35 => OPC(xori)    & reg(0) & reg(6) & reg(4) & "--",            -- 
      36 => OPC(andi)    & reg(0) & reg(0) & reg(5) & "--",            -- 
      37 => OPC(add)     & reg(1) & reg(3) & reg(3) & "--",            -- 
      38 => OPC(setil)   & reg(1) & std_logic_vector(to_unsigned(16#10#,DW/2)),            -- 
      39 => OPC(andi)    & reg(0) & reg(0) & reg(1) & "--",            -- 
      40 => OPC(xori)    & reg(0) & reg(0) & reg(1) & "--",            -- 
      41 => OPC(bne)     & "---"  & std_logic_vector(to_signed(+6,DW/2)),            -- 
      42 => OPC(add)     & reg(2) & reg(3) & reg(3) & "--",            -- 
      43 => OPC(setil)   & reg(2) & std_logic_vector(to_unsigned(16#86#,DW/2)),            -- 
      44 => OPC(ld)      & reg(0) & reg(2) & "---"  & "--",            -- 
      45 => OPC(addil)   & reg(0) & std_logic_vector(to_unsigned(1,DW/2)),            -- 
      46 => OPC(st)      & reg(0) & reg(2) & "---"  & "--",            -- 
      47 => OPC(xori)    & reg(0) & reg(6) & reg(4) & "--",            -- 
      48 => OPC(andi)    & reg(0) & reg(0) & reg(5) & "--",            -- 
      49 => OPC(add)     & reg(1) & reg(3) & reg(3) & "--",            -- 
      50 => OPC(setil)   & reg(1) & std_logic_vector(to_unsigned(16#20#,DW/2)),            -- 
      51 => OPC(andi)    & reg(0) & reg(0) & reg(1) & "--",            -- 
      52 => OPC(xori)    & reg(0) & reg(0) & reg(1) & "--",            -- 
      53 => OPC(bne)     & "---"  & std_logic_vector(to_signed(+6,DW/2)),            -- 
      54 => OPC(add)     & reg(2) & reg(3) & reg(3) & "--",            -- 
      55 => OPC(setil)   & reg(2) & std_logic_vector(to_unsigned(16#86#,DW/2)),            -- 
      56 => OPC(ld)      & reg(0) & reg(2) & "---"  & "--",            -- 
      57 => OPC(addil)   & reg(0) & std_logic_vector(to_signed(-1,DW/2)),            -- 
      58 => OPC(st)      & reg(0) & reg(2) & "---"  & "--",            -- 
      59 => OPC(add)     & reg(7) & reg(3) & reg(5) & "--",            -- 
      60 => OPC(setil)   & reg(0) & std_logic_vector(to_unsigned(16#81#,DW/2)),            -- 
      61 => OPC(st)      & reg(7) & reg(0) & "---"  & "--",            -- 
      62 => OPC(jmp)     & "---"  & std_logic_vector(to_unsigned(16,DW/2)),            -- 
      63 => OPC(nop)     & "---"  & "---"  & "---"  & "--",            -- 
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
