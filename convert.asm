;.MODEL	TINY
;.STACK
;.CODE
DATA    SEGMENT                     ;定义数据段
        BUF     DB  4   DUP(0)
        TEMP1   DW  0
        MESS0   DB  'PLEASE INPUT FOUR NUMBER: $'
        MESS1   DB  'INPUT INCORRECT$'
        MESS2   DB  'BIN: $'
        MESS3   DB  'HEX: $'
DATA    ENDS                        ;数据段结束

CODE    SEGMENT                     ;定义代码段
        ASSUME  DS:DATA, CS:CODE    ;段属性说明
START:  MOV     AX,DATA             ;初始化DS
        MOV     DS,AX               ;初始化DS              
        ;填写代码
NOFOUR: MOV     DX, OFFSET      MESS0
        CALL    DISPMESS
        LEA     BX, BUF
        MOV     CX, 4
INP:    MOV	AL, 00H
	MOV     AH, 01H
        INT     21H
        CMP     AL, 08H
        JE      BACK
BACK1:        CMP     AL, '0'
        JB      ERROR
        CMP     AL, '9'
        JA      ERROR
        SUB     AL, 30H
        MOV     [BX], AL
        INC     BX
        LOOP    INP
        JMP    OK
ERROR:  MOV     DX, OFFSET      MESS1
        CALL    NEWLINE
        CALL    DISPMESS
        CALL    NEWLINE
        JMP     NOFOUR

OK:     MOV     AX, 0
        MOV     DX, 0
        MOV     SI, 10
        MOV     BX, 0
        MOV     CX, 4
MUL10:  MUL     SI
        MOV     DL, [BX]
        XOR     DH, DH
        ADD     AX,DX
        INC     BX
        LOOP    MUL10
        MOV     TEMP1, AX
        CALL    HEX2BIN
        CALL    DEC2HEX


        MOV     AX, 4C00H
        INT     21H
BACK:   MOV     AL, 08H
        INT     10H
        ADD     CX
        JMP     BACK1
HEX2BIN     PROC
        MOV     DX, OFFSET      MESS2
        CALL    NEWLINE
        CALL    DISPMESS
        MOV     BX, TEMP1
        MOV     CX, 16
        XOR     DH,DH
LP1:    ROL     BX, 1
        MOV     DL, 0
        ADC     DL, 30H
        CMP     DH,00H
        JE      ABNORM
LP2:    MOV     AH, 02H
        INT     21H
LP3:        LOOP    LP1
        MOV     AL, 'B'
        CALL    DISPCHAR
        RET
ABNORM: CMP     DL,30H
        JE      LP3
        MOV     DH,01H
        JMP     LP2
HEX2BIN     ENDP
DEC2HEX     PROC
        MOV     DX, OFFSET      MESS3
        CALL    NEWLINE
        CALL    DISPMESS
        MOV     CH, 4
        MOV     CL, 4
        XOR     DH,DH
DISP:   ROL     TEMP1, CL
        MOV     AX, TEMP1
        AND     AX, 000FH
        CMP     DH,00H
        JE      ABNORM1
LOP2:   CALL    TOHEX
        CALL    DISPCHAR
LOP3:   DEC     CH
        JNZ     DISP
        MOV     AL, 'H'
        CALL    DISPCHAR
        RET
ABNORM1:CMP     AL,00H
        JE      LOP3
        MOV     DH,01H
        JMP     LOP2
DEC2HEX     ENDP

DISPMESS    PROC    NEAR
        MOV     AH, 9
        INT     21H
        RET

DISPMESS    ENDP

NEWLINE     PROC
        PUSH    AX
        PUSH    DX
        MOV     DL, 0DH
        MOV     AH, 2
        INT     21H
        MOV     DL, 0AH
        MOV     AH, 2
        INT     21H
        POP     DX
        POP     AX
        RET
NEWLINE     ENDP

TOHEX     PROC
        and     al, 0fh
        ADD     AL, 30H
        CMP     AL,39H
        JBE     BACK
        ADD     AL,07H
BACK:   RET
TOHEX     ENDP

DISPCHAR    PROC
        MOV     DL,AL
        MOV     AH, 2
        INT     21H
        RET
DISPCHAR    ENDP

 
CODE    ENDS                        ;代码段结束
        END     START               ;源程序结束
