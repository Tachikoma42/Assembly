MLENGTH = 128
DATA    SEGMENT                     ;定义数据段
        BUFF    DB      MLENGTH
                DB      ?
                DB      MLENGTH DUP(0)                ;定义变量
        MESS0   DB      'PLEASE INPUT 4 NUMBER: $'
        ;定义更多变量
DATA    ENDS                        ;数据段结束

CODE    SEGMENT                     ;定义代码段
        ASSUME  DS:DATA, CS:CODE    ;段属性说明
START:  MOV     AX,DATA             ;初始化DS
        MOV     DS,AX               ;初始化DS      
NOFOUR: MOV     DX, OFFSET      MESS0
        CALL    DISPMESS
        MOV     DX, OFFSET      BUFF
        MOV     AH,0AH
        INT     21H
        CALL    NEWLINE
        MOV     BH,0
        MOV     BL,0
        MOV     CL,BUFF+1
        MOV     CH,0
        CMP     CL,04H              ;检测是否输入4位字符
        JNE     NOFOUR     

;        MOV     SI, OFFSET  BUFF+2                              ;指向字符串首地址
;AGAIN:  MOV     AL, [SI]
;        INC     SI
                                    ;判断是否为数字
;        CMP     AL, '0'
;        JB      NOFOUR
;        CMP     AL, '9'
;        JA      NOFOUR      
;        LOOP    AGAIN
                                    ;判断完毕，为4位数字
        CALL    DISPNUM
        CALL    NEWLINE
        CALL    REVDISPNUM
        CALL    NEWLINE
        ;填写代码
        
        MOV     AX,4C00H            ;返回DOS
        INT     21H;

; SUBPROG:  DISPMESS
; DISPLAY THE NUMBER JUST ENTERED
; 
;
DISPNUM     PROC
        MOV     SI, OFFSET  BUFF+2
        MOV     CX, 4
NEXT:   MOV     DL, [SI]
        INC     SI
        CALL    ECHOCH
        LOOP    NEXT
        RET
DISPNUM     ENDP    

;
;
;
;
REVDISPNUM  PROC
        MOV     SI,OFFSET   BUFF+6
        MOV     CX,5
NEXT1:  MOV     DL,[SI]
        DEC     SI
        CALL    ECHOCH
        LOOP    NEXT1
        RET
REVDISPNUM     ENDP

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

; SUBPROG:  ECHOCH
; USING DOS NUMBER 2 TO DISPLAY A CHARACTER
;INPUT VALUE NULL
;EXIT VALUE NULL
ECHOCH      PROC    NEAR
        MOV     AH, 2
        INT     21H
        RET
ECHOCH      ENDP

CODE    ENDS                        ;代码段结束
        END     START               ;源程序结束
