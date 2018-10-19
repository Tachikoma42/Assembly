.MODEL  TINY

    COM_ADD     EQU     0F003H
    PA_ADD      EQU     0F000H
    PB_ADD      EQU     0F001H
    PC_ADD      EQU     0F002H

.STACK  100

.CODE

START:  MOV     AX, @DATA
        MOV     DS, AX
        NOP
        MOV     DX, COM_ADD
        MOV     AL, 90H
        OUT     DX, AL
        MOV     DX, PA_ADD
        IN      AL, DX
        call    compare
        NOT     AL
        MOV     DX, PB_ADD
        OUT     DX, AL

        MOV     AX, 4C00H
        INT     21H

compare proc
    cmp al,01111111b
    jb  jp1
    and al, 01111111b
    NOT al
   jp1: ret


compare endp
        END     START