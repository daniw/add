-------------------------------------------------------------------------------
-- Entity: cpu_reg
-- Author: Waj
-- Date  : 28-Feb-14
-------------------------------------------------------------------------------
-- Description:
-- Register block for the RISC-CPU of the von-Neuman MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: 8 * 16
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity cpu_reg is
  port(rst      : in std_logic;
       clk      : in std_logic;
       -- CPU internal interfaces
       reg_in   : in  t_ctr2reg;
       reg_out  : out t_reg2ctr;
       alu_res  : in std_logic_vector(DW-1 downto 0);
       alu_op1  : out std_logic_vector(DW-1 downto 0);
       alu_op2  : out std_logic_vector(DW-1 downto 0)
       );
end cpu_reg;

architecture rtl of cpu_reg is
  signal reg_blk : t_regblk;
  
begin

  -----------------------------------------------------------------------------
  -- Mux input data to ALU combinationally depending on source info from
  -- control unit.
  -----------------------------------------------------------------------------
  alu_op1 <= reg_blk(to_integer(unsigned(reg_in.src1)));
  alu_op2 <= reg_blk(to_integer(unsigned(reg_in.src2)));

  -----------------------------------------------------------------------------
  -- Mux and register data/address to Control Unit depending on source info.
  -----------------------------------------------------------------------------
  P_mux: process(clk)
  begin
    if rising_edge(clk) then
      reg_out.data <= reg_blk(to_integer(unsigned(reg_in.dest)));
      reg_out.addr <= reg_blk(to_integer(unsigned(reg_in.src1)))(AW-1 downto 0);
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- CPU register block
  -- Store ALU result depending on destination info from control unit.
  -- Note: Some CPU registers have non-zero reset values to allow simulation 
  -- of register-to-register instructions without load-instructions.
  -----------------------------------------------------------------------------
  P_reg: process(rst, clk)
  begin
    if rst = '1' then
      reg_blk <= (
                  0      => std_logic_vector(to_unsigned(16#00_40#, DW)),
                  1      => std_logic_vector(to_unsigned(16#00_41#, DW)),
                  2      => std_logic_vector(to_unsigned(16#00_42#, DW)),
                  3      => std_logic_vector(to_unsigned(16#00_43#, DW)),
                  others => (others => '0'));
    elsif rising_edge(clk) then
      if reg_in.enb_res = '1' then
        -- store result from ALU
        reg_blk(to_integer(unsigned(reg_in.dest))) <= alu_res;
      elsif reg_in.enb_data = '1' then
        -- store data from memory (load instruction)
        reg_blk(to_integer(unsigned(reg_in.dest))) <= reg_in.data;
      end if;
    end if;
  end process;
  
end rtl;
