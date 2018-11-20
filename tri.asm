.MODEL  TINY
    COM_ADD EQU     0F000H
    PERIOD  EQU     0FFH
.STACK 100
.CODE
START:  MOV     AX, @DATA
        MOV     DS, AX
        NOP
        MOV     DX, COM_ADD
        MOV     AL, 0
GOON1:  OUT     DX, AL
        INC     AL
        INC     AL
        CMP     AL, PERIOD
        JZ      GOON2
        JMP     GOON1
GOON2:  OUT     DX, AL
        DEC     AL
        DEC     AL
        CMP     AL, 0
        JNZ     GOON2
        JMP     GOON1
        MOV     AX, 4C00H
        INT     21H
END     START
