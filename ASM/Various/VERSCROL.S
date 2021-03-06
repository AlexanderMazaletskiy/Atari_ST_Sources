; VERSCROL.S
; 1988.04.15.
; This stuff was programmed at night by Dr Krall.
; You are allowed to use the routines included in
; the listing only if you are one of the big boys
; in the Magic Hackers.

; Setblock as usual.

 MOVE.L A7,A5
 MOVE.L 4(A5),A5
 MOVE.L $C(A5),D0
 ADD.L $14(A5),D0
 ADD.L $1C(A5),D0
 ADD.L #$1100,D0
 MOVE.L A5,D1
 ADD.L D0,D1
 AND.L #-2,D1
 MOVE.L D1,A7
 MOVE.L D0,-(SP)
 MOVE.L A5,-(SP)
 MOVE.W D0,-(SP)
 MOVE.W #$4A,-(SP)
 TRAP #1
 ADD.L #12,SP

; Set up some kreegah graphics:

 MOVE.W #4,-(SP)
 TRAP #14
 ADDQ.L #2,SP
 CMPI.W #2,D0
 BEQ TERM
 MOVE.W D0,REZ
 DC.W $A000
 DC.W $A00A
 MOVE.W #0,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.W #5,-(SP)
 TRAP #14
 ADD.L #12,SP
 CLR.L -(SP)
 MOVE.W #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SUPER
 MOVE.W #2,-(SP)
 TRAP #14
 ADDQ.L #2,SP
 MOVE.L D0,SCREEN
 MOVE.L $FF8240,-(SP)
 MOVE.W #$000,$FF8240
 MOVE.W #$777,$FF8242

; The very program begins here.

RESTART:
 MOVE.L #MESSAGE,A0      ; Load start addr. of text into A0.
MAIN:
 MOVE.B (A0),D0          ; Read current character via (A0) into D0.
 CMPI.B #0,D0            ; 0 indicates end of text.
 BEQ RESTART
 MOVE.B D0,CHAR          ; Put character into CHAR, which is within
                         ; the output buffer form printing.
 MOVE.L #OUTPUT,-(SP)    ; PRINT output buffer on screen,
 MOVE.W #9,-(SP)         ; only a single character actually.
 TRAP #1
 ADDQ.L #6,SP
 ADDQ.L #1,A0            ; Increase text pointer.
 MOVE.L A0,-(SP)         ; Save text pointer. (A0 is needed.)
; This widens the text to double-width.
 MOVE.L SCREEN,A0        ; Load start addr. of screen into A0.
 ADD.L #24*8*160+8,A0    ; Add on offset.
 MOVE.L #7,D0            ; 8 lines to be widened.
SIZELOOP:
 CLR.L D1                ; Clear read register (D1).
 CLR.L D2                ; Clear wide register (D2).
 MOVE.W (A0),D1          ; Read current word into D1.
 BTST #0,D1              ; Text pixel #0 (rightmost).
 BEQ.S NO0               ; Not set, skip.
 ORI.W #%0000000000000011,D2   ; Set bits (double) in wide register.
NO0:                           ; The following lines are similar as
 BTST #1,D1                    ; for bit #0.
 BEQ.S NO1
 ORI.W #%0000000000001100,D2
NO1:
 BTST #2,D1
 BEQ.S NO2
 ORI.W #%0000000000110000,D2
NO2:
 BTST #3,D1
 BEQ.S NO3
 ORI.W #%0000000011000000,D2
NO3:
 BTST #4,D1
 BEQ.S NO4
 ORI.W #%0000001100000000,D2
NO4:
 BTST #5,D1
 BEQ.S NO5
 ORI.W #%0000110000000000,D2
NO5:
 BTST #6,D1
 BEQ.S NO6
 ORI.W #%0011000000000000,D2
NO6:
 BTST #7,D1
 BEQ.S NO7
 ORI.W #%1100000000000000,D2
NO7:
 MOVE.W D2,(A0)             ; Now write widened value to screen.
 ADD.L #160,A0              ; Step A0 down to next line on screen.
 DBRA D0,SIZELOOP           ; Until all 8 lines in char. widened.
; And this one is about to give it a nice height.
; It puts some words on the stack for later use.
 MOVE.L SCREEN,A0            ; Load screen addr. into A0.
 ADD.L #24*8*160+7*160+8,A0  ; Add offset.
 MOVE.L #7,D0                ; 8 lines (normal character height)
GETIT:
 MOVE.W (A0),-(SP)           ; Put a line of the char. on stack.
 MOVE.W (A0),-(SP)           ; Again.
                             ; Please note that we now have pushed
                             ; the same word twice on stack. Later
                             ; when the draw routine pulls words
                             ; from stack, it will have to pull twice
                             ; as many words as there really are lines
                             ; in a normal char., and so the char.
                             ; will be double-height on screen.
 CLR.W (A0)                  ; Erase normal character line.
                             ; (We don't want the normal size char.
                             ; remaining on screen after that we have
                             ; pushed its data on the stack.)
 SUB.L #160,A0               ; Step up one screen line.
                             ; (It is being read backwards.)
 DBRA D0,GETIT               ; Until all character lines (words) are
                             ; read and double-pushed on stack.

; This is the vertical scrolling routine:

 MOVE.L #15,D1               ; Scroll 16 lines before next char.
SCROLLMAIN:
 MOVE.L SCREEN,A0            ; Load A0 with screen start addr.
 ADD.L #24*8*160+7*160,A0    ; Add offset.
 MOVE.W (SP)+,(A0)           ; Pull word from stack to screen.
 MOVE.L $466,D0              ; Wait for vertical sync. Same as a call
WVBL:                        ; of XBIOS #37, but using the method
 CMP.L $466,D0               ; shown here, we will keep control of
 BEQ WVBL                    ; all registers are being affected.
 MOVE.L SCREEN,A0            ; Load A0 with screen start addr.
 MOVE.L #199,D0              ; 200 lines to be scrolled vertically.
SCROLL:
 MOVE.W 160(A0),D2           ; Move graphics word from a line ahead of
                             ; pointer (A0) and store it in D2.
                             ; (Offset 160 means a line ahead.)
 MOVE.W D2,0*8(A0)           ; Put D2 value into current address.
; The following MOVE.W operations causes the vast amount of identical
; vertical scrollines being shown on screen.
; 0*8(A0) (above) handles the leftmost 16 pixels.
; 2*8(A0) (below) handles the next 16 pixels, and so on.
; Every MOVE.W corresponds to one of the 'bars' of scrolling text.
 MOVE.W D2,2*8(A0)
 MOVE.W D2,4*8(A0)
 MOVE.W D2,6*8(A0)
 MOVE.W D2,8*8(A0)
 MOVE.W D2,10*8(A0)
 MOVE.W D2,12*8(A0)
 MOVE.W D2,14*8(A0)
 MOVE.W D2,16*8(A0)
 MOVE.W D2,18*8(A0)
;
 ADD.L #160,A0         ; Next screen line.
 DBRA D0,SCROLL        ; Until 200 times, that is, the whole screen.
 DBRA D1,SCROLLMAIN    ; Until 16 lines scrolled.
 MOVE.W #$B,-(SP)      ; Examine keyboard.
 TRAP #1
 ADDQ.L #2,SP
 CMPI.W #$FFFF,D0
 BEQ LEAVE            ; A keypress quits.
 MOVE.L (SP)+,A0      ; Now restore the textpointer that was saved
                      ; on the stack quite a long time ago.
 BRA MAIN             ; Over and over.
;
; Some important comment instructions.
 NEG.W (A2)
 MOVEA.L A3,A0
 ADDQ.W #1,D1
 DC.W $4C4C
; It is over, yeah.
; Bring it back to life.
LEAVE:
 MOVE.W REZ,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.W #5,-(SP)
 TRAP #14
 ADD.L #12,SP
 DC.W $A009
 MOVE.L (SP)+,A0     ; Correct stack, or else last textpointer pushed
                     ; on stack will stay there forever. That wouldn't
                     ; be nice, would it? Never mind about A0.
 MOVE.L (SP)+,$FF8240
 MOVE.L SUPER,-(SP)
 MOVE.W #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP
TERM:
 CLR.W -(SP)
 TRAP #1

 ALIGN

SUPER: DC.L 0
SCREEN: DC.L 0
REZ: DC.W 0
OUTPUT: DC.B 27,'Y',32+24,32+3,27,'b',1
CHAR: DC.B '?',0
MESSAGE:
 DC.B 'Dr Krall says: '
 DC.B 'What about some vertical scrolling?   '
 DC.B 'Would that really do it?     '
 DC.B 'Leave some pixels on the screen...   '
 DC.B 'If you start to feel bored, just hit a key.    '
 DC.B 'The text will now start over.           ',0

 END

 