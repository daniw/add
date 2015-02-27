-------------------------------------------------------------------------------
-- Entity: cpu_alu
-- Author: Waj
-- Date  : 26-May-13
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 9)
-- ALU for the RISC-CPU of the von-Neuman MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: ... tbd ...
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
  -- ISE workaround 2
  -----------------------------------------------------------------------------  
  g_ISE2: if ISE_TOOL generate
    with ("00" & alu_in.op) select
    result <= std_logic_vector(unsigned(oper1) + unsigned(oper2))   when OPC(add),
              std_logic_vector(unsigned(oper1) + unsigned(oper2))   when OPC(add),
              oper1 and oper2                                       when OPC(andi),
              oper1 or oper2                                        when OPC(ori),
              oper1 xor oper2                                       when OPC(xori),
              oper1(DW-2 downto 0) & "0"                            when OPC(slai),
              "0" & oper1(DW-1 downto 1)                            when OPC(srai),
              oper1                                                 when OPC(mov),
              (others => '0')                                       when others;
  end generate;
  
end rtl;
