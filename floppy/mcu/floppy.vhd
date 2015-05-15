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
        pitch_fix       : in    std_logic_vector(15 downto 0);
        -- output signals to cpu
        status_init     : out   std_logic;
        status_melody   : out   std_logic;
        -- output signals to floppy
        floppy_step     : out   std_logic;
        floppy_dir      : out   std_logic;
    );
end floppy;

architecture rtl of floppy is


begin
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
