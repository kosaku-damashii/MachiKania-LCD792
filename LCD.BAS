WIDTH 40
USECLASS LCD792
USEVAR LCD

LCD=NEW(LCD792)
LCD.INIT()

FOR I=0 TO 15
  CLS
  PRINT "["+HEX$(I*16)+"~"+HEX$(I*16+15)+"]"
  PRINT ""

  P$="0123456789ABCDEF"
  LCD.PRT(0,P$)
  PRINT P$

  P$=""
  FOR J=0 TO 15
    P$=P$+CHR$((I*16)+J)
  NEXT
  LCD.PRT(1,"            ")
  LCD.PRT(1,P$)
  PRINT P$

  WHILE INKEY()=0:WEND
NEXT
END

REM CLASS "LCD792"
OPTION CLASSCODE

METHOD INIT
  VAR C
  I2C 100:REM Set I2C Baudrate 100 KHz
  C=20   :REM Contrast:0~63
  REM Initialize AMQ0802
  I2CWRITE $3E,$00,$14:WAIT 1                    :REM Cursor or display shift
  I2CWRITE $3E,$00,$70 OR (C AND 15):WAIT 1      :REM Contrast
  I2CWRITE $3E,$00,$5C OR (C >> 4 AND 3):WAIT 1  :REM Contrast
  GOSUB _LINE,1
  GOSUB _CLR
  GOSUB _DCTRL,1,0,0
RETURN

METHOD PRT
  REM Print String in line n
  VAR S,C,D,A,I,G,N
  I2CWRITE $3E,0,$80+((ARGS(1) AND 1)<<6):WAIT 1
  G=0
  N=0

  S=ARGS(2)
  WHILE PEEK(S)
    C=PEEK(S)
    IF ((C >= $20) AND (C <= $7D)) OR ((C >= $A0) AND (C <= $DF)) THEN
      I2CWRITE $3E,$40,C:WAIT 1
    ELSE
      D=SYSTEM(103)+2048+8*(16*(C/16)+(C%16))    :REM 6x8 dot font
      I2CWRITE $3E,0,$40+(8*G):WAIT 1
      IF PEEK32(D) OR PEEK32(D+4) THEN
        FOR I=0 TO 7
          A=PEEK(D) >> 3
          I2CWRITE $3E,$40,A:WAIT 1
          D=D+1
        NEXT
        I2CWRITE $3E,0,$80+$40+N:WAIT 1
        I2CWRITE $3E,$40,G:WAIT 1
        G=G+1
      ELSE
        I2CWRITE $3E,0,$80+$40+N:WAIT 1
        I2CWRITE $3E,$40,$20:WAIT 1
      ENDIF
      IF G>=8 THEN G=0
    ENDIF
    N=N+1
    S=S+1
  WEND
RETURN

REM --- Function set

METHOD LINE
  GOSUB _LINE,ARGS(1)
RETURN

LABEL _LINE
  N=ARGS(1) AND 1   :REM N=0:One-line, N=1:Two-line
  I2CWRITE $3E,$00,$30+(N<<3):WAIT 1
RETURN


REM --- Clear display

METHOD CLR
  GOSUB _CLR
RETURN

LABEL _CLR
  I2CWRITE $3E,$00,$01:WAIT 1
RETURN

REM --- Diplay ON/OFF control

METHOD DCTRL
  GOSUB _DCTRL, ARGS(1), ARGS(2), ARGS(3)
RETURN

LABEL _DCTRL
  D=ARGS(1) AND 1   :REM 1:Display on, 0:Display off
  C=ARGS(2) AND 1   :REM 1:Cursor on, 0:Cursor off
  B=ARGS(3) AND 1   :rem 1:Blink on, 0:Blink off
  I2CWRITE $3E,$00,$08 AND (D<<2) AND (C<<1) AND B:WAIT 1
RETURN
