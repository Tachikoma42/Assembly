.MODEL  TINY
    COM_ADD EQU     0F000H
    PERIOD  EQU     0FFH
.STACK 100
.CODE
START:  MOV     AX, @DATA
        MOV     DS, AX
        NOP
        MOV     DX, COM_ADD
RE:     
        MOV     AL, 80H
        OUT     DX, AL
        call    DELAY1


        MOV     AL, 0
        OUT     DX, AL
        call    delay1

        JMP     RE
        MOV     AX, 4C00H
        INT     21H   

DELAY1 PROC

        PUSH    CX
        MOV     CX, 4
LO1:    PUSH    CX
        MOV     CX, 60000
LO2:    LOOP    LO2
        POP     CX
        LOOP    LO1
        POP     CX
        RET
DELAY1  ENDP


END     START
