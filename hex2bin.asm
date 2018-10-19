stacks segment
stack dw 200h dup(0);不太明白要200h这么大
stacks ends
data segment
    in_buf db 6;定义输入字符串最大长度
    in_len db ?;输入字符串实际长度
    dec_buf db 6 dup(30h),'='
    bin_buf db 16 dup(30h),'B='
    hex_buf db 4 dup(30h),'H'
    crlf db 0dh,0ah,'$'
    ;注意这儿定义数据是放在一块儿的，就不需要把二进制和十六进制的字符串分别再设置结束符
    mes_1 db 'please input a number(0~65535):$'
    mes_2 db 'input invalid,exit!',0dh,0ah,'$'
data ends

code segment
	assume cs:code,ds:data,ss:stacks
START: mov ax,data
    mov ds,ax
    call input
    mov bx,offset dec_buf
    add bl,in_len
    mov byte ptr [bx],'D';注意！这儿一定要覆盖住原字符串的最后一个回车符
                        ;否则，输出时，那个回车符会使前面的字符被覆盖
    call str2bin;首先判断输入的合法性并转化为数值
    jc exit_no
    call bin2str;将十进制转化为二进制
    call hex2str;将十进制转化为十六进制
    mov dx,offset crlf
    call out_str
    mov dx,offset dec_buf
    call out_str
    mov ah,4ch
    int 21h
    
    exit_no:;输入不合法时的提示
    mov dx,offset crlf
    call out_str
    mov dx,offset mes_2
    call out_str
    ret
 
input:;功能：从键盘输入字符串
mov dx,offset mes_1
mov ah,9
int 21h
mov dx,offset in_buf
mov ah,10
int 21h
ret
 
str2bin:;功能：判断输入的十进制是否合法
;若合法则把十进制的ASCII码转化成数值形式
sub ax,ax;ax用来存放十进制的最终数值
mov si,10;si用来做乘数
sub ch,ch
mov cl,in_len;输入串的实际长度设置为循环次数
mov di,offset dec_buf;di指向串实际开始的位置
loop_10:
mov bl,[di]
cmp bl,39h;若大于字符9，不合法
ja quit_n
cmp bl,30h;若小于字符0，不合法
jb quit_n
sub bh,bh;避免bh里面有杂数据，清零
sub bl,30h
mul si;ax*10
jc quit_n
add ax,bx;(ax*10)+bx
jc quit_n
inc di
loop loop_10;cx不为零，继续循环
clc;没有跳转到quit_n,则表示合法，设置cf=0
ret
quit_n:
stc;表明输入的十进制不合法，设置cf=1
ret
 
bin2str:;功能：将十进制转化为二进制
push ax;ax保存的是十进制的数值
;因为之后还要用到去转化为十六进制，所以先push进堆栈暂存
mov cx,16;设置需要循环的次数
mov bx,offset bin_buf
loop_20:
shl ax,1
jnc next_20;如果该位为零
inc byte ptr [bx]
next_20:
inc bx
loop loop_20
pop ax
ret
 
hex2str:;功能：将十进制转化为十六进制
mov bx,ax
mov si,offset hex_buf
mov ch,4
loop_30:
mov cl,4
rol bx,cl;当移动次数大于1时，必须用cl代替
mov al,bl;从高到低提取四位二进制数送入al
and al,0fh
add al,30h;al=0~9,加30h转化为ascii码
cmp al,3ah
jl next_30
add al,7;al>9,加37h转化为ascii码
next_30:
mov [si],al
inc si
dec ch
jnz loop_30;注意，这儿只能用dec运算对标志位的设置来判断循环与否
;因为cl被用来存放位移数了
ret
 
out_str:;用于输出的子程序
mov ah,9
int 21h
ret
 
code ends
end main