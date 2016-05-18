-------------------------------------------------------------------------------
-- Entity: gpio
-- Author: Waj
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
  port(rst     : in    std_logic;
       clk     : in    std_logic;
       -- GPIO bus signals
       bus_in  : in  t_bus2rws;
       bus_out : out t_rws2bus;
       -- GPIO pin signals
       gpio_in      : in  std_logic_vector(DW-1 downto 0);
       gpio_out     : out std_logic_vector(DW-1 downto 0);
       gpio_out_enb : out std_logic_vector(DW-1 downto 0);
       -- Encoder pin signals
       enc_a        : in std_logic;
       enc_b        : in std_logic
       );
end gpio;

architecture rtl of gpio is

  -- address select signal
  signal addr_sel : t_gpio_addr_sel;
  -- peripheral registers - gpio
  signal data_in_reg  : std_logic_vector(DW-1 downto 0);
  signal data_out_reg : std_logic_vector(DW-1 downto 0);
  signal out_enb_reg  : std_logic_vector(DW-1 downto 0);
  -- gpio input synchronisation
  signal sync_gpio_in : std_logic_vector(DW-1 downto 0);
  -- peripheral registers - encoder
  signal enc_capture  : std_logic;
  signal enc_capt_reg : std_logic;
  signal enc_capt_prev: std_logic;
  signal enc_buf_dist : std_logic_vector(DW-1 downto 0);
  signal enc_buf_pos  : std_logic_vector(DW-1 downto 0);
  signal enc_buf_neg  : std_logic_vector(DW-1 downto 0);
  -- encoder counter registers
  signal enc_cnt_dist : std_logic_vector(DW-1 downto 0);
  signal enc_cnt_pos  : std_logic_vector(DW-1 downto 0);
  signal enc_cnt_neg  : std_logic_vector(DW-1 downto 0);
  -- encoder count enable
  signal enc_cnt_enb_pos    : std_logic;
  signal enc_cnt_enb_neg    : std_logic;
  -- encoder fsm
  type t_enc_state is (st_active, st_idle_pos, st_idle_neg);
  signal c_st   : t_enc_state;
  signal n_st   : t_enc_state;
 
begin

  -- output ssignment
  gpio_out     <= data_out_reg;
  gpio_out_enb <= out_enb_reg;

  -----------------------------------------------------------------------------
  -- Input register
  -----------------------------------------------------------------------------  
  P_in: process(clk)
  begin
    if rst = '1' then
      sync_gpio_in <= (others=>'0');
    elsif rising_edge(clk) then
      sync_gpio_in <= gpio_in;
      data_in_reg <= sync_gpio_in;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Encoder fsm
  -----------------------------------------------------------------------------
  -- Memorizing process
  p_enc_fsm_seq: process(rst, clk)
  begin
    if rst = '1' then
      c_st <= st_active;
    elsif rising_edge(clk) then
      c_st <= n_st;
    end if;
  end process;
  -- Combinatoric process
  p_enc_fsm_comb: process(enc_a, enc_b, c_st)
  begin
    -- default assignments
    n_st <= c_st;
    enc_cnt_enb_pos <= '0';
    enc_cnt_enb_neg <= '0';
    -- states
    case c_st is
      when st_active =>
        if enc_a = '0' and enc_b = '0' then
          n_st <= st_idle_pos;
        end if;
      when st_idle_pos =>
        if enc_a = '1' and enc_b = '0' then
          n_st <= st_idle_neg;
        elsif enc_a = '1' and enc_b = '1' then
          enc_cnt_enb_pos <= '1';
          n_st <= st_active;
        end if;
      when st_idle_neg =>
        if enc_a = '0' and enc_b = '1' then
          n_st <= st_idle_pos;
        elsif enc_a = '1' and enc_b = '1' then
          enc_cnt_enb_neg <= '1';
          n_st <= st_active;
        end if;
      when others =>
        n_st <= st_active;
    end case;
  end process;

  -----------------------------------------------------------------------------
  -- Encoder counter
  -----------------------------------------------------------------------------
  p_enc_cnt: process(rst, clk)
  begin
    if rst = '1' then
      -- clear counter registers
      enc_cnt_dist <= (others => '0');
      enc_cnt_pos  <= (others => '0');
      enc_cnt_neg  <= (others => '0');
      -- clear buffer registers
      enc_buf_dist <= (others => '0');
      enc_buf_pos  <= (others => '0');
      enc_buf_neg  <= (others => '0');
    elsif rising_edge(clk) then
      if enc_capture = '1' then
        -- capture occured -> copy counter to buffer and reset counter
        if enc_cnt_enb_pos = '0' and enc_cnt_enb_neg = '0' then -- no count
          -- counter registers
          enc_cnt_dist <= (others => '0');
          enc_cnt_pos  <= (others => '0');
          enc_cnt_neg  <= (others => '0');
          -- buffer registers
          enc_buf_dist <= enc_cnt_dist;
          enc_buf_pos  <= enc_cnt_pos;
          enc_buf_neg  <= enc_cnt_neg;
        elsif enc_cnt_enb_pos = '0' and enc_cnt_enb_neg = '1' then -- neg count
          -- counter registers
          enc_cnt_dist <= (others => '0');
          enc_cnt_pos  <= (others => '0');
          enc_cnt_neg  <= (others => '0');
          -- buffer registers
          enc_buf_dist <= std_logic_vector(unsigned(enc_cnt_dist) - 1);
          enc_buf_pos  <= enc_cnt_pos;
          enc_buf_neg  <= std_logic_vector(unsigned(enc_cnt_neg)  + 1);
        elsif enc_cnt_enb_pos = '1' and enc_cnt_enb_neg = '0' then -- pos count
          -- counter registers
          enc_cnt_dist <= (others => '0');
          enc_cnt_pos  <= (others => '0');
          enc_cnt_neg  <= (others => '0');
          -- buffer registers
          enc_buf_dist <= std_logic_vector(unsigned(enc_cnt_dist) + 1);
          enc_buf_pos  <= std_logic_vector(unsigned(enc_cnt_pos)  + 1);
          enc_buf_neg  <= enc_cnt_neg;
        else -- pos and neg count (currently impossible)
          -- counter registers
          enc_cnt_dist <= (others => '0');
          enc_cnt_pos  <= (others => '0');
          enc_cnt_neg  <= (others => '0');
          -- buffer registers
          enc_buf_dist <= enc_cnt_dist;
          enc_buf_pos  <= std_logic_vector(unsigned(enc_cnt_pos)  + 1);
          enc_buf_neg  <= std_logic_vector(unsigned(enc_cnt_neg)  + 1);
        end if;
      else -- no capture occured
        if enc_cnt_enb_pos = '0' and enc_cnt_enb_neg = '0' then -- no count
          -- counter registers
          enc_cnt_dist <= enc_cnt_dist;
          enc_cnt_pos  <= enc_cnt_pos;
          enc_cnt_neg  <= enc_cnt_neg;
          -- buffer registers
          enc_buf_dist <= enc_buf_dist;
          enc_buf_pos  <= enc_buf_pos;
          enc_buf_neg  <= enc_buf_neg;
        elsif enc_cnt_enb_pos = '0' and enc_cnt_enb_neg = '1' then -- neg count
          -- counter registers
          enc_cnt_dist <= std_logic_vector(unsigned(enc_cnt_dist) - 1);
          enc_cnt_pos  <= enc_cnt_pos;
          enc_cnt_neg  <= std_logic_vector(unsigned(enc_cnt_neg)  + 1);
          -- buffer registers
          enc_buf_dist <= enc_buf_dist;
          enc_buf_pos  <= enc_buf_pos;
          enc_buf_neg  <= enc_buf_neg;
        elsif enc_cnt_enb_pos = '1' and enc_cnt_enb_neg = '0' then -- pos count
          -- counter registers
          enc_cnt_dist <= std_logic_vector(unsigned(enc_cnt_dist) + 1);
          enc_cnt_pos  <= std_logic_vector(unsigned(enc_cnt_pos)  + 1);
          enc_cnt_neg  <= enc_cnt_neg;
          -- buffer registers
          enc_buf_dist <= enc_buf_dist;
          enc_buf_pos  <= enc_buf_pos;
          enc_buf_neg  <= enc_buf_neg;
        else -- pos and neg count (with current state machine impossible)
          -- counter registers
          enc_cnt_dist <= enc_cnt_dist;
          enc_cnt_pos  <= std_logic_vector(unsigned(enc_cnt_pos)  + 1);
          enc_cnt_neg  <= std_logic_vector(unsigned(enc_cnt_neg)  + 1);
          -- buffer registers
          enc_buf_dist <= enc_buf_dist;
          enc_buf_pos  <= enc_buf_pos;
          enc_buf_neg  <= enc_buf_neg;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Encoder - Capture signal
  -----------------------------------------------------------------------------
  p_enc_capture: process(clk, rst)
  begin
    if rst = '1' then
      enc_capture <= '0';
      enc_capt_prev <= '0';
    else
      if rising_edge(clk) then
        if enc_capt_prev = '0' and enc_capt_reg = '1' then
          -- rising edge on capture
          enc_capture <= '1';
        else
          enc_capture <= '0';
        end if;
        enc_capt_prev <= enc_capt_reg;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Address Decoding (combinationally)
  -----------------------------------------------------------------------------  
  process(bus_in.addr)
  begin
    case bus_in.addr is
      -- Port 1 addresses -----------------------------------------------------
      when c_addr_gpio_data_in  => addr_sel <= gpio_data_in;
      when c_addr_gpio_data_out => addr_sel <= gpio_data_out;
      when c_addr_gpio_out_enb  => addr_sel <= gpio_enb;
      -- Encoder adresses -----------------------------------------------------
      when c_addr_enc_ctrl      => addr_sel <= enc_ctrl;
      when c_addr_enc_dist      => addr_sel <= enc_dist;
      when c_addr_enc_pos       => addr_sel <= enc_pos;
      when c_addr_enc_neg       => addr_sel <= enc_neg;
      -- unused addresses -----------------------------------------------------
      when others               => addr_sel <= none;
    end case;       
  end process;

  -----------------------------------------------------------------------------
  -- Read Access (R and R/W registers)
  -----------------------------------------------------------------------------  
  P_read: process(clk)
  begin
    if rising_edge(clk) then
      -- default assignment
      bus_out.data <= (others => '0');
      -- use address select signal
      case addr_sel is
        when gpio_data_in  => bus_out.data <= data_in_reg;
        when gpio_data_out => bus_out.data <= data_out_reg;
        when gpio_enb      => bus_out.data <= out_enb_reg;
        when enc_ctrl      => bus_out.data <= "101010100101010" & enc_capture;
        when enc_dist      => bus_out.data <= enc_buf_dist;
        when enc_pos       => bus_out.data <= enc_buf_pos;
        when enc_neg       => bus_out.data <= enc_buf_neg;
        when others        => null;
      end case;       
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Write Access (R/W registers only)
  -----------------------------------------------------------------------------  
  P_write: process(clk, rst)
  begin
    if rst = '1' then
      data_out_reg <= (others => '0');
      out_enb_reg  <= (others => '0');  -- output disabled per default
      enc_capt_reg <= '0';
    elsif rising_edge(clk) then
      if bus_in.wr_enb = '1' then
        -- use address select signal
        case addr_sel is
          when gpio_data_out => data_out_reg <= bus_in.data;
          when gpio_enb      => out_enb_reg  <= bus_in.data;
          when enc_ctrl      => enc_capt_reg <= bus_in.data(0);
          when others        => null;
        end case;       
      else
        enc_capt_reg <= '0';
      end if;
    end if;
  end process;

end rtl;
