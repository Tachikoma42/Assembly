.model  tiny
        ;8255 control
        com55_add   equ     0f003h
        pa55_add    equ     0f000h
        pb55_add    equ     0f001h
        pc55_add    equ     0f002h
        ;8253 control
        com53_add   equ     0e003h
        out53_add   equ     0e000h

.stack 100
.data
	inkey db ?
.code
start:  mov     ax, @data
        mov     ds, ax
        nop
			
		 MOV AL,00010100B
     MOV DX,com53_add
     OUT DX,AL
     MOV DX,out53_add      

     MOV AX,08H
     OUT DX,AL
     MOV AL,AH
     OUT DX,AL
	
	MOV AL,00H
   MOV DX,com53_add 
   OUT DX,AL  
   
   MOV DX,out53_add
   IN AL,DX ;LOW
	mov	dx, com55_add
	mov	al, 90h
	out	dx, al
	mov	dx, pb55_add
	mov	al, 11000011b
	out	dx, al
	mov	dx, pc55_add
	mov	al, 00111100b
	out dx, al
	hi:
	call input
	mov	al, inkey
		jmp hi
		 quit:   mov     ax, 4c00h
        int     21h
		input       proc
                ; use f5 sec to input direction
                ; 1 for up   2 for down
                ; 3 for left 4 for right
                ; 0 for no input
                ; result is in the inkey variable
                ; 
                push    ax
                push    cx
                push    dx

                mov     dx, pa55_add
                in      al, dx
                cmp     al, 0ffh
                je      noput           ;no input jump out 
                ;call    delay
                in      al, dx
                cmp     al, 0ffh
                je      noput
                mov     cx, 8
                xor     ah, ah
                mov     ah, al
                xor     al, al
        in1:    rol     ah, 1
                inc     al
                jnc     in2
                jmp     in1
        in2:    mov     inkey, al
        	jmp	bye
        noput:  mov     inkey, 0
             bye:     pop     ax
                pop     cx
                pop     dx
              ret
input       endp
	
		  
	delay       proc    
                push    bx
                push    cx
                mov     bx,10
        del1:   mov     cx, 10
        del2:   loop    del2
                dec     dx
                jnz     del1
                pop     cx
                pop     bx
                ret
delay       endp 

        end     start
