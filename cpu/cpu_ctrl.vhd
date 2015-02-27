-------------------------------------------------------------------------------
-- Entity: cpu_ctrl
-- Author: Waj
-- Date  : 28-Feb-14
-------------------------------------------------------------------------------
-- Description:
-- Control unit without instruction pipelining for the RISC-CPU of the
-- von-Neuman MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: ... tbd ...
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity cpu_ctrl is
  port(rst      : in std_logic;
       clk      : in std_logic;
       -- bus interface signals
       data_in  : in std_logic_vector(DW-1 downto 0);
       addr     : out std_logic_vector(AW-1 downto 0);
       data_out : out std_logic_vector(DW-1 downto 0);
       r_wb     : out std_logic;
       -- CPU internal interfaces
       reg_in   : in  t_reg2ctr;
       reg_out  : out t_ctr2reg;
       prc_in   : in  t_prc2ctr;
       prc_out  : out t_ctr2prc;
       alu_in   : in  t_alu2ctr;
       alu_out  : out t_ctr2alu
       );
end cpu_ctrl;

architecture rtl of cpu_ctrl is

  -- FSM signals
  type state is (s_if, s_id, s_ex, s_ma, s_rw);
  signal c_st, n_st : state;
  -- Instruction register & decoding
  signal instr_reg : std_logic_vector(DW-1 downto 0);
  signal instr_enb : std_logic;
  
begin

  -- Dummy assignments :ToDo:!!!!!!!!!!!!!!!!!!!!!!!!!!
  r_wb <= '0';
  reg_out.data <= data_in ;
  with c_st select
    data_out <= reg_in.data      when s_id,
                (others => '0')  when others;

  -----------------------------------------------------------------------------
  -- PC Interface
  -----------------------------------------------------------------------------
  prc_out.mode <= linear;
  prc_out.addr <= (others => '0');
  addr <= prc_in.pc;
  
  -----------------------------------------------------------------------------
  -- Instruction register & decoding
  -----------------------------------------------------------------------------
  P_ir: process(clk)
  begin
    if rising_edge(clk) then
      if instr_enb = '1' then
        instr_reg <= data_in;
      end if;
    end if;
  end process;
  alu_out.op   <= instr_reg(DW-1-(OPCW-OPAW) downto DW-OPCW);
  reg_out.dest <= instr_reg(10 downto 8);
  reg_out.src1 <= instr_reg( 7 downto 5);
  reg_out.src2 <= instr_reg( 4 downto 2);

  -----------------------------------------------------------------------------
  -- FSM: Mealy-type
  -- Inputs : c_st, instr_reg
  -- Outputs: instr_enb, reg_out.enb, prc_out.enb
  -----------------------------------------------------------------------------
  -- memoryless process
  p_fsm_com: process (c_st, instr_reg)
  begin
    -- default assignments
    n_st        <= c_st; -- remain in current state
    instr_enb   <= '0';
    reg_out.enb <= '0';
    prc_out.enb <= '0';
    -- specific assignments
    case c_st is
      when s_if =>
        -- instruction fetch
        n_st <= s_id;
      when s_id =>
        -- instruction decode
        n_st <= s_ex;
        instr_enb <= '1';
      when s_ex =>
        -- instruction execute
        if to_integer(unsigned(instr_reg(DW-1 downto DW-(OPCW-OPAW)))) <= 7 then
        -- Note: The condition above can be more elegantly written with 'val
        -- attribute, but this is not supported by ISE XST.
        -- if t_alu_instr'val(to_integer(unsigned(instr_reg(DW-1 downto DW-(OPCW-OPAW))))) <= mov  then
          -- reg/reg-instruction:
          -- increase PC, store result from ALU, and start next instr. cycle 
          prc_out.enb <= '1';  
          reg_out.enb <= '1';  
          n_st        <= s_if; 
        else
          -- other instruction: ToDo!!!!!!!!!!!!!!!
          n_st <= s_ma;        
        end if;
      when s_ma =>
        -- memory access
        n_st <= s_rw;
      when s_rw =>
        -- register write-back
        n_st <= s_if;
      when others =>
        n_st <= s_if; -- handle parasitic states
    end case;
  end process;
  ----------------------------------------------------------------------------- 
  -- sequential process
  -- # of FFs: 3 (assuming binary state encoding)
  P_fsm_seq: process(rst, clk)
  begin
    if rst = '1' then
      c_st <= s_if;
    elsif rising_edge(clk) then
      c_st <= n_st;
    end if;
  end process;

    
end rtl;
