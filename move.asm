ROW = 5
CLOUM = 10
ESCKEY = 1BH
DATA    SEGMENT
        MESS    DB      'HELLO'
        MESS_LEN = $-MESS
        COLORB  DB      07H,01H,0FH,70H,74H
        COLORE  LABEL   BYTE
DATA    ENDS
CODE    SEGMENT
        ASSUME  CS:CODE, DS:DATA
START:  MOV     DI, OFFSET      COLORB-1
        MOV     AX, DATA
        MOV     DS, AX
        MOV     ES, AX
NEXTC:  INC     DI
        CMP     DI, OFFSET      COLORE
        JNZ     NEXTE
        MOV     DI, OFFSET      COLORB
NEXTE:  MOV     BL, [DI]
        MOV     SI, OFFSET      MESS
        MOV     CX, MESS_LEN
        MOV     DH, ROW
        MOV     DL, CLOUM
        CALL    ECHO
        MOV     AH,0
        INT     16H
        CMP     AL, ESCKEY
        JNZ     NEXTC
        MOV     AX, 4C00H
        INT     21H

ECHO    PROC   
        PUSH    ES
        PUSH    BP
        PUSH    DS
        POP     ES
        MOV     BP, SI
        MOV     BH,0
        MOV     AL,0
        MOV     AH,13H
        INT     10H
        POP     BP
        POP     ES
        RET
ECHO    ENDP

CODE    ENDS    
        END     START