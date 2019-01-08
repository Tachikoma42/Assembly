.model  tiny
    com_add     equ     0f003h
    pa_add      equ     0f000h
    pb_add      equ     0f001h
    pc_add      equ     0f002h

.stack 100
.data
tableRev  db  01h,03h,02h,06h,04h,0ch,08h,09h
tablePos  db 08h,0ch,04h,06h,02h,03h,01h,09h
d1        dw    ?
;0001 0011 0010 0110 0100 1100 1000 1001

.code
start:  mov     ax, @data
        mov     ds, ax
        nop

        mov     dx, com_add
        mov     al, 10010000b
        ;pa-in pc-out pb-out
        out     dx, al
reload: mov     al, 0
        mov     dx, pb_add
        out     dx, al

        mov     dx, pa_add
        in      al, dx
        cmp     al, 0ffh
        je      pos

rev:    mov     di, offset tableRev
        jmp     circle
pos:    mov     di, offset tablePos
        jmp     circle
circle: mov     cx, 8
        mov     bx, di
s2:     mov     al, [bx]
        mov     dx, pc_add
        out     dx, al
        call    delay
        inc     bx
        loop    a2
        jmp     reload
quit:   mov     ax, 4c00h
        int     21h

delay   proc    near
        push    bx
        push    cx
        mov     bx,1000
del1:   mov     cx, 0
del2:   loop    del2
        dec     dx
        jnz     del1
        pop     cx
        pop     bx
        ret
delay       endp 
        end     start
