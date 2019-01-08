SSEG SEGMENT PARA STACK'STACK';堆栈段
     DB 100 DUP(?)
SSEG ENDS	
DSEG SEGMENT ;数据段
     RESULT DB 20 DUP(?);存储被按下的按键的值
     BEI DB 80H,40H,20H,10H,08H,04H,02H,01H ;存贮放在第一行的障碍的数值
     POINT DB 12H;存储当前的第一行的点点的数值
     TTABLE DB 0FEH,3CH ;;单元1里面存放点阵列即PB，单元2里面存放点阵行即PC，即当前的“筋斗云”的位置
     DTIME DB 20,15,10,05,20,15,10,05,20,15,10,05;存储控制游戏难度的延时长度
     CTR DB 0;存储游戏来到了第几关
DSEG ENDS
CSEG SEGMENT;代码段
ASSUME CS:CSEG,SS:SSEG,DS:DSEG
MAIN PROC FAR
START:MOV AX,DSEG
      MOV DS,AX
      MOV AL,10010000B;8255初始化，pa输入（按键在F5区），pb输出(JP24点阵点亮，0选中行)，pc输出(JP23点阵点亮，1选中列)
      MOV DX,0F003H
      OUT DX,AL
       
      MOV DX,0E003H
      MOV AL,00010100B
      OUT DX,AL
      MOV DX,0E000H
      MOV AL,4
      OUT DX,AL   ;初始化8253控制字(CLK0接4M时钟，GATE0置高，CS接CS2)将CLK0作为随机数的输入口，通过读取8253当前计数值，作为随机数的输入
       
      LEA DI,TTABLE
      MOV CX,0FEH
      MOV [DI],CX
      INC DI
      MOV CX,3CH
      MOV [DI],CX;这里写内存并使得“筋斗云在最下面行出现”
    
      
R1:   LEA SI,RESULT
      MOV AL,0
      MOV [SI],AL
      CALL RANDOM;随机数放在DL中
      MOV BH,0
      MOV BL,DL
      CALL RANDOM
      ADD BL,DL
      DEC BX
      LEA SI,BEI
      MOV AL,[SI][BX]
      MOV AH,AL;随机数对应列选择放在AH中     
      LEA SI,POINT
      MOV [SI],AH;这里是通过CALL随机数程序，得到0~7的随机数，然后控制障碍的随机位置


D1: 
      MOV AL,0
      ;pb输出(JP24点阵点亮，0选中行)，
      MOV DX,0F001H;pb55_add
      OUT DX,AL
      MOV AL,7FH
      OUT DX,AL 
      LEA SI,POINT
      MOV AL,[SI]
      ;pc输出(JP23点阵点亮，1选中列)
      MOV DX,0F002H;pc55_add
      OUT DX,AL

       ;0f002是位选
       ;0F001  
     
      MOV CX,2  
RT:   CALL DELAY  
      LOOP RT   
      MOV AL,0 
      MOV DX,0F001H
      OUT DX,AL
      LEA DI,TTABLE
      MOV AL,[DI]
      MOV DX,0F001H
      OUT DX,AL
      MOV AL,[DI+1]
      MOV DX,0F002H 
      OUT DX,AL;以上程序可以静态的显示开机时候的状态
;即下面一行“筋斗云”，上面一个随机的数的点点      


      LEA DI,TTABLE
      MOV AL,[DI]
      CMP AL,7FH
      JNZ AGAIN
      INC DI
      MOV AL,[DI]
      LEA SI,POINT
      MOV BL,[SI]
      AND AL,BL
      CMP AL,0;等于0的话就是没碰到，跳到R1 变化点点
      JZ AGAIN;不等于0就是不变
      ;这里的程序只有当碰到之后，才会走到
      ;一方面碰到之后，如果随机数依旧使得两者碰到，依旧会跳到R1进行变换随机数
      ;如果更换随机数之后，没有碰到，会走下面的R11，然后跳到R1，变换随机数
      ;从而形成一种乱码的现象，作为失败的惩罚

R11: 
      NOP     
      JMP R1   
AGAIN:
      CALL PANDUAN;通过CALL子程序判定当前是哪一个按键被按下，并写入内存
      LEA DI,TTABLE
      MOV AL,[DI]
      CMP AL,7FH
      JNZ A2
      MOV AL,0FEH
      MOV [DI],AL
      INC DI
      MOV AL,[DI]
      LEA SI,POINT
      MOV BL,[SI]
      AND AL,BL
      CMP AL,0
      JZ CHANGE;等于就是跳到A2就是不变 ，没有碰到
      ;JMP R11;跳到R11变化，就是不等于的时候，就是碰到了     
      ;以上的程序涉及两个判定
      ;第一个是“筋斗云”是否到达最上面一行，如果没有到达，则跳到A2进行下一步判定
      ;第二个是如果到达了最上面一行，判定有没有和障碍碰到，如果碰到则跳到R1，更换随机数，如果没有碰到，则继续
      ;这里判定是否碰到的算法是 让障碍和“筋斗云”所在的两个数字按位与，如果没有碰到，结果为0，碰到了，结果就不为0
A2:   
      LEA SI,RESULT
      MOV CX,[SI]
      CMP CX,1
      JZ SHANG;按键1则点阵图案上移
      CMP CX,2
      JZ XIA1;按键2则点阵图案下移
      CMP CX,3
      JZ ZUO;按键3则点阵图案坐移
      CMP CX,4
      JZ YOU;按键4则点阵图案右移
      CMP CX,5;按键5则变点点
      JZ R11
      JMP D1
      ;以上是通过读当前按键值，确定下一步的操作，分为上下左右和更变点点位置
CHANGE:
     LEA DI,CTR
     MOV AL,[DI]
     CMP AL,3
     JNZ B7
     MOV AL,0
     MOV [DI],AL
B7:  INC AL
     MOV [DI],AL
     JMP R11
      ;以上是当我们主动按下5键更换随机数的时候
      ;对游戏难度进行控制
      ;这时候向上的延时变短
SHANG:
      LEA DI,TTABLE
      MOV DX,0F001H
      MOV AL,[DI]
      ROL AL,1
      OUT DX,AL
      MOV [DI],AL;存储左移后新位置
      INC DI
      MOV AL,[DI]
      MOV DX,0F002H
      OUT DX,AL
     MOV AX,DSEG
     MOV DS,AX
      LEA DI,CTR
      MOV BX,[DI]
      LEA SI,DTIME
      MOV CX,[BX][SI]
      MOV CL,CH
      MOV CH,0
      ;MOV CX,10
M1:   CALL DELAY
      LOOP M1
      MOV AL,0
      MOV DX,0F001H
      OUT DX,AL
      MOV AL,7FH
      OUT DX,AL 
      LEA SI,POINT
      MOV AL,[SI]
      MOV DX,0F002H
      OUT DX,AL
      
      
      MOV AX,DSEG
      MOV DS,AX
     LEA DI,CTR
     MOV BX,[DI]
     ;LEA SI,DTIME
    ; MOV CX,[BX][SI]
     ;MOV CX,10
      LEA SI,DTIME
      MOV CX,[BX][SI]
      MOV CL,CH
      MOV CH,0
N1:   CALL DELAY
       LOOP N1
      JMP D1
;以上程序实现了“筋斗云”向上的过程当中位置、延时的变化
;这里没有对内存存储1进行操作，从而向上是一直进行的
XIA1:JMP XIA      
ZUO:  JMP ZUO1
YOU:  JMP YOU1
;以上的3个JMP纯粹是因为星研的开发环境JMP在程序段中跳跃有一定BIT限制引起的

XIA:  LEA DI,TTABLE
      MOV DX,0F001H
      MOV AL,[DI]
      ROR AL,1
      OUT DX,AL
      MOV [DI],AL;存储右移后新位置
      INC DI
      MOV AL,[DI]
      MOV DX,0F002H
      OUT DX,AL
      MOV CX,10
M2:   CALL DELAY
      LOOP M2
      MOV AL,0
      MOV DX,0F001H
      OUT DX,AL
      MOV AL,7FH
      OUT DX,AL 
      LEA SI,POINT
      MOV AL,[SI]
      MOV DX,0F002H
      OUT DX,AL
      MOV CX,10
N2: CALL DELAY
       LOOP N2
      LEA SI,RESULT
      MOV AL,0
      MOV [SI],AL
      JMP AGAIN
;以上程序实现了“筋斗云”向下的过程当中位置、延时一定
;这里有对内存存储1进行操作，使得存储的按键值变为了0，从而向下只有一步
      
ZUO1:LEA DI,TTABLE
      MOV DX,0F001H
      MOV AL,[DI]
      OUT DX,AL
      INC DI
      MOV AL,[DI]
      ROL AL,1
      MOV DX,0F002H
      OUT DX,AL
      MOV [DI],AL;存储上移后新位置
      MOV CX,10
M3:   CALL DELAY
      LOOP M3
      MOV AL,0
      MOV DX,0F001H
      OUT DX,AL
      MOV AL,7FH
      OUT DX,AL 
      LEA SI,POINT
      MOV AL,[SI]
      MOV DX,0F002H
      OUT DX,AL
      MOV CX,10
N3: CALL DELAY
       LOOP N3
      LEA SI,RESULT
      MOV AL,1
      MOV [SI],AL
      JMP AGAIN   
;以上程序实现了“筋斗云”向左的过程当中位置、延时一定
;这里对内存存储1进行操作，向左之后，依旧会不断向上
      
YOU1:  LEA DI,TTABLE
      MOV DX,0F001H
      MOV AL,[DI]
      OUT DX,AL
      INC DI
      MOV AL,[DI]
      ROR AL,1
      MOV DX,0F002H
      OUT DX,AL
      MOV [DI],AL;存储上移后新位置
      MOV CX,10
M4:   CALL DELAY
      LOOP M4
      MOV AL,0
      MOV DX,0F001H
      OUT DX,AL
      MOV AL,7FH
      OUT DX,AL 
      LEA SI,POINT
      MOV AL,[SI]
      MOV DX,0F002H
      OUT DX,AL
      MOV CX,10
N4: CALL DELAY
       LOOP N4
      LEA SI,RESULT
      MOV AL,1
      MOV [SI],AL
      JMP AGAIN   
;以上程序实现了“筋斗云”向右的过程当中位置、延时一定
;这里对内存存储1进行操作，向右之后，依旧会不断向上


            
PANDUAN PROC NEAR;子程序判断是否有按键按下，并返回是哪一个按键
      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX
      MOV DX,0F000H
      IN AL,DX;从pa口读按键输入(按键按下为0)
      MOV CX,2;延时消抖
AGA:  CALL DELAY
      LOOP AGA
      MOV AH,AL
      CMP AL,0FFH
      JNZ A1;有按键按下
      JMP A2
A1:   IN AL,DX
      CMP AL,0FFH
      JZ A3;按下的按键已经弹起
      JMP A1
A3:   MOV CX,8;AH中存放某个按键按下后PA输入值
      MOV AL,0
B1:   ROL AH,1
      INC AL
      JNC C1;CF为0即左移后出来了0是按键按下，则AL中存放哪一个按键(第一个按键数值为1)
      JMP B1
C1:   LEA SI,RESULT
      MOV AH,0
      MOV [SI],AX
      POP DX
      POP CX
      POP BX
      POP AX
      RET
PANDUAN ENDP
;程序判定的基本算法是当读取到有按键按下的时候，进入扫描到底是哪一个按键的程序
;通过循环左移的方式，不断将位送入CF当中
;使用JNC判定，CF是否为0，然后跳走，得到当前按键值
     
DELAY PROC NEAR;20ms延时子程序
      PUSH BX
      PUSH CX
      MOV BX,10
DEL1: MOV CX,0
DEL2: LOOP DEL2
      DEC BX
      JNZ DEL1
      POP CX
      POP BX
      RET
DELAY ENDP
;以上算法是延时子程序


RANDOM PROC NEAR;产生1-4的随机数
      PUSH AX
      PUSH BX
      PUSH CX
      MOV DX,0E003H
      MOV AL,00000101B
      OUT DX,AL
      MOV DX,0E000H
      IN AL,DX
      MOV DL,AL
      POP CX
      POP BX
      POP AX
      RET
RANDOM ENDP
;以上算法是产生随机数，读取8253计数值


MAIN ENDP
CSEG ENDS
     END START

 





