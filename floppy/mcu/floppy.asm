setih 0 std_logic_vector(to_unsigned(0,DW/2)) 		#init
setih 1 std_logic_vector(to_unsigned(0,DW/2)) 
setih 2 std_logic_vector(to_unsigned(0,DW/2)) 
setih 3 std_logic_vector(to_unsigned(0,DW/2)) 
setih 4 std_logic_vector(to_unsigned(16#FF#,DW/2)) 
setil 4 std_logic_vector(to_unsigned(16#FF#,DW/2)) 
setih 5 std_logic_vector(to_unsigned(0,DW/2)) 
setih 6 std_logic_vector(to_unsigned(0,DW/2)) 
setih 7 std_logic_vector(to_unsigned(0,DW/2))
setil 0 std_logic_vector(to_unsigned(16#84#,DW/2))	#read 0x84 init reg
ld 1 0
add 1 1 3
bne std_logic_vector(to_signed(-3,DW/2))          #wait until init = 0
add 6 5 3											#reg5 switch to reg6 oldswitch 
setil 0 std_logic_vector(to_unsigned(16#80#,DW/2))	#read switch to reg5
ld 5 0
add 7 3 5
setil 0 std_logic_vector(to_unsigned(16#81#,DW/2))	#reg 7 to LED
st 7 0
jmp std_logic_vector(to_unsigned(13,DW/2))
nop
