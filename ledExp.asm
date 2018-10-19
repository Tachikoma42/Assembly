START:  MOV     AX, @DATA
        MOV     DS, AX
        NOP


         
        MOV     DX, COM_ADD
        OUT     DX, AL

        MOV     AL, 0FFH
        MOV     DX, PA_ADD
        OUT     DX, AL
        MOV     AL, 00000000B
        MOV     BL, 8
        MOV     DX, PA_ADD
JP1:    OUT     DX, AL
        ADD     AL, 10B
        MOV     CX, 0
        PUSH    BX
JP2:    MOV     BX, 10000
JP3:    DEC     BX
        JNZ     JP3
        LOOP    JP2
        POP     BX
        DEC     BL
        CMP     BL, 0
        JNZ     JP1
        END     START
