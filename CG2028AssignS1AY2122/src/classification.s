 	.syntax unified
 	.cpu cortex-m3
 	.thumb
 	.align 2
 	.global	classification
 	.thumb_func

@ CG2028 Assignment, Sem 2, AY 2021/21
@ (c) CG2028 Teaching Team, ECE NUS, 2021

@ student 1: Name: Damien Lim Yu Hao, Matriculation No.: A0223892Y
@ student 2: Name: , Matriculation No.:

@Register map, DATAPOINTS = 8, CENTROID = 2
@R0 - N, returns class that contains MORE data points
@R1 - points10[DATAPOINT][2]   (arg1)
@R2 - centroids10[CENTROID][2] (arg2)
@R3 - class[DATAPOINT]         (arg3)
@R4 - starting address of centroids10[CENTROID][2]
@R5 - starting address of d[CENTROID][DATAPOINT]
@R6 - starting address of d[CENTROID][DATAPOINT]
@R7 - starting address of points10[CENTROID][2]
@R8 - counter for looping through d[CENTROID][DATAPOINT]
@R9 - counter for matching ONE point10 (x,y) to TWO centroid10 (x,y), and then filling in ONE corresponding COLUMN in d[CENTROID][DATAPOINT]
@R10 - x-coordinate of some points10 point
@      x-coordinate of point-centroid
@      squared difference of x-coordinates between point and centroid
@      squared Euclidean distance between some data point and centroid
@R11 - y-coordinate of some points10 point
@      y-coordinate of point-centroid
@      squared difference of y-coordinates between point and centroid
@....

classification:

@ Equates
        .equ DATAPOINT, 0x8

@ PUSH / save (only those) registers which are modified by your function
		PUSH {R1-R4,R14}

@ parameter registers need not be saved.

@ write asm function body here
        MOV R4, R2       @ initialize R4 with STARTING address of centroids10[CENTROID][2]
        LDR R5, =d       @ load STARTING address of d[CENTROID][DATAPOINT]
        MOV R6, R5       @ copy STARTING address of d[CENTROID][DATAPOINT]
        MOV R7, R1       @ initialize R7 with STARTING address of points10[CENTROID][2]
        LDR R8, =0x0     @ counter for looping through d[CENTROID][DATAPOINT]
        LDR R9, =0x0     @ counter for matching ONE point10 (x,y) to TWO centroid10 (x,y), and then filling in ONE corresponding COLUMN in d[CENTROID][DATAPOINT]


@ each loop iteration matches ONE point10 (x,y) to ONE centroid10 (x,y), and then fills in ONE corresponding entry in d[][]
loop_p:
        LDR R10, [R7], #4     @ POST-INDEX load contents of points10[DATAPOINT][2], x-coordinate of some point
        LDR R11, [R4], #4     @ POST-INDEX load contents of centroids10[CENTROID][2], x-coordinate of some centroid
        SUB R10, R10, R11     @ x-coordinate of points10 MINUS x-coordinate of centroids10, store in R10
        MUL R10, R10, R10     @ squared difference of x-coordinates

        LDR R11, [R7]         @ NORMAL load contents of points10[DATAPOINT][2], y-coordinate of SAME point above
        LDR R12, [R4], #4     @ POST-INDEX load contents of centroids10[CENTROID][2], y-coordinate of SAME centroid above
        SUB R11, R11, R12     @ y-coordinate of points10 MINUS y-coordinate of centroids10, store in R11
        MUL R11, R11, R11     @ squared difference of y-coordinates

        ADD R10, R10, R11     @ squared Euclidean distance between some data point and centroid
        STR R10, [R6]         @ NORMAL store contents of R10 into R6

        B check_p


check_p:
        ADD R9, R9, #1      @ increment counter
        CMP R9, #2          @ have we matched ONE point10 (x,y) to TWO centroid10 (x,y)?

        ITTEE NE
        ADDNE R6, #32       @ if not matched yet, then d[CENTROID][DATAPOINT] needs to be incremented by 32 (still same point)
        MOVNE R7, R1        @ if not matched yet, then points10[CENTROID][2] needs to be reset
        ADDEQ R5, #4        @ if matched, then d[CENTROID][DATAPOINT] needs to be incremented by 4 (move on to next point)
        LDREQ R9, =0x0      @ if matched, reset the counter

        BNE loop_p          @ if not matched yet, proceed to match current point to 2nd centroid
        BEQ loop_d          @ if matched, proceed to next point


@ each loop iteration fills up a VERTICAL column in d[CENTROID][DATAPOINT]
loop_d:
        MOV R4, R2           @ restore R4 with STARTING address of centroids10[CENTROID][2]
        MOV R6, R5           @ initialize R6 with new d[CENTROID][DATAPOINT]
        ADD R1, #8           @ go to next points10 point
        MOV R7, R1           @ go to next points10 point

        ADDS R8, R8, #1      @ increment "i" variable
        CMP R8, =DATAPOINT   @ i == DATAPOINT in for loop?
        BNE loop_p           @ if not, still need to fill-up d[CENTROID][DATAPOINT] 
        B classifyPoint      @ else, can proceed to second part


@ loop through d[CENTROID][DATAPOINT], and check which class each point belongs to
classifyPoint:
        LDR R5, =d
        








@ branch to SUBROUTINE for illustration only
		BL SUBROUTINE

@ prepare value to return (class) to C program in R0
@ the #5 here is an arbitrary result
		MOVW R0, #5

@ POP / restore original register values. DO NOT save or restore R0. Why?
		POP {R1-R4,R14}

@ return to C program
		BX	LR

@ you could write your code without SUBROUTINE
SUBROUTINE:

		BX LR

@label: .word value
d:
    .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  @ d[CENTROID][DATAPOINT], 2D Array


@.lcomm label num_bytes
