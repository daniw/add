-------------------------------------------------------------------------------
-- Company    :  HSLU, Waj
-- Project    :  RT Video Lab 1: Exercise 1
-- Description:  5-tap FIR filter in transposed form
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity fir_1d_trn is
  generic
    (IN_DW   : integer := 8;            -- Input word width
     OUT_DW  : integer := 19;           -- Output word width
     COEF_DW : integer := 7;            -- coefficient word width
     TAPS    : integer := 5;            -- # of taps + 1 output register
     DELAY   : integer := 8);           -- delay line
                                        -- (to adapt latency to system architecture)
  port
    (ce_1     : in  std_logic;          -- clock enable
     clk_1    : in  std_logic;          -- clock
     load     : in  std_logic;          -- load coeff pulse
     coef     : in  std_logic_vector(COEF_DW-1 downto 0);
     din      : in  std_logic_vector(IN_DW-1 downto 0);
     out_data : out std_logic_vector(OUT_DW-1 downto 0)
     );
end fir_1d_trn;

architecture Behavioral of fir_1d_trn is

  -- type declarations
  type STAGE_TYPE is array(TAPS-1 downto 0) of signed(OUT_DW-1 downto 0);
  ....
  
  -- signal declarations (init values for simulation only!!!)
  signal stage    : STAGE_TYPE := (others => (others => '0'));
  ....
  
  -- constant declarations
  ....
  
begin

  -- sequential process (without reset, because SysGen uses FIR-Compiler without
  -- reset signal)
  p0_FIR : process(clk_1)
  begin
    if clk_1'event and clk_1 = '1' then
      if ce_1 = '1' then

        
      ....
      
        
      end if;
    end if;
  end process;

end Behavioral;
