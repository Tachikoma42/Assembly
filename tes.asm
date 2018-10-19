  1     assume cs:code, ds:data
  2     
  3     data segment
  4         dw 100 dup (0)   ; 模拟读取字符的栈
  5     data ends
  6     
  7     code segment
  8     start:
  9             mov ax, data
 10             mov ds, ax
 11             mov si, 0
 12             ; 将ds:si设置为存放字符的栈
 13             call getstr
 14     return:
 15             mov ax, 4c00h
 16             int 21h
 17             
 18     ; 完整的接受字符串输入的子程序
 19     getstr:
 20             push ax
 21     
 22     getstrs:
 23             mov ah, 0
 24             int 16h
 25             cmp al, 20h
 26             jb nochar                        ; ASCII码小于20h, 说明不是字符
 27             
 28             ; 字符的处理分为两步，1:入栈,2:显示栈中的字符
 29             mov ah, 0                        ; 1: 字符入栈
 30             call charstack
 31             mov ah, 2                        ; 2: 显示栈中的字符
 32             call charstack
 33             jmp getstrs
 34                     
 35     nochar:    
 36             cmp ah, 0eh                    ; 退格键的扫描码
 37             je backspace
 38             cmp ah, 1ch                    ; Enter键的扫描码
 39             je enters
 40             jmp getstrs                    ; 其他控制键忽略
 41     
 42     backspace:
 43             mov ah, 1
 44             call charstack                    ; 字符出栈
 45             mov ah, 2
 46             call charstack                    ; 字符显示
 47             jmp getstrs
 48     
 49     enters:
 50             mov al, 0
 51             mov ah, 0
 52             call charstack                    ; 0入栈
 53             mov ah, 2
 54             call charstack                    ; 显示栈中的字符串
 55             
 56             pop ax
 57             ret
 58             
 59     
 60     ; 子程序: 字符栈的入栈、出栈和显示
 61     ; 参数说明：(ah)=功能号，0表示入栈，1表示出栈，2表示显示
 62     ; ds:si指向字符栈的空间
 63     ; 对于0号功能：(al)=入栈字符；
 64     ; 对于1号功能: (al)=返回的字符;
 65     ; 对于2号功能：(dh)、(dl)=字符串在屏幕上显示的行、列位置。
 66     
 67     charstack:    jmp short charstart
 68         table     dw charpush, charpop, charshow
 69         top       dw 0                                ; 栈顶
 70         
 71     charstart:
 72                 push bx
 73                 push dx
 74                 push di
 75                 push es
 76     
 77                 cmp ah, 2
 78                 ja sret
 79                 mov bl, ah
 80                 mov bh, 0
 81                 add bx, bx
 82                 jmp word ptr table[bx]
 83                 
 84     charpush:    
 85                 mov bx, top
 86                 mov [si][bx], al
 87                 inc top
 88                 jmp sret
 89                 
 90     charpop:
 91                 cmp top, 0
 92                 je sret
 93                 dec top
 94                 mov bx, top
 95                 mov al, [si][bx]
 96                 jmp sret
 97                 
 98     charshow:   ;(dh)、(dl)=字符串在屏幕上显示的行、列位置。
 99                 cmp bx, 0b800h
100                 mov es, bx
101                 mov al, 160
102                 mov ah, 0
103                 mul dh
104                 mov di, ax
105                 add dl, dl
106                 mov dh, 0
107                 add di, dx        ; 设置 es:di
108                 
109                 mov bx, 0
110     charshows:     cmp bx, top
111                 jne noempty
112                 mov byte ptr es:[di], ' '
113                 jmp sret
114     noempty:    
115                 mov al, [si][bx]
116                 mov es:[di], al
117                 mov byte ptr es:[di+2], ' '
118                 inc bx
119                 add di, 2
120                 jmp charshows
121     sret:        
122                 pop es
123                 pop di
124                 pop dx
125                 pop bx
126                 ret
127     
128     code ends
129 
130 end start
