.MODEL  TINY

    COM_ADD     EQU     0F003H
    PA_ADD      EQU     0F000H
    PB_ADD      EQU     0F001H
    PC_ADD      EQU     0F002H

.STACK  100
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
.CODE

START:  MOV     AX, @DATA
        MOV     DS, AX
        NOP
        XOR     BX,BX
        MOV     DX, COM_ADD
        MOV     AL, 82H
        OUT     DX, AL
        CALL    DISP
JP2:    MOV     DX, PB_ADD
JP1:    IN      AL, DX
        CMP     AL, 80H
        JNE     JP1
        INC     BL
        CMP     BL,16
        JE      JP3
JP4:    CALL    DISP
JP5:        IN      AL, 0H
        JNE     JP5
        JMP     JP2
        MOV     AX, 4C00H
        INT     21H
JP3:    XOR     BX, BX
        JMP     JP4
DISP    PROC
        PUSH    DX
        PUSH    AX
        PUSH    BX

        MOV     DX, PC_ADD; CONTRAL
        MOV     AL, 0FEH
        OUT     DX, AL
        MOV     DX, PA_ADD; DISPLAY
        MOV     AL, BL
        LEA     BX, LED7SEG
        XLAT
        OUT     DX, AL

        POP     BX
        POP     AX
        POP     DX
DISP    ENDP

;DL500MS		PROC
;		PUSH	CX	
;		MOV	CX,60000	
;DL500MS1:	LOOP	DL500MS1	
;		POP	CX	
;		RET		
;DL500MS	ENDP

        END     START