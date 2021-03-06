*****************************************************************************
* 4-Planes-F�llroutine (AUSMASKIERT).                                       *
* Kann f�r 4- und 8-Planeorientierten Screen Routinen erzeugen, wobei die   *
* Version f�r 4 Planescreen deutlich kompakter und schneller ist !          *
*                                                                           *
* HLine 18.1.1993, HLine-Creator 19.1.1993                                  *
* Umarbeitung zu Includefile:    29.1.                                      *
* Letzte Korrektur:               5.3.1994                                  *
* Update:                        23.5.1995 (Routinen f�r 8-Planescreen).    *
*                                                                           *
* Coded by BDC/AURA, alias Jochen der Knaus.                                *
* Coderight (C) AURA-Productions.                                           *
*                                                                           *
*    VERSION:           2.00                                                *
*    UPDATE:            29.1.1993                                           *
*    OPTIMIERUNG:       18.3.1995 (4 Tz / HLine)                            *
*    WICHTIG:           Datencache wird in der HLineroutine AUSgeschalten ! *
*****************************************************************************

FEHLERKOR       EQU     1               ; Fehlerkorrektur (0=an) (ein "bne.s")

SCR_WIDE_M      EQU     320             ; Max. horizontale Aufl�sung
SCR_WIDE        EQU     (320-64)        ; Tats�chliche horiz. Aufl�sung.
PLANES          EQU     8

hl_cache        EQU     $0019           ; Cacheinitialisierungswert.

PMOD            EQU     0               ; 0 : PMOD-File / 1: Includefile.

*****************************************************************************
* Aufruf HLine-F�llroutine.                                                 *
*                                                                           *
* d3 - Planedaten: Plane 4+3                                                *
* d4 - Planedaten: Plane 2+1                                                *
* d7 - Anzahl HLines.                                                       *
*                                                                           *
* a0 - Screenbase                                                           *
* a3 - Offset und Randbitmaptabelle f�r linke Koordinaten.                  *
* a4 -               "                  rechte      "    .                  *
* a5 - Linkes Koordinatenarray.                                             *
* a6 - Rechtes Koordinatenarray.                                            *
*****************************************************************************

        IFEQ    PMOD                            ; Bin�rfile ?
                MC68030
                ORG     0

           IFEQ (PLANES-4)                      ; Ausgabe in 4 Planefile.
                MODUL   "f:\lib\hline4_4.inc"
           ELSE
                MODUL   "f:\lib\hline4_8.inc"   ; Ausgabe in 8 Planefile.
           ENDIF

                bra.w   build_16                ; Routinenaufbau.
                bra.w   calc_r_16               ; Offsettabellen.

                DC.B    'PMOD'                  ; PMOD-Header
           IFEQ (PLANES-4)
                DC.B    'H-FILL 4/4 Pla.',0
           ELSE
                DC.B    'H-FILL 4/8-Pla.',0
           ENDIF
                DC.B    'BDCannibal/AURA',0
                DC.B    '01930595'
                DC.B    '020020--'
                DC.B    '--------'
        ENDIF

*****************************************************************************
* Generierung der Farbroutinen f�r alle 16 Farben (0-15!).                  *
* Routine etwas konfus, aber who cares ???                                  *
* PARAMETER:    a0      - Buffer f�r Routinencode        (16*256 Bytes)     *
*               a1      - Routinenadressen und Farbwerte ( 16*16 Bytes)     *
*                         wird vom Proggy folgenderma�en besetzt:           *
*                         0.l - move_daten Wort 1 und Wort 2                *
*                         4.l -      "        " 3     "    4                *
*                         8.l - Adresse der HLineroutine.                   *
*                        12.l - Nicht belegt (zur Aufstockung auf 16 Bytes) *
*****************************************************************************
build_16:       movem.l d0-a6,-(sp)

                movec   cacr,a2
                pea     (a2)
                moveq   #0,d0
                movec   d0,cacr

                lea     hl_r_tab16(PC),a2       ; HLine-aufbau Tabelle.

                moveq   #15,d7          ; 16 Routs
rout_loop:      move.w  d7,d0           ; Z�hler holen. Wandlung spiegelverk.
                eor.w   #15,d0          ; 16-x = Farbe.
                lea     (a2,d0.w*8),a6  ; Verkn�pfungstabelle dieser Farbe.
                
                moveq   #3,d6           ; konstante Planedaten dieser Farbe.
get_pl_da:      ror.w   #1,d0           ; Bit ins C-Bit schieben.
                bcc.s   clr_pla         ; War Bit gesetzt ?

                move.w  #$ffff,(a1)+    ; diese Plane war gesetzt.
                bra.s   pla_set

clr_pla:        clr.w   (a1)+           ; Plane l�schen.
pla_set:        dbra    d6,get_pl_da    ; n�chste Plane checken.

                move.l  a0,(a1)+        ; Routinenadresse sichern.
                addq.l  #4,a1           ; auf 16 Byte Grenze bringen !

                moveq   #0,d3           ; Offset-Berechnungsfaktor.

                move.w  (a6)+,d0        ; L�nge Verkn�pfungsrout. in Bytes.

                move.l  lea_pc+0(pc),(a0)+
                move.l  lea_pc+4(pc),(a0)+
                move.w  lea_pc+8(PC),(a0)+ ; "move"-Routinenende.
                lea     -2(a0),a5       ; sp�ter kommt noch Offset rein !

                move.w  #$203c,(a0)+    ; "move.l #x,d0", Cache install.
                move.l  #hl_cache,(a0)+
                move.l  s_cache(PC),(a0)+ ; Cache l�schen und anschalten.

                lea     hline_16(PC),a4 ; allgemeine Startroutine.
                moveq   #9-1,d6         ; Gr��e Startrout in W�rtern (-1)
move_start:     move.w  (a4)+,(a0)+
                dbra    d6,move_start

                moveq   #9*2,d3         ; Startroutine.

                move.b  (a4),(a0)+      ; Erste H�lfte des "bgt.s"-Befehls.
                move.b  d0,(a0)         ; L�nge der Verkn�pfungsroutine.

        IFEQ    FEHLERKOR
                addi.b  #14,(a0)+       ; "lea","dbra","rts" und "bne.s"

                addq.l  #2,a4           ; "bne.s" anf�gen, um abzubrechen,
                move.b  (a4),(a0)+      ; falls x2_off > x1_off ! 
                move.b  d0,(a0)
                addq.b  #4,(a0)+
                addq.w  #4,d3
        ELSE
                addi.b  #12,(a0)+       ; "lea","dbra" und "rts"
                addq.w  #2,d3           ; 2 Bytes Rout.
        ENDIF

                move.w  andl_d0d1(PC),(a0)+ ; Shortlinebefs: Beide Randwerte
                move.w  swap_d0(PC),(a0)+   ; miteinander verkn�pfen.
                addq.w  #4,d3           ; nicht den �berblick verlieren.
        
                bsr.w   verkn_d0        ; Vekn�pfungscode f�r d0 einf�gen.
                add.w   d0,d3           ; L�nge Verkn�pfungsrout.

                lea     co_e_s(PC),a3   ; "next line"-Code
                move.w  (a3)+,(a0)+     ; "lea $x(a0),a0"
                addq.w  #4,d3           ; n�chsten Befehl inkl. ! (Offset !)

                move.w  d3,2(a3)
                neg.w   2(a3)           ; Negativer Offset !

                move.l  (a3)+,(a0)+     ; "dbra"
                addq.w  #2,d3           ; Befehl vorher, jetzt noch Off-wort.
                move.w  (a3),(a0)+      ; "rts"
                addq.w  #2,d3

                move.w  swap_d0(PC),(a0)+  ; BIG LINE: linker Randwert.
                addq.w  #2,d3

                bsr.s   verkn_d0        ; Randwert verkn�pfen.
                add.w   d0,d3

        IFNE    (PLANES-4)              ; 8 Planemodus ?
                move.w  addq8(pc),(a0)+ ; Ja --> 4 Planes �bergehen.
                addq.w  #2,d3
        ENDIF

                move.l  s_jmp(PC),(a0)+ ; Startcode f�r aufg. Schleife.
                move.w  s_jmp+4(PC),(a0)+
                addq.w  #6,d3

                move.l  movem(pc),d1            ; move-Code holen.
                moveq   #(SCR_WIDE_M/16-2)-1,d2 ; scr_wide/16 mal diese Seq.
        IFEQ    (PLANES-4)
fill_move:      move.l  d1,(a0)+
                dbra    d2,fill_move
                addi.w  #(SCR_WIDE_M/16-2)*4,d3
        ELSE
                movem.l d0-d3,-(sp)     ; Im 8 Planemode mu� mit Offsets ge-
                move.w  #SCR_WIDE_M-32,d0       ; setzt werden.
                move.w  movel_d(pc),d1
                swap    d1
                move.w  movel_d+4(pc),d3
                swap    d3
fill_move:      move.w  d0,d1           ; Offset.
                move.l  d1,(a0)+        ; 'move.l d3,(d16,a1)'
                subq.w  #4,d0
                move.w  d0,d3           ; Offset.
                move.l  d3,(a0)+        ; 'move.l d4,(d16,a1)'
                subi.w  #12,d0
                dbra    d2,fill_move
                movem.l (sp)+,d0-d3

                move.l  lea_d14(pc),(a0)+       ; Auf rechten Rand gehen.
                addi.w  #(SCR_WIDE_M/16-2)*8+4,d3
        ENDIF

                move.w  d3,(a5)         ; Offset f�r ersten "lea-Befehl"
                addi.w  #12,(a5)        ; "movec"+"movel"  wurden �bergangen.

                move.w  swap_d1(PC),(a0)+ ; rechter Randwert
                addq.w  #2,d3
                bsr.s   verkn_d1        ; Ebenfalls verkn�pfen.
                add.w   d0,d3           ; (Kein addq mehr, da Zeilenende!).

                lea     co_e_s(pc),a3   ; "next line" s.o.
                move.w  (a3)+,(a0)+
                addq.w  #4,d3
                move.w  d3,2(a3)
                neg.w   2(a3)
                move.l  (a3)+,(a0)+
                move.w  (a3)+,(a0)+

                dbra    d7,rout_loop

                move.l  (sp)+,d0
                movec   d0,cacr

                movem.l (sp)+,d0-a6
                rts

*****************************************************************************
* Berechnung der Randmuster und Offset f�r jede Koordinate.                 *
* PARAMETER:    a0      - Arrayadresse linke Offsets/R�nder                 *
*               a1      -       "      rechte       "                       *
*                         (Arraygr��e: SCR_WIDE_M*4 Bytes)                  *
*****************************************************************************
calc_r_16:      movem.l d0-d1/d7,-(sp)

                move.w  #SCR_WIDE_M-1,d7 ; F�r jede Koord ein Wert.
                move.w  #$FFFF,d0       ; Startmaske (x=0)
                moveq   #0,d1           ; Offset.
left_loop:      move.w  d0,(a0)+        ; Maske.
                move.w  d1,(a0)+        ; Offset.

                lsr.w   #1,d0           ; n�chster Status.
                bne.s   no_d_sh1

                move.w  #$FFFF,d0       ; alle 15 Durchg�nge neu anfangen.
                addq.w  #4,d1           ; n�chster Offset.

no_d_sh1:       dbra    d7,left_loop


                move.w  #SCR_WIDE_M-1,d7 ; Offset analog links, Maske bit-
                move.l  #$7fff8000,d0   ; spiegelverkehrt zu links.
                moveq   #0,d1
right_loop:     move.w  d0,(a1)+
                move.w  d1,(a1)+

                ror.l   #1,d0           ; n�chsten Bitstatus.
                bcc.s   no_next_p2      ; durch ?

        IFEQ    (PLANES-4)
                addq.w  #4,d1           ; n�chster Offset.
        ELSE
                addq.w  #8,d1
        ENDIF
                move.l  #$7fff8000,d0   ; Bitstatus zur�ck.

no_next_p2:     dbra    d7,right_loop

                movem.l (sp)+,d0-d1/d7
                rts


; Verkn�pfungscode f�r d0/d1 nach Tabelle erzeugen und in Code schreiben.
; Tab. in a6.
verkn_d0:       movem.l d0/d7/a5/a6,-(sp)
                lea     befs_16(PC),a5  ; mit d0 verkn�pfen, Tab. normal.
                bra.s   s_verk

verkn_d1:       movem.l d0/d7/a5/a6,-(sp)
                lea     befs_16+2(PC),a5        ; mit d1: 1 Befehl Offset !

s_verk:         moveq   #6-1,d7         ; max. 6 Befehle.
get_bef:        move.b  (a6)+,d0        ; Befehlbyte holen.
                bmi.s   vor_end         ; $ff signalisiert vorzeitiges Ende.

                ext.w   d0
                move.w  (a5,d0.w*2),(a0)+ ; Befehl holen und in Code eintr.
                dbra    d7,get_bef

vor_end:        movem.l (sp)+,d0/d7/a5/a6
                rts

swap_d0:        swap    d0
swap_d1:        swap    d1
andl_d0d1:      and.l   d1,d0           ; f�r Shortlines.

movem:          move.l  d3,(a1)+        ; F�r gro�e Verschiebedinge
                move.l  d4,(a1)+
addq8:          addq.l  #8,a1           ; 4 Planes �bergehen (8 Planemode)
movel_d:        move.l  d3,$1234(a1)
                move.l  d4,$4321(a1)
s_cache:        movec   d0,cacr         ; Zum Cache l�schen und starten.

; Allgemeine Startroutine bei allen Routs.
hline_16:       move.w  (a5)+,d0        ; linke Koordinate.             [2 By]
                move.w  (a6)+,d1        ; rechte    "                      [2]
                move.l  (a3,d0.w*4),d0  ; Randbitmap + Offset links  [4]
                move.l  (a4,d1.w*4),d1  ;           "         rechts [4]
                lea     (a0,d0.w*2),a1  ; auf Screenadresse gehen.      [4]

                sub.w   d0,d1           ; L�nge HLine in 16 Pixeln.     [2]
                bgt.s   hline_16        ; Linie l�nger als 16 Pixel !   [2]
                bne.s   hline_16        ; Gegen Fehler !!!

; Code am Ende einer Shortline (8 Bytes).
co_e_s:         adda.l  d5,a0           ; Scanoffset.
dbra:           dbra    d7,dbra         ;                               [4]
                rts                     ;                               [2]

; Um "move"-Routinenende in Register zu haben. Kann nicht �ber JMP(PC,d0.w)
; angesprungen werden, da bei 640 Pixeln Breite die Sache > 128 Bytes ist.
lea_pc:         
        IFEQ    (PLANES-4)              ; Scanoffset 4 Planes.
                move.l  #(SCR_WIDE/2),d5
        ELSE
                move.l  #SCR_WIDE,d5    ; Scanoffset 8 Planes.
        ENDIF           
                lea     0(PC),a2        ;                               [4]

; Code zum Einsprung in die F�llschleife der "inneren"-W�rter. (6 Bytes).
s_jmp:          neg.w   d1              ; R�ckw�rts in Schleife einspringen. [2]
        IFEQ    (PLANES-4)
                jmp     (4.b,a2,d1.w)   ; +4 wegen rechter Randverkn�pfung.  [4]
        ELSE
                jmp     (8.b,a2,d1.w*2)
        ENDIF
lea_d14:        lea     (a1,d1.w*4),a1  ; Auf rechten Rand gehen.

; F�r Verkn�pfungscodeaufbau ben�tigten Befehle. Befehlscode f�r Tabelle:
befs_16:        move.w  d0,d2           ; 0     Zeichnen links: Codes normal,
                move.w  d1,d2           ; 1              rechts: + 1 !!!
                not.w   d0              ; 2
                not.w   d1              ; 3
                not.w   d2              ; 4
                not.w   d2              ; 5     f�r rechte Randverkn�pfung.
                or.w    d0,(a1)+        ; 6 
                or.w    d1,(a1)+        ; 7
                and.w   d0,(a1)+        ; 8
                and.w   d1,(a1)+        ; 9 
                and.w   d2,(a1)+        ; 10
                and.w   d2,(a1)+        ; 11    f�r rechts

; Verkn�pfungscodetabelle:      0.w : L�nge Routine.
;                         2.b - 7.b : Befehle. ($ff=Ende).
hl_r_tab16:     dc.b    0,10            ; Farbe   0: 10 Bytes, nur maskieren.
                dc.b    2,8,8,8,8,$ff
                dc.b    0,10,6,2,8,8,8,$ff      ; 1
                dc.b    0,12,0,4,10,6,10,10     ; 2
                dc.b    0,10,6,6,2,8,8,$ff      ; 3
                dc.b    0,12,0,4,10,10,6,10     ; 4
                dc.b    0,12,0,4,6,10,6,10      ; 5
                dc.b    0,12,0,4,10,6,6,10      ; 6
                dc.b    0,10,6,6,6,2,8,$ff      ; 7
                dc.b    0,12,2,8,8,8,2,6        ; 8   ...,2 (modified !)
                dc.b    0,12,0,4,6,10,10,6      ; 9
                dc.b    0,12,0,4,10,6,10,6      ; 10
                dc.b    0,12,0,4,6,6,10,6       ; 11
                dc.b    0,12,0,4,10,10,6,6      ; 12
                dc.b    0,12,0,4,6,10,6,6       ; 13
                dc.b    0,12,0,4,10,6,6,6       ; 14
                dc.b    0,8,6,6,6,6,$ff,0       ; 15
