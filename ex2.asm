DATA    SEGMENT                     ;定义数据段
VAL1    DB  12H,8EH                 ;定义变量
        ;定义更多变量
DATA    ENDS                        ;数据段结束

CODE    SEGMENT                     ;定义代码段
MAIN    PROC    FAR                  
        ASSUME  DS:DATA, CS:CODE    ;段属性说明
START:  PUSH    DS                      
        MOV     AX,0                    
        PUSH    AX                      
        MOV     AX,DATA                 
        MOV     DS,AX               ;初始化DS
        ;填写代码
        RET                             
MAIN    ENDP                            
CODE    ENDS                        ;代码段结束
        END     START               ;源程序结束