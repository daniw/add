; XOR two values stored in RAM at addresses 0x40 and 0x41
xor     r0, r0, r0
addil   r0, 0x40
ld      r4, r0
addil   r0, 0x01
ld      r5, r0
xor     r4, r4, r5

; Write the result to the GPIO data register address 0x80
addil   r0, 0x3F
st      r4, r0
