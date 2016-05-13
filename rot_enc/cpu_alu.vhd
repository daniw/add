-------------------------------------------------------------------------------
-- Entity: cpu_alu
-- Author: Waj
-------------------------------------------------------------------------------
-- Description:
-- ALU for the RISC-CPU of the von-Neuman MCU.
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

  signal result_reg  : std_logic_vector(DW-1 downto 0);
  signal alu_enb_reg : std_logic;
  signal imml        : std_logic_vector(DW-1 downto 0);
  signal immh        : std_logic_vector(DW-1 downto 0);
  constant ext_0     : std_logic_vector(IOWW-1 downto 0) := (others => '0');
  constant ext_1     : std_logic_vector(IOWW-1 downto 0) := (others => '1');

begin
  
  -- output assignment
  result <= result_reg;

  -- helper signals for addil/addih instructions with sign extension
  imml <= (ext_0 & alu_in.imm) when alu_in.imm(alu_in.imm'left) = '0' else
          (ext_1 & alu_in.imm);         
  immh <= alu_in.imm & ext_0;
  
  -----------------------------------------------------------------------------
  -- ALU operations (ISE workaround)
  -----------------------------------------------------------------------------
  P_alu: process(clk)
  begin
    if rising_edge(clk) then
      if    to_integer(unsigned(alu_in.op)) = 0 then   -- add
        result_reg <= std_logic_vector(unsigned(oper1) + unsigned(oper2));
      elsif to_integer(unsigned(alu_in.op)) = 1 then   -- sub
        result_reg <= std_logic_vector(unsigned(oper1) - unsigned(oper2));
      elsif to_integer(unsigned(alu_in.op)) = 2 then   -- and
        result_reg <= oper1 and oper2;
      elsif to_integer(unsigned(alu_in.op)) = 3 then   -- or
        result_reg <= oper1 or oper2;
      elsif to_integer(unsigned(alu_in.op)) = 4 then   -- xor
        result_reg <= oper1 xor oper2;
      elsif to_integer(unsigned(alu_in.op)) = 5 then   -- slai
        result_reg <= oper1(DW-2 downto 0) & '0';
      elsif to_integer(unsigned(alu_in.op)) = 6 then   -- srai
        result_reg <= oper1(DW-1) & oper1(DW-1 downto 1);
      elsif to_integer(unsigned(alu_in.op)) = 7 then   -- mov
        result_reg <= oper1;
      elsif to_integer(unsigned(alu_in.op)) = 12 then  -- addil
        result_reg <= std_logic_vector(unsigned(oper1) + unsigned(imml));
      elsif to_integer(unsigned(alu_in.op)) = 13 then  -- addih
        result_reg <= std_logic_vector(unsigned(oper1) + unsigned(immh));
      elsif to_integer(unsigned(alu_in.op)) = 14 then  -- setil
        result_reg <= oper1(DW-1 downto DW/2) & alu_in.imm;
      elsif to_integer(unsigned(alu_in.op)) = 15 then  -- setih
        result_reg <= alu_in.imm & oper1(DW/2-1 downto 0);
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- More elegant solution using type attribute 'val. Unfortunately, this
  -- attribute is not supported by ISE XST, but works fine with Vivado.
  -- (also note that the complementary attribute to 'val is 'pos)
  -- ToDo: register!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  -----------------------------------------------------------------------------
  g_NOT_ISE: if not ISE_TOOL generate 
    with t_alu_instr'val(to_integer(unsigned(alu_in.op))) select result_reg <=
      std_logic_vector(unsigned(oper1) + unsigned(oper2)) when add,
      std_logic_vector(unsigned(oper1) - unsigned(oper2)) when sub,
      oper1 or oper2                                      when andi,
      oper1 or oper2                                      when ori,
      oper1 xor oper2                                     when xori,
      oper1(DW-2 downto 0) & '0'                          when slai,
      oper1(DW-1) & oper1(DW-1 downto 1)                  when srai,
      oper1                                               when mov,
      std_logic_vector(unsigned(oper1) + unsigned(imml))  when addil,
      std_logic_vector(unsigned(oper1) + unsigned(immh))  when addih,
      (others =>'0')                                      when others;
  end generate g_NOT_ISE;

  -----------------------------------------------------------------------------
  -- Update and register flags N, Z, C, O from registerd ALU results
  -----------------------------------------------------------------------------
  P_flag: process(clk)
    variable v_op2 : std_logic_vector(DW-1 downto 0);
  begin
    if rising_edge(clk) then
      -- regsiter enable from CPU_CTRL ----------------------------------------
      alu_enb_reg <= alu_in.enb;
      -- flag update with registered enable and registered ALU result ---------
      if alu_enb_reg = '1' then
        -- get correct Operand 2 for add/addil/addih
        if (to_integer(unsigned(alu_in.op)) =  0) then   
          v_op2 := oper2; --add
        elsif (to_integer(unsigned(alu_in.op)) = 12) then
          v_op2 := imml; --addil
        else
          v_op2 := immh; --addih
        end if;
        -- N, updated with each operation -------------------------------------
        alu_out.flag(N) <= result_reg(DW-1);
        -- Z, updated with each operation -------------------------------------
        alu_out.flag(Z) <= '0';
        if to_integer(unsigned(result_reg)) = 0 then
          alu_out.flag(Z) <= '1';
        end if;
        -- C, updated with add/addil/addih/sub only ---------------------------
        if (to_integer(unsigned(alu_in.op)) =  0) or
           (to_integer(unsigned(alu_in.op)) = 12) or   
           (to_integer(unsigned(alu_in.op)) = 13) then 
          -- add/addil/addih (use v_op2)
          alu_out.flag(C) <= (oper1(DW-1) and     v_op2(DW-1))      or
                             (oper1(DW-1) and not result_reg(DW-1)) or
                             (v_op2(DW-1) and not result_reg(DW-1));
        elsif to_integer(unsigned(alu_in.op)) = 1 then
          -- sub (use oper2)
          alu_out.flag(C) <= (oper2(DW-1)      and not oper1(DW-1))      or
                             (result_reg(DW-1) and not oper1(DW-1))      or
                             (oper2(DW-1)      and     result_reg(DW-1));
        end if;
        -- O, updated with add/addil/addih/sub only ---------------------------
        if (to_integer(unsigned(alu_in.op)) =  0) or
           (to_integer(unsigned(alu_in.op)) = 12) or   
           (to_integer(unsigned(alu_in.op)) = 13) then 
          -- add/addil/addih (use v_op2)
          alu_out.flag(O) <= (not oper1(DW-1) and not v_op2(DW-1) and     result_reg(DW-1)) or
                             (    oper1(DW-1) and     v_op2(DW-1) and not result_reg(DW-1));
        elsif to_integer(unsigned(alu_in.op)) = 1 then
          -- sub (use oper2)
          alu_out.flag(O) <= (    oper1(DW-1) and not oper2(DW-1) and not result_reg(DW-1)) or
                             (not oper1(DW-1) and     oper2(DW-1) and     result_reg(DW-1));
        end if;     
      end if;
    end if;
  end process;

end rtl;
