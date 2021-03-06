		* Exemple de forme 3D ---> un cube
cube:
	dc.w	8		* 8 points
	dc.w	-100,-100,-100
	dc.w	100,-100,-100
	dc.w	100,100,-100
	dc.w	-100,100,-100
	dc.w	-100,-100,100
	dc.w	100,-100,100
	dc.w	100,100,100
	dc.w	-100,100,100
	
	dc.w	6		* 6 faces
	dc.w	4,1,1		* 4 points dans face No1, couleur 1, test visibilit�e
	dc.w	4,5,6,7
	dc.w	4,2,1		* 4 points dans face No2
	dc.w	7,6,2,3
	dc.w	4,3,1		* 4 points dans face No3
	dc.w	0,1,5,4
	dc.w	4,4,1		* 4 points dans face No4
	dc.w	4,7,3,0
	dc.w	4,5,1		* 4 points dans face No5
	dc.w	1,2,6,5
	dc.w	4,6,1		* 4 points dans face No6, couleur 1
	dc.w	3,2,1,0
	
cube2:
	dc.w	8		* 8 points
	dc.w	-100,-100,-100
	dc.w	100,-100,-100
	dc.w	100,100,-100
	dc.w	-100,100,-100
	dc.w	-100,-100,100
	dc.w	100,-100,100
	dc.w	100,100,100
	dc.w	-100,100,100
	
	dc.w	8		* 8 faces
	
	dc.w	4,1,0
	dc.w	3,7,4,0
	dc.w	4,2,0
	dc.w	0,4,5,1
	dc.w	4,3,0
	dc.w	1,5,6,2
	dc.w	4,4,0
	dc.w	2,6,7,3
	
	dc.w	4,1,0
	dc.w	0,4,7,3
	dc.w	4,2,0
	dc.w	1,5,4,0
	dc.w	4,3,0
	dc.w	2,6,5,1
	dc.w	4,4,0
	dc.w	3,7,6,2

				* un tetraede
tri:
	dc.w	5
	dc.w	0,150,0
	dc.w	-100,0,-100
	dc.w	100,0,-100
	dc.w	100,0,100
	dc.w	-100,0,100
	
	dc.w	5
	dc.w	3,8,1
	dc.w	0,2,1
	dc.w	3,10,1
	dc.w	0,3,2
	dc.w	3,9,1
	dc.w	0,4,3
	dc.w	3,11,1
	dc.w	0,1,4
	dc.w	4,4,1
	dc.w	1,2,3,4
	
carre:
	dc.w	4
	dc.w	-300,-300,-300
	dc.w	-300,-300,300
	dc.w	300,-300,300
	dc.w	300,-300,-300
	dc.w	2
	dc.w	4,10,1
	dc.w	0,1,2,3
	dc.w	4,11,1
	dc.w	3,2,1,0
	
OBJET	MACRO
	dc.l	\1
	dc.w	\2,\3,\4,\5,\6,\7
	endm
	
alliance:
	dc.w	22		;22 points.
*********************
	dc.w	-32,80,-32	;Points No 0
	dc.w	-32,80,32		;Points No 1
	dc.w	32,80,-32		;Points No 2
	dc.w	32,80,32		;Points No 3
	dc.w	112,-80,-32	;Points No 4
	dc.w	112,-80,32	;Points No 5
	dc.w	48,-80,-32	;Points No 6
	dc.w	48,-80,32		;Points No 7
	dc.w	32,-48,-32	;Points No 8
	dc.w	32,-48,32		;Points No 9
	dc.w	-32,-48,-32	;Points No 10
	dc.w	-32,-48,32	;Points No 11
	dc.w	-48,-80,-32	;Points No 12
	dc.w	-48,-80,32	;Points No 13
	dc.w	-112,-80,-32	;Points No 14
	dc.w	-112,-80,32	;Points No 15
	dc.w	-16,-16,-32	;Points No 16
	dc.w	-16,-16,32	;Points No 17
	dc.w	16,-16,-32	;Points No 18
	dc.w	16,-16,32		;Points No 19
	dc.w	0,16,-32		;Points No 20
	dc.w	0,16,32		;Points No 21


	dc.w	17		;17 faces.
*********************
	dc.w	4,1,1	;4 points dans face 9
	dc.w	19,21,20,18

	dc.w	4,1,1	;4 points dans face 10
	dc.w	21,17,16,20
	
	dc.w	4,2,1	;4 points dans face 8
	dc.w	17,19,18,16

	dc.w	4,4,1	;4 points dans face 0
	dc.w	1,3,2,0
	
	dc.w	4,3,1	;4 points dans face 2
	dc.w	5,7,6,4
	
	dc.w	4,3,1	;4 points dans face 4
	dc.w	9,11,10,8
	
	dc.w	4,3,1	;4 points dans face 6
	dc.w	13,15,14,12

	dc.w	4,2,1	;4 points dans face 1
	dc.w	3,5,4,2
	
	dc.w	4,2,1	;4 points dans face 3
	dc.w	7,9,8,6

	dc.w	4,2,1	;4 points dans face 5
	dc.w	11,13,12,10

	dc.w	4,2,1	;4 points dans face 7
	dc.w	15,1,0,14

	dc.w	4,6,1	;4 points dans face 11
	dc.w	16,18,8,10

	dc.w	7,6,1	;7 points dans face 13
	dc.w	0,2,20,16,10,12,14

	dc.w	6,6,1	;6 points dans face 14
	dc.w	2,4,6,8,18,20
	
	dc.w	4,5,1	;4 points dans face 12
	dc.w	11,9,19,17

	dc.w	7,5,1	;7 points dans face 15
	dc.w	1,15,13,11,17,21,3

	dc.w	6,5,1	;6 points dans face 16
	dc.w	7,5,3,21,19,9
	
craft:
	dc.w	14		;14 points.
*********************
	dc.w	0,0,100		;Points No 0
	dc.w	0,10,10		;Points No 1
	dc.w	0,-10,10		;Points No 2
	dc.w	-21,0,10		;Points No 3
	dc.w	19,0,10		;Points No 4
	dc.w	0,19,-21		;Points No 5
	dc.w	0,12,-100		;Points No 6
	dc.w	0,-6,-100		;Points No 7
	dc.w	-12,0,-100	;Points No 8
	dc.w	12,0,-100		;Points No 9
	dc.w	-165,0,-61	;Points No 10
	dc.w	-168,0,-85	;Points No 11
	dc.w	168,0,-85		;Points No 12
	dc.w	168,0,-61		;Points No 13


	dc.w	15		;14 faces.
*********************
	dc.w	3,10,1	;3 points dans face 4
	dc.w	3,1,5

	dc.w	3,10,1	;3 points dans face 5
	dc.w	1,4,5
	
	dc.w	3,3,1	;3 points dans face 0
	dc.w	3,0,1

	dc.w	3,4,1	;3 points dans face 1
	dc.w	0,4,1

	dc.w	3,2,1	;3 points dans face 2
	dc.w	2,0,3

	dc.w	3,3,1	;3 points dans face 3
	dc.w	2,4,0

	dc.w	4,3,1	;4 points dans face 7
	dc.w	8,3,5,6

	dc.w	4,4,1	;4 points dans face 8
	dc.w	4,9,6,5

	dc.w	4,2,1	;4 points dans face 9
	dc.w	7,2,3,8

	dc.w	4,3,1	;4 points dans face 10
	dc.w	4,2,7,9

	dc.w	4,10,1	;4 points dans face 11
	dc.w	9,7,8,6

	dc.w	4,10,0	;4 points dans face 12
	dc.w	3,8,11,10

	dc.w	4,10,0	;4 points dans face 13
	dc.w	4,13,12,9
	
	dc.w	4,10,0	;4 points dans face 12
	dc.w	10,11,8,3

	dc.w	4,10,0	;4 points dans face 13
	dc.w	9,12,13,4


DODE	MACRO	
	DC.W	\1,\2,\3
	ENDM


dodecaedre
	DC.W	20

	DODE	283,631,390
	DODE	458,631,-149
	DODE	0,631,-482
	DODE	-458,631,-149
	DODE	-283,631,390
	DODE	-458,149,631
	DODE	0,-149,780
	DODE	458,149,631
	DODE	742,-149,241
	DODE	742,149,-241
	DODE	458,-149,-631
	DODE	0,149,-780
	DODE	-458,-149,-631
	DODE	-742,149,-241
	DODE	-742,-149,241
	DODE	-283,-631,-390
	DODE	-458,-631,149
	DODE	0,-631,482
	DODE	458,-631,149
	DODE	283,-631,-390


fdodecaedre
	DC.W	12	

	DC.W	5,1,0,0,1,2,3,4
	DC.W	5,2,0,0,4,5,6,7
	DC.W	5,3,0,0,7,8,9,1
	DC.W	5,4,0,1,9,10,11,2
	DC.W	5,1,0,2,11,12,13,3
	DC.W	5,2,0,3,13,14,5,4
	DC.W	5,3,0,12,15,16,14,13
	DC.W	5,4,0,14,16,17,6,5
	DC.W	5,1,0,6,17,18,8,7
	DC.W	5,2,0,8,18,19,10,9
	DC.W	5,3,0,11,10,19,15,12
	DC.W	5,4,0,17,16,15,19,18
	
obj1	OBJET	tri,0,0,-70,0,0,0
obj2	OBJET	cube,0,0,30,0,0,0
obj3	OBJET	cube2,0,0,30,0,0,0
obj4	OBJET	carre,0,0,400,0,0,0
obj5	OBJET	alliance,0,0,30,0,0,0
obj6	OBJET	craft,0,0,30,0,0,0
obj7	OBJET	dodecaedre,0,0,1975,0,0,0

lobj	dc.l	obj1,obj2,obj3,obj4,obj5
	dc.l	obj6,obj7,obj1,obj1,obj1
curobj	dc.l	obj2
