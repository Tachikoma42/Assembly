.MODEL  TINY

    COM_ADD     EQU     0B002H
    P0_ADD      EQU
    P1_ADD      EQU
    P2_ADD      EQU

.STACK  100
;.DATA


.CODE

START:  MOV     AX, @DATA
        MOV     DS, AX
        NOP
        MOV DX,COM_ADD ;控制口
        MOV AL,01000001B;通道0控制字，先读写低字节,后高字节,方式3,BCD计数
        OUT DX,AL;写入控制字
        MOV AL,5 ;低字节
        MOV DX,P1_ADD ;通道2
        OUT DX,AL ;写入低字节


        MOV	AX,4C00H
        INT	21H

END     START