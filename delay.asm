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