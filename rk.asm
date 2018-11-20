.MODEL  TINY

    COM_ADD     EQU     0F003H
    PA_ADD      EQU     0F000H
    PB_ADD      EQU     0F001H
    PC_ADD      EQU     0F002H

.STACK  100
x	
.DATA
    LED7SEG     DB      11111100B
                DB      01100000B
                DB      11011010B
                DB      11110010B
                DB      01100110B
                DB      10110110B
                DB      10111110B
                DB      11100000B
                DB      11111110B
                DB      11110110B
                DB      11101110B
                DB      00111110B
                DB      10011100B
                DB      01111010B
                DB      10011110B
                DB      10001110B
        
    THREEONE    DB      01110000B
                DB      01100000B
                DB      01010000B
                DB      01000000B
                DB      00110000B
                DB      00100000B
    BUF     DB  6 DUP(0)
.CODE

START:      MOV     AX, @DATA
            MOV     DS, AX
            NOP
            MOV     DX, COM_ADD
            MOV     AL, 10010000B
            OUT     DX, AL
            MOV     BL, 0
KS1:        CALL    KS              ;READ BUTTON
            CMP     AL, 0FFH
            JE      KS1
            CALL    DELAY           ;DELAY FOR 抖动
            CALL    KS
            CMP     AL, 0FFH
            JE      KS1

            MOV     CL, 2
            MOV     AH, 0
            MOV     AL, 11111101B
CONTIN:     PUSH    AX
            MOV     DX, PC_ADD
            OUT     DX, AL
            MOV     DX, PA_ADD
            IN      AL, DX
            MOV     AH, AL
            CMP     AH, 0FFH
            JNE     NEXT0
            POP     AX
            ROR     AL,1
            LOOP    CONTIN
            JMP     KS1
NEXT0:      MOV     CH,CL
            MOV     CL,7
BEGIN0:     SHL     AH,1
            JNC     COL0
            LOOP    BEGIN0
            JMP     KS1
COL0:       CMP     BL,6
            JE      THEEND
            CALL    STORE
            CALL    DISPLAY

            INC     BL
            JMP     KS1   

THEEND:     MOV     AX, 4C00H
            INT     21H

DISPLAY     PROC    NEAR
        PUSH    BX

        MOV     AH, BL
        INC     AH
        MOV     BL, 0
NEXT1:  MOV     DX, PC_ADD
        MOV     AL, BL
        LEA     BX, THREEONE
        XLAT
        OUT     DX, AL
        LEA     SI, BUF
        ADD     SI, BL
        MOV     BH, [SI]
        MOV     DX, PB_ADD
        OUT     DX, BH
        INC     BL
        CMP     BL, AH
        JE      TRUEEND
        JMP     NEXT1
TRUEEND: POP     BX
        RET
DISPLAY     ENDP
STORE       PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        
        MOV     BH, CL
        DEC     CH
        MOV     CL, 3
        SHL     CH, CL
        ADD     BH, CH
        MOV     AL, BH
        LEA     SI, BUF
        ADD     SI, BL
        MOV     AL, BH
        LEA     BX, LED7SEG
        XLAT
        MOV     [SI], AL
        
        POP     DX
        PUSH    CX
        PUSH    BX
        PUSH    AX
        RET
STORE       ENDP
KS          PROC    NEAR
        MOV     DX, PC_ADD
        MOV     AL, 00H
        OUT     DX, AL
        MOV     DX, PA_ADD
        IN      AL, DX          ;READ FROM PORT A
        RET
KS          ENDP

DELAY       PROC    NEAR
        PUSH    BX
        PUSH    CX
        MOV     BX,2000
DEL1:   MOV     CX, 0
DEL2:   LOOP    DEL2
        DEC     DX
        JNZ     DEL1
        POP     CX
        POP     BX
        RET
DELAY       ENDP