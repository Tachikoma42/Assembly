#include "conio.h"
void main(void){
    unsigned char array1[0x100];
    unsigned char array2[0x100];
    int i ;
    for(i = 0; i<0x100;i++)
        array1[i] = ~i;
    for(i = 0;i<0x100;i++)
        outportb(i+0x2000, array1[i]);
    for(i = 0;i<0x100;i++)
        array2[i] = inportb(i+0x2000);
    while(1);
}