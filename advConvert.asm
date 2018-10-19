DATA    SEGMENT                     ;定义数据段
    INBUF       DB  6
    INLEN       DB  ? 
    DECBUF      DB  6   DUP(30H), '='
    BINBUF      DB  16  DUP(30H), 'B='
    HEXBUF      DB  4   DUP(30H),'H'
    MESS0       DB  'PLEASE INPUT A NUMBER (0-65535): $'
    MESS1       DB  'INVALID INPUT$'
DATA    ENDS                        ;数据段结束
CODE    SEGMENT                     ;定义代码段
        ASSUME  DS:DATA, CS:CODE    ;段属性说明
START:  MOV     AX,DATA             ;初始化DS
        MOV     DS,AX               ;初始化DS         
        MOV     DX, OFFSET      MESS0
        CALL    DISPMESS   
        CALL    NEWLINE   
        MOV     DX, OFFSET  INBUF
        MOV     AH,10
        MOV     AL,0;星研要求al=0
        INT     21H
        MOV     BX, OFFSET  DECBUF
        ADD     BL,INLEN
        MOV     BYTE PTR    [BX], 'D'
        CALL    CHECK
        JC      WRONG
        CALL    DEC2BIN
        CALL    DEC2HEX
        CALL    DISP
        MOV     AX,4C00H            ;返回DOS
        INT     21H;
WRONG:  MOV     DX, OFFSET  MESS1
        CALL    DISPMESS
        MOV     AX, 4C00H
        INT     21H


DISP        PROC
        CALL    NEWLINE
        MOV     AH, 9
        INT     21H
        RET
DISP        ENDP
DEC2BIN     PROC
        PUSH    AX
        MOV     CX, 16
        MOV     BX, OFFSET  BINBUF
LOP2:   SHL     AX,1
        JNC     NEX1
        INC     BYTE    PTR [BX]
NEX1:   INC     BX
        LOOP    LOP2    
        POP     AX
        RET
DEC2BIN     ENDP

DEC2HEX     PROC
        MOV     BX,AX
        MOV     CH,4
        MOV     SI, OFFSET HEXBUF
LOP3:   MOV     CL,4
        ROL     BX,CL
        MOV     AL,BL
        AND     AL, 0FH
        ADD     AL, 30H
        CMP     AL, 3AH
        JL      NEX2
        ADD     AL, 7
NEX2:   MOV     [SI], AL
        INC     SI
        DEC     CH
        JNZ     LOP3
        RET
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

CHECK       PROC
        XOR     AX, AX
        MOV     SI, 10
        XOR     CH, CH
        MOV     CL, INLEN
        MOV     DI, OFFSET DECBUF
LOP1:   MOV     BL,[DI]
        CMP     BL,39H
        JA      WRONGF
        CMP     BL, 30H
        JB      WRONGF
        XOR     BH,BH
        SUB     BL, 30H
        MUL     SI
        JC      WRONGF
        ADD     AX,BX
        JC      WRONGF
        INC     DI
        LOOP    LOP1
        CLC
        RET
WRONGF:  STC
        RET
CHECK       ENDP
CODE    ENDS                        ;代码段结束
        END     START               ;源程序结束
