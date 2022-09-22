@0|100000000000011|1110110000000000 = 1.111011 * 2^4 = 30.75
@0|100000000000001|0001000000000000 = 1.0001   * 2^2 = 4.25

@Addition:
@0|100000000000100|0001100000000000 = 1.00011  * 2^5 = 35

@Mltiplication:
@0|100000000000110|0000010101100000 = 1.00000101011 * 2^7 = 130.6875




.section .data
num: .word 0b01000000000000111110110000000000, 0b01000000000000010001000000000000,30,40
num1: .word 0b01000000000000000000000000000000, 16383, 0b10000000000000000000000000000000, 0b10000000000000000

ForZero1:
lsl r3, #2                @01matissa to mantissa
lsr r3, #16               @mantissa shifted to last 16 bits in r3
lsl r5, #16               @exponent shifted to 16 bits from last in r5
lsl r9, #31               @sign bit shifted to first bit in r9
add r9, r9, r5            @adding exponent to r9
add r9, r3                @adding mantissa to r9
str r9, [r1]              @final sum of r9 stored in r1
b Finish11                @addition done

ForOne1:
lsl r3, #1
lsr r3, #16
add r5, r5, #1
lsl r5, #16
lsl r9, #31
add r9, r9, r5
add r9, r3
str r9, [r1]
b Finish12

ForZero2:
lsl r3, #2
lsr r3, #16
lsl r5, #16
lsl r9, #31
add r9, r9, r5
add r9, r3
str r9, [r1]
b Finish21

ForOne2:
lsl r3, #1
lsr r3, #16
add r5, r5, #1
lsl r5, #16
lsl r9, #31
add r9, r9, r5
add r9, r3
str r9, [r1]
b Finish22

r5LessOrEqual:       
sub r6, r4, r5	           @r6 have difference of exponents
lsr r3, r6                 @mantissa of q is shifted 
add r3, r3, r2             @r3 has sum of mantissa of p and q
add r5, r5, r6             @r5 and r4 are equal exponents
mov r0, r3                 @r0 also has sum 
lsr r0, #31                @r0 has MSB of mantissa sum
and r0, #1                 
cmp r0, #1                 @comparinig MSB with one 
bne ForZero2               @if MSB is 0 
Finish21:
cmp r0, #1
beq ForOne2                @if MSB is one
Finish22:
b Finish

r5more:
sub r6, r5, r4             @r6 have difference of exponents
lsr r2, r6                 @mantissa of p is shifted
add r3, r3, r2             @r3 has sum of mantissa of p and q
add r4, r4, r6             @r5 and r4 are equal exponents
mov r0, r3                 @r0 also has sum 
lsr r0, #31                @r0 has MSB of mantissa sum
and r0, #1                 
cmp r0, #1                 @comparinig MSB with one
bne ForZero1               @if MSB is 0
Finish11:                  
cmp r0,#1                
beq ForOne1                @if MSB is one
Finish12:                 
b Finish     

lpfpAdd:
stmfd sp!, { r2- r9, lr}
ldmia r1, { r2- r3}        @r2,r3 has 32bits p and q respectively
mov r4, r2                 @made copy of r2
mov r5, r3                 @made copy of r3
lsr r4, #31                @r4 has sign bit of p
lsr r5, #31                @r5 has sign bit of q
cmp r4, r5                 @comparing sign bit of p and q
add r1, r1, #8             @r1 is pointing to space allocated to sum
mov r9, r4                 @r9 has sign bit of sum

ForExponent:
stmfd sp!, { r4- r8, lr}    
mov r4, r2                 @r4 has p
mov r5, r3                 @r5 has q
lsl r4, #1                 @sign bit removed
lsr r4, #17                @mantissa is removed, only exponent left
lsl r5, #1                 @sign bit removed
lsr r5, #17                @mantissa is removed, only exponent left
lsl r2, #16                @r2 has mantissa of p
lsr r2, #2                 @r2 has 00Mantissa of p
ldr r8, =num1
ldr r7, [r8]
add r2, r2, r7             @r2 has 01Mantissa of p
lsl r3, #16                @r3 has mantissa of q
lsr r3, #2                 @r3 has 00Mantissa of q
add r3, r3, r7             @r3 has 01Mantissa of q
cmp r4, r5                 @comparing exponents
blt r5more                 @if r4 is less
cmp r4, r5
bge r5LessOrEqual	   @if r4 is greater or equal

Finish:
b Back

If01:
lsr r7, #16
add r9, r9, r4
add r9, r9, r7
b FinishM

lpfpMultiply:
@stmfd sp!,{ r2- r9, lr}
ldr r1, =num
ldmia r1, { r2, r3}        @r2 r3 has 32 bit p and q respectively
mov r4, r2                 @r4 has p  
mov r5, r3                 @r5 has q
lsr r4, #31                @r4 has MSB of p
lsr r5, #31                @r5 has MSB of q
eor r9, r5, r4             @r9 has xor of sign bits of p and q
lsl r9, #31                @shifting sign bit to MSB of r9
mov r4, r2                 @r4 has p
mov r5, r3                 @r5 has q
lsl r4, #1                 
lsr r4, #17                @r4 has exponent
lsl r5, #1
lsr r5, #17                @r5 has exponent
add r4, r4, r5             @r4 has sum of exponents
ldr r8, =num1  
add r8, #4            
ldr r7,[r8]                @r7 has bias value
sub r4, r7                 @r4 has final exponent
lsl r4, #17
lsr r4, #1
lsl r2, #16                @r2 has mantissa of p
lsr r2, #1                 @r2 has 0mantissa of p
add r8, #4   
ldr r7, [r8]
add r2, r7                 @r2 has 1mantissa of p
lsr r2, #15                @r2 has 1mantissa of p in last 17 bits
lsl r3, #16
lsr r3, #1
add r3, r7
lsr r3, #15
umull r7, r6, r3, r2       @r6, r7 has multiplication of mantissas
cmp r6, #1                 @comparing MSB with 1
beq If01                   @if MSB is one
add r8, #4
ldr r8, [r8]
add r4, r8
lsl r6, #31
lsr r7, #1
add r6, r6, r7
lsr r6, #16
add r9, r9, r6              @r9 has signbit and mantissa
add r9, r9, r4              @exponent also added to r9

FinishM:
add r1, r1, #12
str r9, [r1]
ldmfd sp!, { r2- r9, pc}

_start:
ldr r1, =num
b lpfpAdd
Back:
b lpfpMultiply
