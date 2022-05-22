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

;导入外部符号
EXTRN MENU_TITLE:BYTE
EXTRN MENU_COUNT:BYTE
EXTRN MENU_INFO:BYTE
EXTRN MENU_NOW:BYTE

;虚拟段 此段是显存的第一页
VIDEO SEGMENT AT 0B800H 
        VIDEO_AREA DB 4000 DUP(?)
VIDEO ENDS

;该段和main中的同名段会合并
CODE SEGMENT PARA PUBLIC 'code'
    ASSUME CS:CODE
        ;导出符号
        PUBLIC CLS
        PUBLIC SETTEXT
        PUBLIC DISPSTR
        PUBLIC DISPMENU
;清空屏幕过程
CLS PROC FAR
        ;保护寄存器
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH ES
        ;定位到VIDEO:0
        MOV BX,0
        ;屏幕大小 25*80*2 Bytes = 4000 Bytes 
        MOV CX,4000
        MOV AX,VIDEO
        MOV ES,AX
CLS_LOOP:
        ;循环置零
        MOV BYTE PTR ES:[BX],0
        DEC CX
        INC BX
        JNZ CLS_LOOP
        ;恢复寄存器
        POP ES
        POP CX
        POP BX
        POP AX
        RETF
CLS ENDP

SETTEXT PROC FAR
        PUSH AX
        ;设置字符模式 25*80 16色
        XOR AX,AX
        INT 10H
        ;关闭光标
        MOV CH,00100000B
        MOV AH,01H
        INT 10H
        POP AX
        RETF
SETTEXT ENDP

;显示字符串函数
;入口参数 DS:SI 串地址,AH X,AL Y,DH 颜色
;出口参数 SI 该串的尾地址
DISPSTR PROC FAR
        ;保护寄存器值
        PUSH AX
        PUSH DX
        PUSH CX
        PUSH ES
        PUSH DI
        ;计算打印开始坐标
        PUSH AX
        MOV AH,80
        MUL AH
        POP CX
        MOV CL,CH
        XOR CH,CH
        ADD AX,CX
        ;将地址装入 ES:DI指向显存 DS:SI指向源串
        MOV CX,VIDEO
        MOV ES,CX
        MOV CX,OFFSET VIDEO_AREA
        ADD CX,AX
        MOV DI,CX
        ;显示循环 直到发现00H
DISP_LOOP:
        MOV AL,[SI]
        CMP AL,00H
        JE DISP_END
        MOV ES:[DI],AL
        INC DI
        MOV ES:[DI],DH
        INC DI
        INC SI
        JMP DISP_LOOP
        ;恢复寄存器值
DISP_END:
        POP DI
        POP ES
        POP CX
        POP DX
        POP AX
        RETF
DISPSTR ENDP

;打印菜单
DISPMENU PROC FAR
        ;保护寄存器
        PUSH CX
        PUSH AX
        PUSH SI
        PUSH DX
        ;打印菜单标题
        MOV AX,OFFSET MENU_TITLE
        MOV SI,AX
        XOR AX,AX
        MOV DH,00001111B
        CALL DISPSTR
        ;将菜单数量装入CX
        XOR CH,CH
        MOV CL,[MENU_COUNT]
        ;将菜单起始地址装入SI
        MOV AX,OFFSET MENU_INFO
        MOV SI,AX
        XOR AX,AX
        ;从第一行开始打印菜单项（0起始行）
        MOV AL,1
        ;DL存放当前菜单下标
        MOV DL,[MENU_NOW]
        ADD DL,1
MENU_LOOP:
        CMP DL,AL
        JE CHCOLOR ;当前选中菜单项反色且闪烁
        MOV DH,00001111B
        JMP CHCOLOREND
CHCOLOR:
        MOV DH,11110000B
CHCOLOREND:
        ;调用显示函数        
        CALL DISPSTR
        INC SI
        INC AL
        LOOP MENU_LOOP
        ;恢复寄存器
        POP DX
        POP SI
        POP AX
        POP CX
        RETF
DISPMENU ENDP

CODE ENDS
        END