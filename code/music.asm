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
EXTRN DISPSTR:FAR
EXTRN CLS:FAR

MUSIC_DATA SEGMENT
        NOW_FREQ    DW  0 ;播放音符的入口参数
        TIMER       DB  0 ;计时器 55ms计数一次
        MAXCOUNT    DB  0 ;延时入口参数
        ;保存1ch中断的原始向量表
        ORIGIN_CS   DW  0 
        ORIGIN_IP   DW  0
        ;歌曲频率表
        FREQ_TAB    DW  740,830,554,622,494,587,554,494,494,554,587,587,554,494,554,622,740,830
                    DW	622,740,554,587,494,554,494,622,740,830,622,740,554,587,494,554,622,587
                    DW	554,494,554,587,494,554,587,740,554,587,554,494,554,494,554,740,830,554
                    DW	622,494,587,554,494,494,554,587,587,554,494,554,622,740,830,622,740,554
                    DW	587,494,554,494,622,740,830,622,740,554,587,494,554,622,587,554,494,554
                    DW	587,494,554,587,740,554,587,554,494,554,494,494,494,370,415,494,370,415
                    DW	494,554,622,554,659,622,659,740,494,494,370,415,494,415,659,622,554,494
                    DW	370,311,329,370,494,370,415,494,370,415,494,494,554,622,494,370,415,370
                    DW	494,494,466,494,370,415,494,659,622,659,740,494,466,494,370,415,494,370
                    DW	415,494,554,622,554,659,622,659,740,494,494,370,415,494,415,659,622,554
                    DW	494,370,311,329,370,494,370,415,494,370,415,494,494,554,622,494,370,415
                    DW	370,494,494,466,494,370,415,494,659,622,659,740,494,554,740,830,554,622
                    DW	494,587,554,494,494,554,587,587,554,494,554,622,740,830,622,740,554,587
                    DW	494,554,494,622,740,830,622,740,554,587,494,554,622,587,554,494,554,587
                    DW	494,554,587,740,554,587,554,494,554,494,554,740,830,554,622,494,587,554
                    DW	494,494,554,587,587,554,494,554,622,740,830,622,740,554,587,494,554,494
                    DW	622,740,830,622,740,554,587,494,554,622,587,554,494,554,587,494,554,587
                    DW	740,554,587,554,494,554,494,494,494,370,415,494,370,415,494,554,622,554
                    DW	659,622,659,740,494,494,370,415,494,415,659,622,554,494,370,311,329,370
                    DW	494,370,415,494,370,415,494,494,554,622,494,370,415,370,494,494,466,494
                    DW	370,415,494,659,622,659,740,494,466,494,370,415,494,370,415,494,554,622
                    DW	554,659,622,659,740,494,494,370,415,494,415,659,622,554,494,370,311,329
                    DW	370,494,370,415,494,370,415,494,494,554,622,494,370,415,370,494,494,466
                    DW	494,370,415,494,659,622,659,740,494,554,164,164,329,329,185,185,370,370
                    DW	155,155,311,311,207,207,415,415,138,138,277,277,185,185,370,370,123,123
                    DW	246,246,123,123,246,246,164,329,185,370,155,311,207,415,138,277,185,370
                    DW	123,246,123,246,164,329,185,370,155,311,207,415,138,277,185,185,370,370
                    DW	123,246,123,246,164,329,185,370,155,311,207,415,138,277,185,370,123,246
                    DW	123,246,164,207,246,329,155,185,246,311,138,164,207,246,123,155,185,246
                    DW	164,207,246,329,155,185,246,311,138,164,207,246,123,155,185,246,164,207
                    DW	246,329,155,185,246,311,138,164,207,246,123,155,185,246,164,207,246,329
                    DW	155,185,246,311,138,164,207,246,123,155,185,246,164,164,329,329,185,185
                    DW	370,370,155,155,311,311,207,207,415,415,138,138,277,277,185,185,370,370
                    DW	123,123,246,246,123,123,246,246,164,329,185,370,155,311,207,415,138,277
                    DW	185,370,123,246,123,246,164,329,185,370,155,311,207,415,138,277,185,185
                    DW	370,370,123,246,123,246,164,329,185,370,155,311,207,415,138,277,185,370
                    DW	123,246,123,246,164,207,246,329,155,185,246,311,138,164,207,246,123,155
                    DW	185,246,164,207,246,329,155,185,246,311,138,164,207,246,123,155,185,246
                    DW	164,207,246,329,155,185,246,311,138,164,207,246,123,155,185,246,164,207
                    DW	246,329,155,185,246,311,138,164,207,246,123,155,185,246,622,659,740,988
                    DW	622,659,740,988,1108,1244,1108,932,988,740,622,659,740,988,1108,932,988,1108
                    DW	1318,1244,1318,1108,0
        ;歌曲时值表
        TIME_TAB    DB  4,4,2,4,2,2,2,4,4,4,4,2,2,2,2,2,2,2
                    DB	2,2,2,2,2,2,2,4,4,2,2,2,2,2,2,2,2,2
                    DB	2,2,2,4,2,2,2,2,2,2,2,2,4,4,4,4,4,2
                    DB	4,2,2,2,4,4,4,4,2,2,2,2,2,2,2,2,2,2
                    DB	2,2,2,2,4,4,2,2,2,2,2,2,2,2,2,2,2,2
                    DB	4,2,2,2,2,2,2,2,2,4,4,4,4,2,2,4,2,2
                    DB	2,2,2,2,2,2,2,2,4,4,2,2,2,2,2,2,2,2
                    DB	2,2,2,2,4,2,2,4,2,2,2,2,2,2,2,2,2,2
                    DB	4,2,2,2,2,2,2,2,2,2,2,4,4,4,2,2,4,2
                    DB	2,2,2,2,2,2,2,2,2,4,4,2,2,2,2,2,2,2
                    DB	2,2,2,2,2,4,2,2,4,2,2,2,2,2,2,2,2,2
                    DB	2,4,2,2,2,2,2,2,2,2,2,2,4,4,4,4,2,4
                    DB	2,2,2,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2
                    DB	2,2,2,4,4,2,2,2,2,2,2,2,2,2,2,2,2,4
                    DB	2,2,2,2,2,2,2,2,4,4,4,4,4,2,4,2,2,2
                    DB	4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2
                    DB	4,4,2,2,2,2,2,2,2,2,2,2,2,2,4,2,2,2
                    DB	2,2,2,2,2,4,4,4,4,2,2,4,2,2,2,2,2,2
                    DB	2,2,2,2,4,4,2,2,2,2,2,2,2,2,2,2,2,2
                    DB	4,2,2,4,2,2,2,2,2,2,2,2,2,2,4,2,2,2
                    DB	2,2,2,2,2,2,2,4,4,4,2,2,4,2,2,2,2,2
                    DB	2,2,2,2,2,4,4,2,2,2,2,2,2,2,2,2,2,2
                    DB	2,4,2,2,4,2,2,2,2,2,2,2,2,2,2,4,2,2
                    DB	2,2,2,2,2,2,2,2,4,4,2,4,2,4,2,4,2,4
                    DB	2,4,2,4,2,4,2,4,2,4,2,4,2,4,2,4,2,4
                    DB	2,4,2,4,2,4,4,4,4,4,4,4,4,4,4,4,4,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,4,2,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,2,4,2,4,2,4
                    DB	2,4,2,4,2,4,2,4,2,4,2,4,2,4,2,4,2,4
                    DB	2,4,2,4,2,4,2,4,4,4,4,4,4,4,4,4,4,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,4
                    DB	2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                    DB	4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,4,4
                    DB	2,2,2,2,2,2,2,2,4,4,2,2,4,2,4,2,2,2
                    DB	2,2,2,0
        MUSIC_INF1  DB  "Playing...(Press q to exit)",0
MUSIC_DATA ENDS

;打开蜂鸣器的宏
SPKON MACRO
        PUSH AX

        IN AL,61H
        OR AL,03H
        OUT 61H,AL ;61H端口低两位送11开启蜂鸣器

        POP AX
ENDM

;关闭蜂鸣器的宏
SPKOFF MACRO
        PUSH AX

        IN AL,61H
        AND AL,0FCH
        OUT 61H,AL ;61H端口低两位送00关闭蜂鸣器
        
        POP AX
ENDM

;频率设置宏
SETFREQ MACRO FREQ_MEM
        PUSH AX
        PUSH BX
        PUSH DX
        
        MOV BX,[FREQ_MEM]
        ;2号定时器设置为方波发生器模式
        MOV AL,0B6H
        OUT 43H,AL
        ;使用频率计算计数器数量
        MOV DX,12H
        MOV AX,3280H
        DIV BX
        ;向计数器送计数值
        OUT 42H,AL
        MOV AL,AH
        OUT 42H,AL

        POP DX
        POP BX
        POP AX
ENDM

MUSIC_CODE SEGMENT PARA PUBLIC 'code'
        ASSUME CS:MUSIC_CODE,DS:MUSIC_DATA
        PUBLIC MUSIC

;延时函数 使用自定义的1CH中断的回调计数值来判断时间
DELAY PROC
        PUSH DS
        PUSH AX

        MOV AX,MUSIC_DATA
        MOV DS,AX

        ;关中断 重置计数器 开中断
        CLI
        XOR AX,AX
        MOV [TIMER],AH
        STI
        ;循环判断是否计满
DELAY_LOOP:
        MOV AH,[TIMER]
        MOV AL,[MAXCOUNT]
        CMP AH,AL
        JNE DELAY_LOOP
        ;计满 清空计数器 退出
        XOR AX,AX
        MOV [TIMER],AL

        POP AX
        POP DS
        RET
DELAY ENDP

;产生声音
GENSOUND PROC
        PUSH AX
        PUSH BX
        PUSH DS
        PUSH SI
        PUSH DI
        PUSH CX
        
        MOV AX,MUSIC_DATA
        MOV DS,AX
        ;根据入口参数开始播放
        SETFREQ NOW_FREQ
        SPKON
        ;延时 
        CALL DELAY
        ;关蜂鸣器
        SPKOFF
        ;音符间间隔 短延时
        MOV CX,0FFFFH
SHORT_DELAY:
        LOOP SHORT_DELAY

        POP CX
        POP DI
        POP SI
        POP DS
        POP BX
        POP AX
        RET
GENSOUND ENDP

;安装中断处理程序
INSTALL_TIMER PROC
        PUSH AX
        PUSH DS
        PUSH ES
        
        MOV AX,MUSIC_DATA
        MOV DS,AX

        XOR AX,AX
        MOV ES,AX
        ;安装时关闭中断
        CLI
        ;备份原始中断向量 并重新设置中断向量位置
        ;1CH 向量 0:1CH*4 -> IP 0:1CH*4+2 -> CS
        PUSH ES:[1CH*4]
        POP [ORIGIN_IP]
        MOV WORD PTR ES:[1CH*4],OFFSET TIMERINT

        PUSH ES:[1CH*4+2]
        POP [ORIGIN_CS]
        PUSH CS
        POP AX
        MOV WORD PTR ES:[1CH*4+2],AX
        ;开中断
        STI

        POP ES
        POP DS
        POP AX
        RET
INSTALL_TIMER ENDP

;卸载中断处理程序
UNINSTALL_TIMER PROC
        PUSH AX
        PUSH ES

        XOR AX,AX
        MOV ES,AX
        ;重新安装时关闭中断
        CLI
        ;恢复备份的向量
        PUSH [ORIGIN_IP]
        POP ES:[1CH*4]

        PUSH [ORIGIN_CS]
        POP ES:[1CH*4+2]
        ;开中断
        STI

        POP ES
        POP AX
        RET
UNINSTALL_TIMER ENDP

;主程序部分
MUSIC PROC FAR
        PUSH AX
        PUSH DS
        PUSH BX
        PUSH CX
        PUSH SI
        
        MOV AX,MUSIC_DATA
        MOV DS,AX
        ;清空屏幕 打印提示信息
        CALL FAR PTR CLS
        MOV AX,OFFSET MUSIC_INF1
        MOV SI,AX
        XOR AX,AX
        MOV DH,00111100B
        CALL FAR PTR DISPSTR
        ;安装中断处理程序
        CALL INSTALL_TIMER
        ;设置播放参数读取地址
        MOV SI,OFFSET FREQ_TAB
        MOV DI,OFFSET TIME_TAB
        ;循环读取 播放
MUSIC_LOOP:
        ;读取并设置频率
        MOV AX,[SI]
        CMP AX,0 ;遇到0 结束播放
        JE MUSIC_END
        MOV [NOW_FREQ],AX
        ;读取时值 遇到0 结束播放
        MOV BH,[DI]
        CMP BH,0
        JE MUSIC_END
        ;设置延时参数
        MOV [MAXCOUNT],BH
        ADD SI,2
        INC DI
        ;调用播放函数
        CALL GENSOUND
        ;判断有无按下按键 没有继续循环
        MOV AH,11H
        INT 16H
        JZ MUSIC_LOOP
        ;有 读取按键
        MOV AH,10H 
        INT 16H
        CMP AX,1071H ;不为q 继续播放
        JNE MUSIC_LOOP
MUSIC_END:
        ;卸载中断处理程序
        CALL UNINSTALL_TIMER

        POP SI
        POP CX
        POP BX
        POP DS
        POP AX
        RETF
MUSIC ENDP

;中断处理程序所在位置
TIMERINT:
        PUSH AX
        PUSH DS

        ;关中断
        CLI
        ;计数
        MOV AX,MUSIC_DATA
        MOV DS,AX
        MOV AH,[TIMER]
        INC AH
        MOV [TIMER],AH
        ;开中断
        STI

        POP DS
        POP AX
        IRET

MUSIC_CODE ENDS
        END