PBC		equ	$ffe0
HSR		equ	$ffe9
HTX		equ	$ffeb

		org	p:$0
		jmp	debut

		org	p:$40
debut
		move	#-1,m0
		move	#-1,m1
		move	#-1,m2
		move	#-1,m4
		move	#-1,m5
		move	#-1,m6
		move	#$1000,r0
		do	#2500,re_init
		jsr	load
		move	a1,y:(r0)+
re_init
		move	#0,a
		move	#0,b

wait		movep	#1,X:PBC	
		jclr	#0,x:HSR,wait
		move	x:HTX,a1
		move	#0,b1
		cmp	a,b
		jseq	calcul_3D		
		move	#1,b1
		cmp	a,b
		jseq	charge	
		move	#2,b1
		cmp	a,b
		jseq	calcul_stars
		move	#3,b1
		cmp	a,b
		jseq	charge_stars
		jmp	re_init

calcul_3D
		jsr	calcul
		jsr	plans_secants
		jsr	produit_vectoriel

		move	x:$ff,r6
		nop
		move	x:(r6),x1
		jsr	xmit
		move	#$300,r6
		do	x1,fin_transmet
		move	y:(r6)+,x1
		jsr	xmit
		move	y:(r6)+,x1
		jsr	xmit
		move	y:(r6)+,x1
fin_transmet
		move	#20,r0
		nop
		move	x:(r0)+,x1
		jsr	xmit
		do	x1,fin_transmet1
		move	x:(r0)+,x1
		jsr	xmit
fin_transmet1
		move	#40,r0
		nop
		move	x:(r0)+,x1
		do	x1,trans_off
		move	x:(r0)+,x1
		jsr	xmit
		do	x1,trans_off2		
		move	x:(r0)+,x1
		jsr	xmit
trans_off2
		nop
trans_off
		rts

calcul_stars
		jsr	calcul
		move	#$302,r4
		move	#3,n4		
		move	#1,a1
		move	a1,x1
		move	#0,a
		move	x:$ff,r0
		nop
		move	x:(r0),x0
		do	x0,compte_stars
		move	y:(r4)+n4,b
		tst	b
		jpl	nega_stars
		add	x1,a
nega_stars
		nop
compte_stars	
		move	a1,x1
		jsr	xmit

		tst	a
		jeq	send_stars

		move	#$302,r4
		move	#$300,r2
		move	#3,n4		
		move	#1,n2		
		move	#0,a
		move	#3,a1
		move	a1,y1

		move	x:$ff,r0
		nop
		move	x:(r0),x0
		do	x0,send_stars
		move	y:(r4)+n4,b
		tst	b
		jpl	negatif_stars
		move	y:(r2),x1				
		jsr	xmit
		move	y:(r2+n2),x1				
		jsr	xmit
negatif_stars
		move	r2,a1
		add	y1,a
		move	a1,r2			
send_stars
		rts

; calcul attend les valeurs de cos B sin B
; cos C sin C cos A sin A
; puis l increment du Z pour la projection
; puis le coef multiplicateur tjs pour la projection
; enfin l adresse des points a tourner !
calcul
		move	#0,r0
		do	#6,fin_receive_cosinus		
		jsr	load
		move	a1,x:(r0)+
fin_receive_cosinus
		move	#15,r0
		do	#2,fin_receive_coef
		jsr	load
		move	a1,x:(r0)+
fin_receive_coef
		jsr	load
		move	a1,r6	
		jsr	load
		move	a1,x:(r0)+	
		jsr	load
		move	a1,x:(r0)+
		move	#192,n2
		move	#120,n6

		move	#0,r0
		move	#6,r1
		move	#9,r2
		move	#12,r4
		move	#3,r5
		move	#-2,n5
		move	#2,n4

		move	x:(r0)+,x0	 		;cos b
		move	x:(r0)+,x1			;sin b
		move	x:(r0)+,y0			;cos c
		move	x:(r0)+,y1			;sin c
		mpy	x0,y0,a		x1,x:(r4)+	; stock C et calcul A
		mpy	x0,y1,a		a1,x:(r1)+	; stock A et calcul B
		mpy	y0,x1,a		a1,x:(r2)+	; stock B
		move	x:(r0)+,y0			;cos a
		move	x:(r0)+,x1			;sin a
		mpy	-y1,y0,b	a1,y1
		mac	y1,x1,b				
		mpy	x0,x1,b		b1,x:(r1)+	;stock D 
		mpy	x0,y0,b		b1,x:(r4)+	;stock F

		move	#1,r0
		nop
		move	x:(r0)+,y1			; x0=cos c   y0=cos a   x1=sin a  y1=sin b		
		move	x:(r0)+,x0						
		mpy	x1,y1,a		b1,x:(r4)+	; stock I
		mpy	x0,y0,b		
		move	a1,x0		
		move	x:(r5),y1	; charge sin c
		mpy	x0,y1,a
		add	b,a		x:(r5+n5),x0	
		mpy	y1,x1,a		a1,x:(r2)+	; stock E
		move	b1,y1				;x0= sin b  y1=sin c x1=sin a  y0=cos a
		mac     y1,x0,a		x:(r5)-,y1	
		mpy	y1,x0,a		a1,x:(r1)+	; y1=sin c x1= sin a x0=sin b y0=cos a
		move	a1,y1
		mpy	y1,y0,a		x:(r5),y0
		mac	-y0,x1,a
		move	a1,x:(r2)

		move	#$300,r4
		move	r6,x:$ff
		move	#$1000,r0
		move	x:(r6)+,x0
		do	x0,fin_calcul
		move	#6,r1
		move	x:(r6)+,x1
		move	x:(r6)+,y1
		move	x:(r6)+,y0
		move	x:(r1)+,x0
		mpy	x0,x1,a		x:(r1)+,x0
		mac	x0,y1,a		x:(r1)+,x0
		macr	x0,y0,a		x:(r1)+,x0	
		mpy	x0,x1,a		x:(r1)+,x0	a,y:(r4)
		mac	x0,y1,a		x:(r1)+,x0
		macr	x0,y0,a		x:(r1)+,x0
		mpy	-x0,x1,b	x:(r1)+,x0	
		mac	x0,y1,b		x:(r1)+,x0	;y:(r4),y1	; y1= x tourne
		macr	x0,y0,b		x:(r1)+,x1
		move	b1,y:(r4+n4)
		sub	x1,b		;a1,x0				; x0= y tourne
		neg	b			
		move	b1,n0
		move	x:(r1)+,y0					; y0= multiplicateur x/2				
		move	y:(r0+n0),x1					; x1= 1/(z+profondeur)		

		move	x:(r1)+,x0
		move	x:(r1)+,y1
		add	y1,a		y:(r4),b	
		add	x0,b		a1,x0	
		
		mpy	x0,y0,b		b1,y1		
		mpy	y1,y0,a		b0,x0		
		mpyr	x0,x1,b		a0,y1		
		mpyr	y1,x1,a		n2,x1	
		add	x1,a		n6,x1
		add	x1,b

		move	a1,y:(r4)+
		move	b1,y:(r4)+
		move	y:(r4)+,x1
fin_calcul
		rts

charge_stars	
	movep	#1,X:PBC	
	jclr	#0,x:HSR,charge_stars
	move	x:HTX,r0

wait_nb_s	
	movep	#1,X:PBC	
	jclr	#0,x:HSR,wait_nb_s
	move	x:HTX,x0
	move	x0,x:(r0)+
	
	do	x0,fin_charge_s	
	do	#3,fin_charge_s0
	jsr	load
	move	a1,x:(r0)+
fin_charge_s0
	nop
fin_charge_s
	rts

; charge attend le nombre de points a charger
; l adresse du chargement puis les coordonnees

charge	movep	#1,X:PBC	
	jclr	#0,x:HSR,charge
	move	x:HTX,x0

wait_ad	movep	#1,X:PBC	
	jclr	#0,x:HSR,wait_ad
	move	x:HTX,r0
	nop
	move	x0,x:(r0)+
	
	do	x0,fin_charge	
	do	#3,fin_charge0
	jsr	load
	move	a1,x:(r0)+
fin_charge0
	nop
fin_charge
	move	#0,b
	jsr	load		; recois le nb d 'objets
	move	a1,x:(r0)+
	move	#0,a
	jsr	load
	move	a1,x:(r0)+	; recois le nb de plans secants
	cmp	a,b
	jeq	rec_plans

	do	a1,rec_plans
	do	#5,rec_plans0
	jsr	load		; recois 5 valeurs: pour les plans secants
	move	a1,x:(r0)+
rec_plans0
	nop
rec_plans
	jsr	load		;   <---------+
	do	a1,waiting	;             |
	jsr	load		; recois le nb de valeurs pour les
	move	a1,x:(r0)+	; produits vectoriels
waiting
	rts	


	rts

load	movep	#1,X:PBC	
	jclr	#0,x:HSR,load
	move	x:HTX,a1
	rts

xmit	jclr	#1,X:HSR,xmit
	move	x1,X:HTX
	rts



plans_secants
	move	r6,x:$fe
	clr 	a	#0,r0
	move	x:(r6)+,x1
	do	x1,fin_clr
	move	a1,x:(r0)+
fin_clr	
	move	x:(r6)+,x1
	cmp	x1,a
	jeq	un_seul_objet	
	do	x1,fin_calcul_plans
	move	x:(r6)+,r0
	move	x:(r6)+,r1
	move	x:(r6)+,r2
	move	x:(r6)+,r5
	move	x:(r6)+,r4

	move	y:(r2)+,a
	move	y:(r5)+,b
	sub	b,a	
	move	a1,x0
	move	y:(r4)+,a
	sub	b,a	
	move	a1,x1	

	move	y:(r2),a
	move	y:(r5),b
	sub	b,a
	move	a1,y0
	move	y:(r4),a
	sub	b,a	
	move	a1,y1	
	mpy	x0,y1,a
	mac	-x1,y0,a
	tmi	x1,a	r0,r1
	nop
	move	x:(r1),a
	move	#1,r0
	move	r0,x1
	add	x1,a
	move	a1,x:(r1)
fin_calcul_plans
	move	#$ffffff,y1
	move	#20,r5
	move	x:$fe,r1
	nop
	move	x:(r1),b
	move	b1,x:(r5)+
	sub	x1,b	b1,x0
	move	b1,y0
	do	x0,fin_tri1
	move	#0,r1
	move	#0,r2
	move	x:(r1)+,a
	do	y0,fin_tri
	move	x:(r1),b
	cmp	a,b
	tgt	b,a  r1,r2
	move	x:(r1)+,b
fin_tri
	move	r2,x:(r5)+	
	move	y1,x:(r2)
fin_tri1			
	rts							


un_seul_objet
	move	#20,r5
	move	#$1,r1
	move	#$0,r0
	move	r1,x:(r5)+
	move	r0,x:(r5)+
	rts


produit_vectoriel
	move	#2,n2
	move	#2,n5
	move	#2,n4
	move	#3,n6
	move	#40,r0

	move	x:$fe,r1
	nop
	move	x:(r1),x0
	move	x0,x:(r0)+
	do	x0,nb_objet

	move	x:(r6)+,x1
	move	x1,x:(r0)+
	do	x1,nb_face
	move	#0,r1

	move	x:(r6)+,n0
	move	r6,n1
	
	move	x:(r6)+,r2
	move	x:(r6)+,r5
	move	x:(r6)+,r4

	move	y:(r2)+,a
	move	y:(r5)+,b
	sub	b,a	
	move	a1,x0
	move	y:(r4)+,a
	sub	b,a	
	move	a1,x1	

	move	y:(r2),a
	move	y:(r5),b
	sub	b,a
	move	a1,y0
	move	y:(r4),a
	sub	b,a	
	move	a1,y1	
	mpy	x0,y1,a
	mac	-x1,y0,a
	move	#0,b
	move	#12,b0
	sub	b,a
	jmi	invisible
	add	b,a
	asr	a
	move	a0,y:(r1)+

	move	y:(r2)+,a
	move	y:(r5)+,b
	sub	b,a	
	move	a1,x0
	move	y:(r4)+,a
	sub	b,a	
	move	a1,x1	

	move	y:(r2),a
	move	y:(r5),b
	sub	b,a
	move	a1,y0
	move	y:(r4),a
	sub	b,a	
	move	a1,y1	
	mpy	x0,y1,a
	mac	-x1,y0,a
	asr	a	(r6)-n6
	move	a0,y:(r1)+

	move	x:(r6)+,r2
	move	x:(r6)+,r5
	move	x:(r6)+,r4

	move	y:(r2)+n2,a
	move	y:(r5)+n5,b
	sub	b,a	
	move	a1,x0
	move	y:(r4)+n4,a
	sub	b,a	
	move	a1,x1	

	move	y:(r2),a
	move	y:(r5),b
	sub	b,a
	move	a1,y0
	move	y:(r4),a
	sub	b,a	
	move	a1,y1	
	mpy	x0,y1,a
	mac	-x1,y0,a
	asr	a
	move	a0,y:(r1)+
	move	#0,r1
	nop
	move	y:(r1)+,x0
	mpy	x0,x0,a		y:(r1)+,x0
	mac	x0,x0,a		y:(r1)+,x0
	mac	x0,x0,a
	move	#0,r1

; recherche la racine carre de A sur 20 bits resultat ds x0
	move	#0,x0
	move	#%100000000000000000000,x1
	do	#20,fin_racine
	move	x1,b1	
	lsr	b
	move	b1,x1
	move	x0,b1
	or	x1,b
	move	b1,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	fin_racine0
	move	x0,b1
	eor	x1,b
	move	b1,x0
fin_racine0
	nop
fin_racine

	move	#0,b
	move	y:(r1),b1
	and	#$fe,ccr
	rep	#24
	div	x0,b
	move	#0,a
	move	b0,a0
	rep	#9
	asl	a	
	jmp	visible
invisible
	move	#$ffffff,a1
visible
	move	a1,x:(r0)+
	move	#0,a
	move	n1,a1
	move	n0,x1
	add	x1,a
	move	a1,r6
	nop
nb_face
	nop
nb_objet
	rts