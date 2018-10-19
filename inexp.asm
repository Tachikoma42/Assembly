        MOV     AL, 10000010B
        MOV     DX, COM_ADD
        OUT     DX, AL

JP2:    MOV     DX, PB_ADD
JP1:    IN      AL, DX
        AND     AL, 01H
        JZ      JP1
        INC     BL
        MOV     DX, PC_ADD
        MOV     AL, BL
        NOT     AL
        OUT     DX, AL
        CALL    DL500ms
        JMP     JP2


        MOV     AL, 10000010B
        MOV     DX, COM_ADD
        OUT     DX, AL
JP3:    MOV     DX, PB_ADD
JP1:    IN      AL, DX
        AND     AL, 01H
        JZ      JP1
        INC     BL
        MOV     DX, PC_ADD
        MOV     AL,BL
        NOT     AL
        OUT     DX, AL
        MOV     DX, PB_ADD
JP2:    IN      AL,DX
        AND     AL,01H
        JNZ     JP2
        CALL    DL500ms
        JMP     JP3
