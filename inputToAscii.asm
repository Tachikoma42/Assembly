DATA    SEGMENT                     ;定义数据段
    MESS0   DB      'PLEASE INPUT CHARACTER: $'
DATA    ENDS                        ;数据段结束

CODE    SEGMENT                     ;定义代码段
        ASSUME  DS:DATA, CS:CODE    ;段属性说明
START:  MOV     AX,DATA             ;初始化DS
        MOV     DS,AX               ;初始化DS              
        MOV     DX, OFFSET      MESS0
        CALL    DISPMESS
        MOV     AH,01H
        INT     21H
        CMP     AL, 13H
        JE      EXIT
        CALL    NEWLINE
        CALL    IN2ASCII

EXIT:   MOV     AX,4C00H            ;返回DOS
        INT     21H;


; SUBPROG:  DISPMESS
; USING DOS NUMBER 9 TO DISPLAY STRING
; INPUT VALUE NULL
; EXIT VALUE NULL
DISPMESS    PROC    NEAR
        MOV     AH, 9
        INT     21H
        RET
DISPMESS    ENDP

; SUBPROG:  NEWLINE
; DISP ENTER AND \N
;INPUT VALUE NULL
;EXIT VALUE NULL
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

; SUBPROG:  IN2ASCII
; CONVERT INPUT TO ASCII
;
;
IN2ASCII    PROC
    XOR     AH,AH
    MOV     BL,16
    DIV     BL
    PUSH    AX
    MOV     DL,AL
    ADD     DL,'0'
    MOV     AH,2
    INT     21H
    POP     AX
    MOV     DL,AH
    ADD     DL,'0'
    MOV     AH,2
    INT     21H
    MOV     DL, 'H'
    INT     21H
    RET
IN2ASCII    ENDP

CODE    ENDS                        ;代码段结束
        END     START               ;源程序结束
