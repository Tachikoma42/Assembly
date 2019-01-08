.model  tiny
    com_add     equ 0f000h
.stack  100
.code
start:  mov     ax, @data
        mov     ds, ax
        nop
        mov     dx, com_add
        in      ax, dx
        jmp     $
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