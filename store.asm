DESG    SEGMENT

BUF     DB  5 DUP(?)

DESG    ENDS

CSEG    SEGMENT
    ASSUME  CS:CSEG, DS:DESG
START:  MOV     AX, DESG
        MOV     DS, AX
        MOV     AX, DATA
        LEA     SI, BUF
        MOV     AL, 11111111B
        MOV     [SI], AL
        INC     SI
        MOV     AL, 10101010B

        MOV     AH, 4CH
        INT     21H
CSEG    ENDS
END START
