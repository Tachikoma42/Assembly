assume  cs:code
code 	    segment 	
               org   100h
start:      mov  dx,04a6h	;控制寄存器地址
            mov  ax,90h	;设置为A口输入，;B口输出,C输出
            out	   dx,ax           ;8255初始化
check0:   ; check0检测是否有健被按下
            mov  ax,00h      ;C口的PC0、PC1、PC2作为行选择线
            mov  dx,04a4h  ;C口地址
            out 	 dx,ax ; 写入C口内容00H，即令所有行为低电平
            mov dx,04a0h  ;A口地址
            in  	ax,dx     ;读入A口的内容
            cmp al,0ffh   ;判定是否有列线为低电平
            je  	check0   ;没有，无闭合键，则循环等待
            mov  cx,05ffh  ;延迟常数，可以修改来改变延时时间 
delay:      loop delay	;有，则延迟清除抖动，当cx=0时则停止该循环
  ; 行扫描键盘和列扫描键盘，确定被按键的行值和列值
            mov  	cl,3   ;行数
            mov  	ah,0
            mov  	al, 0fbh  ; 0fbh=1111 1011B
contin:     push 	ax          ;将ax的内容(0fbh)入栈保存
            mov  	dx,04a4h    ;C口地址
            out  	dx,al  ;写入C口内容0fbh=1111 1011B，即将第三行置为低电平 
            mov  	dx,04a0h     ;A口地址
            in   	al,dx            ;读入A口的内容
            mov  	ah,al            ;将A口的内容送入ah 
            cmp  	ah,0ffh        ;判断是否有列线为低电平
            jne  	next            ;比较结果不等于0则转移，即有列线为低电平
            pop  	ax  ; 比较结果等于0,即没有列线为低电平，（ax）=00fbh
            ror  	al,1  ; fbh（1111 1011B）循环右移，（al）=1111 1101检测下一行
            loop 	contin  ;循环扫描下一行，确定行
            jmp  	check0  ;若所有行都没有被按下，则返回check0重新检测
next: 	    mov  	ch,cl  ;保存行值至ch
            mov  	cl,7  ;列值从0开始编号0-7
begin0:     shl   ah,1     ; ah为A口的内容，逻辑左移1位，末位补0
            jnc  	goon    ;无进位则转移，即可确定列
            loop 	begin0 ;继续循环，确定列
            jmp 	check0  
goon: ;计算显示码在discode中的位置：（行数-1）*8 +列值
            mov 	bl, cl    ;保存列值至BL
  	        dec  	ch        ;行数减1           
            mov  	cl,3  
            shl  	ch, cl   ;左移三位即相当于减1之后的行数*8
            add 	bl, ch   ;确定显示码在discode表中的偏移量，即（行数-1）*8+列值
            mov  	bh,0
            mov  	cx,bx   ;显示码在discode表中的偏移量送CX 
display:    mov  	si, offset discode
        	  add  	si, cx  ;显示码偏移地址
          	mov  	dx,04a4h  ;C口地址
            mov  	al,0fh
            out  	dx,al  ;写入C口内容，使位控（LED1）有效 
            mov 	al,[si]  ; 取被按键的显示字形码送入al
            mov  	dx,04a2h ;B口地址
          	out  	dx,al   ; 将显示字形码送B口输出显示
         	  nop
          	nop 
            jmp     check0    
discode  db 	3fh,06h,5bh,4fh,66h,6dh,7dh,07h;（0-7）
               db  	7fh,6fh,77h,7ch,39h,5eh,79h,71h ;（8-F）                                      
               db  	01h,02h,04h,08h,10h,20h,40h,80h;（abcdefgh） ;显示字形码表 
code 	 	ends
end 	 	start


