-------------------------------------------------------------------------------
-- Company    :  HSLU
-- Engineer   :  Gai, Waj
-- 
-- Create Date:  26-May-11
-- Project    :  RT Video Lab 1: Exercise 3
-- Description:  2D 5x5-FIR filter in transposed form with loadable coefficients
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity fir_2d_trn_load is
  port (ce_1    : in  std_logic;
        clk_1  : in  std_logic;
        coef   : in  std_logic_vector (6 downto 0);
        gain   : in  std_logic_vector (19 downto 0);
        line1  : in  std_logic_vector (7 downto 0);
        line2  : in  std_logic_vector (7 downto 0);
        line3  : in  std_logic_vector (7 downto 0);
        line4  : in  std_logic_vector (7 downto 0);
        line5  : in  std_logic_vector (7 downto 0);
        load_1 : in  std_logic; 
        load_2 : in  std_logic; 
        load_3 : in  std_logic; 
        load_4 : in  std_logic; 
        load_5 : in  std_logic; 
        dout   : out std_logic_vector (7 downto 0)
        );
end fir_2d_trn_load; 
             
architecture Behavioral of fir_2d_trn_load is
  
  constant len_inData_vec : integer := line1'length * 5; 
  constant len_inLoad_vec : integer := 5;
  constant number_of_firs : integer := 5;
  constant DW_OUT_FIR_5x5 : integer := 8;
  constant binary_Point_Gain : integer := 17;

  signal fir_data_in   : std_logic_vector(len_inData_vec-1 downto 0)    := (others => '0');
  signal fir_load_in   : std_logic_vector(len_inLoad_vec-1 downto 0)    := (others => '0');
  signal fir_dout      : std_logic_vector(number_of_firs*19-1 downto 0) := (others => '0');
  signal fir_1_dout    : std_logic_vector(18 downto 0)                  := (others => '0');
  signal fir_2_dout    : std_logic_vector(18 downto 0)                  := (others => '0');
  signal fir_3_dout    : std_logic_vector(18 downto 0)                  := (others => '0');
  signal fir_4_dout    : std_logic_vector(18 downto 0)                  := (others => '0');
  signal fir_5_dout    : std_logic_vector(18 downto 0)                  := (others => '0');
  signal adder_1_dout  : std_logic_vector(19 downto 0)                  := (others => '0');
  signal adder_2_dout  : std_logic_vector(19 downto 0)                  := (others => '0');
  signal adder_3_dout  : std_logic_vector(20 downto 0)                  := (others => '0');
  signal adder_4_dout  : std_logic_vector(21 downto 0)                  := (others => '0');
  signal reg1_dout     : std_logic_vector(18 downto 0)                  := (others => '0');
  signal reg2_dout     : std_logic_vector(18 downto 0)                  := (others => '0');
  signal reg2_dout_ext : std_logic_vector(20 downto 0)                  := (others => '0');
  signal reg3_dout     : std_logic_vector(19 downto 0)                  := (others => '0');
  signal abs_dout      : std_logic_vector(21 downto 0)                  := (others => '0');
  signal mult_dout     : std_logic_vector(41 downto 0)                  := (others => '0');

  component fir_1d_trn_load is
    generic(
      IN_DW   : integer;  -- Input word width
      OUT_DW  : integer;  -- Output word width
      COEF_DW : integer;  -- coefficient word width
      TAPS    : integer;  -- # of taps + 1 output register
      DELAY   : integer   -- output delay line
                          -- (to adapt latency to system architecture)
      );
    port(
      ce_1     : in  std_logic;  -- clock enable
      clk_1    : in  std_logic;  -- clock
      load     : in  std_logic;  -- load coeff pulse
      coef     : in  std_logic_vector(COEF_DW-1 downto 0);
      din      : in  std_logic_vector(IN_DW-1 downto 0);
      out_data : out std_logic_vector(OUT_DW-1 downto 0)
      );
  end component;

  component MULT is
    generic(
      DW_IN_1 : integer;
      DW_IN_2 : integer;
      DELAY   : integer
      );
    port(
      ce_1        : in  std_logic;
      clk_1       : in  std_logic;
      FACTOR_IN_1 : in  std_logic_vector(DW_IN_1-1 downto 0);
      FACTOR_IN_2 : in  std_logic_vector(DW_IN_2-1 downto 0);
      PRODUCT_OUT : out std_logic_vector((DW_IN_1 + DW_IN_2 - 1) downto 0)
      );
  end component;

  component ADDER is
    generic(
      DW_IN : integer
      );
    port(
      ce_1    : in  std_logic;
      clk_1   : in  std_logic;
      S_IN_1  : in  std_logic_vector(DW_IN-1 downto 0);
      S_IN_2  : in  std_logic_vector(DW_IN-1 downto 0);
      SUM_OUT : out std_logic_vector(DW_IN downto 0)
      );
  end component;

  component ABS_VAL is
    generic(
      DW : integer
      );
    port(
      ce_1    : in  std_logic;
      clk_1   : in  std_logic;
      VAL_IN  : in  std_logic_vector(DW-1 downto 0);
      VAL_OUT : out std_logic_vector(DW-1 downto 0)
      );
  end component;

  component Pipeline_Reg is
    generic(
      DW_IN : integer
      );
    port(
      clk_1 : in  std_logic;
      en    : in  std_logic;
      D     : in  std_logic_vector(DW_IN-1 downto 0);
      Q     : out std_logic_vector(DW_IN-1 downto 0)
      );
  end component;

  component CONVERT is
    generic(
      DW_IN     : integer;
      DW_OUT    : integer;
      BIN_PNT : integer
      );
    port(
      clk_1 : in  std_logic;
      ce_1  : in  std_logic;
      din   : in  std_logic_vector(DW_IN-1 downto 0);
      dout  : out std_logic_vector(DW_OUT-1 downto 0)
      );
  end component;

begin
  
  -- Concatenate input signals to enable 1D-FIR instantiation 
  -- line
  fir_data_in(1*8-1 downto 0) <= line1;
  fir_data_in(2*8-1 downto 1*7+1) <= line2;
  fir_data_in(3*8-1 downto 2*7+2) <= line3;
  fir_data_in(4*8-1 downto 3*7+3) <= line4;
  fir_data_in(5*8-1 downto 4*7+4) <= line5;
  -- load
  fir_load_in(0) <= load_1;
  fir_load_in(1) <= load_2;
  fir_load_in(2) <= load_3;
  fir_load_in(3) <= load_4;
  fir_load_in(4) <= load_5;
  -- De-concatenate 1D-FIR outpus 
  fir_1_dout <= fir_dout(1*19-1 downto 0);
  fir_2_dout <= fir_dout(2*19-1 downto 1*18+1);
  fir_3_dout <= fir_dout(3*19-1 downto 2*18+2);
  fir_4_dout <= fir_dout(4*19-1 downto 3*18+3);
  fir_5_dout <= fir_dout(5*19-1 downto 4*18+4);

  -- instantiate 5 1D-FIR filter
  FIR_5x5 : for N in 0 to 4 generate
    fir_N : fir_1d_trn_load
      generic map(
        IN_DW   => 8,
        OUT_DW  => 19,
        COEF_DW => 7,
        TAPS    => 5,
        DELAY   => 8
        )
      port map(
        ce_1     => ce_1,
        clk_1    => clk_1,
        load     => fir_load_in(N),
        coef     => coef,
        din      => fir_data_in((N+1)*8-1 downto N*7+N),
        out_data => fir_dout((N+1)*19-1 downto N*18+N)
        );
  end generate;

  -- instantiate adder tree
  ADDER_1 : ADDER
    generic map(
      DW_IN => fir_1_dout'length
      )
    port map(
      ce_1    => ce_1,
      clk_1   => clk_1,
      S_IN_1  => fir_1_dout,
      S_IN_2  => fir_2_dout,
      SUM_OUT => adder_1_dout
      );

  ADDER_2 : ADDER
    generic map(
      DW_IN => fir_3_dout'length
      )
    port map(
      ce_1    => ce_1,
      clk_1   => clk_1,
      S_IN_1  => fir_3_dout,
      S_IN_2  => fir_4_dout,
      SUM_OUT => adder_2_dout
      );

  ADDER_3 : ADDER
    generic map(
      DW_IN => adder_1_dout'length
      )
    port map(
      ce_1    => ce_1,
      clk_1   => clk_1,
      S_IN_1  => adder_1_dout,
      S_IN_2  => adder_2_dout,
      SUM_OUT => adder_3_dout
      );

  reg2_dout_ext <= "00" & reg2_dout;
  ADDER_4 : ADDER
    generic map(
      DW_IN => adder_3_dout'length
      )
    port map(
      ce_1    => ce_1,
      clk_1   => clk_1,
      S_IN_1  => adder_3_dout,
      S_IN_2  => reg2_dout_ext,
      SUM_OUT => adder_4_dout
      );

  REG_1 : Pipeline_Reg
    generic map(
      DW_IN => fir_5_dout'length
      )
    port map(
      clk_1 => clk_1,
      en    => '1',
      D     => fir_5_dout,
      Q     => reg1_dout
      );

  REG_2 : Pipeline_Reg
    generic map(
      DW_IN => reg1_dout'length
      )
    port map(
      clk_1 => clk_1,
      en    => '1',
      D     => reg1_dout,
      Q     => reg2_dout
      );

  -- instantiate components for output scaling
  REG_GAIN : Pipeline_Reg
    generic map(
      DW_IN => gain'length
      )
    port map(
      clk_1 => clk_1,
      en    => load_5,
      D     => gain,
      Q     => reg3_dout
      );

  ABS_1 : ABS_VAL
    generic map(
      DW => adder_4_dout'length
      )
    port map(
      ce_1    => ce_1,
      clk_1   => clk_1,
      VAL_IN  => adder_4_dout,
      VAL_OUT => abs_dout
      );

  MULT_1 : MULT
    generic map(
      DW_IN_1 => abs_dout'length,
      DW_IN_2 => reg3_dout'length,
      DELAY   => 3
      )
    port map(
      ce_1        => ce_1,
      clk_1       => clk_1,
      FACTOR_IN_1 => abs_dout,
      FACTOR_IN_2 => reg3_dout,
      PRODUCT_OUT => mult_dout
      );

  CONV_1 : CONVERT
    generic map(
      DW_IN   => mult_dout'length,
      DW_OUT  => DW_OUT_FIR_5x5,
      BIN_PNT => binary_Point_Gain
      )
    port map(
      clk_1 => clk_1,
      ce_1  => ce_1,
      din   => mult_dout,
      dout  => dout
      );
  
end Behavioral; 
