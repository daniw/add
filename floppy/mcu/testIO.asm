setil 0 std_logic_vector(to_unsigned(16#80#,DW/2)) # Testprogramm to count in assembler
setil 1 std_logic_vector(to_unsigned(16#81#,DW/2))
ld 3 0
st 3 1
jmp std_logic_vector(to_unsigned(16#02#,DW/2))
nop
