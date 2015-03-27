-------------------------------------------------------------------------------
-- Company    :  HSLU
-- Engineer   :  Gai, Waj
-- 
-- Create Date:  19-May-11 
-- Project    :  RT Video Lab 1: Exercise 2
-- Description:  Testbench for 5-tap FIR filter with loadable coefficients
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std; use std.textio.all;
             
entity fir_1d_load_tb IS
end fir_1d_load_tb;

architecture behavior of fir_1d_load_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  component fir_1d_trn_load is
    generic
      (IN_DW, OUT_DW, COEF_DW, TAPS, DELAY : integer);
  port
    (ce_1     : in  std_logic;          -- clock enable
     clk_1    : in  std_logic;          -- clock
     load     : in  std_logic;          -- load coeff pulse
     coef     : in  std_logic_vector;   -- coefficients
     din      : in  std_logic_vector;   -- data input
     out_data : out std_logic_vector    -- filtered output data
     );
  end component;
    
  -- clock frequency definition
  constant clk_freq : real := 100.0;                  -- 100 MHz
  constant t_clk    : time := 1000.0/clk_freq * 1 ns; -- one clock period
       
  -- define delays for timing-simulation
  constant t_stim : time := 0.25*t_clk; -- delay time for stimuli application
  constant t_prop : time := 0.25*t_clk; -- propagation delay for UUT mimic

  -- design parameters
  constant IN_DW 	: integer := 8;
  constant OUT_DW	: integer := 19;
  constant COEF_DW: integer := 7;
  constant TAPS	: integer := 5;
  constant DELAY	: integer := 8;  -- adapt to adjust filter latency!!!

  -- inputs signals
  signal clk      : std_logic := '0';
  signal load 	  : std_logic := '0';
  signal coef	  : std_logic_vector(COEF_DW-1 downto 0) := (others => '0');
  signal din 	  : std_logic_vector(IN_DW-1 downto 0) := (others => '0');
                                                                                          
  -- outputs signals
  signal out_data : std_logic_vector(OUT_DW-1 downto 0) := (others => '0');

  -- local testbench control signals
  signal load_done : boolean := false;
  signal err_cnt : natural := 0;

  -- I/O files
  -- Expeceted responses are generated for the middle row of the corresponding
  -- filter mask, which correspnds to the following coefficients:
  -- Filter        : b0   b1   b2   b3   b4
  ------------------------------------------
  -- 1_Identity    :  0    0    1    0    0
  -- 2_Edge        :  0   -1    8   -1    0
  -- 3_SobelX      :  0    2    0   -2    0
  -- 4_SobelY      :  0    0    0    0    0  
  -- 5_SobelXY     :  0   -1    0    1    0
  -- 6_Blur        :  1    0    0    0    1 
  -- 7_Smooth      :  1    5   44    5    1  
  -- 8_Sharpen     :  0   -2   32   -2    0
  -- 9_Gaussian    :  2    4    8    4    2
  ------------------------------------------
  constant mask_type : string := "7_Smooth";
  file f_stimuli_d : text is in "..\1x5_Filter\" & mask_type & "\FIR_IN.txt";
  file f_stimuli_c : text is in "..\1x5_Filter\" & mask_type & "\COEF_SEQ.txt";
  file f_exp_resp  : text is in "..\1x5_Filter\" & mask_type & "\FIR_OUT.txt";
  file f_act_resp  : text is out "..\1x5_Filter\" & mask_type & "\FIR_VHDL_OUT.txt";
                                  
begin

  -- Instantiate the Unit Under Test 
  uut : fir_1d_trn_load
    generic map (
      IN_DW   => IN_DW,
      OUT_DW  => OUT_DW,
      COEF_DW => COEF_DW,
      TAPS    => TAPS,
      DELAY   => DELAY
      )
    port map (
      ce_1     => '1',
      clk_1    => clk,
      load     => load,
      coef     => coef,
      din      => din,
      out_data => out_data
      );
  
  -- Clock generation
  p_clk :process
  begin
    wait for t_clk/2;
    clk <= not clk;
  end process;

  -- apply coeff_load stimuli to UUT
  p_stim_c:process(clk)
    variable inline   : line;
    variable char     : character;
    variable cnt_load : natural := 0;
  begin
    if clk'event and clk = '1' then
      cnt_load := cnt_load + 1;
      -- generate load-pulse 5 cycles long
      if cnt_load = 100 then
        load <= '1' after t_stim;
      elsif cnt_load = 105 then
        load <= '0' after t_stim;
      end if;
      -- apply coefficients 1 cycle too early and one cycle too long in order
      -- to check correct load sequence (see COEF_SEQ.txt)
      if cnt_load >= 100 then
        if not endfile(f_stimuli_c) then
          readline(f_stimuli_c,inline);
          for k in COEF_DW-1 downto 0 loop
            read(inline,char);
            if char = '0' then
              coef(k) <= '0' after t_stim; 
            else
              coef(k) <= '1' after t_stim;
            end if;
          end loop;
        else
          -- start data_in application
          load_done <= true;
        end if;
      end if;
    end if;
  end process;

  -- apply data_in stimuli to UUT
  p_stim_d:process(clk)
    variable inline : line;
    variable char   : character;
  begin
    if clk'event and clk = '1' then
      if load_done and (not endfile(f_stimuli_d)) then
        readline(f_stimuli_d,inline);
        for k in IN_DW-1 downto 0 loop
          read(inline,char);
          if char = '0' then
            din(k) <= '0' after t_stim; 
          else
            din(k) <= '1' after t_stim;
          end if;
        end loop;
      elsif endfile(f_stimuli_d) then
        -- end of simulation
        assert false report "******** End of simulation : " &
                            "Total Number of Mismatches detected = " &
                            integer'image(err_cnt) &
                            " ********"
          severity failure;
      end if;
    end if;
  end process;

  -- compare expected with actual responses and write output file
  p_check: process(clk)
    variable line_exp, line_act : line;
    variable str_exp, str_act   : string(OUT_DW downto 1);
  begin
    if clk'event and clk = '1' then
      if load_done then
        -- read expected value from file
        readline(f_exp_resp, line_exp);
        for k in OUT_DW-1 downto 0 loop
          -- get all bits in actual output
          if out_data(k) = '0' then
            str_act(k+1) := '0';
          elsif out_data(k) = '1' then
            str_act(k+1) := '1';
          end if;
          write(line_act, str_act(k+1));
          -- get all bits in expected output
          read(line_exp, str_exp(k+1));
        end loop;
        -- write actual value to file
        writeline(f_act_resp, line_act);
        -- compare actual and expected output vector
        if not (str_exp = str_act) then
          assert false
            report "expected: " & str_exp & "  actual: " & str_act severity note;
          err_cnt <= err_cnt + 1;
        end if;
      end if;
    end if;
  end process;

end;
