;具体流程：ASCII码输入->十进制->十六进制->ASCII码显示
;故需要子函数完成进制转换、ascii转换
data    segment para
    buf         db 4 dup(0)
    var_10      dw 0
    str_input   db 0dh, 0ah, 'Please input four numbers(0-9):$'
    str_error   db 0dh, 0ah, 'The input is error, please try again.$'
    str_output  db 0dh, 0ah, 'The hex result is:$'
data    ends
stack   segment stack
    dw 100 dup(0)
stack   ends
code    segment para
    assume  cs:code, ds:data, ss:stack   
    main    proc far
        mov     ax, data
        mov     ds, ax
    loop_again:                 ;输入有错误需要重新读取输入
        lea     dx, str_input   ;显示数据输入提示信息
        mov     ah, 9
        int     21h
        lea     bx, buf         ;用bx来作为buf的指代
        mov     cx, 4           ;循环输入4个数
    loop_input: 
        mov     ah, 1           ;输入数据
        int     21h
        cmp     al, '0'         ;判断输入字符是否为‘0’~‘9’
        jb      error
        cmp     al, '9'
        ja      error           ;非法字符，进行错误处理
        ;直接输入一个字符，处理一个字符
        sub     al, 30h         ;ASCII转换为二进制，得到 0-9
        mov     [bx], al        ;存入缓冲区
        inc     bx
        loop    loop_input
        jmp     input_valid     ;数据输入正确后 ,跳转到后续处理
    error: 
        lea     dx, str_error   ;显示错误提示信息
        mov     ah, 9
        int     21h
        jmp     loop_again      ;跳转到重新输入
    input_valid:                ;现在数据以二进制的形式存储
        mov     ax, 0           ;以(((0*10+dl3)*10+dl2)*10+dl1)*10+dl0计算
                                ;十进制数据结果存放到ax中
        mov     dx, 0           ;因为ax可以满足存放四位十进制数的需求
        mov     si, 10          
        mov     bx, 0
        mov     cx, 4
    loop_mul10: 
        mul     si              ;相乘后dx仍然保持 0
        mov     dl, [bx]        ;将buf数据取到dl中
        mov     dh, 0
        add     ax, dx
        inc     bx
        loop    loop_mul10      ;循环4次乘10
        mov     var_10, ax      ;得到的 4 位十进制数存放到 var_10 中
                                ;var_10共16位，存放十进制数对应的二进制
        lea     dx, str_output
        mov     ah, 9
        int     21h             ;显示输出提示符
        mov     ch, 4           ;以16进制显示输入的数据，循环四次
        mov     cl, 4
    loop_display: 
        rol     var_10, cl      ;循环左移4位，因为要先显示高位
        mov     ax, var_10
        and     ax, 000fh       ;仅保留最低四位
        call    bin2asc         ;二进制转换为 ASCII
        call    pchar           ;显示一个十六进制字符
        dec     ch
        jnz     loop_display
        mov     al, 'H'         ;显示十六进制‘H’记号
        call    pchar
        mov     ax, 4c00h
        int     21h
    main    endp

    ;功能: 将一个二进制数字转换为ASCII
    ;输入参数 : AL中存放二进制数（有效位只有低四位）
    ;输出参数 : AL中存放ASCII
    bin2asc     proc
        and     al, 0fh
        add     al, 30h
        cmp     al, 39h
        jbe     done_b2a
        add     al, 07h         ;是A~Z
    done_b2a: 
        ret                     ;返回
    bin2asc     endp

    ;功能：显示单个字符
    ;输入参数：AL中存放ASCII
    ;输出参数：无
    pchar   proc
        mov     dl, al
        mov     ah, 2
        int     21h
        ret                     ;返回
    pchar   endp
code    ends
    end     main
