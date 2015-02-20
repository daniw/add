-------------------------------------------------------------------------------
-- Entity: cpu_prc
-- Author: Waj
-- Date  : 26-May-13
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 9)
-- Program Counter unit for the RISC-CPU of the von-Neuman MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: ... tbd ...
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

  -- program counter
  signal pc : std_logic_vector(AW-1 downto 0);

begin

  -- assign outputs
  ctr_out.pc <= pc;

  -----------------------------------------------------------------------------
  -- Program Counter
  -----------------------------------------------------------------------------
  P_pc: process(clk, rst)
    variable v_addr : std_logic_vector(AW downto 0);
  begin
    if rst = '1' then
      pc <= (others => '0');
    elsif rising_edge(clk) then
      if ctr_in.enb = '1' then
        ctr_out.exc <= no_err;   -- default assignment
        case ctr_in.mode is
          when linear =>
            -- PC := PC + 1
            pc <= std_logic_vector(unsigned(pc) + 1);     
            if pc = X"FF" then
              ctr_out.exc <= lin_err; 
            end if;
          when abs_jump =>
            -- PC := addr
            pc <= ctr_in.addr;
          when rel_offset =>
            -- PC := PC + addr
            v_addr := std_logic_vector(unsigned('0' & pc) + unsigned(ctr_in.addr));
            pc <= v_addr(AW-1 downto 0);
            if v_addr(AW) = '1' then
              ctr_out.exc <= lin_err;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process;

end rtl;
