DELAY2 PROC
        PUSH    CX
        MOV     CX, 4
LO1:    PUSH    CX
        MOV     CX, 60000
LO2:    LOOP    LO2
        POP     CX
        LOOP    LO1
        POP     CX
        RET
DELAY2  ENDP