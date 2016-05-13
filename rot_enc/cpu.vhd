-------------------------------------------------------------------------------
-- Entity: cpu
-- Author: Waj
-------------------------------------------------------------------------------
-- Description: 
-- Top-level of CPU for simple von-Neumann MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: 0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity cpu is
  port(rst     : in    std_logic;
       clk     : in    std_logic;
       -- CPU bus signals
       bus_in  : in  t_bus2cpu;
       bus_out : out t_cpu2bus
       );
end cpu;

architecture rtl of cpu is

  signal ctr2prc : t_ctr2prc;
  signal prc2ctr : t_prc2ctr;
  signal ctr2alu : t_ctr2alu;
  signal alu2ctr : t_alu2ctr;
  signal ctr2reg : t_ctr2reg;
  signal reg2ctr : t_reg2ctr;
  signal alu_res, alu_op1, alu_op2  : std_logic_vector(DW-1 downto 0);

begin

  -----------------------------------------------------------------------------
  -- Instantiation of top-level components (assumed to be in library work)
  -----------------------------------------------------------------------------
  -- Control Unit--------------------------------------------------------------
  i_ctrl: entity work.cpu_ctrl
    port map(
      rst      => rst,
      clk      => clk,
      data_in  => bus_in.data,
      addr     => bus_out.addr,
      data_out => bus_out.data,
      rd_enb   => bus_out.rd_enb, 
      wr_enb   => bus_out.wr_enb, 
      reg_in   => reg2ctr,
      reg_out  => ctr2reg,
      prc_in   => prc2ctr,
      prc_out  => ctr2prc,
      alu_in   => alu2ctr,
      alu_out  => ctr2alu 
    );

  -- Address Generation -------------------------------------------------------
  i_prc: entity work.cpu_prc
    port map(
      rst      => rst,
      clk      => clk,
      ctr_in   => ctr2prc,
      ctr_out  => prc2ctr
    );

  -- ALU ----------------------------------------------------------------------
  i_alu: entity work.cpu_alu
    port map(
      rst      => rst,
      clk      => clk,
      alu_in   => ctr2alu,
      alu_out  => alu2ctr,
      oper1    => alu_op1,
      oper2    => alu_op2,
      result   => alu_res
    );

  -- Register Block -----------------------------------------------------------
  i_reg: entity work.cpu_reg
    port map(
      rst      => rst,
      clk      => clk,
      reg_in   => ctr2reg,
      reg_out  => reg2ctr,
      alu_res  => alu_res,
      alu_op1  => alu_op1,
      alu_op2  => alu_op2
    );
  
end rtl;
