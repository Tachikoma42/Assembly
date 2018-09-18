DATA SEGMENT
MSG0 DB 13, 10, 'This Program can display ASCII.$'
MSG1 DB 13, 10, 'press any key...', 13, 10, '$'
MSG2 DB 13, 10, 'the ascii of this letter is $'
DATA ENDS
;---------------------------------
CODE SEGMENT
ASSUME CS:CODE, DS:DATA
START:
MOV AX, DATA
MOV DS, AX
MOV DX, OFFSET MSG0
MOV AH, 9 ;9号功能调用，显示提示.
INT 21H ;显示.
;---------------------------------
LOP:
MOV DX, OFFSET MSG1
MOV AH, 9 ;9号功能调用，显示提示.
INT 21H ;显示.
MOV AH, 1 ;1号功能调用，键入、显示.
INT 21H ;
CMP AL, 13
JZ EXIT ;回车就结束.
PUSH AX
MOV DX, OFFSET MSG2
MOV AH, 9 ;9号功能调用，显示提示.
INT 21H
;------------------------
POP AX
CALL CHANUM ;调用显示程序.
JMP LOP
;---------------------------------
EXIT:
MOV AH, 4CH
INT 21H
;---------------------------------
CHANUM: ;显示AL中的ASCII码.
    MOV AH, 0 ;下面显示两位16进制数.
    MOV BL, 16
    DIV BL
    PUSH AX
    MOV DL, AL
    ADD DL, '0'
    CMP DL, 3AH
    JB H1
    ADD DL, 7
H1: MOV AH, 2
    INT 21H
    POP AX
    MOV DL, AH
    ADD DL, '0'
    CMP DL, 3AH
    JB H2
    ADD DL, 7
H2: MOV AH, 2
    INT 21H
    MOV DL, 'H' ;显示H.
    INT 21H
    MOV DL, '.'
    INT 21H
    RET
;---------------------------------
CODE ENDS
END START