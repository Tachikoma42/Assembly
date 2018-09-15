MLENGTH  = 128                                                  ;缓冲区长度
DSEG    SEGMENT                                                
    BUFF    DB  MLENGTH                                         ;符合0AH号功能调用所需的缓冲区
            DB  ?                                               ;实际键入的字符数
            DB  MLENGTH     DUP(0)                              
    MESS0   DB  'Please input: $'
    MESS1   DB  'X = $'                                         ;数字个数输出提示
    MESS2   DB  'Y = $'                                         ;字符个数输出提示
DSEG    ENDS

CSEG    SEGMENT
    ASSUME  CS:CSEG, DS:DSEG
START:  MOV     AX, DSEG
        MOV     DS, AX                                          ;设置DS
        MOV     DX, OFFSET  MESS0                               ;设置提示消息
        CALL    DISPMESS
        MOV     DX, OFFSET  BUFF                                
        MOV     AH, 0AH                                         ;接收一个字符串
        INT     21H
        CALL    NEWLINE
        MOV     BH, 0                                           ;初始化数字计数器
        MOV     BL, 0                                           ;初始化字符计数器
        MOV     CL, BUFF+1                                      ;字符串长度
        
                                    ;MOV     DL, CL
                                    ;MOV     AH, 02H
                                    ;INT     21H
        MOV     CH, 0  
        JCXZ    COK                                             ;若字符串长度等于零，不统计

                                        ;开始处理字符串

        MOV     SI, OFFSET  BUFF+2                              ;指向字符串首地址
AGAIN:  MOV     AL, [SI]                                        ;取一个字符
        INC     SI                                              ;调整数据指针，指向下一个数据

                                        ;判断是否为数字
        CMP     AL, '0'                                         ;小于0，转向下一个字符                      
        JB      NEXT                    
        CMP     AL, '9'                                         ;大于9，转向字符统计
        JA      NODEC                   
                                        ;结束判断

        INC     BH                                              ;判断为数字，数字计数加一
        JMP     SHORT   NEXT                                    ;取下一个字符

                                        ;判断是否为字母
NODEC:  OR      AL, 20H                                         ;大写转为小写字符，小写不变
        CMP     AL, 'a'                                         ;判断是否为字母
        JB      NEXT                                            ;不是，取下一个数
        CMP     AL, 'z'                                         
        JA      NEXT                                            ;不是，取下一个数
        INC     BL                                              ;判断为字符，字符计数器加一
NEXT:   LOOP    AGAIN


COK:    MOV     DX, OFFSET MESS1
        CALL    DISPMESS
        MOV     AL, BH
        XOR     AH, AH
        CALL    DISPAL
        CALL    NEWLINE
        MOV     DX, OFFSET      MESS2
        CALL    DISPMESS
        MOV     AL, BL
        XOR     AH, AH
        CALL    DISPAL
        CALL    NEWLINE

        MOV     AX, 4C00H
        INT     21H

; SUBPROG   DISPAL
; USING DEC TO REPRESENT 8 BIT BIN
; INPUT VALUE AL = 8 BIT BIN
; EXIT VALUE  NULL
DISPAL  PROC    NEAR
        MOV     CX, 3
        MOV     DL, 10
DISP1:  DIV     DL
        XCHG    AH, AL
        ADD     AL, 30H
        PUSH    AX
        XCHG    AH, AL
        MOV     AH, 0
        LOOP    DISP1
        MOV     CX, 3
DISP2:  POP     DX
        CALL    ECHOCH
        LOOP    DISP2
        RET
DISPAL ENDP

; SUBPROG:  DISPMESS
; USING DOS NUMBER 9 TO DISPLAY STRING
; INPUT VALUE NULL
; EXIT VALUE NULL
DISPMESS    PROC    NEAR
        MOV     AH, 9
        INT     21H
        RET
DISPMESS    ENDP



; SUBPROG:  ECHOCH
; USING DOS NUMBER 2 TO DISPLAY A CHARACTER
;INPUT VALUE NULL
;EXIT VALUE NULL
ECHOCH      PROC    NEAR
        MOV     AH, 2
        INT     21H
        RET
ECHOCH      ENDP

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
CSEG    ENDS
        END     START
