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

REM === CLASS "LCD792" ====
OPTION CLASSCODE

METHOD INIT
  VAR M
  I2C 100   :REM Set I2C Baudrate 100 KHz
  M=ARGS(-2)
  CALL M.SHIFT(0,1)   :REM Shift cursor to the right
  CALL M.CTRST(10)    :REM Contrast:0~63
  CALL M.CLINE(1)     :REM 2 lines
  CALL M.CLR()        :REM Cleasr display
  CALL M.DCTRL(1,0,0) :REM Disp:ON,Cursor:OFF,Blink:OFF
RETURN

REM --- Print String in line n
METHOD PRT
  VAR S,C,D,A,I,G,N,M
  G=0
  N=0
  S=ARGS(2)
  M=ARGS(-2)
  WHILE PEEK(S)
    C=PEEK(S)
    IF ((C >= $20) AND (C <= $7D)) OR ((C >= $A0) AND (C <= $DF)) THEN
      CALL M.PUTC(ARGS(1),N,C)
    ELSE
      D=SYSTEM(103)+2048+8*(16*(C/16)+(C%16))    :REM 6x8 dot font
      IF PEEK32(D) OR PEEK32(D+4) THEN
        CALL M.SETD(D,G)
        CALL M.PUTC(ARGS(1),N,G)
        G=G+1
      ELSE
        CALL M.PUTC(ARGS(1),N,$20)
      ENDIF
      IF G>=8 THEN G=0
    ENDIF
    N=N+1
    S=S+1
  WEND
RETURN

REM --- Set a character data 
METHOD SETD
  VAR D,G,A 
  D=ARGS(1)         :REM Font data top sddress
  G=ARGS(2)         :REM fONT number (0-7)
  I2CWRITE $3E,0,$40+(8*G):WAIT 1
  FOR I=0 TO 7
    A=PEEK(D) >> 3
    I2CWRITE $3E,$40,A:WAIT 1
    D=D+1
  NEXT
RETURN

REM --- Print a character 
METHOD PUTC
  VAR L,C,D
  L=ARGS(1) AND 1   :REM Line
  C=ARGS(2)         :REM Column
  D=ARGS(3)         :REM Char data
  I2CWRITE $3E,0,$80+(L<<6)+C:WAIT 1
  I2CWRITE $3E,$40,D:WAIT 1
RETURN

REM --- Cursor or display shift
METHOD SHIFT
  USEVAR S_C,R_L
  VAR S_C,R_L
  S_C=ARGS(1) AND 1
  R_L=ARGS(2) AND 1
  I2CWRITE $3E,$00,$10+(S_C<<3)+(R_L<<2):WAIT 1
RETURN

REM --- Function set
METHOD CLINE
  VAR N
  N=ARGS(1) AND 1   :REM N=0:One-line, N=1:Two-line
  I2CWRITE $3E,$00,$30+(N<<3):WAIT 1
RETURN


REM --- Clear display
METHOD CLR
  I2CWRITE $3E,$00,$01:WAIT 1
RETURN

REM --- Diplay ON/OFF control
METHOD DCTRL
  VAR D,C,B
  D=ARGS(1) AND 1   :REM 1:Display on, 0:Display off
  C=ARGS(2) AND 1   :REM 1:Cursor on, 0:Cursor off
  B=ARGS(3) AND 1   :REM 1:Blink on, 0:Blink off
  I2CWRITE $3E,$00,$08+(D<<2)+(C<<1)+B:WAIT 1
RETURN

REM --- Contrast
METHOD CTRST
  VAR C
  C=ARGS(1)   :REM Contrast
  I2CWRITE $3E,$00,$70 OR (C AND $0F):WAIT 1
  I2CWRITE $3E,$00,$5C OR (C >> 4 AND 3):WAIT 1
RETURN
