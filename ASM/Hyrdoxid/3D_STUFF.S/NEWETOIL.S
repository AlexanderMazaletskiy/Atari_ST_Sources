*****************************
*      3D CALCUL ROUTINE    *	
*      	    by		    *	
*     Cristalion/Hydroxid   *
*****************************

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	BSR	INITS
	BSR	INIT_RAST 
	MOVE.L	#TIMER,$4D2
 	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	MAKE_YTABLE
	BSR	CLR_REGISTERS
	MOVE.W	#0,$FFFF8240
	MOVE.W	#$FFF,$FFFF8242
	MOVE.L	#TIMER,$4D2
	lea.l colors,a0
	lea.l $FFFF9800,a1
	move.l (a0),4(a1)
	move.l (a0),8(a1)
	move.l (a0),16(a1)
	move.l (a0)+,32(a1)
	move.l (a0),12(a1)
	move.l (a0),20(a1)
	move.l (a0),24(a1)
	move.l (a0),36(a1)
	move.l (a0),40(a1)
	move.l (a0),44(a1)
	move.l (a0)+,48(a1)
	move.l (a0),28(a1)
	move.l (a0),52(a1)
	move.l (a0)+,56(a1)
	move.l (a0),60(a1)

LOOP
	MOVE.L	#$00500070,$FFFF9800
	BSR	READ_CURVE
	CMPI.W	#0,ZDEP
	BGT.S	STOP_ZOOM
	ADDQ.W	#8,ZDEP
STOP_ZOOM
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT1
	MOVE.L	#$FF000000,$FFFF9800
NO_ALt1
	BSR	EFFA
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT2
	MOVE.L	#$00FF0000,$FFFF9800
NO_ALT2
	BSR	MAKE_CUBE
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT3
	MOVE.L	#$FFFF00FF,$FFFF9800
NO_ALT3
	BSR	TRACE_LIGNE
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	addq.l #2,affecr
	move.w affecr+2,d0
	andi.w #8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s trainee			; on boucle
 	sub.w #8,affecr+2
trainee
	MOVEM.L	(SP)+,A1-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$00FF,$FFFF9800
NO_ALT
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
	BRA	SORTIE
*********************
MAKE_CUBE
*	ADD.W	#4,X_ANGLE1
*	CMPI.W	#720,X_ANGLE1
*	BLT.S	NO_STOP
*	CLR.W	X_ANGLE1
*NO_STOP
	ADD.W	#2,Y_ANGLE1
	CMPI.W	#720,Y_ANGLE1
	BLT.S	NO_STOP2
	CLR.W	Y_ANGLE1
NO_STOP2
	ADD.W	#2,Z_ANGLE1
	CMPI.W	#720,Z_ANGLE1
	BLT.S	NO_STOP3
	CLR.W	Z_ANGLE1
NO_STOP3
	MOVE.W	X_ANGLE1,X_ANGLE
	MOVE.W	Y_ANGLE1,Y_ANGLE
	MOVE.W	Z_ANGLE1,Z_ANGLE
	BSR	TRIGO
	MOVE.W	XE1,XE
	MOVE.W	YE1,YE
	MOVE.W	ZE1,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX
	MOVE.W	YP,DY
;
	MOVE.W	XE2,XE
	MOVE.W	YE2,YE
	MOVE.W	ZE2,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+2
	MOVE.W	YP,DY+2
;
	MOVE.W	XE3,XE
	MOVE.W	YE3,YE
	MOVE.W	ZE3,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+4
	MOVE.W	YP,DY+4
;
	MOVE.W	XE4,XE
	MOVE.W	YE4,YE
	MOVE.W	ZE4,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+6
	MOVE.W	YP,DY+6
;
	MOVE.W	XE5,XE
	MOVE.W	YE5,YE
	MOVE.W	ZE5,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+8
	MOVE.W	YP,DY+8
;
	MOVE.W	XE6,XE
	MOVE.W	YE6,YE
	MOVE.W	ZE6,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+10
	MOVE.W	YP,DY+10
;
	MOVE.W	XE7,XE
	MOVE.W	YE7,YE
	MOVE.W	ZE7,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+12
	MOVE.W	YP,DY+12
;
	MOVE.W	XE8,XE
	MOVE.W	YE8,YE
	MOVE.W	ZE8,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+14
	MOVE.W	YP,DY+14
;
	MOVE.W	XE9,XE
	MOVE.W	YE9,YE
	MOVE.W	ZE9,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+16
	MOVE.W	YP,DY+16
;
	MOVE.W	XE10,XE
	MOVE.W	YE10,YE
	MOVE.W	ZE10,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+18
	MOVE.W	YP,DY+18
;
	MOVE.W	XE11,XE
	MOVE.W	YE11,YE
	MOVE.W	ZE11,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+20
	MOVE.W	YP,DY+20
;
	MOVE.W	XE12,XE
	MOVE.W	YE12,YE
	MOVE.W	ZE12,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+22
	MOVE.W	YP,DY+22
;
	MOVE.W	XE13,XE
	MOVE.W	YE13,YE
	MOVE.W	ZE13,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+24
	MOVE.W	YP,DY+24
;
	MOVE.W	XE14,XE
	MOVE.W	YE14,YE
	MOVE.W	ZE14,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+26
	MOVE.W	YP,DY+26
	RTS
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
INITS
*	MOVEC	CACR,D0			
*	MOVE.L	D0,OLD_CACR
*	MOVE.L	#$3111,D0		; cache on ... 
*	MOVEC	D0,CACR			

	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE	

	MOVE.L	#SCREEN,D0	
	ADD.L	#10000,D0
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,SCREEN_ADD

;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000001100010,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	add.l	 #46080,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	RTS

*******************************SOUS ROUTINES*****************************************
READ_CURVE
	LEA	CURVE,A2
	ADDQ.W	#2,CURVE_COMPT
	CMPI.W	#2880,CURVE_COMPT
	BLT.S	NO_D
	CLR	CURVE_COMPT
NO_D
	MOVE.W	CURVE_COMPT,D1	
	MOVE.W	(A2,D1.W),XADD
	LEA	2880(A2),A2
	MOVE.W	(A2,D1.W),YADD
	RTS
TIMER
	MOVE.L	#TIMER_B1,$120.W
	MOVE.B	#180,$FFFFFA21.W
	MOVE.B	#8,$FFFFA1B
	RTS
TIMER_B1	
	MOVE.W	#$2700,SR
	MOVE.L	#$00400050,$FFFF9800
	CLR.B	$FFFFA21	
	CLR.B	$FFFFA1B
	BCLR	#0,$FFFFFA0F.W	
	MOVE.W	#$2300,SR	
	RTE

INIT_RAST:
	move.l	$120.W,SAVE_HBL
	move.b	$ffffa1b,SAVE_A1B
	move.b	$ffffa09,SAVE_A09
	move.b	$ffffa21,SAVE_A21
	move.b	$ffffa07,SAVE_A07
	move.b	$ffffa13,SAVE_A13
	
	and.b	#$40,$fffa09
	or.b	#1,$fffa07
	or.b	#1,$fffa13	
	RTS
******************************LA ROUTINE D'EFFACAGE PLAN1**********************
EFFA
	MOVEM.L	D0/A1,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	ADD.W	#0,A1
	MOVEQ	#0,D0
	MOVE.W	#239,D1
.EFF
OXO	SET	0
	REPT	24
	MOVE.W	D0,OXO(A1)
OXO	SET	OXO+8
	ENDR
	LEA	192(A1),a1
	DBF	D1,.EFF
	MOVEM.L	(SP)+,D0/A1
	RTS
VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
CLS
	MOVEM.L	D0/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	move.l workecr,a1
	MOVE.W	#7999,D0
OK
	MOVE.L	#0,(A0)+
	move.l #0,(a1)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d6/a0-a6
	rts
MAKE_YTABLE
	LEA	Y_TABLE,A1
	MOVE.B	#250,D1
	MOVEQ.L	#0,D2
MAKE
	MOVE.L	D2,(A1)+
	ADD.L	#192,D2
	DBF	D1,MAKE
	RTS
**********************
TRACE_LIGNE
;face1
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	LINE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	LINE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	LINE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	LINE
;face2
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	LINE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	LINE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	LINE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	LINE
;lignes 
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	LINE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	LINE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+8,CX2
	MOVE.W	DY+8,CY2
	BSR	LINE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	LINE
;branches de l'etoile
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+16,CX2
	MOVE.W	DY+16,CY2
	BSR	LINE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+16,CX2
	MOVE.W	DY+16,CY2
	BSR	LINE
	MOVE.W	DX+12,CX1
	MOVE.W	DY+12,CY1
	MOVE.W	DX+16,CX2
	MOVE.W	DY+16,CY2
	BSR	LINE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+16,CX2
	MOVE.W	DY+16,CY2
	BSR	LINE
;
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	LINE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	LINE
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	LINE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	LINE
;
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+20,CX2
	MOVE.W	DY+20,CY2
	BSR	LINE
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+20,CX2
	MOVE.W	DY+20,CY2
	BSR	LINE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+20,CX2
	MOVE.W	DY+20,CY2
	BSR	LINE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+20,CX2
	MOVE.W	DY+20,CY2
	BSR	LINE
;
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+22,CX2
	MOVE.W	DY+22,CY2
	BSR	LINE
	MOVE.W	DX+12,CX1
	MOVE.W	DY+12,CY1
	MOVE.W	DX+22,CX2
	MOVE.W	DY+22,CY2
	BSR	LINE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+22,CX2
	MOVE.W	DY+22,CY2
	BSR	LINE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+22,CX2
	MOVE.W	DY+22,CY2
	BSR	LINE
;
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+24,CX2
	MOVE.W	DY+24,CY2
	BSR	LINE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+24,CX2
	MOVE.W	DY+24,CY2
	BSR	LINE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+24,CX2
	MOVE.W	DY+24,CY2
	BSR	LINE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+24,CX2
	MOVE.W	DY+24,CY2
	BSR	LINE
;
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	LINE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	LINE
	MOVE.W	DX+12,CX1
	MOVE.W	DY+12,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	LINE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	LINE
	RTS
****************************ROUTINE DE CALCUL************************************
********************************************************
*precalculs trigonometriques			       *
*en entree:x_angle,y_angle,z_angle(angles de rotation) *	
*en sortie:(A,B,C,D,E,F,G,H,I)*512		       *				
********************************************************


TRIGO
	MOVEM.L	D0-D7/A4-A6,-(SP)
	LEA	COS_TAB,A4
	LEA	SIN_TAB,A5
	LEA	X_ANGLE,A6
	MOVE.W	(A6)+,D2	;d2=x angle
	MOVE.W	(A6)+,D1	;d1=y ...
	MOVE.W	(A6)+,D0	;d0=z ...

	MOVE.W	(A5,D2.W),D5	;d5=sinx
	MOVE.W	(A4,D2.W),D4	;d4=cosx
	MOVE.W	(A5,D1.W),D3	;d3=siny
	MOVE.W	(A4,D1.W),D2	;d2=cosy
	MOVE.W	(A5,D0.W),D1	;d1=sinz
	MOVE.W	(A4,D0.W),D0	;d0=cosz

	LEA	VAR_3D,A6	;zone sauvegarde calc intermediaire
	MOVEQ.W	#9,D7		;nombre de decalages pour/512

	;**********CALCUL DE C************
SP_C
	MOVE.W	D3,D6		;siny
	NEG.W	D6		;-siny	
	MOVE.W	D6,(A6)+
	;**********CALCUL DE F************
SP_F	
	MOVE.W	D2,D6		;cosy
	MULS	D5,D6		;cosy*sinx
	ASR.L	D7,D6		;/512
	MOVE.W	D6,(A6)+
	;**********CALCUL DE I************
SP_I
	MOVE.W	D2,D6		;cosy
	MULS	D4,D6		;cosy*cosx
	ASR.L	D7,D6		;/512
	MOVE.W	D6,(A6)+		
	;**********CALCUL DE A************
SP_A
	MOVE.W	D0,D6		;cosz
	MULS	D2,D6		;cosz*cosy
	ASR.L	D7,D6		
	MOVE.W	D6,(A6)+
	;**********CALCUL DE D************
SP_D
	MOVE.W	D1,D6		;sinz	
	MULS	D4,D6		;sinz*cosx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	ASR.L	D7,D6		
	MULS	D5,D6		;cosz*siny*sinx
	ASR.L	D7,D6
	SUB.W	A4,D6		;(cosz*siny*sinx)-(sinz*cosx)
	MOVE.W	D6,(A6)+
	;**********CALCUL DE G************
SP_G
	MOVE.W	D7,D6		;sinz
	MULS	D5,D6		;sinz*sinx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	ASR.L	D7,D6
	MULS	D4,D6		;cosz*siny*cosx
	ASR.L	D7,D6
	ADD.W	A4,D6		;(cosz*siny*cosx)+(sinz*sinx)
	MOVE.W	D6,(A6)+
	;**********CALCUL DE B************
SP_B
	MOVE.W	D1,D6		;sinz		
	MULS	D2,D6		;sinz*cosy
	ASR.L	D7,D6
	MOVE.W	D6,(A6)+
	;**********CALCUL DE E************
SP_E
	MOVE.W	D0,D6		;cosz
	MULS	D4,D6		;cosz*cosx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny
	ASR.L	D7,D6
	MULS	D5,D6		;sinz*siny*sinx
	ASR.L	D7,D6
	ADD.W	A4,D6		;(sinz*siny*sinx)+(cosz*cosx)
	MOVE.W	D6,(A6)+	
	;**********CALCUL DE H*************
SP_H
	MOVE.W	D0,D6		;cosz
	MULS	D5,D6		;cosz*sinx
	ASR.L	D7,D6	
	MOVE.W	D6,A4

	MOVE.W	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny		
	ASR.L	D7,D6
	MULS	D4,D6		;sinz*siny*cosx
	ASR.L	D7,D6
	SUB.W	A4,D6		;(sinz*siny*cosx)-(cosz*sinx)
	MOVE.W	D6,(A6)+
	MOVEM.L	(SP)+,D0-D7/A4-A6
	RTS
********************************************
*calcul des coordonnees planes		   *
*en entree:xe,ye,ze,z_pt_fuite   	   *
*en sortie:xp,yp coordonnees planes	   *
*new_xe,new_ye,new_ze nouvelles coord sp   *
********************************************

SP_TO_PL
	MOVEM.L	D0-D7/A1-A6,-(SP)		
	LEA	XE,A6
	MOVEM.W	(A6)+,D0-D2
	LEA	XDEP,A3
	MOVEM.W	(A3)+,D3-D5
	MOVEQ.W	#9,D6
	ASL.L	D6,D3		;xdep*512
	ASL.L	D6,D4		;ydep*512
	ASL.L	D6,D5		;zdep*512
	MOVE.L	D3,A1
	MOVE.L	D4,A2
	MOVE.L	D5,A3

	LEA	VAR_3D,A6
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5

	MULS	(A6)+,D3	;d3=c*xe*512
	MULS	(A6)+,D4	;d4=f*ye*512
	MULS	(A6)+,D5	;d5=i*ze*512
	ADD.L	D4,D5		;+f*ye*512
	ADD.L	D3,D5		;+c*xe*512
	ADD.L	A3,D5		;+zdep*512
	MOVE.L	D5,A5		;a5=new_ze*512
	DIVS	Z_PT_FUITE,D5	;d5=new_ze/z_pt_fuite
	
	MOVE.W	#512,D7
	SUB.W	D5,D7		;d7=512*q
				;d7=512*(1-new_ze/z_pt_fuite)
	MOVE.W	D0,D3		;d3=xe
	MOVE.W	D1,D4		;d4=ye
	MOVE.W	D2,D5		;d5=ze

	MULS	(A6)+,D3	;d3=a*xe*512
	MULS	(A6)+,D4	;d4=d*ye*512
	MULS	(A6)+,D5	;d5=g*ze*512
	ADD.L	D4,D5		
	ADD.L	D3,D5
	ADD.L	A1,D5
	MOVE.L	D5,A4		;a4=new_xe*512
	DIVS	D7,D5		;d5=new_xe/q

	MULS	(A6)+,D0	;d0=b*xe*512
	MULS	(A6)+,D1	;d1=e*ye*512
	MULS	(A6)+,D2	;d2=h*ze*512
	ADD.L	D0,D1		
	ADD.L	D1,D2
	ADD.L	A2,D2
	MOVE.L	D2,D6		;d6=new_ye*512
	DIVS	D7,D2		;d2=new_ye/q

	LEA	XP,A6		;A6 pointe sur zone de sauve 
				;coord planes
	ADD.W	XADD,D5
	MOVE.W	D5,(A6)+	;xp
	
	ADD.W	YADD,D2
	MOVE.W	D2,(A6)+	;yp

	MOVEM.L	(SP)+,D0-D7/A1-A6
	RTS

SORTIE
	MOVE.B	SAVE_A09,$FFFFA09
	MOVE.B	SAVE_A07,$FFFFA07	
	MOVE.L	SAVE_HBL,$120.W
	MOVE.B	SAVE_A1B,$FFFFA1B	
	MOVE.B	SAVE_A21,$FFFFA21	
	MOVE.B	SAVE_A13,$FFFFA13	
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.B	#8,$FFFFC02
	MOVE.B	#15,$484
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\LINEROUT\OVER_LIN.S"
	SECTION DATA
OLD_CACR	DC.W	0
SAV_CY1		DC.W	0
IND		DC.B	0
*colors		dc.l	$FFFF00FF,$00600080,$008000A0,$00C000E0
colors		dc.l	$60200060,$80400080,$A06000A0,$C06000C0
AFFECR:		DC.L 	1
WORKECR:	DC.L 	1
OLDXBIOS2:	DC.L	1
OLDMODECODE	DC.W	1
FORME		INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\V.INL"	
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
CURVE		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\LISSAJOU.INL"
SIN_TAB		EQU	COS_TAB+720	
****GRAND CUBE**********
XE1		DC.W	15
YE1		DC.W	15
ZE1		DC.W	-15
;
XE2		DC.W	15
YE2		DC.W	-15
ZE2		DC.W	-15
;
XE3		DC.W	-15
YE3		DC.W	15
ZE3		DC.W	-15
;
XE4		DC.W	-15
YE4		DC.W	-15
ZE4		DC.W	-15
;
XE5		DC.W	15
YE5		DC.W	15
ZE5		DC.W	15
;
XE6		DC.W	15
YE6		DC.W	-15
ZE6		DC.W	15
;
XE7		DC.W	-15
YE7		DC.W	15
ZE7		DC.W	15
;
XE8		DC.W	-15
YE8		DC.W	-15
ZE8		DC.W	15
;
*****************
XE9		DC.W	-100
YE9		DC.W	0
ZE9		DC.W	0
;
XE10		DC.W	100
YE10		DC.W	0
ZE10		DC.W	0
;
XE11		DC.W	0
YE11		DC.W	0
ZE11		DC.W	-100
;
XE12		DC.W	0
YE12		DC.W	0
ZE12		DC.W	100
;
XE13		DC.W	0
YE13		DC.W	-100
ZE13		DC.W	0
;
XE14		DC.W	0
YE14		DC.W	100
ZE14		DC.W	0
;
*****************
CURVE_COMPT	DC.W	0
XADD		DC.W	0
YADD		DC.W	0
XE		DC.W	0
YE		DC.W	0
ZE		DC.W	0
XDEP		DC.W	0
YDEP		DC.W	0
ZDEP		DC.W	-1802
X_ANGLE		DC.W	0
Y_ANGLE		DC.W	0
Z_ANGLE		DC.W	0
X_ANGLE1	DC.W	2
Y_ANGLE1	DC.W	2
Z_ANGLE1	DC.W	2
X_ANGLE2	DC.W	2
Y_ANGLE2	DC.W	2
Z_ANGLE2	DC.W	2
X_ANGLE3	DC.W	2
Y_ANGLE3	DC.W	2
Z_ANGLE3	DC.W	2
SAVE_HBL:	DC.L	0
SAVE_A1B:	DC.B	0
SAVE_A21:	DC.B	0
SAVE_A07:	DC.B	0
SAVE_A09:	DC.B	0
SAVE_A13:	DC.B	0
SAVE_REZ:	DC.W	0
Z_PT_FUITE	DC.W	250
CX1		DC.W	0
CX2		DC.W	0
CY1		DC.W	0
CY2		DC.W	0
SCREEN_ADD	DC.L	0
	SECTION	BSS
DX		DS.W	50
DY		DS.W	50
XP		DS.W	1
YP		DS.W	1
NEW_XE		DS.W	1
NEW_YE		DS.W	1
NEW_ZE		DS.W	1

VAR_3D		DS.W	9
Y_TABLE		DS.L	300
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
SCREEN		DS.W	100000
	END
								 																																																	  																									  																																								  																									  																																								  																								