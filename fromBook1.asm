start:  mov dx, 0f000h
        mov al, 0
goon1:  out dx, al
        inc al
        cmp al, 0ffh
        jz  goon2
        jmp goon1
goon2:  out dx, al
        dec al
        cmp al, 0
        jnz goon2
        jmp goon1


start:  mov dx, 0f000h
        mov al, 80h
goon1:  out dx, al
        inc al
        cmp al, 0ffh
        jz  goon2
        jmp goon1
goon2:  out dx, al
        dec al
        cmp al, 80h
        jnz goon2
        jmp goon1