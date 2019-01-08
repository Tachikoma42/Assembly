.model tiny
    com_add equ 0f000h
    period  equ 160
.stack 100
.code
start:  mov     ax, @data
        mov     ds,ax
        nop
        mov     dx, com_add
        mov     al,0
goon1:  out     dx, al
        add     al, 4

        cmp     al, period
        ja      goon2
        jmp     goon1
goon2:  out     dx, al
        sub     al, 4
        
        cmp     al, 0
        ja      goon2
        jmp     goon1
        mov     ax, 4c00h
        int     21h
end     start

.model  tiny
    com_add     equ 0f000h
    period      equ 0ffh
.stack  100
.code
start:  mov     ax, @data
        mov     ds, ax
        nop
        mov     dx, com_add
re:     mov     al, 78h
        out     dx, al
        call    delay1
        mov     al, 0
        out     dx, al
        call    delay1

        jmp     re
        mov     ax, 4c00h
        int     21h

delay1  proc
        push    cx
        mov     cx, 4
lo1:    push    cx
        mov     cx, 28500
lo2:    loop    lo2
        pop     cx
        loop    lo1
        pop     cx
        ret
delay1  endp

end     start
