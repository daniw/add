-------------------------------------------------------------------------------
-- Entity: cpu_prc
-- Author: Waj
-------------------------------------------------------------------------------
-- Description:
-- Program Counter unit for the RISC-CPU of the von-Neuman MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: 8 + 2
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity cpu_prc is
  port(rst      : in std_logic;
       clk      : in std_logic;
       -- CPU internal interfaces
       ctr_in   : in  t_ctr2prc;
       ctr_out  : out t_prc2ctr
       );
end cpu_prc;

architecture rtl of cpu_prc is

  -- program counter and exception signals
  signal pc  : std_logic_vector(AW-1 downto 0);
  signal exc : t_addr_exc;

begin

  -- assign outputs
  ctr_out.pc  <= pc;
  ctr_out.exc <= exc;
  
  -----------------------------------------------------------------------------
  -- Program Counter
  -----------------------------------------------------------------------------
  P_pc: process(clk, rst)
    variable v_pc   : std_logic_vector(AW-1 downto 0);
    variable v_addr : std_logic_vector(AW downto 0);
  begin
    if rst = '1' then
      pc  <= (others => '0');
      exc <= no_err;  
    elsif rising_edge(clk) then
      if ctr_in.enb = '1' then
        exc <= no_err;   -- default assignment
        case ctr_in.mode is
          when linear =>
            -- PC := PC + 1
            v_pc := std_logic_vector(unsigned(pc) + 1);     
            if v_pc(AW-1) /= BA(ROM)(AW-1) then -- NOT NICE! Find better solution!!!!!!!!!!!!!!!!!!!!!!!
              -- PC would leave ROM address space
              -- do not increment and issue error
              exc <= lin_err;
            else
              pc <= v_pc;     
            end if;
          when abs_jump =>
            -- PC := addr
            pc <= ctr_in.addr;
          when rel_offset =>
            -- PC := PC + addr
            v_addr := std_logic_vector(unsigned('0' & pc) + unsigned(ctr_in.addr));
            pc <= v_addr(AW-1 downto 0);
            if v_addr(AW) = '1' and ctr_in.addr(AW-1) = '0' then
              -- overflow with addition of positive relative offset
              exc <= rel_err;
            elsif v_addr(AW) = '0' and ctr_in.addr(AW-1) = '1' then
              -- underflow with addition of negative relative offset
              exc <= rel_err;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process;

end rtl;
