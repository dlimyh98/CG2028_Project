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
@R5 - ONE points10 point compared to centroid0
@R6 - same points10 point in R5 compared to centroid1
@R7 - starting address of points10[CENTROID][2]
@R8 - counter for looping through all DATAPOINTS
@R9 - counter for matching ONE point10 (x,y) to TWO centroid10 (x,y)
@R10 - x-coordinate of some points10 point
@      x-coordinate of point-centroid
@      squared difference of x-coordinates between point and centroid
@      squared Euclidean distance between some data point and centroid
@R11 - y-coordinate of some points10 point
@      y-coordinate of point-centroid
@      squared difference of y-coordinates between point and centroid
@R12 - starting address of class[DATAPOINT]
@
@....

classification:

@ Equates
        .equ DATAPOINT, 0x8

@ PUSH / save (only those) registers which are modified by your function
		PUSH {R1-R4,R14}

@ parameter registers need not be saved.

@ write asm function body here
        MOV R4, R2       @ initialize R4 with STARTING address of centroids10[CENTROID][2]
        LDR R5, =0x0     @ initialize distance between point to centroid0 as 0
        LDR R6, =0x0     @ initialize distance between point to centroid1 as 0
        MOV R7, R1       @ initialize R7 with STARTING address of points10[CENTROID][2]
        LDR R8, =0x0     @ counter for looping through all DATAPOINTS
        LDR R9, =0x0     @ counter for matching ONE point10 (x,y) to TWO centroid10 (x,y)
        MOV R12, R3      @ save the STARTING address of class[DATAPOINT], need to use it later


@ each loop iteration matches ONE point10 (x,y) to ONE centroid10 (x,y)
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

        ADD R9, R9, #1        @ increment counter
        CMP R9, #2            @ have we found out TWO distances between point and centroid0/centroid0?

        ITTEE NE
        MOVNE R5, R10         @ if only found out ONE distance so far, then record this distance in R5
        MOVNE R7, R1          @ if only found out ONE distance so far, then points10[CENTROID][2] needs to be reset
        MOVEQ R10, R6         @ if found out TWO distances already, record this distance in R6
        LDREQ R9, =0x0        @ if found out TWO distances already, reset the counter

        BNE loop_p            @ if only ONE distance found so far, proceed to match current point to 2nd centroid
        BEQ loop_d            @ else, proceed to next point


@ each loop iteration fills in an entry in class[DATAPOINTS]
loop_d:
        MOV R4, R2           @ restore R4 with STARTING address of centroids10[CENTROID][2]
        ADD R1, #8           @ go to next points10 point
        MOV R7, R1           @ go to next points10 point

        LDR R10, =0x0        @ point will belong to centroid0
        LDR R11, =0x1        @ point will belong to centroid1

        CMP R5, R6           @ point-centroid0 vs point-centroid1, does R5 - R6

        ITE PL                @ condition = R5 - R6 is POSITIVE or ZERO
        STRPL R10, [R3], #4   @ distance in R5 is larger, so point must belong to centroid0
        STRMI R11, [R3], #4   @ distance in R6 is larger, so point must belong to centroid1

        ADDS R8, R8, #1            @ increment "i" variable
        CMP R8, =DATAPOINT         @ i == DATAPOINT in for loop?

        BNE loop_p                 @ if not, still have more points to classify
        B whichCentroidMorePoints  @ else, can proceed to second part


@ iterate through class[DATAPOINT]
whichCentroidMorePoints:
        MOV R3, R12
        








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
