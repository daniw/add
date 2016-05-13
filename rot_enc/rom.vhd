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
    -- set GPIO(7:0) = LED(7:0) to Output
    OPC(setil) & reg(3) & n2slv(16#02#, DW/2),         -- setil r3, 0x02
    OPC(setih) & reg(3) & n2slv(16#03#, DW/2),         -- setih r3, 0x03
    OPC(setil) & reg(4) & n2slv(16#FF#, DW/2),         -- setil r4, 0xFF
    OPC(st)    & reg(4) & reg(3) & "-----",            -- GPIO_OUT_ENB = 0xFF
    -- initialize GPIO data output values (permanently stored in r4) 
    OPC(setil) & reg(3) & n2slv(16#01#, DW/2),         -- setil r3, 0x01
    OPC(setil) & reg(4) & n2slv(16#2A#, DW/2),         -- setil r4, 0x2A (LED(7:0)=00101010)
    OPC(st)    & reg(4) & reg(3) & "-----",            -- GPIO_DATA_OUT = 0x2A
    -- initilize bit masks for toggling specific bits
    OPC(setil) & reg(5) & n2slv(16#03#, DW/2),         -- setil r5, 0x03 (LED(1:0))
    OPC(setil) & reg(6) & n2slv(16#0C#, DW/2),         -- setil r6, 0x0C (LED(3:2))
    OPC(setil) & reg(7) & n2slv(16#30#, DW/2),         -- setil r7, 0x30 (LED(5:4))
    ---------------------------------------------------------------------------
    -- addr 0x00A: start of end-less loop
       -- outer for-loop (r2)
       -- init r2 = 0x0064 => 10 * 500 ms = 5 s
       OPC(setil) & reg(2) & n2slv(16#0A#, DW/2),         -- setil r2, 0x0A
       OPC(setih) & reg(2) & n2slv(16#00#, DW/2),         -- setih r2, 0x00
          -- middle for-loop (r1)
          -- init r1 = 0x0064 => 100 * 5 ms = 500 ms
          OPC(setil) & reg(1) & n2slv(16#64#, DW/2),      -- setil r1, 0x64
          OPC(setih) & reg(1) & n2slv(16#00#, DW/2),      -- setih r1, 0x00
             -- inner for-loop (r0)
             -- init r0 = 0x5161 => 20833 * 4 * 3 cc = 5 ms
             OPC(setil) & reg(0) & n2slv(16#61#, DW/2),   -- setil r0, 0x61
             OPC(setih) & reg(0) & n2slv(16#51#, DW/2),   -- setih r0, 0x51
                -- execute
                OPC(nop)   & "-----------",               
                OPC(nop)   & "-----------",                       
             -- check condition
             OPC(addil) & reg(0) & n2slv(16#FF#, DW/2),   -- addil r0, 0xFF
             OPC(bne)   & "-11"  & n2slv(16#FD#, AW-2),   -- bne 0x3FD (-3)
             -- toggle LED(1:0)
             OPC(xori)  & reg(4) & reg(4) & reg(5)& "--", -- apply bit mask     
             OPC(st)    & reg(4) & reg(3) & "-----",      -- write new value to GPIO_DATA_OUT
          -- check condition
          OPC(addil) & reg(1) & n2slv(16#FF#, DW/2),      -- addil r1, 0xFF
          OPC(bne)   & "-11"  & n2slv(16#F7#, AW-2),      -- bne 0x3F7 (-9)
          -- toggle LED(3:2)
          OPC(xori)  & reg(4) & reg(4) & reg(6)& "--",    -- apply bit mask     
          OPC(st)    & reg(4) & reg(3) & "-----",         -- write new value to GPIO_DATA_OUT
       -- check condition
       OPC(addil) & reg(2) & n2slv(16#FF#, DW/2),         -- addil r2, 0xFF
       OPC(bne)   & "-11"  & n2slv(16#F1#, AW-2),         -- bne 0x3F1 (-15)
       -- toggle LED(3:2)
       OPC(xori)  & reg(4) & reg(4) & reg(7)& "--",       -- apply bit mask     
       OPC(st)    & reg(4) & reg(3) & "-----",            -- write new value to GPIO_DATA_OUT
    -- end of end-less loop
    OPC(jmp)   & "-00" & n2slv(16#0A#, AW-2),             -- jmp 0x00A
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
