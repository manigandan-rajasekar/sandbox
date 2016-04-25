.model SMALL
.data
EV DB ?
R DB ?
FIND DB 'FIND THE GOLD MINE!$'
THANK DB 'THANK YOU $'
NORMAL DB ' - NORMAL$'
SELECTED DB ' - SELECTED$'
EXPLORED DB ' - EXPLORED$'
EXIT DB 'PRESS ESC TO EXIT$'
WON DB 'YOU WON! YOUR SCORE:$'
INST1 DB 'USE ARROW KEYS TO NAVIGATE$'
INST2 DB 'PRESS SPACE TO SELECT$'
INST3 DB 'YOU ARE IN BOX:$'
GETNAME DB 'CONGRATULATIONS! YOU HAVE MADE A TOP SCORE.YOUR NAME: $'
FNAME DB 'TOPSCORES.TXT',0
HEADER_NAME DB 'NAME$'
HEADER_SCORE DB 'SCORE$'
FOOTER_TEXT1 DB 'TO CLEAR LIST PRESS BACKSPACE$'
FOOTER_TEXT2 DB 'TO PLAY AGAIN PRESS ENTER$'
FOOTER_TEXT3 DB 'TO EXIT PRESS ANY OTHER KEY$'
TOPSCORES_TEXT DB 'TOP SCORES$'
CAUTION_NOTICE DB 'CAUTION',0DH,0AH,0DH,0AH,'   MAX OF TEN CHARACTERS. ENTER ONLY ALPHABETS.',0DH,0AH,0DH,0AH,'   NUMBERS IF ENTERED WILL NOT BE INCLUDED IN THE NAME.',0DH,0AH,0DH,0AH,'   YOU CANNOT EDIT YOUR NAME BECAUSE BACKSPACE AND DELETE DO NOT WORK.$'

NUMBERS DB '1)',0DH,0AH,'2)',0DH,0AH,'3)',0DH,0AH,'4)',0DH,0AH,'5)',0DH,0AH,'6)',0DH,0AH,'7)',0DH,0AH,'8)',0DH,0AH,'9)',0DH,0AH,'10)',0DH,0AH,24h
BUFFER DB ?
BUFFER1 DB 140 DUP ('$')
HANDLE DW ?
WINNER DB 255 DUP ('$')
NOOFCHARS DW ?
EVE DB ?
FLA DB ?
REMAINING DB ?
REST DB ?
RECORDS DB ?
CURRENT_SCORE DB ?
FILE_SCORE DB ?

SCORE DB ?
CROW BYTE ?
CCOL BYTE ?
COLOR BYTE ?
MINE_ROW BYTE ?
MINE_COL BYTE ?
ROW BYTE ?
COL BYTE ?
RED BYTE ?
BLUE BYTE ?
PINK BYTE ?
UP BYTE ?
LEFT BYTE ?
RIGHT BYTE ?
DOWN BYTE ?
ESCAPE BYTE ?
SPACE BYTE ?
BORDER_ROW BYTE ?
BORDER_COL BYTE ?
.CODE

;PRINT MSG
PRINT macro MSG
        pusha
        mov dx,offset MSG
        mov ah,09h
        int 21h
        popa
        endm

CONVERT MACRO SCORE

        PUSHA
        MOV AL,SCORE
        PUSH AX
        MOV AH,0
        AAM
        ADD AH,20H
        CMP AH,20H
        JE DISP1
        ADD AH,10H
DISP1:
        MOV DL,AH
        MOV AH,6
        PUSH AX
        INT 21H
        POP AX
        MOV DL,AL
        ADD DL,30H
        INT 21H

        POP AX
        MOV SCORE,AL
        POPA
        ENDM

;CLEAR SCREEN

CLRSCR MACRO
        PUSHA
        SETCURSOR 1,79
        MOV AH,8
        MOV BH,0
        INT 10H

        MOV BL,BH
        MOV BH,AH
        MOV CX,0
        MOV DX,194FH
        MOV AX,600H
        INT 10H
        POPA
ENDM

;GET CURRENT POSITION
GETCURSOR MACRO ROW,COL
        PUSHA
        MOV AH,03H
        MOV BH,0
        INT 10H
        MOV ROW,DH
        MOV COL,DL
        POPA
ENDM

;SET CURSOR TO ROW,COLUMN
SETCURSOR MACRO ROW,COLUMN
        PUSHA
        MOV AH,02H
        MOV BH,0
        MOV DH,ROW
        MOV DL,COLUMN
        INT 10H
        POPA
        ENDM


BOX_ROW MACRO A
        PUSHA
        MOV AH,9H
        MOV BH,0
        MOV AL,0AH
        MOV BL,A
        MOV CX,5
        INT 10H
        POPA
        ENDM
OUTLINE MACRO
        PUSHA
        MOV AH,9H
        MOV BH,0
        MOV AL,0H
        MOV BL,07H
        MOV CX,5
        INT 10H

        POPA
        ENDM
BOX MACRO A,ROW,COLUMN
        PUSHA
        SETCURSOR ROW,COLUMN
        BOX_ROW A
        SETCURSOR ROW+1,COLUMN
        BOX_ROW A
        POPA
        ENDM

BOX_MEMORY MACRO A,ROW,COLUMN
        PUSHA
        SETCURSOR ROW,COLUMN
        BOX_ROW A
        INC ROW
        SETCURSOR ROW,COLUMN
        BOX_ROW A
        DEC ROW
        POPA
        ENDM

GETCOLOR MACRO ROW,COLUMN

        PUSHA
        MOV AH,02H
        MOV BH,0
        MOV DH,ROW
        MOV DL,COLUMN
        INT 10H

        MOV AH,08H
        MOV BH,0
        INT 10H


        MOV COLOR,AH

        POPA
        ENDM


COMPUTE MACRO


        MOV AX,3
        MUL MINE_ROW
        MOV MINE_ROW,AL
        ADD MINE_ROW,2
        MOV BL,MINE_ROW

        MOV AX,6
        MUL MINE_COL
        MOV MINE_COL,AL
        ADD MINE_COL,2
        MOV BH,MINE_COL

ENDM

RANDOM MACRO
PUSHA

LOOP3:
MOV AH,2CH
INT 21H

;MOV AL,2
;MUL DH
;MOV DH,AL
;SUB DH,56
;JS LOOP3

MOV CL,8
MOV AH,0
MOV AL,DH
DIV CL
MOV MINE_ROW,AL
MOV MINE_COL,AH
POPA
ENDM

PRINTROWCOL MACRO  CROW,CCOL
        PUSHA

        MOV DL,0
        MOV AH,6
        INT 21H

        INC CROW
        MOV AL,CROW
        MOV AH,0
        MOV CL,3
        DIV CL

        MOV AH,6
        MOV DL,AL
        ADD DL,30H
        INT 21H

        DEC CROW

        MOV DL,0
        MOV AH,6
        INT 21H

        MOV DL,58H
        MOV AH,6
        INT 21H

        MOV DL,0
        MOV AH,6
        INT 21H

        MOV AL,CCOL
        MOV AH,0
        MOV CL,6
        DIV CL

        INC AL
        MOV AH,6
        MOV DL,AL
        ADD DL,30H
        INT 21H


        POPA
        ENDM

FILE_OPEN MACRO FNAME,HANDLE
PUSHA

MOV AH,5BH
MOV CX,2H
MOV DX,OFFSET FNAME
INT 21H

MOV AH,3DH
MOV AL,2H
MOV DX,OFFSET FNAME
INT 21H

MOV HANDLE,AX
POPA
ENDM

FILE_WRITE MACRO HANDLE
PUSHA


MOV CX,SI
MOV AH,40H
MOV BX,HANDLE
INT 21H

MOV AL,SCORE
CALL DISP



POPA
ENDM

FWRITE MACRO

PUSHA

MOV CX,2
MOV AH,40H
MOV BX,HANDLE
INT 21H


POPA
ENDM

FILE_CLOSE MACRO HANDLE
PUSHA
MOV AH,3EH
MOV BX,HANDLE
INT 21H
POPA
ENDM

FILE_APPEND MACRO HANDLE
PUSHA
MOV AH,42H
MOV AL,2H
MOV BX,HANDLE
MOV CX,0
MOV DX,0
INT 21H
POPA

ENDM

GETSCOREFROMFILE MACRO CURRENT_SCORE,FILE_SCORE,SCORE
PUSHA

MOV RECORDS,0
FILE_OPEN FNAME,HANDLE

LP1:

MOV AH,3FH
MOV BX,HANDLE
MOV CX,1
LEA DX,buffer
INT 21H

CMP CX,AX
JNE EOF1

mov al, buffer
.IF AL>2FH && AL<3AH
        INC RECORDS

.ENDIF
JMP LP1

EOF1:
FILE_CLOSE HANDLE

MOV AL,RECORDS
MOV CL,2
DIV CL
MOV RECORDS,AL

FILE_OPEN FNAME,HANDLE
MOV EV,0
MOV REMAINING,0
MOV REST,0
MOV FILE_SCORE,0

LP2:

MOV AH,3FH
MOV BX,HANDLE
MOV CX,1
LEA DX,buffer
INT 21H

CMP CX,AX
JNE EOF2

mov al, buffer
        .IF AL>2FH && AL<3AH
                .IF EV==0
                        SUB AL,30H
                        MOV FILE_SCORE,AL
                        MOV AL,10
                        MUL FILE_SCORE
                        MOV FILE_SCORE,AL
                        INC EV
                .ELSE

                        MOV EV,0
                        SUB AL,30H
                        ADD FILE_SCORE,AL
                        MOV AL,FILE_SCORE
                        MOV AH,CURRENT_SCORE
                        INC REMAINING
                        CMP AL,AH
                        JA LP2
                        DEC REMAINING
                        JMP EOF2

                 .ENDIF


        .ENDIF


JMP LP2

EOF2:
FILE_CLOSE HANDLE

.IF REMAINING ==10
JMP OVER1
.ENDIF

FILE_OPEN FNAME,HANDLE

;POSITION FILE POINTER TO READ TEXT INTO BUFFER

MOV AL,15
MUL REMAINING
MOV DX,AX
MOV AH,42H
MOV AL,0
MOV BX,HANDLE
MOV CX,0
INT 21H

;READ INTO A BUFFER

MOV AL,RECORDS
MOV AH,REMAINING
SUB AL,AH
MOV REST,AL
;NEW CODE

.IF RECORDS == 10
       SUB REST,1
.ENDIF

MOV AL,15
MUL REST
MOV CX,AX


MOV AH,3FH
MOV BX,HANDLE
LEA DX,BUFFER

INT 21H

FILE_CLOSE HANDLE

;PUT CURRENT SCORE

FILE_OPEN FNAME,HANDLE


MOV AL,15
MUL REMAINING
MOV DX,AX

MOV AH,42H
MOV AL,0
MOV BX,HANDLE
MOV CX,0
INT 21H

PUTINFILE SCORE

MOV AL,15
MUL REST
MOV CX,AX
MOV AH,40H
MOV BX,HANDLE
LEA DX,BUFFER
INT 21H

FILE_CLOSE HANDLE
OVER1:
POPA
ENDM



PUTINFILE1 MACRO SCORE

PUSHA

MOV ROW,12
MOV COL,60
SETCURSOR 12,60
MOV SI,0

.REPEAT

WRONGCHAR1:
SETCURSOR ROW,COL
mov ah,1
int 21h
.IF (AL>40H && AL< 5BH)||(AL>60H && AL< 7BH)||AL==0DH
        INC COL
.ELSE


        JMP WRONGCHAR1

.ENDIF

mov WINNER[SI],al
INC SI
.IF AL==0DH

.REPEAT
mov WINNER[SI],al
INC SI
.UNTIL SI==11

.ENDIF

.UNTIL SI>=10


mov dx,offset WINNER



FILE_WRITE HANDLE
POPA

ENDM

PUTINFILE MACRO SCORE
PUSHA

MOV ROW,12
MOV COL,60
SETCURSOR 12,60
MOV SI,0

.REPEAT

WRONGCHAR:
SETCURSOR ROW,COL
mov ah,1
int 21h
.IF (AL>40H && AL< 5BH)||(AL>60H && AL< 7BH)||AL==0DH
        INC COL
.ELSE


        JMP WRONGCHAR

.ENDIF

mov WINNER[SI],al
INC SI
.IF AL==0DH

.REPEAT
mov WINNER[SI],al
INC SI
.UNTIL SI==11

.ENDIF

.UNTIL SI>=10


mov dx,offset WINNER



FILE_WRITE HANDLE
POPA

ENDM


GETFROMFILE MACRO ROW,COL
SETCURSOR 1,25
PRINT TOPSCORES_TEXT
SETCURSOR 5,0
PRINT NUMBERS
FILE_OPEN FNAME,HANDLE
MOV EV,0
LP: mov ah,3fh ;Read data from the file
lea dx, Buffer ;Address of data buffer
mov cx, 1 ;Read one byte
mov bx, HANDLE ;Get file handle value
int 21h
cmp ax, cx ;EOF reached?
jne EOF
mov al, Buffer ;Get character read

.IF AL==0DH

        JMP LP
.ELSE
        ;SETCURSOR ROW,3

        ;PUSH AX

        ;MOV AH,02H

        ;MOV DL,COUNTER
        ;INC COUNTER
        ;INT 21H
        ;POP AX


        .IF (AL>40H && AL< 5BH)||(AL>60H && AL< 7BH)

        SETCURSOR ROW,COL
        call putc ;Print it
        INC COL

        .ELSE

                .IF(AL>2FH && AL<3AH)
                        .IF EVE==0
                        MOV COL,50
                        .ENDIF
                        SETCURSOR ROW,COL
                        CALL PUTC
                        MOV FILE_SCORE,AL
                        INC FILE_SCORE
                        INC COL
                        .IF EVE!=0
                            MOV COL,3
                        .ENDIF
                .ELSE
                        .IF EVE==0
                                INC EVE
                        .ELSE
                                DEC EVE
                                INC ROW
                        .ENDIF

                .ENDIF

        .ENDIF
.ENDIF



jmp LP ;Read next byte

EOF: mov bx,HANDLE
FILE_CLOSE HANDLE
ENDM


.STARTUP

PLAYAGAIN:
MOV NOOFCHARS,0
;COLOR VALUES

        MOV RED,44H
        MOV BLUE,11H
        MOV PINK,55H

;ROWVALUES

        MOV CROW,2
        MOV CCOL,2
        MOV MINE_ROW,2
        MOV MINE_COL,2
        MOV FILE_SCORE,0
        ;GENERATING RANDOM VALUE FOR ROW AND COLUMN OF MINE
        RANDOM
        ;CONVERTING INTO WHICH BRICK IT LIES
        COMPUTE

        MOV EVE,0
;KEYVALUES

        MOV ESCAPE,1BH
        MOV UP,48H
        MOV LEFT,4BH
        MOV RIGHT,4DH
        MOV DOWN,50H
        MOV SPACE,20H

        MOV SCORE,65
        MOV CURRENT_SCORE,0
        MOV FILE_SCORE,0

;SETTING SCREEN VIDEO MODE TO 03H

        MOV AH,0
        MOV AL,3H
        INT 10H

CLRSCR
;OUTLINE PRINTING

;MAP PRINTING

.REPEAT
 MOV CCOL,2
.REPEAT
BOX_MEMORY BLUE,CROW,CCOL
ADD CCOL,6
.UNTIL (CCOL==50)
ADD CROW,3
.UNTIL (CROW==26)
MOV CROW,2
MOV CCOL,2
BOX_MEMORY RED,CROW,CCOL
;NAME AND OTHERS PRINTING

        SETCURSOR 2,52
        PRINT FIND

        MOV BORDER_ROW,3
        MOV BORDER_COL,51
        .REPEAT
        SETCURSOR BORDER_ROW,BORDER_COL
        OUTLINE
        INC BORDER_COL
        .UNTIL BORDER_COL==70


        BOX BLUE,5,53
        SETCURSOR 5,58
        PRINT NORMAL

        BOX RED,8,53
        SETCURSOR 8,58
        PRINT SELECTED

        BOX PINK,11,53
        SETCURSOR 11,58
        PRINT EXPLORED

        SETCURSOR 15,52
        PRINT EXIT

        SETCURSOR 17,52
        PRINT INST1

        SETCURSOR 19,52
        PRINT INST2



;KEY CHECK


LOOP1:  ;BLINK CROW,CCOL

        SETCURSOR 21,52
        PRINT INST3
        PRINTROWCOL CROW,CCOL

        MOV AH,07H
        INT 21H
        .IF AL!=LEFT && AL!=ESCAPE && AL!=RIGHT && AL!=UP && AL!=DOWN && AL!=SPACE
                JMP LOOP1
        .ELSE
                .IF AL==ESCAPE
            CLRSCR
                        SETCURSOR 12,40
                        PRINT THANK
            JMP EX
                .ENDIF


                .IF AL==RIGHT
                        GETCOLOR CROW,CCOL
                        .IF COLOR==44H ;RED
                                BOX_MEMORY BLUE,CROW,CCOL

                        .ENDIF
                        .IF CCOL==44
                                MOV CCOL,-4
                        .ENDIF


                        ADD CCOL,6
                        GETCOLOR CROW,CCOL
                        .IF COLOR==11H ;BLUE
                                BOX_MEMORY RED,CROW,CCOL
                        .ELSE
                                BOX_MEMORY PINK,CROW,CCOL
                        .ENDIF
                        JMP LOOP1

                .ENDIF
                .IF AL==DOWN
                        GETCOLOR CROW,CCOL
                        .IF COLOR==44H ;RED
                                BOX_MEMORY BLUE,CROW,CCOL

                        .ENDIF
                        .IF CROW==23
                                MOV CROW,-1
                        .ENDIF


                        ADD CROW,3
                        GETCOLOR CROW,CCOL
                        .IF COLOR==11H ;BLUE
                                BOX_MEMORY RED,CROW,CCOL
                        .ELSE
                                BOX_MEMORY PINK,CROW,CCOL
                        .ENDIF
                        JMP LOOP1

                .ENDIF

                .IF AL==LEFT
                        GETCOLOR CROW,CCOL
                        .IF COLOR==44H ;RED
                                BOX_MEMORY BLUE,CROW,CCOL

                        .ENDIF
                        .IF CCOL==2
                                MOV CCOL,50
                        .ENDIF


                        SUB CCOL,6
                        GETCOLOR CROW,CCOL
                        .IF COLOR==11H ;BLUE
                                BOX_MEMORY RED,CROW,CCOL
                        .ELSE
                                BOX_MEMORY PINK,CROW,CCOL
                        .ENDIF
                        JMP LOOP1

                .ENDIF
                .IF AL==UP
                        GETCOLOR CROW,CCOL
                        .IF COLOR==44H ;RED
                                BOX_MEMORY BLUE,CROW,CCOL

                        .ENDIF
                        .IF CROW==2
                                MOV CROW,26
                        .ENDIF


                        SUB CROW,3
                        GETCOLOR CROW,CCOL
                        .IF COLOR==11H ;BLUE
                                BOX_MEMORY RED,CROW,CCOL
                        .ELSE
                                BOX_MEMORY PINK,CROW,CCOL
                        .ENDIF
                        JMP LOOP1

                .ENDIF


                .IF AL==SPACE
                        DEC SCORE
                        PUSH AX
                        MOV AL,SCORE
                        MOV CURRENT_SCORE,AL
                        POP AX
                        .IF BL==CROW && BH==CCOL



                              BOX_MEMORY 66H,CROW,CCOL
                              SETCURSOR 12,40
                              MOV CROW,11
                              MOV CCOL,2

                              .REPEAT
                              MOV CCOL,2
                              .REPEAT
                              BOX_MEMORY 00H,CROW,CCOL
                              ADD CCOL,6
                              .UNTIL CCOL==50
                              ADD CROW,3
                              .UNTIL CROW==17

                              SETCURSOR 13,15
                              PRINT WON
                              CONVERT SCORE

                              MOV AH,07H
                              INT 21H

                              CLRSCR
                              ;SETCURSOR 3,3
                              ;GETSCOREFROMFILE CURRENT_SCORE,FILE_SCORE,SCORE
                              SETCURSOR 16,40
                              PRINT CAUTION_NOTICE

                              SETCURSOR 12,5
                              PRINT GETNAME

                              GETSCOREFROMFILE CURRENT_SCORE,FILE_SCORE,SCORE
                              ;FILE_OPEN FNAME,HANDLE
                              ;FILE_APPEND HANDLE

                              ;PUTINFILE SCORE




                        .ELSE
                        GETCOLOR CROW,CCOL
                                .IF COLOR==55H
                                        INC SCORE
                                .ENDIF
                        BOX_MEMORY PINK,CROW,CCOL

                        JMP LOOP1
                        .ENDIF

                .ENDIF

        .ENDIF
 EX:
 CLRSCR
 SETCURSOR 3,3
 PRINT HEADER_NAME
 SETCURSOR 3,49
 PRINT HEADER_SCORE
 SETCURSOR 20,2
 PRINT FOOTER_TEXT1
 SETCURSOR 20,40
 PRINT FOOTER_TEXT2
 SETCURSOR 22,20
 PRINT FOOTER_TEXT3

 SETCURSOR 4,4
 MOV CROW,5
 MOV CCOL,3
 GETFROMFILE CROW,CCOL
 MOV AH,07H
 INT 21H
 .IF AL==0DH
        JMP PLAYAGAIN
 .ENDIF
 .IF AL==8H
        MOV AH,41H
        MOV DX,OFFSET FNAME
        INT 21H
        JMP PLAYAGAIN
 .ENDIF
;CLEAR SCREEN
        CLRSCR
 SETCURSOR 12,22


 PRINT THANK
 PRINT WINNER





 MOV AH,07H
 INT 21H

CLRSCR
.EXIT
DISP PROC NEAR
         PUSH DX
         MOV AH,0
         AAM
         ADD AH,20H
         JE DISPLA1
         ADD AH,10H
         DISPLA1:

         MOV SCORE,AH
         MOV DX,OFFSET SCORE

         FWRITE


         MOV DL,AL
         ADD DL,30H
         MOV SCORE,DL

         MOV DX,OFFSET SCORE
         FWRITE
         POP DX

         RET
DISP ENDP

putc proc near

mov dl,al
mov ah,2
int 21h

ret
putc endp

END
