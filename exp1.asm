.MODEL	TINY	

	COM_ADD		EQU		0F003H	
	PA_ADD		EQU		0F000H	
	PB_ADD		EQU		0F001H	
	PC_ADD		EQU		0F002H	

.STACK		100	

.DATA	

	LED_Data		
				DB	01111101B	;东西绿灯，南 北红灯
				DB	11111101B	;东西绿灯闪烁，南北红灯
				DB	10111101B	;东西黄灯亮，南北红灯
				DB	11010111B	;东西红灯，南北绿灯
				DB	11011111B	;东西红灯，南北绿灯闪烁
				DB	11011011B	;东西红灯，南北黄灯亮

.CODE	

START:	MOV		AX,@DATA	
		MOV		DS,AX	
		NOP		
		MOV		DX,COM_ADD	
		MOV		AL,80H	;PA、PB、PC为基本输出模式
		OUT		DX,AL	
		MOV		DX,PA_ADD	;灯全熄灭
		MOV		AL,0FFH	
		OUT		DX,AL	
		LEA		BX,LED_Data	
START1:	MOV		AL,0	
		XLAT		
		OUT		DX,AL	;东西绿灯，南北红灯
		CALL	DL5S	
		MOV		CX,6	
START2:	MOV		AL,1		
		XLAT		
		OUT		DX,AL	;东西绿灯闪烁，南北红灯
		CALL	DL500ms	
		MOV		AL,0	
		XLAT		
		OUT		DX,AL	
		CALL	DL500ms	
		LOOP	START2	
		MOV		AL,2		;东西黄灯亮，南北红灯
		XLAT		
		OUT		DX,AL	
		CALL	DL3S	
		MOV		AL,3		;东西红灯，南北绿灯
		XLAT		
		OUT		DX,AL	
		CALL	DL5S	
		MOV		CX,6	
START3:	MOV		AL,4		;东西红灯，南北绿灯闪烁
		XLAT		
		OUT		DX,AL	
		CALL	DL500ms	
		MOV		AL,3	
		XLAT		
		OUT		DX,AL	
		CALL	DL500ms	
		LOOP	START3	
		MOV		AL,5		;东西红灯，南北黄灯亮
		XLAT		
		OUT		DX,AL	
		CALL	DL3S	
		JMP	START1	



DL500ms		PROC		NEAR	
		PUSH	CX	
		MOV	CX,60000	
DL500ms1:	LOOP	DL500ms1	
		POP	CX	
		RET		
DL500ms	ENDP		
DL3S		PROC	NEAR	
		PUSH	CX	
		MOV		CX,6	
DL3S1:	CALL	DL500ms	
		LOOP	DL3S1	
		POP	CX	
		RET		
		ENDP		
DL5S	PROC	NEAR	
		PUSH	CX	
		MOV	CX,10	
DL5S1:	CALL	DL500ms	
		LOOP	DL5S1	
		POP	CX	
		RET		
		ENDP		
			
		END		START	
