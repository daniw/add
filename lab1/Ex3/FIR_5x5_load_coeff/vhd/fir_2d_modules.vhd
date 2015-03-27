-------------------------------------------------------------------------------
-- Company    :  HSLU
-- Engineer   :  Gai, Waj
-- 
-- Create Date:  26-May-11
-- Project    :  RT Video Lab 1: Exercise 3
-- Description:  Components for 2D 5x5-FIR filter 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Multiplier
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity MULT is
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

end MULT;

architecture structural of MULT is
  type DELAY_TYPE is array(DELAY-1 downto 0) of std_logic_vector((DW_IN_1 + DW_IN_2 - 1) downto 0);

  signal FACTOR_1_BUF : unsigned(DW_IN_1-1 downto 0);
  signal FACTOR_2_BUF : unsigned(DW_IN_2-1 downto 0);
  signal DelayLine    : DELAY_TYPE := (others => (others => '0'));
  
begin
  FACTOR_1_BUF <= unsigned(FACTOR_IN_1);
  FACTOR_2_BUF <= unsigned(FACTOR_IN_2);

  x0_multiply : process(clk_1)
  begin
    if clk_1'event and clk_1 = '1' then
      if ce_1 = '1' then
        DelayLine(DELAY-1)          <= std_logic_vector(FACTOR_1_BUF * FACTOR_2_BUF);
        DelayLine(DELAY-2 downto 0) <= DelayLine(DELAY-1 downto 1);
        PRODUCT_OUT                 <= DelayLine(0);
      end if;
    end if;
  end process x0_multiply;
end structural;


-------------------------------------------------------------------------------
-- Adder
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity ADDER is
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

end ADDER;

architecture structural of ADDER is
  signal IN_Sign1 : signed(DW_IN downto 0);
  signal IN_Sign2 : signed(DW_IN downto 0);
begin
  -- sign-extension of inputs
  IN_Sign1 <= signed(S_IN_1(DW_IN-1) & '1' & S_IN_1(DW_IN-2 downto 0)) when S_IN_1(DW_IN-1) = '1' else
              signed(S_IN_1(DW_IN-1) & '0' & S_IN_1(DW_IN-2 downto 0));
  
  IN_Sign2 <= signed(S_IN_2(DW_IN-1) & '1' & S_IN_2(DW_IN-2 downto 0)) when S_IN_2(DW_IN-1) = '1' else
              signed(S_IN_2(DW_IN-1) & '0' & S_IN_2(DW_IN-2 downto 0));
  
  x0_ADD : process(clk_1)
  begin
    if clk_1'event and clk_1 = '1' then
      if ce_1 = '1' then
        SUM_OUT <= std_logic_vector(signed(IN_Sign1 + IN_Sign2));
      end if;
    end if;
  end process x0_ADD;
  
end structural;


-------------------------------------------------------------------------------
-- absolute Value
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity ABS_VAL is
  generic(
    DW: integer
    );

  port(
    ce_1    : in  std_logic;
    clk_1   : in  std_logic;
    VAL_IN  : in  std_logic_vector(DW-1 downto 0);
    VAL_OUT : out std_logic_vector(DW-1 downto 0)
    );
end ABS_VAL;

architecture structural of ABS_VAL is
  signal   OutReg : std_logic_vector(DW-1 downto 0);
  
begin
  x0_abs : process(clk_1)
  begin
    if clk_1'event and clk_1 = '1' then
      if ce_1 = '1' then

    
        -- :ToDo: ------------------------------------------------------------
        -- Implement logic to generate absolute value of VAL_IN
        -----------------------------------------------------------------------
        OutReg <= .....
          
            
        -- additional output register
        VAL_OUT <= OutReg;
      end if;
    end if;
  end process x0_abs;
  
end structural;

-------------------------------------------------------------------------------
-- Pipeline register
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity Pipeline_Reg is
  generic(
    DW_IN : integer
    );
  port(
    clk_1 : in  std_logic;
    en    : in  std_logic;
    D     : in  std_logic_vector(DW_IN-1 downto 0);
    Q     : out std_logic_vector(DW_IN-1 downto 0)
    );
end Pipeline_Reg;

architecture structural of Pipeline_Reg is
begin
  p_reg : process(clk_1)
  begin
    if clk_1'event and clk_1 = '1' then
      if en = '1' then
        Q <= D;
      end if;
    end if;
  end process p_reg;
end structural;

-------------------------------------------------------------------------------
-- Truncation/Saturation unit
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity CONVERT is
  generic(
    DW_IN   : integer;
    DW_OUT  : integer;
    BIN_PNT : integer
    );
  port(
    clk_1 : in  std_logic;
    ce_1  : in  std_logic;
    din   : in  std_logic_vector(DW_IN-1 downto 0);
    dout  : out std_logic_vector(DW_OUT-1 downto 0)
    );
end CONVERT;

architecture structural of CONVERT is

begin
  x0_CONV : process(clk_1)
  begin
    if clk_1'event and clk_1 = '1' then
      if ce_1 = '1' then


        -- :ToDo: ------------------------------------------------------------
        -- Implement logic to scale the unsigned value din, which has a total
        -- number of DW_IN bits and BIN_PNT fractional bits, such that
        --  a) dout has a total number of DW_OUT bits and zero fractional bits
        --  b) saturation is applied if the value of din exceeds the maximum 
        --     unsigned value of dout
        -----------------------------------------------------------------------
        dout <= .....


      end if;
    end if;
  end process;
end structural;
