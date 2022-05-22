; Copyright 2022 AlexZhu2001@stu.xupt.edu.cn
; Permission is hereby granted, free of charge, to any person obtaining a copy 
; of this software and associated documentation files (the "Software"), to deal 
; in the Software without restriction, including without limitation the rights to 
; use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
; of the Software, and to permit persons to whom the Software is furnished to do 
; so, subject to the following conditions:
; The above copyright notice and this permission notice shall be included in 
; all copies or substantial portions of the Software.
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
; SOFTWARE.
;导入符号
EXTRN CLS:FAR
EXTRN SETTEXT:FAR
EXTRN DISPMENU:FAR
EXTRN DISPSTR:FAR
EXTRN MUSIC:FAR

EXTRN MENU_TITLE:BYTE
EXTRN MENU_COUNT:BYTE
EXTRN MENU_INFO:BYTE
EXTRN MENU_NOW:BYTE
EXTRN EXIT_FLAG:BYTE

BCD2ASCII MACRO REG,MEM
        PUSH AX

        MOV AH,REG
        MOV AL,REG
        MOV CL,4
        SHR AL,CL
        AND AH,0FH
        ADD AL,30H
        ADD AH,30H
        MOV [MEM],AX 

        POP AX
ENDM

DATA_MENU SEGMENT
        ;date str
        YEAR        DW  0,0 ;年份 四位
                    DB  "/"
        MONTH       DW  0 ;月份 两位
                    DB  "/"
        DAY         DW  0 ;日 两位
                    DB  " "
        HOUR        DW  0 ;小时 两位
                    DB  ":"
        MINUTE      DW  0 ;分钟 两位
                    DB  ":"
        SECOND      DW  0 ;秒 两位
                    DB  5 DUP(' '),00H ;字符串结束符
        INFO_DATE   DB  "Press any key return to menu..."
                    DB  00H
        RE_VEC      DW  0000H,0FFFFH ;重启向量 远跳转到此处复位
DATA_MENU ENDS

;附加的代码段
CODE2 SEGMENT PARA PUBLIC 'code'
        ASSUME CS:CODE2,DS:DATA_MENU
        ;导出符号
        PUBLIC MENU_CALL
;菜单调用
MENU_CALL PROC FAR
        PUSH AX
        ;类似于switch的选择
        MOV AL,[MENU_NOW]
        CMP AL,0 ;为0 跳转调用0号
        JE CALL0
        CMP AL,1 ;为1 跳转调用1号
        JE CALL1
        CMP AL,2 ;为2 跳转调用2号
        JE CALL2
        CMP AL,3 ;为3 跳转调用3号
        JE CALL3
        JMP CALLEND ;都不是 不发生调用
CALL0:
        CALL FAR PTR CLOCK ;时间子程序
        JMP CALLEND
CALL1:
        CALL FAR PTR MUSIC ;音乐子程序
        JMP CALLEND
CALL2:
        CALL FAR PTR REST ;重启子程序
        JMP CALLEND
CALL3:
        CALL FAR PTR EXIT ;退出子程序
        JMP CALLEND
CALLEND:
        POP AX
        RET
MENU_CALL ENDP

CLOCK PROC FAR
        ;保护寄存器
        PUSH AX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DS
        ;更换数据段
        MOV AX,DATA_MENU
        MOV DS,AX

        CALL FAR PTR CLS

CLOCK_LOOP:
        ;调用BIOS时间中断
        MOV AH,02H
        INT 1AH
        ;压缩BCD转ASCII
        PUSH CX
        BCD2ASCII CH,HOUR
        POP CX
        BCD2ASCII CL,MINUTE
        BCD2ASCII DH,SECOND

        ;调用BIOS时间中断
        MOV AH,04H
        INT 1AH

        PUSH CX
        BCD2ASCII CH,YEAR
        POP CX
        BCD2ASCII CL,YEAR+2
        PUSH DX
        BCD2ASCII DH,MONTH
        POP DX
        BCD2ASCII DL,DAY
        JMP JMP_TMP_END
JMP_TMP:
        JMP CLOCK_LOOP
JMP_TMP_END:
        ;打印时间
        MOV AX,OFFSET YEAR
        MOV SI,AX
        XOR AX,AX
        MOV DH,00001111B
        CALL FAR PTR DISPSTR
        ;打印提示信息
        MOV AX,OFFSET INFO_DATE
        MOV SI,AX
        XOR AH,AH
        MOV AL,01H
        MOV DH,00001111B
        CALL FAR PTR DISPSTR
        ;判断有无按键输入
        MOV AH,11H
        INT 16H
        JZ JMP_TMP
        ;读取按键输入
        MOV AH,10H
        INT 16H
        ;清屏
        CALL CLS
        ;恢复寄存器
        POP DS
        POP SI
        POP DX
        POP CX
        POP AX
        RET
CLOCK ENDP

REST PROC FAR
        ;重启 不保存寄存器
        ;向 0040H:0072H写入1234H
        MOV AX,0040H
        MOV DS,AX
        MOV BX,0072H
        MOV AX,1234H
        MOV [BX],AX
        ;长跳转到复位向量所指定处
        MOV AX,DATA_MENU
        MOV DS,AX
        JMP DWORD PTR RE_VEC
        RET
REST ENDP

EXIT PROC FAR
        PUSH AX
        ;退出标志置1
        MOV AL,1
        MOV [EXIT_FLAG],AL
        POP AX
        RETF
EXIT ENDP

CODE2 ENDS
        END