# Flag-testing with ADD/SUB commands
ld  4 0     # ld r4, r0
ld  5 1     # ld r5, r1
ld  6 2     # ld r6, r2
ld  7 3     # ld r7, r3
add 0 5 4   # add r0, r5, r4
st  0 1     # st r0, r1
sub 0 5 4   # sub r1, r5, r4
st  0 2     # st r0, r2
add 0 7 6   # add r0, r7, r6
st  0 3     # st r0, r3
sub 0 7 6   # sub r1, r7, r6
st  0 0     # st r0, r0

