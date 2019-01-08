data segment
buf db 'press"F"to Forward rotation',0dh,0ah,'press"R"to Reverse rotation',0dh,0ah,'press"S"to Stop',0dh,0ah,'press"E"to exit$'
str db 'control speed1,2$'
d1 dw ?
psta db 08h,0ch,04h,06h,02h,03h,01h,09h;相序表正
pstb db 01h,03h,02h,06h,04h,0ch,08h,09h;相序表反
data ends
code segment
   assume cs：code,ds：data
start：mov ax,data
      mov dx,ax
show：lea dx,buf
      mov ah,09h
      int 21h
      mov dx,203h
      mov al,10000000b
      out dx,al;初始化8255
first：mov ah,01h
      int 21h
      cmp al,46h；入口判断
      je forward
      cmp al,66h
      je forward
      cmp al,52h
      je reverse
      cmp al,72h
      je reverse
      cmp al,53h
      je stop
      cmp al,73h
      je stop
      cmp al,45h
      je exit
      cmp al,65h
      je exit
      jmp show


forward：mov di,offset psta
        jmp circle
Reverse：mov di,offset pstb
        jmp circle
circle：mov d1,560h;设置延迟初值
reload：mov si,di
       mov cx,7;设8拍循环次数
lop：mov al,[si]
    mov dx,200h
    out dx,al；将相序表送到控制口
    mov bx,d1;延时数值
delay1：mov dx,800
delay2：mov ah,01h
       int 16h
       jnz time
        dec dx
       jnz delay2
       dec bx
       jnz delay1;延时
       inc si；相序表+1
       dec cx
       jnz lop;循环7次
       jmp reload；完成7次，重新赋值
time：mov ah,01h
     int 21h
     cmp al,31h
     je s1
     cmp al,32h
     je s2 
     cmp al,46h；判断是否变换方向和速度
     je forward
     cmp al,66h
     je forward
     cmp al,52h
     je reverse
     cmp al,72h
     je reverse
     cmp al,53h
     je stop
     cmp al,73h
     je stop
     jmp exit
s1：mov d1,01h；延迟（即速度控制），可以添加更多的延迟以达到精确控制
   jmp reload
s2：mov d1,02h
   jmp reload


stop：jmp show
exit：mov ah,4ch
     int 21h
code ends
end start
