-------------------------------------------------------------------------------
-- Entity: ram
-- Author: Waj
-- Date  : 11-May-13
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 9)
-- GPIO block for simple von-Neumann MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: ... tbd ...
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity gpio is
    port(rst            : in    std_logic;
        clk             : in    std_logic;
        -- GPIO bus signals
        bus_in          : in  t_bus2rws;
        bus_out         : out t_rws2bus;

        -- LED, Switches and Buttons
        to_LED          : out std_logic_vector(7 downto 0);
        from_SW         : in std_logic_vector(3 downto 0);
        from_BTN_ROT_C  : in std_logic;
        from_BTN_EAST   : in std_logic;
        from_BTN_WEST   : in std_logic;
        from_BTN_NORTH  : in std_logic;

        -- Floppy connection
        step_to_floppy  : out std_logic;
        dir_to_floppy   : out std_logic
        en_to_floppy    : out std_logic
        );
end gpio;

architecture rtl of gpio is

    component floppy is
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
        floppy_dir      : out   std_logic
        floppy_en       : out   std_logic
        );
    end component floppy;

    signal in_1, in_2 : std_logic_vector(7 downto 0);
    signal next_out, current_out : std_logic_vector(7 downto 0);
    signal f_status_init        : std_logic;
    signal f_status_melody      : std_logic;
    signal f_enable             : std_logic;
    signal f_mode               : std_logic;
    signal f_pitch_fix          : std_logic_vector(15 downto 0);
        
begin

    floppy1 : floppy
    port map(
        rst             => rst,
        clk             => clk,
        enable          => f_enable,
        mode            => f_mode,
        pitch_fix       => f_pitch_fix,
        status_init     => f_status_init,
        status_melody   => f_status_melody,
        floppy_step     => step_to_floppy,
        floppy_dir      => dir_to_floppy,
        floppy_en       => en_to_floppy
        );


  -----------------------------------------------------------------------------
  -- sequential process: DUMMY to avoid logic optimization
  -- To be replaced.....
  -- # of FFs: ......
  -----------------------------------------------------------------------------  
  
-- For testing only !!! inout without CPU  
--  to_LED(7 downto 4) <= from_SW;
--  to_LED(3) <= from_BTN_ROT_C;
--  to_LED(2) <= from_BTN_EAST;
--  to_LED(1) <= from_BTN_WEST;
--  to_LED(7) <= from_BTN_NORTH;
  
  

  
  P_synch : process(rst,clk) -- for synchronizing the inputs with 2 FFs
  begin
      if rst = '1' then
            in_1 <= (others => '0');
            in_2 <= (others => '0');
        elsif rising_edge(clk) then
            in_1(3 downto 0) <= from_SW;
            in_1(4) <= from_BTN_EAST;
            in_1(5) <= from_BTN_NORTH;
            in_1(6) <= from_BTN_WEST;
            in_1(7) <= from_BTN_ROT_C;
            in_2 <= in_1;
        end if;
    end process;
    
    -- Connecting the internal Signals
    to_LED <= current_out;
    current_out <= next_out;
        
  
    P_busaccess : process(rst, clk)
    begin
        if rst = '1' then
            bus_out.data <= (others => '0');
        elsif rising_edge(clk) then
            next_out <= current_out; -- take the same output if no new data avaiable
            if unsigned(bus_in.addr) = to_unsigned(16#00#,AWL) then
                bus_out.data(7 downto 0) <= in_2; -- Only the low byte is used !
                bus_out.data(15 downto 8) <= (others => '0');
            elsif unsigned(bus_in.addr) = to_unsigned(16#01#,AWL) then
                bus_out.data(7 downto 0) <= current_out; -- Only the low byte is used !
                bus_out.data(15 downto 8) <= (others => '0');
            elsif unsigned(bus_in.addr) = to_unsigned(16#02#,AWL) then
                bus_out.data(0) <= f_enable;
                bus_out.data(15 downto 1) <= (others => '0');
            elsif unsigned(bus_in.addr) = to_unsigned(16#03#,AWL) then
                bus_out.data(0) <= f_mode;
                bus_out.data(15 downto 1) <= (others => '0');
            elsif unsigned(bus_in.addr) = to_unsigned(16#04#,AWL) then
                bus_out.data(0) <= f_status_init;
                bus_out.data(15 downto 1) <= (others => '0');
            elsif unsigned(bus_in.addr) = to_unsigned(16#05#,AWL) then
                bus_out.data(0) <= f_status_melody;
                bus_out.data(15 downto 1) <= (others => '0');
            elsif unsigned(bus_in.addr) = to_unsigned(16#06#,AWL) then
                bus_out.data(15 downto 0) <= f_pitch_fix;
            end if;
            if bus_in.we = '1' then -- write to register
                if unsigned(bus_in.addr) = to_unsigned(16#01#,AWL) then
                    next_out <= bus_in.data(7 downto 0);--<= "01010111";
                elsif unsigned(bus_in.addr) = to_unsigned(16#02#,AWL) then
                    f_enable <= bus_in.data(0);
                elsif unsigned(bus_in.addr) = to_unsigned(16#03#,AWL) then
                    f_mode <= bus_in.data(0);
                elsif unsigned(bus_in.addr) = to_unsigned(16#06#,AWL) then
                    f_pitch_fix <= bus_in.data;
                end if;
            end if;
        end if;
    end process;

end rtl;
