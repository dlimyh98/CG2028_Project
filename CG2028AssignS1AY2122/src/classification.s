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

@ Register map, DATAPOINTS = 8, CENTROID = 2
@ R0 - points10[DATAPOINT][2] (arg1)
@      returns class that contains MORE data points
@ R1 - centroids10[CENTROID][2] (arg2)
@ R2 - class[DATAPOINT] (arg3)
@ R3 - starting address of centroids10[CENTROID][2]
@       counter for number of points under centroid0
@ R4 - ONE points10 point compared to centroid0
@       counter for number of points under centroid1
@ R5 - same points10 point in R5 compared to centroid1
@ R6 - starting address of points10[CENTROID][2]
@ R7 - counter for looping through all DATAPOINTS
@ R8 - counter for matching ONE point10 (x,y) to TWO centroid10 (x,y)
@ R9 - x-coordinate of some points10 point
@      x-coordinate of point-centroid
@      squared difference of x-coordinates between point and centroid
@      squared Euclidean distance between some data point and centroid
@ R10 - y-coordinate of some points10 point
@       y-coordinate of point-centroid
@       squared difference of y-coordinates between point and centroid
@ R11 - starting address of class[DATAPOINT]
@
@....

classification:

@ Equates
        .equ DATAPOINT, 0x8

@ PUSH / save (only those) registers which are modified by your function, parameter registers need not be saved
		PUSH {R3-R11,R14}

@ parameter registers need not be saved.

@ write asm function body here
        MOV R3, R1       @ initialize R3 with STARTING address of centroids10[CENTROID][2]
        LDR R4, =0x0     @ initialize distance between point to centroid0 as 0
        LDR R5, =0x0     @ initialize distance between point to centroid1 as 0
        MOV R6, R0       @ initialize R6 with STARTING address of points10[CENTROID][2]
        LDR R7, =0x0     @ counter for looping through all DATAPOINTS
        LDR R8, =0x0     @ counter for matching ONE point10 (x,y) to TWO centroid10 (x,y)
        MOV R11, R2      @ save the STARTING address of class[DATAPOINT], need to use it later


@ each loop iteration matches ONE point10 (x,y) to ONE centroid10 (x,y)
loop_p:
        LDR R9, [R6], #4      @ POST-INDEX load contents of points10[DATAPOINT][2], x-coordinate of some point
        LDR R10, [R3], #4     @ POST-INDEX load contents of centroids10[CENTROID][2], x-coordinate of some centroid
        SUB R9, R9, R10       @ x-coordinate of points10 MINUS x-coordinate of centroids10, store in R9
        MUL R9, R9, R9        @ squared difference of x-coordinates

        LDR R10, [R6]         @ NORMAL load contents of points10[DATAPOINT][2], y-coordinate of SAME point above
        LDR R11, [R3], #4     @ POST-INDEX load contents of centroids10[CENTROID][2], y-coordinate of SAME centroid above
        SUB R10, R10, R11     @ y-coordinate of points10 MINUS y-coordinate of centroids10, store in R10
        MUL R10, R10, R10     @ squared difference of y-coordinates

        ADD R9, R9, R10       @ squared Euclidean distance between some data point and centroid

        ADD R8, R8, #1        @ increment counter
        CMP R8, #2            @ have we found out TWO distances between point and centroid0/centroid0?
        ITTEE NE
        MOVNE R4, R9          @ if only found out ONE distance so far, then record this distance in R5
        MOVNE R6, R0          @ if only found out ONE distance so far, then points10[CENTROID][2] needs to be reset
        MOVEQ R5, R9          @ if found out TWO distances already, record this distance in R6
        LDREQ R8, =0x0        @ if found out TWO distances already, reset the counter

        BNE loop_p            @ if only ONE distance found so far, proceed to match current point to 2nd centroid
        BEQ loop_d            @ else, proceed to next point


@ each loop iteration fills in an entry in class[DATAPOINTS]
loop_d:
        MOV R3, R1           @ restore R3 with STARTING address of centroids10[CENTROID][2]
        ADD R0, #8           @ go to next points10 point
        MOV R6, R0           @ go to next points10 point

        LDR R9, =0x0         @ point will belong to centroid0
        LDR R10, =0x1        @ point will belong to centroid1

        CMP R4, R5            @ point-centroid0 vs point-centroid1, does R4 - R5
        ITE PL                @ condition: R4 - R5 is POSITIVE or ZERO
        STRPL R9, [R2], #4    @ distance in R4 is larger, so point must belong to centroid0
        STRMI R10, [R2], #4   @ distance in R5 is larger, so point must belong to centroid1

        ADD R7, R7, #1            @ increment "i" variable
        CMP R7, DATAPOINT        @ i == DATAPOINT in for loop?

        BNE loop_p                 @ if not, still have more points to classify
        B whichCentroidMorePoints  @ else, can proceed to second part


whichCentroidMorePoints:
        MOV R2, R11         @ restore R2 to STARTING address of class[DATAPOINTS]
        LDR R3, =0x0        @ counter for number of points under centroid0
        LDR R4, =0x0        @ counter for number of points under centroid1
        LDR R5, =DATAPOINT  @ iterate through class[DATAPOINTS]

        B loop_c

@ iterate through class[DATAPOINT]
loop_c:
        CMP R5, #0         @ have we iterated through ENTIRE class[DATAPOINTS]?
        BEQ returnClass    @ if yes, return to C program

        LDR R6, [R2], #4   @ load element of class[DATAPOINTS] into R6

        CMP R6, #0         @ do R6 - 0
        ITE EQ             @ condition: R6 == 0?
        ADDEQ R3, #1       @ if yes, then increment counter for centroid0
        ADDNE R4, #1       @ if no, then increment counter for centroid1

        CMP R3, R4         @ points in centroid0 - points in centroid1
        ITE MI             @ condition: centroid0 has less points than centroid1
        MOVMI R7, #1       @ NEGATIVE: R7 stores centroid with larger amount of points (centroid1 here)
        MOVPL R7, #0       @ POSITIVE OR ZERO: R7 stores centroid with larger amount of points (centroid0 or centroid1 here)

        SUB R5, #1         @ decrement iteration counter through class[DATAPOINTS]
        B loop_c           @ loop back again


@ prepare value to return (class) to C program in R0
returnClass:
		MOV R0,R7    @ R7 contains the centroid number with the most points

@ POP / restore original register values. DO NOT save or restore R0. Since return value is stored in R0
		POP {R3-R11,R14}

@ return to C program
		BX	LR



@ branch to SUBROUTINE for illustration only
		BL SUBROUTINE

@ you could write your code without SUBROUTINE
SUBROUTINE:

		BX LR

@label: .word value
d:
    .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  @ d[CENTROID][DATAPOINT], 2D Array

@.lcomm label num_bytes
