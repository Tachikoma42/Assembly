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