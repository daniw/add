-------------------------------------------------------------------------------
-- Company    :  HSLU
-- Engineer   :  Gai, Waj
--
-- Create Date:  05-Apr-11, 21-Mar-14
-- Project    :  RT Video Lab 1: Exercise 1
-- Description:  5-tap FIR filter in direct form
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity fir_1d_dir is
  generic
    (IN_DW   : integer := 8;            -- Input word width
     OUT_DW  : integer := 19;           -- Output word width
     COEF_DW : integer := 7;            -- coefficient word width
     TAPS    : integer := 5;            -- # of taps + 1 input register
     DELAY   : integer := 8);           -- output delay line
                                        -- (to adapt latency to system architecture)
  port
    (ce_1     : in  std_logic;          -- clock enable
     clk_1    : in  std_logic;          -- clock
     load     : in  std_logic;          -- load coeff pulse
     coef     : in  std_logic_vector(COEF_DW-1 downto 0);
     din      : in  std_logic_vector(IN_DW-1 downto 0);
     out_data : out std_logic_vector(OUT_DW-1 downto 0)
     );
end fir_1d_dir;

architecture Behavioral of fir_1d_dir is

  -- type declarations
  type STAGE_TYPE is array(TAPS-1 downto 0) of signed(IN_DW-1 downto 0);
  type DELAY_TYPE is array(DELAY downto 0) of signed(IN_DW-1 downto 0);
  type COEFF_TYPE is array(TAPS-1 downto 0) of signed(COEF_DW-1 downto 0);

  -- signal declarations (init values for simulation only!!!)
  signal stage    : STAGE_TYPE := (others => (others => '0'));
  signal del_line : DELAY_TYPE := (others => (others => '0'));

  -- constant declarations
  constant C_coef : COEFF_TYPE := (to_signed(2, COEF_DW),   -- b4
                                   to_signed(4, COEF_DW),   -- b3
                                   to_signed(8, COEF_DW),   -- b2
                                   to_signed(4, COEF_DW),   -- b1
                                   to_signed(2, COEF_DW));  -- b0
  constant C_ext : signed(OUT_DW-IN_DW-COEF_DW-1 downto 0) := (others => '0');

begin

  -- sequential process (without reset, because SysGen uses FIR-Compiler without
  -- reset signal)
  p0_FIR : process(clk_1)
    variable v_filt : signed(OUT_DW-1 downto 0);
  begin
    if rising_edge(clk_1) then
      if ce_1 = '1' then
        -- input delay line
        del_line(DELAY)            <= signed(din);
        del_line(DELAY-1 downto 0) <= del_line(DELAY downto 1);
        -- shift tap delay line
        stage(0) <= del_line(0);
        stage(TAPS-1 downto 1) <= stage(TAPS-2 downto 0);   
        -- compute filter taps
        v_filt := (C_ext & stage(0)) * C_coef(0);
        for k in 1 to TAPS-1 loop
          v_filt := ((C_ext & stage(k)) * C_coef(k)) + v_filt;
        end loop;
        -- output register
        out_data <= std_logic_vector(v_filt);
      end if;
    end if;
  end process;

end Behavioral;

