DATA    SEGMENT                     ;定义数据段
;VAL1    DB  12H,8EH                ;定义变量
BUFF    DB  'How do you do?', 0DH,0AH,'$'
        ;定义更多变量
DATA    ENDS                        ;数据段结束

CODE    SEGMENT                     ;定义代码段
        ASSUME  DS:DATA, CS:CODE    ;段属性说明
START:  MOV     AX,DATA             ;初始化DS
        MOV     DS,AX               ;初始化DS              
        ;填写代码
        LEA     DX,BUFF
        MOV     AH,9
        INT     21H
        
        ;insert code
        MOV     AX,4C00H            ;返回DOS
        INT     21H;
CODE    ENDS                        ;代码段结束
        END     START               ;源程序结束
