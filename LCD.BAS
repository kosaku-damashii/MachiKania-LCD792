USECLASS LCD792
USEVAR LCD

LCD=NEW(LCD792)
LCD.INILCD()

FOR I=0 TO 15
  CLS
  PRINT "["+HEX$(I*16)+"~"+HEX$(I*16+15)+"]"
  PRINT ""

  P$="0123456789ABCDEF"
  LCD.PRTLCD(0,P$)
  PRINT P$

  P$=""
  FOR J=0 TO 15
    P$=P$+CHR$((I*16)+J)
  NEXT
  LCD.PRTLCD(1,"            ")
  LCD.PRTLCD(1,P$)
  PRINT P$

  WHILE INKEY()=0:WEND
NEXT
END

REM CLASS "LCD792"
OPTION CLASSCODE

METHOD INILCD
 I2C 100:REM Set I2C Baudrate 100 KHz
 C=20   :REM Contrast:0~63
 REM Initialize AMQ0802
REM I2CWRITE $3E,$00,$38:WAIT 1
REM I2CWRITE $3E,$00,$39:WAIT 1
 I2CWRITE $3E,$00,$14:WAIT 1                    :REM Cursor or display shift
 I2CWRITE $3E,$00,$70 OR (C AND 15):WAIT 1      :REM Contrast
 I2CWRITE $3E,$00,$5C OR (C >> 4 AND 3):WAIT 1  :REM Contrast
REM I2CWRITE $3E,$00,$6C:WAIT 15
 I2CWRITE $3E,$00,$38:WAIT 1                    :REM 2 line
 I2CWRITE $3E,$00,$01:WAIT 1                    :REM Clear display
 I2CWRITE $3E,$00,$0C:WAIT 1                    :REM Diplay ON/OFF control
RETURN

METHOD PRTLCD
 REM Print String in line n
 VAR S
 I2CWRITE $3E,0,$80+((ARGS(1) AND 1)<<6):WAIT 1
 S=ARGS(2)
 WHILE PEEK(S)
  I2CWRITE $3E,$40,PEEK(S):WAIT 1
  S=S+1
 WEND
RETURN

METHOD CLRLCD
  I2CWRITE $3E,$00,$01:WAIT 1
RETURN