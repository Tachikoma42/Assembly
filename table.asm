data segment
  binval dw 0B39h
data ends

code segment
  assume cs:code,ds:data
start:
  mov ax,data
  mov ds,ax
  ;---------------
  mov bx,binval
  mov cx,16
LP1:
  rol bx,1
  mov dl,0
  adc dl,30h
  mov ah,02h
  int 21h
  loop LP1
  ;---------------
 over:
  mov ah,4ch
  int 21h
code ends
  end start