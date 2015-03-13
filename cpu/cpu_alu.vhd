-------------------------------------------------------------------------------
-- Entity: cpu_alu
-- Author: Waj
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
  port(clk      : in std_logic;
       -- CPU internal interfaces
       alu_in   : in  t_ctr2alu;
       alu_out  : out t_alu2ctr;
       oper1    : in std_logic_vector(DW-1 downto 0);
       oper2    : in std_logic_vector(DW-1 downto 0);
       result   : out std_logic_vector(DW-1 downto 0)
       );
end cpu_alu;

architecture rtl of cpu_alu is

  signal result_int : std_logic_vector(DW-1 downto 0);
  
begin

  -- output assignment
  result <= result_int;
  
  -----------------------------------------------------------------------------
  -- ISE workaround (:-((
  -----------------------------------------------------------------------------
  g_ISE: if ISE_TOOL generate 
    with to_integer(unsigned(alu_in.op)) select result_int <=
      -- Opcode 0: add
      std_logic_vector(unsigned(oper1) + unsigned(oper2)) when 0,
      -- Opcode 1: sub
      std_logic_vector(unsigned(oper1) - unsigned(oper2)) when 1,
      -- Opcode 2: and
      oper1 and oper2                                     when 2,
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
    with t_alu_instr'val(to_integer(unsigned(alu_in.op))) select result_int <=
      std_logic_vector(unsigned(oper1) + unsigned(oper2)) when add,
      std_logic_vector(unsigned(oper1) - unsigned(oper2)) when sub,
      oper1 and oper2                                     when andi,
      oper1 or oper2                                      when ori,
      oper1 xor oper2                                     when xori,
      oper1(DW-2 downto 0) & '0'                          when slai,
      oper1(DW-1) & oper1(DW-1 downto 1)                  when srai,
      oper1                                               when mov,
      (others =>'0')                                      when others;
  end generate g_NOT_ISE;

  -----------------------------------------------------------------------------
  -- Update and register flags N, Z, C, O with valid ALU results
  -----------------------------------------------------------------------------
  P_flag: process(clk)
  begin
    if rising_edge(clk) then
      if alu_in.enb = '1' then
        -- N, updated with each operation -------------------------------------
        alu_out.flag(N) <= result_int(DW-1);
        -- Z, updated with each operation -------------------------------------
        alu_out.flag(Z) <= '0';
        if to_integer(unsigned(result_int)) = 0 then
          alu_out.flag(Z) <= '1';
        end if;
        -- C, updated with add/sub only ---------------------------------------
        if to_integer(unsigned(alu_in.op)) = 0 then
          -- add
          alu_out.flag(C) <= (oper1(DW-1) and     oper2(DW-1))      or
                             (oper1(DW-1) and not result_int(DW-1)) or
                             (oper2(DW-1) and not result_int(DW-1));
        elsif to_integer(unsigned(alu_in.op)) = 1 then
          -- sub
          alu_out.flag(C) <= (oper2(DW-1)      and not oper1(DW-1))      or
                             (result_int(DW-1) and not oper1(DW-1))      or
                             (oper2(DW-1)      and     result_int(DW-1));
        end if;
        -- O, updated with add/sub only --------------------------------------
        if to_integer(unsigned(alu_in.op)) = 0 then
          -- add
          alu_out.flag(O) <= (not oper1(DW-1) and not oper2(DW-1) and     result_int(DW-1)) or
                             (    oper1(DW-1) and     oper2(DW-1) and not result_int(DW-1));
        elsif to_integer(unsigned(alu_in.op)) = 1 then
          -- sub
          alu_out.flag(O) <= (    oper1(DW-1) and not oper2(DW-1) and not result_int(DW-1)) or
                             (not oper1(DW-1) and     oper2(DW-1) and     result_int(DW-1));
        end if;     
      end if;
    end if;
  end process;


end rtl;
