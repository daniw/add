-------------------------------------------------------------------------------
-- Company    :  HSLU
-- Engineer   :  Gai, Waj
-- 
-- Create Date:  19-May-11
-- Project    :  RT Video Lab 1: Exercise 2
-- Description:  5-tap FIR filter in transposed form with loadable coefficients
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity fir_1d_trn_load is
  generic
    (IN_DW   : integer := 8;            -- Input word width
     OUT_DW  : integer := 19;           -- Output word width
     COEF_DW : integer := 7;            -- coefficient word width
     TAPS    : integer := 5;            -- # of taps + 1 output register
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
end fir_1d_trn_load;

architecture Behavioral of fir_1d_trn_load is

  -- Implement here:
  --   * 1x5 FIR filter transposed form
  --   * logic for reloading of coefficients


end Behavioral;
