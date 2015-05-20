-------------------------------------------------------------------------------
-- Entity: floppy
-- Author: daniw
-------------------------------------------------------------------------------
-- Description: floppy
-- Floppy Controller
-------------------------------------------------------------------------------
-- Total # of FFs: ... tbd ...
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity floppy is
    port(
        rst             : in    std_logic;
        clk             : in    std_logic;
        -- input signals from cpu
        enable          : in    std_logic;
        mode            : in    std_logic;
        pitch_fix       : in    unsigned(16 downto 0);
        -- output signals to cpu
        status_init     : out   std_logic;
        status_melody   : out   std_logic;
        -- output signals to floppy
        floppy_step     : out   std_logic;
        floppy_dir      : out   std_logic;
    );
end floppy;

architecture rtl of floppy is

    -- constants to specify module properties
    -- pitch width
    constant PITCH_WIDTH        :   integer = 7; -- 127
    -- melody duration width
    constant MEL_DUR_WIDTH      :   integer = 10; -- 1023
    -- melody duration counter width
    constant MEL_DUR_CNT_WIDTH  :   integer = 27; -- 51150000 (1023 * 50000)
    -- melody address width
    constant MEL_ADDR_WIDTH     :   integer = 10; -- 1023
    -- converted pitch width
    constant PITCH_CONV_WIDTH   :   integer = 23; -- 5772367
    -- step counter width
    constant STEP_CNT_WIDTH     :   integer = 7; -- 80

    -- constant to define number of clock cycles per duration tick
    constant NOF_CLK_DUR        :   integer = 50000;

    -- constant for init pitch
    constant PITCH_INIT         :   unsigned(PITCH_WIDTH-1 downto 0) = 69; -- 440 [Hz]

    -- melody rom
    type t_mel_rom is array (0 to 2**MEL_ADDR_WIDTH-1) of std_logic_vector(MEL_DUR_WIDTH+PITCH_WIDTH-1 downto 0); -- new type instead of std_logic_vector for easier separation of duration and pitch
    constant mel_rom            : t_mel_rom := (
        0 => std_logic_vector(to_unsigned( 65, PITCH_WIDTH)) & std_logic_vector(to_unsigned( 500, MEL_DUR_WIDTH)),
        1 => std_logic_vector(to_unsigned(  0, PITCH_WIDTH)) & std_logic_vector(to_unsigned( 100, MEL_DUR_WIDTH)),
        -- End of melody -> don not change!
        1 => std_logic_vector(to_unsigned(  0, PITCH_WIDTH)) & std_logic_vector(to_unsigned(   0, MEL_DUR_WIDTH)),
    );

    -- signal to cut pitch_fix
    signal pitch_fix

    -- signals for buffering outputs
    signal status_init_reg      :   std_logic;
    signal status_melody_reg    :   std_logic;
    signal step_reg             :   std_logic;
    signal dir_reg              :   std_logic;

    -- signal to indicate end of actual tone
    signal tone_end             :   std_logic;

    -- signal that contains duration of actual tone
    signal duration_melody      :   std_logic_vector(MEL_DUR_WIDTH-1 downto 0); -- in milliseconds

    -- signal that contains pitch of actual tone
    signal pitch_melody         :   std_logic_vector(PITCH_WIDTH-1 downto 0);

    -- pitch after pitch selector
    signal pitch_sel            :   unsigned(PITCH_WIDTH-1 downto 0);

    -- pitch after converted to number of clocks
    signal pitch_conv           :   std_logic_vector(PITCH_CONV_WIDTH-1 downto 0);

    -- step after divider
    signal step_int             :   std_logic;

    -- edge detection of step_reg
    signal step_edge            :   std_logic;
    signal step_edge_prev       :   std_logic;

    -- signal to indicate step_cnt end
    signal step_cnt_end         :   std_logic;

    -- counters
    -- mel_dur_cnt
    signal mel_dur_cnt          :   unsigned(MEL_DUR_CNT_WIDTH-1 downto 0);
    -- mel_tone_cnt
    signal mel_tone_cnt         :   unsigned(MEL_ADDR_WIDTH-1 downto 0);
    -- step_divider
    signal step_divider         :   unsigned(PITCH_CONV_WIDTH-1 downto 0);
    -- step_cnt
    signal step_cnt             :   unsigned(STEP_CNT_WIDTH-1 downto 0);

begin
    -----------------------------------------------------------------------------
    -- combinatorial process to cut pitch_fix to PITCH_WIDTH
    -- in:
    --    pitch_fix_reg
    -- out:
    --    pitch_fix
    -----------------------------------------------------------------------------
    pitch_fix_cut: process(pitch_fix_reg)
    begin
        pitch_fix <= pitch_fix_reg(PITCH_WIDTH-1 downto 0);
    end process;

    -----------------------------------------------------------------------------
    -- combinatorial process to connect buffered outputs to the outputs
    -- in:
    --    status_init_reg
    --    status_melody_reg
    --    step_reg
    --    dir_reg
    -- out:
    --    status_init
    --    status_melody
    --    step
    --    dir
    -----------------------------------------------------------------------------
    reg_out: process(status_init_reg, status_melody_reg, step_reg, dir_reg)
    begin
        status_init     <= status_init_reg;
        status_melody   <= status_melody_reg;
        step            <= step_reg;
        dir             <= dir_reg;
    end process;

    -----------------------------------------------------------------------------
    -- sequential process to count the tone duration
    -- in:
    --    rst
    --    clk
    --    mode
    --    enable
    --    status_melody_reg
    --    duration_melody
    --    mel_dur_cnt
    -- out:
    --    mel_dur_cnt
    --    tone_end
    -----------------------------------------------------------------------------
    dur_cnt: process(rst, clk)
    begin
        if rst = '1' then
            mel_dur_cnt <= '0';
            tone_end <= '0';
        elsif rising_edge(clk) then
            if ((enable = '1') and (mode = '1') and (status_melody_reg = '1')) then
                if mel_dur_cnt = 0 then
                    mel_dur_cnt <= unsigned(duration_melody) * NOF_CLK_DUR;
                    tone_end <= '1';
                else
                    mel_dur_cnt <= mel_dur_cnt - 1;
                    tone_end <= '0';
                end if;
            else
                mel_dur_cnt <= 2;
                tone_end <= '0';
            end if;
        end if;
    end process;

    -----------------------------------------------------------------------------
    -- sequential process to count the number of tones played
    -- in:
    --    rst
    --    clk
    --    mode
    --    enable
    --    status_melody_reg
    --    duration_melody
    --    tone_end
    --    mel_tone_cnt
    -- out:
    --    mel_tone_cnt
    -----------------------------------------------------------------------------
    tone_cnt: process(rst, clk)
    begin
        if rst = '1' then
            mel_tone_cnt <= 0;
        elsif rising_edge(clk) then
            if ((enable = '1') and (mode = '1') and (status_melody_reg = '1')) then
                if tone_end = '1' then
                    mel_tone_cnt <= mel_tone_cnt + 1;
                else
                    mel_tone_cnt <= mel_tone_cnt;
                end if;
            else
                mel_tone_cnt <= 0;
            end if;
        end if;
    end process;

    -----------------------------------------------------------------------------
    -- combinatorial process for melody rom
    -- in:
    --    mel_tone_cnt
    -- out:
    --    duration_melody
    --    pitch_melody
    -----------------------------------------------------------------------------
    melody_rom: process(mel_tone_cnt)
    begin
        duration_melody <= rom(to_integer(mel_tone_cnt)(MEL_DUR_WIDTH+PITCH_WIDTH-1 downto PITCH_WIDTH);
        pitch_melody    <= rom(to_integer(mel_tone_cnt)(PITCH_WIDTH-1 downto 0);
    end process;

    -----------------------------------------------------------------------------
    -- combinatorial process to detect end of melody
    -- in:
    --    pitch_melody
    --    duration_melody
    -- out:
    --    status_melody_reg
    -----------------------------------------------------------------------------
    mel_end_det:    process(pitch_melody, duration_melody)
    begin
        if ((unsigned(duration_melody) = 0 and (unsigned(duration_melody)) = 0) then
            status_melody_reg <= '0';
        else
            status_melody_reg <= '1';
        end if;
    end process;

    -----------------------------------------------------------------------------
    -- combinatorial process for pitch selector
    -- in:
    --    status_init_reg
    --    mode
    --    pitch_fix
    --    pitch_melody
    -- out:
    --    pitch_sel
    -----------------------------------------------------------------------------
    pitch_sel: process(status_init_reg, mode, pitch_fix, pitch_melody)
    begin
        pitch_sel <= PITCH_INIT   when (status_init_reg = '1') else
                     pitch_melody when (mode = '1')            else
                     pitch_fix;
    end process;

    -----------------------------------------------------------------------------
    -- combinatorial process for converting pitch to number of cycles
    -- in:
    --    pitch_sel
    -- out:
    --    pitch_conv
    -----------------------------------------------------------------------------
    pitch_conv: process(pitch_sel)
    begin
        with pitch_sel select
        --                                         # clk                                          MIDI        Frequency
        pitch_conv <= std_logic_vector(to_unsigned(5772367, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(  1, PITCH_WIDTH)), -- 8.661 [Hz]
                      std_logic_vector(to_unsigned(5448389, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(  2, PITCH_WIDTH)), -- 9.177 [Hz]
                      std_logic_vector(to_unsigned(5142594, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(  3, PITCH_WIDTH)), -- 9.722 [Hz]
                      std_logic_vector(to_unsigned(4853963, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(  4, PITCH_WIDTH)), -- 10.30 [Hz]
                      std_logic_vector(to_unsigned(4581531, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(  5, PITCH_WIDTH)), -- 10.91 [Hz]
                      std_logic_vector(to_unsigned(4324389, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(  6, PITCH_WIDTH)), -- 11.56 [Hz]
                      std_logic_vector(to_unsigned(4081680, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(  7, PITCH_WIDTH)), -- 12.24 [Hz]
                      std_logic_vector(to_unsigned(3852593, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(  8, PITCH_WIDTH)), -- 12.97 [Hz]
                      std_logic_vector(to_unsigned(3636363, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(  9, PITCH_WIDTH)), -- 13.75 [Hz]
                      std_logic_vector(to_unsigned(3432270, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 10, PITCH_WIDTH)), -- 14.56 [Hz]
                      std_logic_vector(to_unsigned(3239631, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 11, PITCH_WIDTH)), -- 15.43 [Hz]
                      std_logic_vector(to_unsigned(3057805, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 12, PITCH_WIDTH)), -- 16.35 [Hz]
                      std_logic_vector(to_unsigned(2886183, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 13, PITCH_WIDTH)), -- 17.32 [Hz]
                      std_logic_vector(to_unsigned(2724194, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 14, PITCH_WIDTH)), -- 18.35 [Hz]
                      std_logic_vector(to_unsigned(2571297, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 15, PITCH_WIDTH)), -- 19.44 [Hz]
                      std_logic_vector(to_unsigned(2426981, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 16, PITCH_WIDTH)), -- 20.60 [Hz]
                      std_logic_vector(to_unsigned(2290765, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 17, PITCH_WIDTH)), -- 21.82 [Hz]
                      std_logic_vector(to_unsigned(2162194, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 18, PITCH_WIDTH)), -- 23.12 [Hz]
                      std_logic_vector(to_unsigned(2040840, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 19, PITCH_WIDTH)), -- 24.49 [Hz]
                      std_logic_vector(to_unsigned(1926296, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 20, PITCH_WIDTH)), -- 25.95 [Hz]
                      std_logic_vector(to_unsigned(1818181, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 21, PITCH_WIDTH)), -- 27.5 [Hz]
                      std_logic_vector(to_unsigned(1716135, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 22, PITCH_WIDTH)), -- 29.13 [Hz]
                      std_logic_vector(to_unsigned(1619815, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 23, PITCH_WIDTH)), -- 30.86 [Hz]
                      std_logic_vector(to_unsigned(1528902, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 24, PITCH_WIDTH)), -- 32.70 [Hz]
                      std_logic_vector(to_unsigned(1443091, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 25, PITCH_WIDTH)), -- 34.64 [Hz]
                      std_logic_vector(to_unsigned(1362097, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 26, PITCH_WIDTH)), -- 36.70 [Hz]
                      std_logic_vector(to_unsigned(1285648, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 27, PITCH_WIDTH)), -- 38.89 [Hz]
                      std_logic_vector(to_unsigned(1213490, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 28, PITCH_WIDTH)), -- 41.20 [Hz]
                      std_logic_vector(to_unsigned(1145382, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 29, PITCH_WIDTH)), -- 43.65 [Hz]
                      std_logic_vector(to_unsigned(1081097, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 30, PITCH_WIDTH)), -- 46.24 [Hz]
                      std_logic_vector(to_unsigned(1020420, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 31, PITCH_WIDTH)), -- 48.99 [Hz]
                      std_logic_vector(to_unsigned( 963148, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 32, PITCH_WIDTH)), -- 51.91 [Hz]
                      std_logic_vector(to_unsigned( 909090, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 33, PITCH_WIDTH)), -- 55 [Hz]
                      std_logic_vector(to_unsigned( 858067, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 34, PITCH_WIDTH)), -- 58.27 [Hz]
                      std_logic_vector(to_unsigned( 809907, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 35, PITCH_WIDTH)), -- 61.73 [Hz]
                      std_logic_vector(to_unsigned( 764451, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 36, PITCH_WIDTH)), -- 65.40 [Hz]
                      std_logic_vector(to_unsigned( 721545, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 37, PITCH_WIDTH)), -- 69.29 [Hz]
                      std_logic_vector(to_unsigned( 681048, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 38, PITCH_WIDTH)), -- 73.41 [Hz]
                      std_logic_vector(to_unsigned( 642824, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 39, PITCH_WIDTH)), -- 77.78 [Hz]
                      std_logic_vector(to_unsigned( 606745, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 40, PITCH_WIDTH)), -- 82.40 [Hz]
                      std_logic_vector(to_unsigned( 572691, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 41, PITCH_WIDTH)), -- 87.30 [Hz]
                      std_logic_vector(to_unsigned( 540548, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 42, PITCH_WIDTH)), -- 92.49 [Hz]
                      std_logic_vector(to_unsigned( 510210, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 43, PITCH_WIDTH)), -- 97.99 [Hz]
                      std_logic_vector(to_unsigned( 481574, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 44, PITCH_WIDTH)), -- 103.8 [Hz]
                      std_logic_vector(to_unsigned( 454545, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 45, PITCH_WIDTH)), -- 110 [Hz]
                      std_logic_vector(to_unsigned( 429033, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 46, PITCH_WIDTH)), -- 116.5 [Hz]
                      std_logic_vector(to_unsigned( 404953, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 47, PITCH_WIDTH)), -- 123.4 [Hz]
                      std_logic_vector(to_unsigned( 382225, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 48, PITCH_WIDTH)), -- 130.8 [Hz]
                      std_logic_vector(to_unsigned( 360772, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 49, PITCH_WIDTH)), -- 138.5 [Hz]
                      std_logic_vector(to_unsigned( 340524, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 50, PITCH_WIDTH)), -- 146.8 [Hz]
                      std_logic_vector(to_unsigned( 321412, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 51, PITCH_WIDTH)), -- 155.5 [Hz]
                      std_logic_vector(to_unsigned( 303372, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 52, PITCH_WIDTH)), -- 164.8 [Hz]
                      std_logic_vector(to_unsigned( 286345, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 53, PITCH_WIDTH)), -- 174.6 [Hz]
                      std_logic_vector(to_unsigned( 270274, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 54, PITCH_WIDTH)), -- 184.9 [Hz]
                      std_logic_vector(to_unsigned( 255105, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 55, PITCH_WIDTH)), -- 195.9 [Hz]
                      std_logic_vector(to_unsigned( 240787, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 56, PITCH_WIDTH)), -- 207.6 [Hz]
                      std_logic_vector(to_unsigned( 227272, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 57, PITCH_WIDTH)), -- 220 [Hz]
                      std_logic_vector(to_unsigned( 214516, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 58, PITCH_WIDTH)), -- 233.0 [Hz]
                      std_logic_vector(to_unsigned( 202476, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 59, PITCH_WIDTH)), -- 246.9 [Hz]
                      std_logic_vector(to_unsigned( 191112, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 60, PITCH_WIDTH)), -- 261.6 [Hz]
                      std_logic_vector(to_unsigned( 180386, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 61, PITCH_WIDTH)), -- 277.1 [Hz]
                      std_logic_vector(to_unsigned( 170262, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 62, PITCH_WIDTH)), -- 293.6 [Hz]
                      std_logic_vector(to_unsigned( 160706, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 63, PITCH_WIDTH)), -- 311.1 [Hz]
                      std_logic_vector(to_unsigned( 151686, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 64, PITCH_WIDTH)), -- 329.6 [Hz]
                      std_logic_vector(to_unsigned( 143172, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 65, PITCH_WIDTH)), -- 349.2 [Hz]
                      std_logic_vector(to_unsigned( 135137, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 66, PITCH_WIDTH)), -- 369.9 [Hz]
                      std_logic_vector(to_unsigned( 127552, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 67, PITCH_WIDTH)), -- 391.9 [Hz]
                      std_logic_vector(to_unsigned( 120393, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 68, PITCH_WIDTH)), -- 415.3 [Hz]
                      std_logic_vector(to_unsigned( 113636, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 69, PITCH_WIDTH)), -- 440 [Hz]
                      std_logic_vector(to_unsigned( 107258, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 70, PITCH_WIDTH)), -- 466.1 [Hz]
                      std_logic_vector(to_unsigned( 101238, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 71, PITCH_WIDTH)), -- 493.8 [Hz]
                      std_logic_vector(to_unsigned(  95556, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 72, PITCH_WIDTH)), -- 523.2 [Hz]
                      std_logic_vector(to_unsigned(  90193, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 73, PITCH_WIDTH)), -- 554.3 [Hz]
                      std_logic_vector(to_unsigned(  85131, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 74, PITCH_WIDTH)), -- 587.3 [Hz]
                      std_logic_vector(to_unsigned(  80353, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 75, PITCH_WIDTH)), -- 622.2 [Hz]
                      std_logic_vector(to_unsigned(  75843, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 76, PITCH_WIDTH)), -- 659.2 [Hz]
                      std_logic_vector(to_unsigned(  71586, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 77, PITCH_WIDTH)), -- 698.4 [Hz]
                      std_logic_vector(to_unsigned(  67568, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 78, PITCH_WIDTH)), -- 739.9 [Hz]
                      std_logic_vector(to_unsigned(  63776, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 79, PITCH_WIDTH)), -- 783.9 [Hz]
                      std_logic_vector(to_unsigned(  60196, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 80, PITCH_WIDTH)), -- 830.6 [Hz]
                      std_logic_vector(to_unsigned(  56818, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 81, PITCH_WIDTH)), -- 880 [Hz]
                      std_logic_vector(to_unsigned(  53629, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 82, PITCH_WIDTH)), -- 932.3 [Hz]
                      std_logic_vector(to_unsigned(  50619, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 83, PITCH_WIDTH)), -- 987.7 [Hz]
                      std_logic_vector(to_unsigned(  47778, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 84, PITCH_WIDTH)), -- 1046 [Hz]
                      std_logic_vector(to_unsigned(  45096, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 85, PITCH_WIDTH)), -- 1108 [Hz]
                      std_logic_vector(to_unsigned(  42565, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 86, PITCH_WIDTH)), -- 1174 [Hz]
                      std_logic_vector(to_unsigned(  40176, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 87, PITCH_WIDTH)), -- 1244 [Hz]
                      std_logic_vector(to_unsigned(  37921, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 88, PITCH_WIDTH)), -- 1318 [Hz]
                      std_logic_vector(to_unsigned(  35793, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 89, PITCH_WIDTH)), -- 1396 [Hz]
                      std_logic_vector(to_unsigned(  33784, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 90, PITCH_WIDTH)), -- 1479 [Hz]
                      std_logic_vector(to_unsigned(  31888, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 91, PITCH_WIDTH)), -- 1567 [Hz]
                      std_logic_vector(to_unsigned(  30098, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 92, PITCH_WIDTH)), -- 1661 [Hz]
                      std_logic_vector(to_unsigned(  28409, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 93, PITCH_WIDTH)), -- 1760 [Hz]
                      std_logic_vector(to_unsigned(  26814, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 94, PITCH_WIDTH)), -- 1864 [Hz]
                      std_logic_vector(to_unsigned(  25309, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 95, PITCH_WIDTH)), -- 1975 [Hz]
                      std_logic_vector(to_unsigned(  23889, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 96, PITCH_WIDTH)), -- 2093 [Hz]
                      std_logic_vector(to_unsigned(  22548, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 97, PITCH_WIDTH)), -- 2217 [Hz]
                      std_logic_vector(to_unsigned(  21282, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 98, PITCH_WIDTH)), -- 2349 [Hz]
                      std_logic_vector(to_unsigned(  20088, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned( 99, PITCH_WIDTH)), -- 2489 [Hz]
                      std_logic_vector(to_unsigned(  18960, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(100, PITCH_WIDTH)), -- 2637 [Hz]
                      std_logic_vector(to_unsigned(  17896, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(101, PITCH_WIDTH)), -- 2793 [Hz]
                      std_logic_vector(to_unsigned(  16892, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(102, PITCH_WIDTH)), -- 2959 [Hz]
                      std_logic_vector(to_unsigned(  15944, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(103, PITCH_WIDTH)), -- 3135 [Hz]
                      std_logic_vector(to_unsigned(  15049, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(104, PITCH_WIDTH)), -- 3322 [Hz]
                      std_logic_vector(to_unsigned(  14204, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(105, PITCH_WIDTH)), -- 3520 [Hz]
                      std_logic_vector(to_unsigned(  13407, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(106, PITCH_WIDTH)), -- 3729 [Hz]
                      std_logic_vector(to_unsigned(  12654, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(107, PITCH_WIDTH)), -- 3951 [Hz]
                      std_logic_vector(to_unsigned(  11944, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(108, PITCH_WIDTH)), -- 4186 [Hz]
                      std_logic_vector(to_unsigned(  11274, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(109, PITCH_WIDTH)), -- 4434 [Hz]
                      std_logic_vector(to_unsigned(  10641, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(110, PITCH_WIDTH)), -- 4698 [Hz]
                      std_logic_vector(to_unsigned(  10044, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(111, PITCH_WIDTH)), -- 4978 [Hz]
                      std_logic_vector(to_unsigned(   9480, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(112, PITCH_WIDTH)), -- 5274 [Hz]
                      std_logic_vector(to_unsigned(   8948, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(113, PITCH_WIDTH)), -- 5587 [Hz]
                      std_logic_vector(to_unsigned(   8446, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(114, PITCH_WIDTH)), -- 5919 [Hz]
                      std_logic_vector(to_unsigned(   7972, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(115, PITCH_WIDTH)), -- 6271 [Hz]
                      std_logic_vector(to_unsigned(   7524, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(116, PITCH_WIDTH)), -- 6644 [Hz]
                      std_logic_vector(to_unsigned(   7102, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(117, PITCH_WIDTH)), -- 7040 [Hz]
                      std_logic_vector(to_unsigned(   6703, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(118, PITCH_WIDTH)), -- 7458 [Hz]
                      std_logic_vector(to_unsigned(   6327, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(119, PITCH_WIDTH)), -- 7902 [Hz]
                      std_logic_vector(to_unsigned(   5972, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(120, PITCH_WIDTH)), -- 8372 [Hz]
                      std_logic_vector(to_unsigned(   5637, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(121, PITCH_WIDTH)), -- 8869 [Hz]
                      std_logic_vector(to_unsigned(   5320, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(122, PITCH_WIDTH)), -- 9397 [Hz]
                      std_logic_vector(to_unsigned(   5022, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(123, PITCH_WIDTH)), -- 9956 [Hz]
                      std_logic_vector(to_unsigned(   4740, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(124, PITCH_WIDTH)), -- 10548 [Hz]
                      --std_logic_vector(to_unsigned(   4474, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(125, PITCH_WIDTH)), -- 11175 [Hz]
                      --std_logic_vector(to_unsigned(   4223, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(126, PITCH_WIDTH)), -- 11839 [Hz]
                      --std_logic_vector(to_unsigned(   3986, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(127, PITCH_WIDTH)), -- 12543 [Hz]
                      --std_logic_vector(to_unsigned(   3762, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(128, PITCH_WIDTH)), -- 13289 [Hz]
                      --std_logic_vector(to_unsigned(   3551, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(129, PITCH_WIDTH)), -- 14080 [Hz]
                      --std_logic_vector(to_unsigned(   3351, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(130, PITCH_WIDTH)), -- 14917 [Hz]
                      --std_logic_vector(to_unsigned(   3163, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(131, PITCH_WIDTH)), -- 15804 [Hz]
                      --std_logic_vector(to_unsigned(   2986, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(132, PITCH_WIDTH)), -- 16744 [Hz]
                      --std_logic_vector(to_unsigned(   2818, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(133, PITCH_WIDTH)), -- 17739 [Hz]
                      --std_logic_vector(to_unsigned(   2660, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(134, PITCH_WIDTH)), -- 18794 [Hz]
                      --std_logic_vector(to_unsigned(   2511, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(135, PITCH_WIDTH)), -- 19912 [Hz]
                      --std_logic_vector(to_unsigned(   2370, PITCH_CONV_WIDTH)) when std_logic_vector(to_unsigned(136, PITCH_WIDTH)), -- 21096 [Hz]
                      std_logic_vector(to_unsigned( 113636, PITCH_CONV_WIDTH)) when others; -- 440 [Hz]
    end process;

    -----------------------------------------------------------------------------
    -- sequential process for divider to create internal step signal
    -- in:
    --    rst
    --    clk
    --    pitch_conv
    --    step_divider
    -- out:
    --    step_int
    --    step_divider
    -----------------------------------------------------------------------------
    divider: process(rst, clk)
    begin
        if rst = '1' then
            step_int <= '1';
            step_divider <= (others => '0');
        elsif rising_edge(clk) then
            if (step_divider = 0) then
                step_divider <= pitch_conv;
                step_int <= not step_int;
            else
                step_divider <= step_divider - 1;
                step_int <= step_int;
            end if;
        end if;
    end process;

    -----------------------------------------------------------------------------
    -- combinatorial process to enable step
    -- in:
    --    enable
    --    status_init_reg
    --    step_int
    -- out:
    --    step_reg
    -----------------------------------------------------------------------------
    step_enable: process(enable, status_init_reg, step_int)
    begin
        step_reg <= step_int when (status_init or enable) else
                    '0';
    end process;

    -----------------------------------------------------------------------------
    -- sequential process for edge detection on step_reg
    -- in:
    --    rst
    --    clk
    --    step_reg
    -- out:
    --    step_edge
    -----------------------------------------------------------------------------
    step_edge: process(rst, clk)
    begin
        if rst = '1' then
            step_edge <= '0';
            step_edge_prev <= '0';
        elsif rising_edge(clk) then
            step_edge_prev <= step_reg;
            step_edge <= '1' when (step_reg and (not step_edge_prev)) else
                         '0';
        end if;
    end process;

    -----------------------------------------------------------------------------
    -- sequential process for counting the number of steps
    -- in:
    --    rst
    --    clk
    --    step_cnt_end
    --    step_edge
    --    step_cnt
    -- out:
    --    step_cnt_end
    --    step_cnt
    -----------------------------------------------------------------------------
    step_cnt: process(rst, clk)
    begin
        if rst = '1' then
            step_cnt <= 80;
            step_cnt_end <= '0';
        elsif rising_edge(clk) then
            if step_cnt = 0 then
                step_cnt <= 79;
                step_cnt_end <= '1';
            else
                step_cnt <= step_cnt - 1;
                step_cnt_end <= '0';
            end if;
        end if;
    end process;

    -----------------------------------------------------------------------------
    -- sequential process to generate dir_reg signal
    -- in:
    --    rst
    --    clk
    --    step_cnt_end
    -- out:
    --    dir_reg
    -----------------------------------------------------------------------------
    dir_gen: process(rst, clk)
    begin
        if rst = '1' then
            dir_reg <= '0';
        elsif rising_edge(clk) then
            if step_cnt_end = '1' then
                dir_reg <= not dir_reg;
            else
                dir_reg <= dir_reg;
            end if;
        end if;
    end process;

    -----------------------------------------------------------------------------
    -- sequential process to generate status_init_reg
    -- in:
    --    rst
    --    clk
    --    step_cnt_end
    -- out:
    --    status_init_reg
    -----------------------------------------------------------------------------
    init_ff: process(rst, clk)
    begin
        if rst = '1' then
            status_init_reg <= '1';
        elsif rising_edge(clk) then
            if step_cnt_end = '1' then
                status_init_reg <= '0';
            else
                status_init_reg <= status_init_reg;
            end if;
        end if;
    end process;

    -----------------------------------------------------------------------------
    -- sequential process: DUMMY to avoid logic optimization
    -- To be replaced.....
    -- # of FFs: ......
    -----------------------------------------------------------------------------  
    P_dummy: process(rst, clk)
    begin
        if rst = '1' then
            status_init   <= '1';
            status_melody <= '0';
            floppy_step   <= '0';
            floppy_dir    <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                if unsigned(pitch_fix) > 0 then
                    status_init <= mode and pitch_fix(0);
                    status_melody <= mode and pitch_fix(1);
                    floppy_step <= mode and pitch_fix(2);
                    floppy_dir <= mode and pitch_fix(3);
                end if;
            end if;
        end if;
    end process;
end rtl;
