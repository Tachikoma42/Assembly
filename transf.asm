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
        ranfood     dw      ?
        inkey       db      ?
        snake       db  33  dup(0)
        dir         db  18  dup(0)   
        snakelen    db      2 
        up          db      1
        left        db      2
        down        db      3
        right       db      4
        end         db      8
        die         db      0
        rowmat      db      0, 01111111b, 10111111b, 11011111b, 11101111b,
                            11110111b, 11111011b, 11111101b,11111101b
        colmat      db      0, 10000000b, 01000000b, 00100000b, 00010000b,
                            00001000b, 00000100b, 00000010b, 00000001b
.code
start:  mov     ax, @data
        mov     ds, ax
        nop
        ; initialize 8255
        ; use 8255 to get direction and control 8x8 led matrix
        ; cs - connect to cs1
        ; use pa as input  - connect to sec f5 keyboard
        ; use pb as output - connect to jp24 (0 to select row -)
        ; use pc as output - connect to jp23 (1 to select col |)
        ;pb输出(JP24点阵点亮，0选中行)，pc输出(JP23点阵点亮，1选中列)
        mov     al, 90h
        mov     dx, com55_add
        out     dx, al
        ; initialize 8253
        ; use 8253 to get the seed of the random number
        ; use Middle Square Weyl Sequence RNG method to 
        ; get the random number from 1 to 8

        ; cs - connect to cs2
        ; gate0 - high (vcc)
        ; clk0 - clock ()
        mov     dx, com53_add
        mov     al, 14h
        out     dx, al
        mov     dx, out53_add
        mov     al, 8
        out     dx, al
        call    initSnake ; done
        call    getfood ;done
        resnake:call    display ; under construction 
        call    input ;done
        call    snakeMove;done
        call    hitsome; under construction 
        call    snakeeater; done 
        cmp     die,1
        je      aftermath
        call    delay
        jmp     resnake

        quit:   mov     ax, 4c00h
        int     21h
display     proc
        mov     bx, ranfood
        call dispone
        mov     al, snakelen
        mov     cx, al
        add     al, al
        mov     si, ax
  redisp:      mov     bh, snake[si]
        dec     si
        mov     bl, snake[si]
        dec     si
        call dispone
        loop    redisp
        ret
display     endp
dispone     proc
        push bx
        push dx
        push cx
        push ax
        push si
        ;the point is at bh-high,bl-low
        
        xor     ax, ax
        mov     ax, bl
        mov     si, ax
        mov     al, rowmat[si]
        mov     dx, pb55_add
        out     dx, al

        xor     ax, ax
        mov     ax, bl
        mov     si, ax
        mov     al, colmat[si]
        mov     dx, pc55_add
        out     dx, al
        ;
        pop     si
        pop     ax
        pop     cx
        pop     dx
        pop     bx
        ret
dispone     endp
endgame     proc
         
        ret
endgame     endp
snakeeater  proc
        xor     ax,ax
        mov     al, snakelen
        add     al, al
        mov     si, ax
        mov     bh, snake[si]
        dec     si
        mov     bl, snake[si]   ; snake head at bx
        mov     ax, ranfood
        cmp     ax,bx
        jne     snout
        mov     al, snakelen
                inc     al
                mov     snakelen, al
                xor     ah,ah
                mov     si, ax

                mov     ah, dir[si]
                cmp     ah, up
                je      upSnake1
                cmp     ah, down
                je      doSnake1
                cmp     ah, left
                je      leSnake1
                cmp     right
                je      riSnake1
        upSnake1:mov    ax, ranfood
                mov     bl, snakelen
                add     bl,bl
                xor     bx,bx
                mov     si, bx
                dec     ah
                cmp     ah, 0
                jnz     upk1
                mov     die, 1
                upk1: mov     snake[si], ah
                dec si
                    mov     snake[si],al
                jmp     snout 

        doSnake1:mov    ax, ranfood
                mov     bl, snakelen
                add     bl,bl
                xor     bx,bx
                mov     si, bx
                inc     ah
                cmp     ah, 9
                jnz     dok
                mov     die, 1
                dok: mov     snake[si], ah
                    dec si
                    mov     snake[si],al
                jmp     snout      

        leSnake1:mov    ax, ranfood
                mov     bl, snakelen
                add     bl,bl
                xor     bx,bx
                mov     si, bx
                dec     al
                cmp     al, 0
                jnz     lek
                mov     die, 1
                lek: mov     snake[si], ah
                dec si
                    mov     snake[si],al
                jmp     snout 

        riSnake1:mov    ax, ranfood
                mov     bl, snakelen
                add     bl,bl
                xor     bx,bx
                mov     si, bx
                inc     al
                cmp     al, 9
                jnz     rik
                mov     die, 1
                rik:mov     snake[si], ah
                        dec si
                    mov     snake[si],al
                jmp     snout
        snout:  ret
snakeeater  endp

hitsome     proc
        cmp     die, 1
        je      aftermath
        xor     ax,ax
        mov     al, snakelen
        add     al, al
        mov     si, ax
        mov     bh, snake[si]
        dec     si
        mov     bl, snake[si]   ; snake head at bx
        xor     ax,ax
        mov     al, snakelen
        dec     al
        mov     cx, ax
        inc     al
        add     al,al
        mov     si, ax
        hitre:  mov     dh, snake[si]
                dec     si
                mov     dl, snake[si]
                cmp     dx, bx
                je      aftermath
                dec     si
                loop    hitre
        aftermath:
        call    endgame
        ret
hitsome     endp

snakeMove   proc
        mov     al, snakelen
        xor     ah,ah
        mov     si, ax
        mov     ah, dir[si]
        mov     al, inkey
        cmp     al, 0
        je      same
        cmp     al, ah
        je      same
        sub     ah,al
        cmp     ah, 0feh
        je      same
        cmp     ah, 02h
        je      same
        mov     dir[si], al 
        ; 若蛇头与原方向相同，则不变，若蛇头与输入键位差为2，则不变；其他情况，用inkey来替代蛇头的方向    
        same:   mov     al, dir[si]
        inc     si
        mov     dir[si], al
        call    change

        ret
snakeMove   endp

change      proc
        mov     al, snakelen
        xor     ah, ah
        mov     si, ax
        mov     cx, ax
        neS:    mov     ah, dir[si]
                cmp     ah, up
                je      upSnake
                cmp     ah, down
                je      doSnake
                cmp     ah, left
                je      leSnake
                cmp     right
                je      riSnake
        upSnake:mov     al, cl
                add     al, al
                xor     ah, ah ; si is changed
                mov     si, ax
                mov     ah, snake[si]
                dec     ah
                cmp     ah, 0
                jnz     upk
                mov     die, 1
                upk: mov     snake[si], ah
                jmp     nextStage 

        doSnake:mov     al, cl
                add     al, al
                xor     ah, ah ; si is changed
                mov     si, ax
                mov     ah, snake[si]
                inc     ah
                cmp     ah, 9
                jnz     dok
                mov     die, 1
                dok: mov     snake[si], ah
                jmp     nextStage      

        leSnake:mov     al, cl
                add     al, al
                xor     ah, ah ; si is changed
                mov     si, ax
                dec     si
                mov     ah, snake[si]
                dec     ah
                cmp     ah, 0
                jnz     lek
                mov     die, 1
                lek: mov     snake[si], ah
                jmp     nextStage  

        riSnake:mov     al, cl
                add     al, al
                xor     ah, ah ; si is changed
                mov     si, ax
                dec     si
                mov     ah, snake[si]
                inc     ah
                cmp     ah, 9
                jnz     rik
                mov     die, 1
                rik:mov     snake[si], ah
                jmp     nextStage
        nextStage:
                mov     al, cl
                xor     ah,ah
                mov     si, ax
                inc     si
                mov     ah, dir[si]
                dec     si
                mov     dir[si], ah
                dec     al
                xor     ah, ah
                mov     si, ax
                loop    neS
                ret
change      endp

initSnake   proc
        mov     al, snakelen
        add     al, al
        xor     ah
        mov     si, ax

        mov     snake[si], 4
        dec     si
        mov     snake[si], 4
        dec     si
        mov     snake[si], 4
        dec     si
        mov     snake[si], 3
 
        mov     al, snakelen
        xor     ah,ah
        mov     si,ax
        inc     si
        mov     ah, right
        mov     dir[si], ah
        dec     si
        mov     dir[si], ah
        dec     si
        mov     dir[si], ah
        ret
initSnake   endp

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
                call    delay
                in      al, dx
                cmp     al, 0ffh
                je      noput
                mov     cx, 8
                xor     ah, ah
                mov     ah, al
                xor     al, al
        in1:    rol     ah, 1
                inc     al, 1
                jnc     in2
                jmp     in1
        in2:    mov     inkey, al
        noput:  mov     inkey, 0
                pop     ax
                pop     cx
                pop     dx
                ret
input       endp;check

getfood     proc    
                ; generate food for the snake to eat
                ; use random number to generate
                ; check if the food is interference with the snake
        rerand: call    rcrand
                mov     ax, ranfood
                call    collBody
                cmp ax, 0ffh
                je      rerand

                ret

getfood     endp

collBody    proc
                ; use ax to prealloc point 
                ; use the point to pair with snake(without head)
                ; if collide, set ax = 0ffh
                mov     bl, snakelen
                dec     bl
                mov     cl, bl
                xor     ch,ch
                add     bl, bl
                xor     bh,bh
                mov     si, bx
        collre: mov     bh, snake[si]
                dec     si
                mov     bl, snake[si]
                dec     si
                cmp     ax,bx
                je      coll
                loop    collre
                jmp     nocoll:
        coll:   mov     ax, 0ffh
        nocoll:        ret
collBody    endp

random      proc    
        ; generate random number from 1-8

        mov     al, 00010100b
        mov     dx, com53_add
        out     dx, al
        mov     dx, out53_add

        mov     ax, 08h
        out     dx, al
        mov     al, ah
        out     dx, al
        mov     al, 00h
        mov     dx, com53_add
        out     dx, al

        mov     dx, out53_add
        in      al, dx
        mov     ah, 0
        div     8
        cmp     ah, 0
        jne     noadd
        inc     ah
        noadd:
        mov     al, ah

random      endp;check

rcrand      proc    
        push    ax
        call    random
        mov     ah,al
        call    random
        mov     ranfood, ax
        ; check if the generated point is interference with the snake 
        pop     ax
        ret
rcrand      endp;check

delay       proc    
                push    bx
                push    cx
                mov     bx,10
        del1:   mov     cx, 0
        del2:   loop    del2
                dec     dx
                jnz     del1
                pop     cx
                pop     bx
                ret
delay       endp 

        end     start
