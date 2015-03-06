-------------------------------------------------------------------------------
-- Entity: cpu_ctrl
-- Author: Waj
-------------------------------------------------------------------------------
-- Description:
-- Control unit without instruction pipelining for the RISC-CPU of the
-- von-Neuman MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: 16 + 3
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

  -----------------------------------------------------------------------------
  -- Bus Interface
  -----------------------------------------------------------------------------
  data_out <= reg_in.data;
  with c_st select addr <= reg_in.addr when s_ma,
                           prc_in.pc   when others;
  
  -----------------------------------------------------------------------------
  -- PC Interface
  -----------------------------------------------------------------------------
  prc_out.mode <= linear;
  prc_out.addr <= (others => '0');
  
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
  reg_out.data <= data_in;

  -----------------------------------------------------------------------------
  -- FSM: Mealy-type
  -- Inputs : c_st, instr_reg
  -- Outputs: instr_enb, reg_out.enb, prc_out.enb
  -----------------------------------------------------------------------------
  -- memoryless process
  p_fsm_com: process (c_st, instr_reg)
    variable v_opcode : natural range 0 to 2**OPCW-1;
  begin
    -- default assignments
    n_st             <= c_st; -- remain in current state
    r_wb             <= '0';
    instr_enb        <= '0';
    reg_out.enb_res  <= '0';
    reg_out.enb_data <= '0';
    alu_out.enb      <= '0';
    prc_out.enb      <= '0';
    -- opcode variable (to simplify code only)
        -- This variable could be of type t_instr when using 'val attribute,
        -- but this is not supported by ISE XST.
        -- t_instr'val(to_integer(unsigned(instr_reg(DW-1 downto DW-(OPCW-OPAW)))))
    v_opcode := to_integer(unsigned(instr_reg(DW-1 downto DW-OPCW)));
    -- specific assignments
    case c_st is
      when s_if =>
        -- instruction fetch ------------------------------------------------------
        n_st <= s_id;
      when s_id =>
        -- instruction decode -----------------------------------------------------
        n_st <= s_ex;
        instr_enb <= '1';
      when s_ex =>
        -- instruction execute ----------------------------------------------------
        if v_opcode <= 7 then
          -- reg/reg-instruction
          -- increase PC, store result/flags from ALU, start next instr. cycle 
          prc_out.enb     <= '1';  
          reg_out.enb_res <= '1';  
          alu_out.enb     <= '1';
          n_st            <= s_if; 
        else
          -- other instruction: ToDo !!!!!!!!!!!!!!!!!
          n_st <= s_if;        
        end if;
      when s_ma =>
        -- memory access --------------------------------------------------------
        null; -- ToDo !!!!!!!!!!!!!!!!!!!!!!!!!
      when s_rw =>
        -- register write-back -------------------------------------------------
        null; -- ToDo !!!!!!!!!!!!!!!!!!!!!!!!!
      when others =>
        n_st <= s_if; -- handle parasitic states
    end case;
  end process;
  ------------------------------------------------------------------------------ 
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
