-------------------------------------------------------------------------------
-- Company    :  HSLU
-- Engineer   :  Gai, Waj
-- 
-- Create Date:  27-May-11 
-- Project    :  RT Video Lab 1: Exercise 3
-- Description:  Testbench for 5x5 FIR filter with loadable coefficients
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std; use std.textio.all;
             
ENTITY fir_2d_trn_load_tb IS
END fir_2d_trn_load_tb;

ARCHITECTURE behavior OF fir_2d_trn_load_tb IS 

  -- Component Declaration for the Unit Under Test (UUT)
  COMPONENT fir_2d_trn_load
    PORT(
      ce_1 	: IN  std_logic;
      clk_1	: IN  std_logic;
      coef 	: IN  std_logic_vector(6 downto 0);
      gain 	: IN  std_logic_vector(19 downto 0);
      line1	: IN  std_logic_vector(7 downto 0);
      line2	: IN  std_logic_vector(7 downto 0);
      line3	: IN  std_logic_vector(7 downto 0);
      line4	: IN  std_logic_vector(7 downto 0);
      line5	: IN  std_logic_vector(7 downto 0);
      load_1 	: IN  std_logic;
      load_2 	: IN  std_logic;
      load_3 	: IN  std_logic;
      load_4 	: IN  std_logic;
      load_5 	: IN  std_logic;
      dout 	: OUT  std_logic_vector(7 downto 0)
      );
  END COMPONENT;
  
  -- clock frequency definition
  constant clk_freq : real := 100.0;                  -- 100 MHz
  constant t_clk    : time := 1000.0/clk_freq * 1 ns; -- one clock period
       
  -- define delays for timing-simulation
  constant t_stim : time := 0.25*t_clk; -- delay time for stimuli application
  constant t_prop : time := 0.25*t_clk; -- propagation delay for UUT mimic

  -- design parameters
  constant IN_DW 	: integer := 8;
  constant OUT_DW	: integer := 8;
  constant COEF_DW      : integer := 7;
  constant TAPS	        : integer := 5;

  -- Input signals
  signal clk 	  : std_logic := '1';
  signal line1, line2, line3, line4, line5
                  : std_logic_vector(7 downto 0) := (others => '0');
  signal load_1, load_2, load_3, load_4, load_5
                  : std_logic := '0';
  signal coef 	  : std_logic_vector(6 downto 0) := (others => '0');
  signal gain 	  : std_logic_vector(19 downto 0) := (others => '0');

  -- Output signals
  signal dout : std_logic_vector(7 downto 0) := (others => '0');

  -- local testbench control signals
  signal load_done : boolean := false;
  signal err_cnt   : natural := 0;

  -- I/O files
  -- Filter        : 
  -------------------
  -- 1_Identity    : 
  -- 2_Edge        : 
  -- 3_SobelX      : 
  -- 4_SobelY      :  
  -- 5_SobelXY     : 
  -- 6_Blur        : 
  -- 7_Smooth      :  
  -- 8_Sharpen     : 
  -- 9_Gaussian    : 
  -------------------
  constant mask_type : string := "9_Gaussian";
  file f_stimuli_d1 : text is in "..\5x5_Filter\" & mask_type & "\Line1.txt";
  file f_stimuli_d2 : text is in "..\5x5_Filter\" & mask_type & "\Line2.txt";
  file f_stimuli_d3 : text is in "..\5x5_Filter\" & mask_type & "\Line3.txt";
  file f_stimuli_d4 : text is in "..\5x5_Filter\" & mask_type & "\Line4.txt";
  file f_stimuli_d5 : text is in "..\5x5_Filter\" & mask_type & "\Line5.txt";
  file f_stimuli_c  : text is in "..\5x5_Filter\" & mask_type & "\Coef.txt";
  file f_stimuli_g  : text is in "..\5x5_Filter\" & mask_type & "\Gain.txt";
  file f_exp_resp   : text is in "..\5x5_Filter\" & mask_type & "\Dout.txt";

 begin

  -- Instantiate the Unit Under Test 
  uut : fir_2d_trn_load
    port map (
      ce_1    => '1',
      clk_1   => clk,
      coef    => coef,
      gain    => gain,
      line1   => line1,
      line2   => line2,
      line3   => line3,
      line4   => line4,
      line5   => line5,
      load_1  => load_1,
      load_2  => load_2,
      load_3  => load_3,
      load_4  => load_4,
      load_5  => load_5,
      dout    => dout
      );
  
  -- Clock generation
  p_clk :process
  begin
    wait for t_clk/2;
    clk <= not clk;
  end process;

  -- apply coeff/gain load stimuli to UUT
  p_stim_c:process(clk)
    variable inline   : line;
    variable char     : character;
    variable cnt_load : natural := 0;
  begin
    if clk'event and clk = '1' then
      cnt_load := cnt_load + 1;
      -- read gain value (only once)
      if cnt_load = 1 then
        readline(f_stimuli_g,inline);
        for k in 19 downto 0 loop
          read(inline,char);
          if char = '0' then
            gain(k) <= '0' after t_stim; 
          else
            gain(k) <= '1' after t_stim;
          end if;
        end loop;
      end if;
      -- generate 5 consecutive load-pulses each 5 cycles long
      if cnt_load = 100 then
        load_1 <= '1' after t_stim;
      elsif cnt_load = 105 then
        load_1 <= '0' after t_stim;
        load_2 <= '1' after t_stim;
      elsif cnt_load = 110 then
        load_2 <= '0' after t_stim;
        load_3 <= '1' after t_stim;
      elsif cnt_load = 115 then
        load_3 <= '0' after t_stim;
        load_4 <= '1' after t_stim;
      elsif cnt_load = 120 then
        load_4 <= '0' after t_stim;
        load_5 <= '1' after t_stim;
      elsif cnt_load = 125 then
        load_5 <= '0' after t_stim;
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
          -- start application of input data
          load_done <= true;
        end if;
      end if;
    end if;
  end process;

  -- apply data_in stimuli to UUT
  p_stim_d:process(clk)
    variable inl1, inl2, inl3, inl4, inl5  : line;
    variable char1,char2,char3,char4,char5 : character;
  begin
    if clk'event and clk = '1' then
      if load_done and (not endfile(f_stimuli_d1)) then
        readline(f_stimuli_d1,inl1);
        readline(f_stimuli_d2,inl2);
        readline(f_stimuli_d3,inl3);
        readline(f_stimuli_d4,inl4);
        readline(f_stimuli_d5,inl5);
        for k in IN_DW-1 downto 0 loop
          read(inl1,char1);
          read(inl2,char2);
          read(inl3,char3);
          read(inl4,char4);
          read(inl5,char5);
          if char1 = '0' then line1(k) <= '0' after t_stim; 
          else                line1(k) <= '1' after t_stim; end if;
          if char2 = '0' then line2(k) <= '0' after t_stim; 
          else                line2(k) <= '1' after t_stim; end if;
          if char3 = '0' then line3(k) <= '0' after t_stim; 
          else                line3(k) <= '1' after t_stim; end if;
          if char4 = '0' then line4(k) <= '0' after t_stim; 
          else                line4(k) <= '1' after t_stim; end if;
          if char5 = '0' then line5(k) <= '0' after t_stim; 
          else                line5(k) <= '1' after t_stim; end if;
        end loop;
      elsif endfile(f_stimuli_d1) then
        -- end of simulation
        assert false report "******** End of simulation : " &
                            "Total Number of Mismatches detected = " &
                            integer'image(err_cnt) &
                            " ********"
          severity failure;
      end if;
    end if;
  end process;

  -- compare expected with actual responses
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
          if dout(k) = '0' then
            str_act(k+1) := '0';
          elsif dout(k) = '1' then
            str_act(k+1) := '1';
          end if;
          write(line_act, str_act(k+1));
          -- get all bits in expected output
          read(line_exp, str_exp(k+1));
        end loop;
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
