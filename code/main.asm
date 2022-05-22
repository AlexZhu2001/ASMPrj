;公共符号导入
EXTRN CLS:FAR
EXTRN SETTEXT:FAR
EXTRN DISPMENU:FAR
EXTRN MENU_CALL:FAR
;公共符号导出
PUBLIC MENU_TITLE
PUBLIC MENU_COUNT
PUBLIC MENU_INFO
PUBLIC MENU_NOW
PUBLIC EXIT_FLAG

DATA SEGMENT
        DOS_MODE    DB  0       ;保存DOS的原本显示模式 退出时恢复
        MENU_NOW    DB  0       ;当前选择的菜单项
        ;菜单定义开始
        MENU_TITLE  DB  "MENU",00H
        MENU_INFO   DB  ">CLOCK",00H
                    DB  ">MUSIC",00H
                    DB  ">REBOOT",00H
                    DB  ">EXIT",00H
        ;菜单数量
        MENU_COUNT  DB  4
        ;退出标志
        EXIT_FLAG   DB  0
DATA ENDS

STACK SEGMENT stack
        DB 100H DUP(0)
STACK ENDS
;菜单项下移 若到达底部 上卷
NEXT_MENU MACRO 
        PUSH AX
        MOV AL,[MENU_NOW] 
        MOV AH,[MENU_COUNT]
        INC AL ;菜单项位置加1
        CMP AL,AH
        JL NEXT_END ;没有超过最大 保存
        XOR AL,AL ;清零 回到开头
NEXT_END:
        MOV [MENU_NOW],AL ;存入变量
        POP AX
ENDM
;菜单项上移 若到达顶部 下卷
PREV_MENU MACRO 
        PUSH AX
        MOV AL,[MENU_NOW]
        MOV AH,[MENU_COUNT]
        DEC AL ;当前为0时 会变为-1
        CMP AL,0FFH ;是否为-1
        JG PREV_END
        ADD AL,[MENU_COUNT] ;计算出的值等效于 MENU_COUNT-1
PREV_END:
        MOV [MENU_NOW],AL
        POP AX
ENDM

CODE SEGMENT PARA PUBLIC 'code'
        ASSUME CS:CODE,DS:DATA,SS:STACK

START:  MOV AX,DATA
        MOV DS,AX
        ;备份显示方式
        MOV AH,0FH
        INT 10H
        MOV [DOS_MODE],AL
        ;设置显示模式 方便直接读写显存
        CALL SETTEXT
        ;清空屏幕
        CALL CLS

MAIN_LOOP:
        ;判断缓冲区有无按键
        MOV AH,11H
        INT 16H
        JZ FLUSH_MENU ;没有 跳刷新菜单
        ;读取按键
        MOV AH,10H 
        INT 16H
        ;是否为上箭头
        CMP AX,48E0H
        JE UPARROW
        ;是否为下箭头
        CMP AX,50E0H
        JE DOWNARROW
        ;是否为回车 包括小键盘
        CMP AX,1C0DH
        JE ENTERK
        CMP AX,0E00DH
        JE ENTERK
        ;都不是 跳刷新菜单
        JMP FLUSH_MENU
UPARROW:
        ;调用菜单项上移宏
        PREV_MENU
        JMP FLUSH_MENU
DOWNARROW:
        ;调用菜单项下移宏
        NEXT_MENU
        JMP FLUSH_MENU
ENTERK:
        ;远调用 菜单函数
        CALL FAR PTR MENU_CALL
        CALL FAR PTR SETTEXT
        CALL FAR PTR CLS
        JMP FLUSH_MENU
FLUSH_MENU:
        ;刷新菜单
        CALL DISPMENU
        ;是否设置退出标志
        MOV AL,[EXIT_FLAG]
        CMP AL,1
        JNE MAIN_LOOP ;未置位 继续循环
        ;恢复显示方式
        MOV AL,[DOS_MODE]
        XOR AH,AH
        INT 10H
        ;退出到DOS
        MOV AX,4C00H
        INT 21H
CODE ENDS
        END START

