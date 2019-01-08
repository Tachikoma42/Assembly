.model small
.stack 200
.data
Len db ? ;蛇的长度
Body dw 200 dup(0) ;蛇的身体位置
Direction dw 256

foodX dw ? ;食物坐标
foodY dw ?
seed dw 2 ;随即数种子


.code
main proc far
    mov ax , @data
    mov ds , ax

    call Init_snake   ;初始化蛇
    call getfood   ;得到第一个食物
    call run_snake   ;开始运动蛇
    exit:

    mov ah , 4ch
    int 21h    ;退出到DOS
main endp

;******************************************************************************************
;函数名: cutsnake
;功能: 显示蛇的一格
;传递参数:     
; si/di 游戏空间列/游戏空间行(50*50)
;******************************************************************************************
cutsnake   proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov cl, snake_color ;置颜色
    mov ax,di   ;取坐标值
    mul cut_y   ;乘象素值
    add ax,topline   ;加上边界
    mov bx , ax  
    add ax , 2  
    mov dx , ax
    push bx
    push dx
    mov ax,si   ;取坐标值
    mul cut_x   ;乘象素值
    add ax,leftline   ;加上边界
    mov si , ax
    add ax , 3
    mov di , ax
    pop dx
    pop bx
    call Rec   ;Rec的参数是cl颜色 si左边 bx上边 di右边 dx下边
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax    
    ret
cutsnake   endp
;******************************************************************************************
;函数名: cutfood
;功能: 显示食物
;传递参数:     
; si/di 游戏空间列/游戏空间行(50*50)
;函数返回: 空
;******************************************************************************************
cutfood   proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov cl , food_color ;置颜色
    mov ax,di   ;取坐标值
    mul cut_y   ;乘象素值
    add ax,topline   ;加上边界
    mov bx , ax
    add ax , 2
    mov dx , ax
    push bx   
    push dx
    mov ax,si   ;取坐标值
    mul cut_x   ;乘象素值
    add ax,leftline   ;加上边界
    mov si , ax
    add ax , 3
    mov di , ax
    pop dx
    pop bx
    call Rec ;Rec的参数是cl颜色 si左边 bx上边 di右边 dx下边
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax    

    ret
cutfood   endp
;******************************************************************************************
;函数名: clearcut
;功能: 清除格
;传递参数:     
; si/di 游戏空间列/游戏空间行(50*50)
;函数返回: 空
;******************************************************************************************
clearcut   proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov cl , 0   ;置颜色(黑)
    mov ax,di   ;取坐标值
    mul cut_y   ;乘象素值
    add ax,topline   ;加上边界
    mov bx , ax
    add ax , 2
    mov dx , ax
    push bx
    push dx
    mov ax,si   ;取坐标值
    mul cut_x   ;乘象素值
    add ax,leftline   ;加上边界
    mov si , ax
    add ax , 3
    mov di , ax
    pop dx
    pop bx
    call Rec   ;Rec的参数是cl颜色 si左边 bx上边 di右边 dx下边
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax    
    ret
clearcut   endp
;******************************************************************************************
;函数名: Rand
;功能: 产生指定范围大小的随机数
;传递参数: si 数字的范围最大值+1
;函数返回: ax 返回随机数的值
;******************************************************************************************
Rand proc
    push bx
    push cx
    push dx
    push si
    mov ah,2ch
    int 21h
    mov ax,dx
    mov dx,0
    mov bx,si   ;指定随机数的范围
    div bx  
    mov ax,dx
    pop si
    pop dx
    pop cx
    pop bx
       ret
Rand endp
;******************************************************************************************
;函数名: getfood
;功能: 产生新食物,即随机产生一组49*49的坐标  
;函数返回: foodx与foody的值
;******************************************************************************************
getfood proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    M1:
    mov si,50   ;置随机数范围（最大值+1）
    call Rand   ;产生随机数
    mov foodx,ax   ;赋予食物坐标x
    mov si,50   ;置随机数范围（最大值+1）
    call Rand   ;产生随机数
    mov foody,ax   ;赋予食物坐标y
    mov si,foodx
    mov di,foody
    mov ax,di   ;取坐标值
    mul cut_y   ;乘象素值
    add ax,topline 
    mov dx,ax
    push dx
    mov ax,si   ;取坐标值
    mul cut_x   ;乘象素值
    add ax,leftline 
    mov cx,ax
    pop dx
    mov ah,0dh
    mov bh,0
    int 10h
    cmp al,snake_color
    jz M1
    call cutfood   ;画食物
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
getfood endp
;******************************************************************************************
;函数名: Delay
;功能: 延时
;******************************************************************************************
Delay proc
    push ax
    push bx
    push cx 
    push dx  
    mov cx,33144
    waitf:
    in al,61h
    and al,10h
    cmp al,ah
    je waitf
    mov ah,al
    loop waitf
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Delay endp
;******************************************************************************************
;函数名: Check_key
;功能: 处理键盘响应    
;函数返回: Direction的值,gameover的值（按ESC时）
;******************************************************************************************
Check_key proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov ah , 01h
    int 16h
    jz check_nokey    ;如果没有按键就继续
    mov ah , 0     ;取得扫描码    
    int 16h
    push ax 
    cmp ah , SPACE
    jnz  S2
    S1:
    mov ah,0
    int 16h
    cmp ah, SPACE
    jnz S1
    S2:
    pop ax
    cmp ah , LEFT     ;往左移动
    jz check_LEFT
    cmp ah , RIGHT    ;往右边移动
    jz check_RIGHT
    cmp ah , UP   ;往上移动
    jz check_UP
    cmp ah , DOWN   ;往下移动
    jz check_DOWN
    cmp ah , QUIT   ;结束游戏
    jz check_QUIT
    jmp check_nokey
    check_LEFT:
    mov ah , -1   ;(-1,0)
    mov al , 0
    mov bx , ax   ;检查是否反向
    add bx , Direction
    jz check_nokey
    mov Direction , ax
    jmp check_nokey
    check_RIGHT:
    mov ah , 1   ;(1,0)
    mov al , 0
    mov bx , ax   ;检查是否反向
    add bx , Direction
    jz check_nokey
    mov Direction , ax
    jmp check_nokey
    check_UP:
    mov ah , 0   ;(0,-1)
    mov al , -1
    mov bx , Direction ;检查是否反向
    sub bl , 1
    jz check_nokey  
    mov Direction , ax
    jmp check_nokey
    check_DOWN:
    mov ah , 0   ;(0,1)
    mov al , 1  
    mov bx , Direction ;检查是否反向
    add bl , 1
    jz check_nokey
    mov Direction , ax
    jmp check_nokey
    check_QUIT:
    jmp check_exit
    check_exit:  ;按下ESC键的情况
    mov gameover,1
    check_nokey:
    mov ah,0ch
    mov al,0
    int 21h
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Check_key endp
;******************************************************************************************
;函数名: Check_die
;功能: 处理死亡的响应
;传递参数:      SI,DI为当前蛇头部的坐标    
;函数返回: 蛇参数的值
;******************************************************************************************
Check_die proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    cmp si , 50   ;检查是否到达边界
    jz dead
    cmp si , 255
    jz dead
    cmp di , 50
    jz dead
    cmp di , 255
    jz dead
    mov ax,si   ;检查是否接触蛇身
    mov dh,al   ;DX中获得当前坐标
    mov ax,di
    mov dl,al
    mov cx,0
    mov cl, Len
    sub cl,1  
    mov bx,offset Body
    check_die_loop:
    add bx , 2
    mov ax , [bx]
    cmp ax , dx   ;取出蛇身信息进行比较
    jz dead    ;触及蛇身即死亡
    loop check_die_loop
    jmp next
    dead:
    mov gameover,1 ;死亡即赋gameover值1
    next:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Check_die endp
;******************************************************************************************
;函数名: Check_eat
;功能: 处理吃到食物的响应
;传递参数: SI,DI为当前蛇头部的坐标    
;函数返回: cx
;******************************************************************************************
Check_eat proc
    push ax
    push bx
    push dx
    push si
    push di
    mov cx,0
    mov ax , foodx
    mov bx , foody
    cmp ax , si
    jz ok1
    jmp check_eat_out
    ok1:     ;横坐标相等
    cmp bx , di
    jz ok2
    jmp check_eat_out
    ok2:     ;纵坐标也相等  
    add point,1   ;加分
    mov cx,1
    check_eat_out:
    pop di
    pop si
    pop dx
    pop bx
    pop ax
    ret
Check_eat endp
;******************************************************************************************
;函数名: Run_snake
;功能: 蛇运动
;******************************************************************************************
run_snake proc
    
    mov dx, 5

    loop1:
    call Delay
    mov al,1
    cmp al,gameover
    jz stop
    mov bx , offset Body
    mov cx,0
    mov cl,Len
    add bx,cx
    add bx,cx
    sub bx,2
    A1:
    mov ax,[bx]   
    mov [bx+2],ax
    sub bx,2
    loop A1
    addhead: 
    mov bx , offset Body   ;增加新头部并改写数据
    mov ax , [bx]
    mov dx , Direction
    add ah , dh   ;坐标加方向
    add al , dl   ;坐标加方向
    mov [bx] , ax   ;存入头部
    mov dx,0  ;为check_die准备参数si,di
    mov dl , ah
    mov si , dx
    mov dl , al
    mov di , dx
    call check_die   ;检查死亡
    mov al,1
    cmp al,gameover
    jz stop 
    call check_eat   ;检查吃
    cmp cx,1
    jz  A2  
    mov bx , offset Body
    mov ax,0
    add Len,1
    mov al , Len
    add bx , ax   ;取到蛇尾
    add bx , ax
    sub bx , 2
    mov ax , [bx]
    mov cx,0
    mov [bx],cx
    mov dx,0
    mov dl , ah
    mov si , dx
    mov dl , al
    mov di , dx
    sub Len,1
    call clearcut
    mov bx , offset Body
    mov ax, [bx]
    mov dx,0
    mov dl , ah
    mov si , dx
    mov dl , al
    mov di , dx
    call cutsnake
    jmp A3
    A2:
    add Len,1
    mov bx , offset Body
    mov ax, [bx]
    mov dx,0
    mov dl , ah
    mov si , dx
    mov dl , al
    mov di , dx
    call cutsnake   ;画新头部
    call getfood
    A3:
    call show_point
    call check_key   ;检查按键
    jmp loop1   ;蛇运动循环DATAS SEGMENT
    stop:

    ret
run_snake endp
;******************************************************************************************
;函数名: Init_snake
;功能: 蛇初始化
;******************************************************************************************
Init_snake proc

    mov al , 4
    mov Len, al ;蛇的初始大小为4
    mov ax,256 ;初始方向为右
    mov Direction,ax
    mov gameover,0
    mov point,0
    mov bx , offset Body
    mov ch , 25 ;蛇的初始位置设为25，25
    mov cl , 25
    mov [bx] , cx
    mov cx,3
    init_first:   ;生成第一个蛇
    mov ax , [bx]
    mov dx , Direction
    sub ah , dh ;坐标x减方向
    sub al , dl ;坐标y减方向
    add bx , 2
    mov [bx] , ax ;保存一格蛇的信息
    loop init_first
    init_print:   ;开始画第一个蛇
    mov cx,0
    mov cl, Len
    mov dx,0
    mov bx , offset Body
    init_print_loop:
    mov ax , [bx]
    mov dl , ah
    mov si , dx
    mov dl , al
    mov di , dx
    call cutsnake ;画一格
    add bx , 2
    loop init_print_loop
    Init_over:

    ret
Init_snake endp
