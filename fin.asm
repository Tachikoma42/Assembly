.MODEL  TINY

    COM_ADD     EQU     0F003H
    PA_ADD      EQU     0F000H
    PB_ADD      EQU     0F001H
    PC_ADD      EQU     0F002H

.STACK  100
.DATA
    ;LEDDATA     DB      01111111B
     ;           DB      10111111B
      ;          DB      11011111B
       ;         DB      11101111B
        ;        DB      11110111B
         ;       DB      11111011B
           ;     DB      11111101B
          ;      DB      11111110B
    
    LEDDATA     DB      11111111B
                DB      11100111B
                DB      11000011B
                DB      10000001B
                DB      00000000B
                DB	10000001B
                DB	11000011B
                DB	11100111B
                DB	11111111B

.CODE

START:  MOV     AX, @DATA
        MOV     DS, AX
        NOP
        MOV     DX, COM_ADD
        MOV     AL, 80H
        OUT     DX, AL
        MOV     DX, PC_ADD
        MOV     AL, 0FEH
        OUT     DX, AL
        MOV     DX, PA_ADD
        MOV     AL, 0F2H
        OUT     DX, AL

        MOV     DX, PB_ADD  ;TURN OFF ALL THE LIGHT
        MOV     AL, 0FFH
        OUT     DX, AL
        LEA     BX, LEDDATA
LP2:    MOV     AL, 0
        XLAT
        OUT     DX, AL
        CALL	DELAY1
        MOV		AL,1
        XLAT
        OUT		DX,AL
        CALL	DELAY1
        MOV		AL,2
        XLAT
        OUT		DX,AL
        CALL	DELAY1
        MOV		AL,3
        XLAT
        OUT		DX,AL
        CALL	DELAY1
        MOV		AL,4
        XLAT
        OUT		DX,AL
        CALL	DELAY1
        MOV		AL,5
        XLAT
        OUT		DX,AL
        CALL	DELAY1
        MOV		AL,6
        XLAT
        OUT		DX,AL
        CALL DELAY1
        MOV		AL,7
        XLAT
        OUT		DX,AL
        CALL	DELAY1


        JMP LP2
        
        MOV	AX,4C00H
        INT	21H

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
