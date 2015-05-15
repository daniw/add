setil 0 std_logic_vector(to_unsigned(40,DW/2)) # Testprogramm to count in assembler
setil 1 std_logic_vector(to_unsigned(01,DW/2))
add 0 0 1
jmp std_logic_vector(to_unsigned(16#02#,DW/2))
nop
