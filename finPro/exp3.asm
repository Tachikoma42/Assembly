assume cs:code,ss:stack,ds:data 

data segment 
        db 16 dup(0)        ;第0字节保存颜色，1字节保存方向(1左2右3上4下),2、3字节保存食物所在行和列,4蛇的节数,5级数，67得分数 
        db 160 dup(0)        ;食蛇尾的每一节所在的行和列,食蛇尾最大节数80 
        db 'game over!',0,'level: 1',0,'scores: 0',0,'wtan',0,'v1.0',0 
data ends 

stack segment 
        dw 32 dup(0) 
stack ends 

code segment 

start: 
        mov ax,3 
        int 10h 
        mov ax,stack  
        mov ss,ax 
        mov sp,20h 
        mov ax,data 
        mov ds,ax 

        call show_wall 

        call show_level_score 
         
        mov al,2 
        mov bx,1 
        mov [bx],al        ;初始方向向右 

        call show_init_snake 
        call randrow 
s_move:         
         
        call show_rand_star 
        call hide_snake_tail 

        call show_snake_head 
         
        call sleep 
         
        mov al,0 
        mov ah,0bh 
        int 21h 
        cmp al,0ffh 
        jz s_next 
        jmp s_move 

s_next: 
        mov al,0 
        mov ah,07 
        int 21h 
        cmp al,4bh        ;按键为左箭头 
        jz s_left 

        cmp al,4dh        ;按键为右箭头 
        jz s_right 

        cmp al,48h        ;按键为上箭头 
        jz s_up 

        cmp al,50h        ;按键为下箭头 
        jz s_down 

        cmp al,39h        ;按键为空格 
        jz s_exit 
        jmp s_move 

s_left: 
        mov al,1 
        mov bx,1 
        mov [bx],al        ;方向改为向左 
        jmp s_move 

s_right: 
        mov al,2 
        mov bx,1 
        mov [bx],al        ;方向改为向右 
        jmp s_move 

s_up: 
        mov al,3 
        mov bx,1 
        mov [bx],al        ;方向改为向上 
        jmp s_move 

s_down: 
        mov al,4 
        mov bx,1 
        mov [bx],al        ;方向改为向下 
        jmp s_move 

s_exit: 
        mov ax,4c00h 
        int 21h 

;------------------------------------睡眼 
sleep: 
        push bx 
        push cx 
         
        mov bx,500 
s7:        mov cx,65535 
s6:        loop s6 

        dec bx 
        jnz s7 

        pop cx 
        pop bx         
        ret 

;------------------------------------得到随机行和列 
;参数：无 
;返回：无 

randrow: 
        push ax 
        push bx 
        push dx 

        call srand 
        mov ax,dx 
        and ah,00001111b 
        mov dl,22 
        div dl 
        inc ah 
        mov bx,2 
        mov [bx],ah 
         
        call srand 
        mov ax,dx 
        and ah,00001111b 
        mov dl,58 
        div dl 
        inc ah 
        mov bx,3 
        mov [bx],ah 

        pop dx 
        pop bx 
        pop ax 
        ret 


;------------------------------------得到随机数 
;参数：无 
;返回：dx 
srand: 
        push ax 
        push cx 
        sti 
        mov ah,0 
        int 1ah                ;时间中断,入口:AH=00读系统时间;AH=01置系统时间 

        pop cx 
        pop ax 
        ret 

         

;------------------------------------清除贪食蛇尾 
;参数：无 
hide_snake_tail: 
        push bx 
        push cx 
        push dx 

        mov dl,0 
        mov bx,0 
        mov [bx],dl 
        mov bx,10h 
        mov dh,[bx] 
        mov dl,[bx+1] 
         
        call show_star 

        mov bx,4        ;把贪食蛇的行列数往前挪一个字位置 
        mov ch,0 
        mov cl,[bx] 
        dec cx 
        add cx,cx 
        mov bx,10h 
s_mov_memtoleft: 
        mov dl,[bx+2] 
        mov [bx],dl 
        inc bx 
        loop s_mov_memtoleft 

        pop dx 
        pop cx 
        pop bx 
        ret 

;------------------------------------显示贪食蛇头 
;参数：无 
;返回：无 
show_snake_head: 
        push ax 
        push bx 
        push cx 
        push dx 
        push si 
         
        mov dl,00000010b  
        mov bx,0 
        mov [bx],dl 
        mov bx,1 
        mov dl,[bx] 
        mov bx,4 
        mov ah,0 
        mov al,[bx] 

        add ax,ax 
        sub ax,4 
        mov bx,ax 
        mov ah,[bx+10h] 
        mov al,[bx+11h] 

judge: 
        cmp dl,1        ;贪食蛇头方向往左 
        jz s_to_left 

        cmp dl,2        ;贪食蛇头方向往右 
        jz s_to_right 

        cmp dl,3        ;贪食蛇头方向往上 
        jz s_to_up 

        cmp dl,4        ;贪食蛇头方向往下 
        jz s_to_down 

s_to_left: 
        dec al 
        jmp s_to_next 

s_to_right: 
        inc al 
        jmp s_to_next 

s_to_up: 
        dec ah 
        jmp s_to_next 

s_to_down: 
        inc ah 
        jmp s_to_next 

s_to_next: 
        mov [bx+12h],ah 
        mov [bx+13h],al 

        cmp ah,0 
        jz s_error 
        cmp ah,24 
        jz s_error 
        cmp al,0 
        jz s_error 
        cmp al,59 
        jz s_error 

        call biteself         

        mov si,2        ;判断是否经过随机的星号所在的行和列 
        mov ch,[si] 
        mov cl,[si+1] 

        cmp ah,ch        ;行号是否相等 
        jnz s_to_last 
        cmp al,cl        ;列号是否相等 
        jnz s_to_last 
        add bx,2        ;经过随机的星号所在的行和列所做处理 
        call randrow 
        call showscore 
        mov si,4 
        mov cl,[si] 
        inc cl 
        mov [si],cl 

        jmp judge 

s_error: 
        call game_over 
         

s_to_last: 
        mov dh,ah 
        mov dl,al 
         
        call show_star 

        pop si 
        pop dx 
        pop cx 
        pop bx 
        pop ax 
        ret 

;------------------------------------查看是否咬到自己 
;参数：ah-行号，al-列号 
;返回：无 
biteself: 
        push ax 
        push bx 
        push cx 

        mov bx,4 
        mov ch,0 
        mov cl,[bx] 
        sub cl,3 
        mov bx,16 
         
s_bite:        jcxz bite_exit 
        cmp ah,[bx] 
        jnz bite_next 
        cmp al,[bx+1] 
        jnz bite_next 
        call game_over 

bite_next: 
        add bx,2 
        dec cl 
        jmp s_bite 

bite_exit: 
        pop cx 
        pop bx 
        pop ax 
        ret 

;------------------------------------显示初始贪食蛇 
;参数：无 
;返回：无 
show_init_snake: 
        push bx 
        push cx 
        push dx 
         
        mov dl,00000010b  
        mov bx,0 
        mov [bx],dl 
        mov dh,1 
        mov dl,1 
        mov bx,10h 
        mov cx,3 
s10:         
        call show_star 
        mov [bx],dh        ;初始贪食蛇行号列号放主内存保存 
        mov [bx+1],dl 
        add bx,2 
        inc dl 
        loop s10 

        mov bx,4        ;保存初始节数 
        mov dl,3 
        mov byte ptr [bx],dl 

        mov bx,1        ;保存初始方向向右 
        mov dl,2 
        mov byte ptr [bx],dl 

        pop dx 
        pop cx 
        pop bx 
        ret 

;------------------------------------显示得分 
;参数：无 
;返回：无 
showscore: 
        push ax 
        push bx 
        push cx 
        push dx 
        push si 

        mov bx,6 
        mov ax,[bx] 
        add ax,100 
        mov [bx],ax 
        mov dx,0 
         
        call dtoc 
         
        mov ax,0b800h 
        mov es,ax 

        mov dh,10 
        mov dl,72 
        mov bh,0 
        mov bl,dl 
        add bl,dl 
        mov al,160 
        mul dh                 
        add bx,ax        ;以上计算字符要放在显存中的偏移地址 

        mov si,8 

        mov ah,2 
        mov ch,0 
s_showscore:         
        mov al,[si] 
        mov cl,al 
        jcxz s_exit_showscore 
        mov es:[bx],ax 
        inc si 
        add bx,2 
        jmp s_showscore 

s_exit_showscore: 

        pop si 
        pop dx 
        pop cx 
        pop bx 
        pop ax 
        ret 

;------------------------------------把十进制数字转化为字符串的子函数 
;参数：ax--dword型数据的低字；dx--dword型数据的高字；ds:si--指向字符串的首地址 
;返回：无 


dtoc:        push ax 
        push bx 
        push cx 
        push dx 
        push si 

        mov si,0 
         
dtoc_s:        mov cx,10 
        call divdw 
        add cx,30h 
        push cx                ;余数加30H后变成ASCII码中的数字字符进栈 
        mov cx,ax 
        jcxz first_step        ;如果ax也就是低16位为0，则去判断高16位是否为0 
        inc si 
        jmp short dtoc_s 

first_step: 
        mov cx,dx 
        jcxz ok_dtoc        ;如果dx也就是高16位为0，则退出转换进入后续处理,否则继续 
        inc si 
        jmp short dtoc_s 

ok_dtoc: 
        mov bx,8 
        mov cx,si 
        inc cx 

reverse: 
        pop [bx]        ;出栈到内存中的位置，正好实现了反转 
        inc bx 
        loop reverse 

        pop si 
        pop dx 
        pop cx 
        pop bx 
        pop ax 
        ret 


;------------------------------------商超过16位的的除法子函数 
;参数：ax--被除数的低16位；dx--被除数的高16位；cx--除数 
;返回：ax--结果的低16位；dx--结果的高16位；cx--余数 

divdw:         
        push bx 
        push bp 

        mov bp,ax 
        mov ax,dx        ;高16位到低16位 
        mov dx,0        ;高16位赋值0，变成值只有16位的除法(实际上还是32位的除法) 
        div cx 

        mov bx,ax        ;高16位除法所得的商存入临时变量bx 
        mov ax,bp        ;低16位返回ax,dx中存高位除法所得的余数 
        div cx 
        mov cx,dx         
        mov dx,bx 

        pop bp 
        pop bx 
        ret 

         
;------------------------------------显示围墙 
;参数：无 
;返回：无 
show_wall: 
        push cx 
        push dx 
        push si 

                 
        mov dl,00100001b ;上墙 
        mov si,0 
        mov [si],dl 
        mov dh,0 
        mov dl,0 
        mov cx,80 
s1:         
        call show_star 
        inc dl 
        loop s1 
  
        dec dl 
        mov dh,1        ;右墙 
        mov cx,23 
s2:         
        call show_star 
        inc dh 
        loop s2 
         
        mov cx,79        ;下墙 
s3:         
        call show_star 
        dec dl 
        loop s3 

        mov cx,24        ;左墙 
s4:         
        call show_star 
        dec dh 
        loop s4 

        mov dh,1 
        mov dl,60 
        mov cx,23        ;中墙 
s5:         
        call show_star 
        inc dh 
        loop s5 


        pop si 
        pop dx 
        pop cx 

        ret 

;------------------------------------显示一个随机星号的子函数 
;参数：无 
;返回：无 
show_rand_star: 
        push bx 
        push dx 
        mov dl,00000010b  
        mov bx,0 
        mov [bx],dl 
        mov bx,2 
        mov dh,[bx] 
        mov bx,3 
        mov dl,[bx] 

        call show_star 
         
        pop dx 
        pop bx 
        ret 



;------------------------------------显示level和score字符串 
;参数：无 
;返回：无 
show_level_score: 
        push ax 
        push bx 
        push dx 
        push si 
        push es 

        mov ax,0b800h 
        mov es,ax 

        mov dh,5 
        mov dl,63 
        mov bh,0 
        mov bl,dl 
        add bl,dl 
        mov al,160 
        mul dh                 
        add bx,ax        ;以上计算字符要放在显存中的偏移地址 

        mov si,187 

        mov ah,2 
        mov ch,0 
s_level:         
        mov al,[si] 
        mov cl,al 
        jcxz s_exit_level 
        mov es:[bx],ax 
        inc si 
        add bx,2 
        jmp s_level 

s_exit_level: 

        mov dh,10 
        mov dl,63 
        mov bh,0 
        mov bl,dl 
        add bl,dl 
        mov al,160 
        mul dh                 
        add bx,ax        ;以上计算字符要放在显存中的偏移地址 

        mov si,196 

        mov ah,2 
        mov ch,0 
s_score: 
        mov al,[si] 
        mov cl,al 
        jcxz s_exit_score 
        mov es:[bx],ax 
        inc si 
        add bx,2 
        jmp s_score 

s_exit_score: 
        mov dh,15 
        mov dl,65 
        mov bh,0 
        mov bl,dl 
        add bl,dl 
        mov al,160 
        mul dh                 
        add bx,ax        ;以上计算字符要放在显存中的偏移地址 

        mov si,206 

        mov ah,2 
        mov ch,0 
s_wtan: 
        mov al,[si] 
        mov cl,al 
        jcxz s_exit_wtan 
        mov es:[bx],ax 
        inc si 
        add bx,2 
        jmp s_wtan 

s_exit_wtan: 
        mov dh,20 
        mov dl,65 
        mov bh,0 
        mov bl,dl 
        add bl,dl 
        mov al,160 
        mul dh                 
        add bx,ax        ;以上计算字符要放在显存中的偏移地址 

        mov si,211 

        mov ah,2 
        mov ch,0 
s_v: 
        mov al,[si] 
        mov cl,al 
        jcxz s_exit_v 
        mov es:[bx],ax 
        inc si 
        add bx,2 
        jmp s_v 


s_exit_v: 

        pop es 
        pop si 
        pop dx 
        pop bx 
        pop ax         
        ret 


;------------------------------------结束游戏子函数 
;参数：无 
;返回：无 
game_over: 
         
        mov ax,0b800h 
        mov es,ax 

        mov dh,10 
        mov dl,25 
        mov bh,0 
        mov bl,dl 
        add bl,dl 
        mov al,160 
        mul dh                 
        add bx,ax        ;以上计算字符要放在显存中的偏移地址 

        mov si,176 

        mov ah,4 
        mov ch,0 
s_loop:        mov al,[si] 
        mov cl,al 
        jcxz s_exit_program 
        mov es:[bx],ax 
        inc si 
        add bx,2 
        jmp s_loop 

s_exit_program: 
        mov ax,4c00h 
        int 21h 



         
;------------------------------------显示一个星号的子函数 
;参数：dh--行号(0--24)；dl--列号(0--79)； 
;返回：无         

show_star:         
        push ax 
        push bx 
        push dx 
        push si 
        push es 

        mov ax,0b800h 
        mov es,ax 

        mov bh,0 
        mov bl,dl 
        add bl,dl 
        mov al,160 
        mul dh                 
        add bx,ax        ;以上计算字符要放在显存中的偏移地址 

        mov si,0 
        mov ah,[si] 
        mov al,'*' 
        mov es:[bx],ax 

        pop es 
        pop si 
        pop dx 
        pop bx 
        pop ax         
        ret 

code ends 

end start
