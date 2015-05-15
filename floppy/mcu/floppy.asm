setil 0 std_logic_vector(to_unsigned(16#84#,DW/2)) # Floppy driver
setil 1 std_logic_vector(to_unsigned(0,DW/2))
ld 3 0
add 3 3 1
bne std_logic_vector(to_unsigned(16#02#,DW/2))		#end init
setil 0 std_logic_vector(to_unsigned(16#86#,DW/2))	#start Pitch Module 0
setil 1 std_logic_vector(to_unsigned(69,DW/2))
st 1 0												#end Pitch Module 0
setil 0 std_logic_vector(to_unsigned(16#82#,DW/2))	#start enable
setil 1 std_logic_vector(to_unsigned(16#FF#,DW/2))
st 1 0												#end enable
jmp std_logic_vector(to_unsigned(11,DW/2))
nop
