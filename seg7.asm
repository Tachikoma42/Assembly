.MODEL  TINY

    COM_ADD     EQU     0F003H
    PA_ADD      EQU     0F000H
    PB_ADD      EQU     0F001H
    PC_ADD      EQU     0F002H

.STACK  100
.CODE

START:      MOV     AX, @DATA
            MOV     DS, AX
            NOP
            MOV     DX, COM_ADD
            MOV     AL, 80H
            OUT     DX, AL
            MOV     DX, PC_ADD
            MOV     AL, 0FH
            OUT     DX, AL
            MOV     DX, PA_ADD
            MOV     AL, 71H
            OUT     DX, AL
            MOV     AX, 4C00H
            INT     21H
            END     START
