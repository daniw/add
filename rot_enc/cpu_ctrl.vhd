-------------------------------------------------------------------------------
-- Entity: cpu_ctrl
-- Author: Waj
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
       wr_enb   : out std_logic;
       rd_enb   : out std_logic;
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
  signal opcode    : natural range 0 to 2**OPCW-1;
  -- write enable signals registered
  signal reg_enb_res : std_logic;
  signal reg_enb_data : std_logic;
  
begin

  -----------------------------------------------------------------------------
  -- Bus Interface
  -----------------------------------------------------------------------------
  data_out <= reg_in.data;

  
  -----------------------------------------------------------------------------
  -- Register Block Interface
  -- registered to break comb. path from bus system to register block
  -----------------------------------------------------------------------------
  P_rbi: process(clk)
  begin
    if rising_edge(clk) then
      -- write enable and data signals to reg block; 
      reg_out.enb_res  <= reg_enb_res;
      reg_out.enb_data <= reg_enb_data;  
      if opcode = 16 then
        -- load instruction, register low & high byte from bus system
        reg_out.data <= data_in;
      elsif opcode = 15 then
        -- setih instruction, register low byte from instr. reg as high byte
        reg_out.data(DW-1 downto DW/2) <= instr_reg(DW/2-1 downto 0);
      else
        -- e.g. setil instruction, register low byte from instr. reg as low byte
        reg_out.data <= instr_reg;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Instruction register 
  -----------------------------------------------------------------------------
  P_ir: process(clk)
  begin
    if rising_edge(clk) then
      -- instruction register
      if instr_enb = '1' then
        instr_reg <= data_in;
      end if;
    end if;
  end process;
  -- Instruction register decoding
  opcode       <= to_integer(unsigned(instr_reg(DW-1 downto DW-OPCW)));  
  alu_out.op   <= instr_reg(DW-1-(OPCW-OPAW) downto DW-OPCW);
  alu_out.imm  <= instr_reg(IOWW-1 downto 0);
  reg_out.dest <= instr_reg(10 downto 8);
  reg_out.src1 <= instr_reg(10 downto 8) when (opcode >= 12 and opcode <= 15) else
                  instr_reg( 7 downto 5);
  reg_out.src2 <= instr_reg( 4 downto 2);
  prc_out.addr <= instr_reg(AW-1 downto 0); 

  -----------------------------------------------------------------------------
  -- FSM: Mealy-type
  -----------------------------------------------------------------------------
  -- memoryless process
  p_fsm_com: process (c_st, opcode, alu_in, reg_in, prc_in)
  begin
    -- default assignments for all outputs
    n_st             <= c_st; -- remain in current state
    rd_enb           <= '0';  
    wr_enb           <= '0';  
    instr_enb        <= '0';
    reg_enb_res      <= '0';
    reg_enb_data     <= '0';
    alu_out.enb      <= '0';
    prc_out.enb      <= '0';
    prc_out.mode     <= linear;
    addr             <= (others => '1');  -- reset vector
    -- specific assignments
    case c_st is
      when s_if =>
        -- instruction fetch ----------------------------------
        rd_enb <= '1';
        if prc_in.exc = no_err then
          -- normal fetch if no exception, otherwise go to reset vector
          addr <= prc_in.pc;
        end if;
        n_st <= s_id;
      when s_id =>
        -- instruction decode ---------------------------------
        instr_enb <= '1';
        n_st      <= s_ex;
      when s_ex =>
        -- instruction execute --------------------------------
        if opcode <= 7 or (opcode >= 12 and opcode <= 15) then
          -- reg/reg-instruction, addil/h instruction, setil/h instruction
          -- increase PC, store result/flags from ALU, start next instr. cycle 
          prc_out.enb <= '1';  
          reg_enb_res <= '1';  
          alu_out.enb <= '1';
          n_st        <= s_if; 
        elsif opcode = 16 or opcode = 17 then
          -- load/store instruction
          -- increase PC, go to "Memory Access" state 
          prc_out.enb <= '1';  
          n_st        <= s_ma;                  
        elsif opcode = 24 then
          -- jump instruction
          -- set PC to absolute address, start next instr. cycle
          prc_out.enb  <= '1';  
          prc_out.mode <= abs_jump;
          n_st         <= s_if;                  
        elsif opcode >= 25 and opcode <= 29 then
          -- branch instructions
          prc_out.enb <= '1';  
          n_st        <= s_if;
          -- bne: branch if not equal (not Z)
          if opcode = 25 and alu_in.flag(Z) = '0' then
            prc_out.mode <= rel_offset;
          end if;
          -- bge: branch if greater/equal (not N or Z)
          if opcode = 26 and (alu_in.flag(N) = '0' or alu_in.flag(Z) = '1') then
            prc_out.mode <= rel_offset;
          end if;
          -- blt: branch if less than (N)
          if opcode = 27 and alu_in.flag(N) = '1' then
            prc_out.mode <= rel_offset;
          end if;
          -- bca: branch if carry set (C)
          if opcode = 28 and alu_in.flag(C) = '1' then
            prc_out.mode <= rel_offset;
          end if;
          -- bov: branch if overflow set (O)
          if opcode = 29 and alu_in.flag(O) = '1' then
            prc_out.mode <= rel_offset;
          end if;
        else
          -- NOP instruction
          prc_out.enb  <= '1';  
          n_st         <= s_if;        
        end if;
      when s_ma =>
        -- memory access -------------------------------------
        if opcode = 16 then
          -- load instruction
          -- read data from memory and go to "Register Write-Back" state  
          rd_enb <= '1';
          n_st   <= s_rw;
        else
          -- store instruction
          -- write data from register to memory and start next instr. cycle 
          wr_enb <= '1';
          n_st   <= s_if; 
        end if;
        addr <= reg_in.addr;
      when s_rw =>
        -- register write-back -------------------------------
        -- store data from memory in register and start next instr. cycle 
        reg_enb_data <= '1';  
        n_st         <= s_if;
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
