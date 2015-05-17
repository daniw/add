setih 0 std_logic_vector(to_unsigned(0,DW/2)) 		#init #SW0: 1=ON/0=OFF     SW2: Modus       SW4-East: v=pitch++    SW5-North: v=pitch--:
setih 1 std_logic_vector(to_unsigned(0,DW/2)) 
setih 2 std_logic_vector(to_unsigned(0,DW/2)) 
setih 3 std_logic_vector(to_unsigned(0,DW/2)) 
setih 4 std_logic_vector(to_unsigned(16#FF#,DW/2)) 
setil 4 std_logic_vector(to_unsigned(16#FF#,DW/2)) 
setih 5 std_logic_vector(to_unsigned(0,DW/2)) 
setih 6 std_logic_vector(to_unsigned(0,DW/2)) 
setih 7 std_logic_vector(to_unsigned(0,DW/2))
setil 0 std_logic_vector(to_unsigned(16#84#,DW/2))	#read 0x84 init reg---------------------ini------------------------------
ld 1 0
add 1 1 3
bne std_logic_vector(to_signed(-3,DW/2))            #wait until init = 0
setil 2 std_logic_vector(to_unsigned(16#84#,DW/2))	#0x86 pitch reg = 69 (Kammerton)
setil 0 std_logic_vector(to_unsigned(69,DW/2))
st 0 2
add 6 5 3											#reg5 switch to reg6 oldswitch ------------read switch----------------------------------
setil 0 std_logic_vector(to_unsigned(16#80#,DW/2))	#read switch to reg5
ld 5 0
add 0 3 4											#reg0 = 0xFF----------------------------enable-----------------------------
add 1 3 3											#reg1 = 1
setil 1 std_logic_vector(to_unsigned(1,DW/2)) 
andi 1 1 5											#reg1 = reg1 & switch
bne std_logic_vector(to_signed(+2,DW/2))
add 0 3 3											#reg0 = 0x00
setil 2 std_logic_vector(to_unsigned(16#82#,DW/2))  #enable = reg2
st 0 2
add 0 3 4											#reg0 = 0xFF----------------------------Modus------------------------
add 1 3 3											#reg1 = 2
setil 1 std_logic_vector(to_unsigned(2,DW/2)) 
andi 1 1 5											#reg1 = reg1 & switch
bne std_logic_vector(to_signed(+2,DW/2))
add 0 3 3											#reg0 = 0x00
setil 2 std_logic_vector(to_unsigned(16#83#,DW/2))  #modus = reg2
st 0 2
xori 0 6 4											#reg0 = !oldswitch------------------------Pitch++---------------------------
andi 0 0 5											#reg0 = !oldswitc & switch
add 1 3 3											#reg1 = 0x10
setil 1 std_logic_vector(to_unsigned(16#10#,DW/2)) 
andi 0 0 1											#reg0 = reg0 & 0x10
xori 0 0 1											#jump if reg0 == 0
bne std_logic_vector(to_signed(+6,DW/2))
add 2 3 3											#reg2 = 0x86 Pitch0
setil 2 std_logic_vector(to_unsigned(16#86#,DW/2)) 
ld 0 2												#pitch++
addil 0 std_logic_vector(to_unsigned(1,DW/2))
st 0 2
xori 0 6 4											#reg0 = !oldswitch------------------------Pitch-- ---------------------------
andi 0 0 5											#reg0 = !oldswitc & switch
add 1 3 3											#reg1 = 0x20
setil 1 std_logic_vector(to_unsigned(16#20#,DW/2))
andi 0 0 1											#reg0 = reg0 & 0x20
xori 0 0 1											#jump if reg0 == 0
bne std_logic_vector(to_signed(+6,DW/2))
add 2 3 3											#reg2 = 0x86 Pitch0
setil 2 std_logic_vector(to_unsigned(16#86#,DW/2)) 
ld 0 2												#pitch--
addil 0 std_logic_vector(to_signed(-1,DW/2))
st 0 2 
add 7 3 5											# --------------------------------------------finish-----------------------------------
setil 0 std_logic_vector(to_unsigned(16#81#,DW/2))	#reg 7 to LED
st 7 0
jmp std_logic_vector(to_unsigned(16,DW/2))
nop
