-------------------------------------------------------------------------------
-- Entity: mcu_pkg
-- Author: Waj
-------------------------------------------------------------------------------
-- Description:
-- VHDL package for definition of design parameters and types used throughout
-- the MCU.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mcu_pkg is

  -----------------------------------------------------------------------------
  -- tool chain selection (because no suppoprt of 'val attritube in ISE XST)
  -----------------------------------------------------------------------------
  constant ISE_TOOL : boolean := true; -- true  = ISE XST
                                       -- false = other synthesizer (e.g. Vivado)
  
  -- system clock frequency in Hz
  constant CF : natural :=  50_000_000;           -- 50 MHz
  
  -----------------------------------------------------------------------------
  -- Helper functions (prototypes)
  -----------------------------------------------------------------------------
  -- std_logic_vector(to_signed(i,w))
  function i2slv(i : integer; w : positive) return std_logic_vector;
  -- std_logic_vector(to_unsigned(n,w))
  function n2slv(n : natural; w : positive) return std_logic_vector;

  -----------------------------------------------------------------------------
  -- design parameters: Memory Map
  -----------------------------------------------------------------------------
  -- bus architecture parameters
  constant DW  : natural range 4 to 64 := 16;     -- data word width
  constant AW  : natural range 2 to 64 := 10;     -- total address width
  constant AWH : natural range 1 to 64 :=  4;     -- high address width
  constant AWL : natural range 1 to 64 := AW-AWH; -- low address width
  -- memory map
  type t_bus_slave is (ROM, RAM, GPIO, FMC, TIM, UART); -- list of bus slaves
  type t_ba is array (t_bus_slave) of std_logic_vector(AW-1 downto 0);
  constant BA : t_ba := (             -- full base addresses 
         ROM  => "0-" & "----" & "----",
         RAM  => "10" & "----" & "----",
         GPIO => "11" & "00--" & "----",
         FMC  => "11" & "01--" & "----",
         TIM  => "11" & "10--" & "----",
         UART => "11" & "11--" & "----"
         );
  type t_hba is array (t_bus_slave) of std_logic_vector(AWH-1 downto 0);
  constant HBA : t_hba := (            -- high base address for decoding
         ROM  => BA(ROM) (AW-1 downto AW-AWH),
         RAM  => BA(RAM) (AW-1 downto AW-AWH),
         GPIO => BA(GPIO)(AW-1 downto AW-AWH),
         FMC  => BA(FMC) (AW-1 downto AW-AWH),
         TIM  => BA(TIM) (AW-1 downto AW-AWH),
         UART => BA(UART)(AW-1 downto AW-AWH)
         );
  -- Relative Register Addresses of Peripherals
  -- GPIO
  constant c_addr_gpio_data_in  : std_logic_vector(AWL-1 downto 0) := n2slv( 0, AWL);
  constant c_addr_gpio_data_out : std_logic_vector(AWL-1 downto 0) := n2slv( 1, AWL);
  constant c_addr_gpio_out_enb  : std_logic_vector(AWL-1 downto 0) := n2slv( 2, AWL);
  type t_gpio_addr_sel is (none, gpio_data_in, gpio_data_out, gpio_enb);
  -- FMC
  -- TIM
  -- UART

  -----------------------------------------------------------------------------
  -- design parameters: CPU Instructions
  -----------------------------------------------------------------------------
  -- CPU instruction set
  -- Note: Defining the OPcode in the way shown below, allows assembler-style
  -- programming with mnemonics rather than machine coding (see rom.vhd).
  constant OPCW : natural range 1 to DW := 5;    -- Opcode word width
  constant OPAW : natural range 1 to DW := 4;    -- ALU operation word width
  constant IOWW : natural range 1 to DW := 8;    -- immediate operand word width
  type t_instr is (add, sub, andi, ori, xori, slai, srai, mov,
                   ld, st,
                   addil, addih, setil, setih,
                   jmp, bne, bge, blt, bca, bov,
                   nop);
  -- Instructions targeted at the ALU are defined by means of a sub-type.
  -- This allows changing the opcode of instructions without having to
  -- modify the source code of the ALU.
  subtype t_alu_instr is t_instr range add to mov;
  type t_opcode is array (t_instr) of std_logic_vector(OPCW-1 downto 0);
  constant OPC : t_opcode := (  -- OPcode
         -- ALU operations -------------------------------
         add   => "00000",      --  0: addition
         sub   => "00001",      --  1: subtraction
         andi  => "00010",      --  2: bit-wise AND
         ori   => "00011",      --  3: bit-wise OR 
         xori  => "00100",      --  4: bit-wise XOR 
         slai  => "00101",      --  5: shift-left arithmetically
         srai  => "00110",      --  6: shift-right arithmetically
         mov   => "00111",      --  7: move between register
         -- Immediate Operands ---------------------------
         addil => "01100",      -- 12: add imm. constant low
         addih => "01101",      -- 13: add imm. constant high
         setil => "01110",      -- 14: set imm. constant low
         setih => "01111",      -- 15: set imm. constant high
         -- Memory load/store ----------------------------
         ld    => "10000",      -- 16: load from memory
         st    => "10001",      -- 17: store to memory
         -- Jump/Branch ----------------------------------
         jmp   => "11000",      -- 24: absolute jump
         bne   => "11001",      -- 25: branch if not equal (not Z)
         bge   => "11010",      -- 26: branch if greater/equal (not N or Z)
         blt   => "11011",      -- 27: branch if less than (N)
         bca   => "11100",      -- 28: branch if carry set (C)
         bov   => "11101",      -- 29: branch if overflow set (O)
         -- Others ---------------------------------------
         nop   => "11111"       -- 31: no operation     
         );
  type t_flags is (Z, N, C, O); -- ALU flags (zero, negative, carry, overflow)
  type t_flag_arr is array (t_flags) of std_logic;
  -- register block
  constant RIDW : natural range 1 to DW := 3; -- register ID word width
  type t_regid is array(0 to 7) of std_logic_vector(RIDW-1 downto 0);
  constant reg : t_regid := ("000","001","010","011","100","101","110","111");  
  type t_regblk is array(0 to 7) of std_logic_vector(DW-1 downto 0);
  -- CPU address generation 
  type t_pc_mode  is (linear, abs_jump, rel_offset);  -- addr calcultion modi
  type t_addr_exc is (no_err, lin_err, rel_err);      -- address exceptions
 
  -----------------------------------------------------------------------------
  -- global types
  -----------------------------------------------------------------------------
  -- Master bus interface -----------------------------------------------------
  type t_bus2cpu is record
    data : std_logic_vector(DW-1 downto 0);
  end record;
  type t_cpu2bus is record
    data   : std_logic_vector(DW-1 downto 0);
    addr   : std_logic_vector(AW-1 downto 0);
    rd_enb : std_logic;
    wr_enb : std_logic;
  end record;
  -- Read-only slave bus interface  -------------------------------------------
  type t_bus2ros is record
    addr   : std_logic_vector(AWL-1 downto 0);
    rd_enb : std_logic;
  end record;
  type t_ros2bus is record
    data : std_logic_vector(DW-1 downto 0);
  end record;
  -- read/write slave bus interface -------------------------------------------
  type t_bus2rws is record
    addr   : std_logic_vector(AWL-1 downto 0);
    data   : std_logic_vector(DW-1 downto 0);
    rd_enb : std_logic; -- use of this signal is optional, depending on slave
    wr_enb : std_logic;
  end record;
  type t_rws2bus is record
    data : std_logic_vector(DW-1 downto 0);
  end record;
  
  -----------------------------------------------------------------------------
  -- CPU internal types
  -----------------------------------------------------------------------------
  -- Control Unit / Register Block interface ----------------------------------
  type t_ctr2reg is record
    src1     : std_logic_vector(RIDW-1 downto 0);
    src2     : std_logic_vector(RIDW-1 downto 0);
    dest     : std_logic_vector(RIDW-1 downto 0);
    enb_res  : std_logic;
    data     : std_logic_vector(DW-1 downto 0);
    enb_data : std_logic;
  end record;
  type t_reg2ctr is record
    data : std_logic_vector(DW-1 downto 0);
    addr : std_logic_vector(AW-1 downto 0);
  end record;
  -- Control Unit / Program Counter interface --------------------------------
  type t_ctr2prc is record
    enb  : std_logic;
    mode : t_pc_mode;
    addr : std_logic_vector(AW-1 downto 0);
  end record;
  type t_prc2ctr is record
    pc  : std_logic_vector(AW-1 downto 0);
    exc : t_addr_exc;
  end record;
  -- Control Unit / ALU interface ---------------------------------------------
  type t_ctr2alu is record
    op  : std_logic_vector(OPAW-1 downto 0);  -- operation
    imm : std_logic_vector(IOWW-1 downto 0);  -- immediate operand
    enb : std_logic;                          -- enable flag update
  end record;
  type t_alu2ctr is record
    flag : t_flag_arr;
  end record;
  
end package mcu_pkg;


package body mcu_pkg is
  
  -----------------------------------------------------------------------------
  -- Function Implementations
  -----------------------------------------------------------------------------
  function i2slv(i : integer;w : positive) return std_logic_vector is
  begin 
    return std_logic_vector(to_signed(i,w));
  end function i2slv;
  
  function n2slv(n : natural;w : positive) return std_logic_vector is
  begin 
    return std_logic_vector(to_unsigned(n,w));
  end function n2slv;


end package body mcu_pkg;
