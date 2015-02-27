-------------------------------------------------------------------------------
-- Entity: cpu_alu
-- Author: Waj
-- Date  : 28-Feb-14
-------------------------------------------------------------------------------
-- Description:
-- ALU for the RISC-CPU of the von-Neuman MCU.
-- The ALU is purely combinational, and thus no .enb signal in the alu_in
-- is required.
-------------------------------------------------------------------------------
-- Total # of FFs: 0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity cpu_alu is
  port(rst      : in std_logic;
       clk      : in std_logic;
       -- CPU internal interfaces
       alu_in   : in  t_ctr2alu;
       alu_out  : out t_alu2ctr;
       oper1    : in std_logic_vector(DW-1 downto 0);
       oper2    : in std_logic_vector(DW-1 downto 0);
       result   : out std_logic_vector(DW-1 downto 0)
       );
end cpu_alu;

architecture rtl of cpu_alu is
  
begin
  
  -----------------------------------------------------------------------------
  -- ISE workaround (:-((
  -----------------------------------------------------------------------------
  g_ISE: if ISE_TOOL generate 
    with to_integer(unsigned(alu_in.op)) select result <=
      -- Opcode 0: add
      std_logic_vector(unsigned(oper1) + unsigned(oper2)) when 0,
      -- Opcode 1: sub
      std_logic_vector(unsigned(oper1) - unsigned(oper2)) when 1,
      -- Opcode 2: and
      oper1 or oper2                                      when 2,
      -- Opcode 3: or
      oper1 or oper2                                      when 3,
      -- Opcode 4: xor
      oper1 xor oper2                                     when 4,
      -- Opcode 5: slai
      oper1(DW-2 downto 0) & '0'                          when 5,
      -- Opcode 6: srai
      oper1(DW-1) & oper1(DW-1 downto 1)                  when 6,
      -- Opcode 7: mov
      oper1                                               when 7,
      -- other (ensures memory-less process)
      (others => '0')                                     when others;
  end generate g_ISE;

  -----------------------------------------------------------------------------
  -- More elegant solution using type attribute 'val. Unfortunately, this
  -- attribute is not supported by ISE XST, but works fine with Vivado.
  -- (also note that the complementary attribute to 'val is 'pos)
  -----------------------------------------------------------------------------
  g_NOT_ISE: if not ISE_TOOL generate 
    with t_alu_instr'val(to_integer(unsigned(alu_in.op))) select result <=
      std_logic_vector(unsigned(oper1) + unsigned(oper2)) when add,
      std_logic_vector(unsigned(oper1) - unsigned(oper2)) when sub,
      oper1 or oper2                                      when andi,
      oper1 or oper2                                      when ori,
      oper1 xor oper2                                     when xori,
      oper1(DW-2 downto 0) & '0'                          when slai,
      oper1(DW-1) & oper1(DW-1 downto 1)                  when srai,
      oper1                                               when mov,
      (others =>'0')                                      when others;
  end generate g_NOT_ISE;

end rtl;
