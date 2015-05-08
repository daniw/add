#!/bin/bash
# Script for converting asm files into vhdl code
#
# author: daniw
# 
# Usage: 
# ./asmtovhdl.sh input.asm output.vhd

echo "################################"
echo "# Assembler asmtovhdl by daniw #"
echo "################################"
echo "Reading Assembler from $1"
echo "Writing VHDL ROM to $2"
echo "..."

rm -f $2

i=0

# VHDL code after ROM definition
echo "-------------------------------------------------------------------------------" >> $2
echo "-- Entity: rom" >> $2
echo "-- Author: Waj" >> $2
echo "-- Date  : 11-May-13, 26-May-13" >> $2
echo "-------------------------------------------------------------------------------" >> $2
echo "-- Description: (ECS Uebung 9)" >> $2
echo "-- Program memory for simple von-Neumann MCU with registerd read data output." >> $2
echo "-------------------------------------------------------------------------------" >> $2
echo "-- Total # of FFs: DW" >> $2
echo "-------------------------------------------------------------------------------" >> $2
echo "library ieee;" >> $2
echo "use ieee.std_logic_1164.all;" >> $2
echo "use ieee.numeric_std.all;" >> $2
echo "use work.mcu_pkg.all;" >> $2
echo "" >> $2
echo "entity rom is" >> $2
echo "  port(clk     : in    std_logic;" >> $2
echo "       -- ROM bus signals" >> $2
echo "       bus_in  : in  t_bus2ros;" >> $2
echo "       bus_out : out t_ros2bus" >> $2
echo "       );" >> $2
echo "end rom;" >> $2
echo "" >> $2
echo "architecture rtl of rom is" >> $2
echo "" >> $2
echo "  type t_rom is array (0 to 2**AWL-1) of std_logic_vector(DW-1 downto 0);" >> $2
echo "  constant rom_table : t_rom := (" >> $2
echo "    ---------------------------------------------------------------------------" >> $2
echo "    -- program code -----------------------------------------------------------" >> $2
echo "    ---------------------------------------------------------------------------" >> $2
echo "    -- addr    Opcode     Rdest    Rsrc1    Rsrc2              description" >> $2
echo "    ---------------------------------------------------------------------------" >> $2

# Actual assembler interpratation
while IFS=' ' read op dest src1 src2 comment
do
    if ! ( [[ $op == \#* ]] || [[ -z $op ]] ); # Ignore comment lines
    then
        if ( [[ $op == "add" ]] );
        then
            echo "         $i  => OPC($op)   & reg($dest) & reg($src1) & reg($src2) & \"--\",    -- r$dest = r$src1 + r$src2" >> $2
            i=$((i+1))
        elif ( [[ $op == "sub" ]] );
        then
            echo "         $i  => OPC($op)   & reg($dest) & reg($src1) & reg($src2) & \"--\",    -- r$dest = r$src1 - r$src2" >> $2
            i=$((i+1))
        elif ( [[ $op == "andi" ]] );
        then
            echo "         $i  => OPC($op)  & reg($dest) & reg($src1) & reg($src2) & \"--\",    -- r$dest = r$src1 and r$src2" >> $2
            i=$((i+1))
        elif ( [[ $op == "ori" ]] );
        then
            echo "         $i  => OPC($op)   & reg($dest) & reg($src1) & reg($src2) & \"--\",    -- r$dest = r$src1 or r$src2" >> $2
            i=$((i+1))
        elif ( [[ $op == "xori" ]] );
        then
            echo "         $i  => OPC($op)  & reg($dest) & reg($src1) & reg($src2) & \"--\",    -- r$dest = r$src1 xor r$src2" >> $2
            i=$((i+1))
        elif ( [[ $op == "slai" ]] );
        then
            echo "         $i  => OPC($op)  & reg($dest) & reg($src1) & \"---\"  & \"--\",    -- r$dest = r$src1 << 1" >> $2
            i=$((i+1))
        elif ( [[ $op == "srai" ]] );
        then
            echo "         $i  => OPC($op)  & reg($dest) & reg($src1) & \"---\"  & \"--\",    -- r$dest = r$src1 >> 1" >> $2
            i=$((i+1))
        elif ( [[ $op == "mov" ]] );
        then
            echo "         $i  => OPC($op)   & reg($dest) & reg($src1) & \"---\"  & \"--\",    -- r$dest = r$src1" >> $2
            i=$((i+1))
        elif ( [[ $op = "addil" ]] );
        then
            echo "         $i  => OPC($op) & reg($dest) & \"$src1\",                -- r$dest = r$dest + \"$src1\"" >> $2
            i=$((i+1))
        elif ( [[ $op = "addih" ]] );
        then
            echo "         $i  => OPC($op) & reg($dest) & \"$src1\",                -- r$dest = r$dest + \"$src1\"" >> $2
            i=$((i+1))
        elif ( [[ $op = "setil" ]] );
        then
            echo "         $i  => OPC($op) & reg($dest) & \"$src1\",                -- r$dest = r$dest + \"$src1\"" >> $2
            i=$((i+1))
        elif ( [[ $op = "setih" ]] );
        then
            echo "         $i  => OPC($op) & reg($dest) & \"$src1\",                -- r$dest = r$dest + \"$src1\"" >> $2
            i=$((i+1))
        elif ( [[ $op = "ld" ]] );
        then
            echo "         $i  => OPC($op)    & reg($dest) & reg($src1) & \"---\"  & \"--\",    -- r$dest = *r$src1" >> $2
            i=$((i+1))
        elif ( [[ $op = "st" ]] );
        then
            echo "         $i  => OPC($op)    & reg($dest) & reg($src1) & \"---\"  & \"--\",    -- *r$src1 = r$dest" >> $2
            i=$((i+1))
        elif ( [[ $op = "jmp" ]] );
        then
            echo "         $i  => OPC($op)   & \"---\"  & \"$dest\",                -- $op \"$dest\"" >> $2
            i=$((i+1))
        elif ( [[ $op = "bne" ]] );
        then
            echo "         $i  => OPC($op)   & \"---\"  & \"$dest\",                -- $op \"$dest\"" >> $2
            i=$((i+1))
        elif ( [[ $op = "bge" ]] );
        then
            echo "         $i  => OPC($op)   & \"---\"  & \"$dest\",                -- $op \"$dest\"" >> $2
            i=$((i+1))
        elif ( [[ $op = "blt" ]] );
        then
            echo "         $i  => OPC($op)   & \"---\"  & \"$dest\",                -- $op \"$dest\"" >> $2
            i=$((i+1))
        elif ( [[ $op = "nop" ]] );
        then
            echo "         $i  => OPC($op)   & \"---\"  & \"---\"  & \"---\"  & \"--\",    -- nop" >> $2
            i=$((i+1))
        else
            echo "Unknown instruction: $op"
        fi
    fi
done < $1

# VHDL code after ROM definition
echo "         others    => (others => '1')" >> $2
echo "         );" >> $2
echo "" >> $2
echo "begin" >> $2
echo "" >> $2
echo "  -----------------------------------------------------------------------------" >> $2
echo "  -- sequential process: ROM table with registerd output" >> $2
echo "  -----------------------------------------------------------------------------  " >> $2
echo "  P_rom: process(clk)" >> $2
echo "  begin" >> $2
echo "    if rising_edge(clk) then" >> $2
echo "      bus_out.data <= rom_table(to_integer(unsigned(bus_in.addr)));" >> $2
echo "    end if;" >> $2
echo "  end process;" >> $2
echo "" >> $2
echo "end rtl;" >> $2

echo finished

# cat $2
