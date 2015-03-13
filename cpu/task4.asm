# const A = 0xF001;
# const B = 0xF000; // sign(A) = sign(B)
# int x,y,z = 0;
# while(sign(z) == sign(x)){
#    x += A;   // accumulate A
#    y += B;   // accumulate B 
#    z = x+y;  // N*(A+B)
# }
#
#
# set constant register values ###################-
setil   0 01000000 # RAM address of variable x hold in reg0
setil   1 01000001 # RAM address of variable y hold in reg1
setil   2 01000010 # RAM address of variable z hold in reg2
setil   6 00000001 # const A (0xF001) hold in reg6 (or load from ROM)
setih   6 11110000
setil   7 00000000 # const B (oxF000) hold in reg7 (or load from ROM)
setih   7 11110000
# while loop starts here ######################
ld      3 0
add     3 3 6
st      3 0
ld      4 1
add     4 4 7
st      4 1
add     5 3 4
st      5 2
bov     00000010
jmp     00000111
# while loop ends here #######################-
# fill remaining addresses with NOP

