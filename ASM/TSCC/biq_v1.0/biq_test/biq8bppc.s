*******************************************************************************
*                68000 BiQ decoder, 8bpp color, version 1.0                   *
*******************************************************************************
* (c) ray//.tSCc.                                                   2005/2006 *
* eml: ray.tscc.de>                                                           *
* www: http://ray.tscc.de                                                     *
*******************************************************************************
* This program is free software; you can redistribute it and/or modify it     *
* under the terms of the GNU General Public License as published by the Free  *
* Software Foundation; either version 2 of the License, or (at your option)   *
* any later version.                                                          *
*******************************************************************************

DWT_LEVELS	=	6
NUM_COLORS	=	256

		rsreset  		; BiQ header structure
BiQ_ident	rs.l	1
BiQ_type	rs.w	1
BiQ_width	rs.w	1
BiQ_height	rs.w	1
BiQ_palette	rs.b	3*NUM_COLORS
BiQ_coeff	rs.b	0


*******************************************************************************
*  void d_BiQ_8bColor(a0.l * BiQSrc, a1.l * Dst, a2.l * TmpBuffer)
*
* Decode a given BiQ image (type 0x01, 8bpp color mapped). a2.l must point to
* a workbuffer, which has the same size dimensions as the destination image.
*
* Note: This code is by no means optimized for speed!! trashes d0-a6.
*******************************************************************************

		section	text
d_BiQ_8bColor:	cmpi.l	#'_BiQ',(a0)+	; Check ID header
		bne.s	.return

		addq.l	#2,a0		; Skip type record
		movem.w	(a0)+,d1/d2	; Width, Height

		; Skip palette record
		lea.l	BiQ_coeff-BiQ_palette(a0),a0

		movem.l	d1-d2/a1-a2,-(sp)
		bsr.w	d_lz78		; Decode DWT coefficients
		movem.l	(sp)+,d1-d2/a1-a2


		moveq.l	#DWT_LEVELS,d0

.iDWTloop:	movea.l	a1,a3		; Perform one reconstruction pass
		move.w	d1,d3
		move.w	d2,d4

		movem.l	d1-d2/a1-a2,-(sp)
		bsr.s	iDWT
		movem.l	(sp)+,d1-d2/a1-a2

		subq.w	#1,d0		; --numlevels == 0?
		bne.s	.iDWTloop

.return:	rts



******************************************************
*  void iDWT(a3.l * src, a2.l * dst, d3.w width, d4.w height, d0.w level)
*
* Perform a single iDWT pass by recombining the DWT
* coefficients pointed to by a3.l into a2.l.
******************************************************

iDWT:		movem.l	a2-a3,-(sp)

		lsr.w	d0,d4		; height >>= level

		move.w	d4,d5		; a4.l = &src[width * (height >> level)]
		mulu.w	d3,d5
		lea.l	(a3,d5.l),a4

		lea.l	(a2,d3.w),a5	; a5.l = dst2 = &dst[width]

		movea.w	d3,a0		; a0.l = width - (width >>= level)
		lsr.w	d0,d3
		suba.w	d3,a0

		movea.l	a0,a1		; a1.l = 2*width - 2*(width >> level)
		adda.l	a1,a1

		move.w	d4,-(sp)


; Perform 2x2 iDWT

.yloop		swap.w	d4
		move.w	d3,d4

.xloop		move.b	(a3,d3.w),d2	; x1 = src[width >> level]
		move.b	(a4,d3.w),d1	; x3 = src[h*width+(width >> level)]
		move.b	(a4)+,d6	; x2 = src[h*width]
		move.b	(a3)+,d7	; x0 = *src++

		add.b	d7,d2
		add.b	d7,d1
		add.b	d7,d6

		move.b	d7,(a2)+	; *dst++  = x0
		move.b	d2,(a2)+	; *dst++  = x1 + x0
		move.b	d6,(a5)+	; *dst2++ = x2 + x0
		move.b	d1,(a5)+	; *dst2++ = x3 + x0

		subq.w	#1,d4		; I'm not using dbra here for size rasons
		bne.s	.xloop		; (saves one "subq.w #1,dn" in the loop setup)

		adda.l	a0,a3		; src += width - (width>> level)
		adda.l	a0,a4

		adda.l	a1,a2		; dst += (width<<1)-(w<<1)
		adda.l	a1,a5

		swap.w	d4
		subq.w	#1,d4
		bne.s	.yloop


; Copy back reconstructed LL bank into source image (slow like hell)

		move.w	(sp)+,d4	; height *= 2
		add.w	d4,d4

		move.w	d3,d6		; Restore source width
		lsl.w	d0,d6

		add.w	d3,d3		; width  *= 2
		sub.w	d3,d6		; width - 2*(width >> level)

		movem.l	(sp)+,a2-a3

.copy_y		move.w	d3,d5

.copy_x		move.b	(a2)+,(a3)+
		subq.w	#1,d5
		bne.s	.copy_x

		adda.w	d6,a2		; src -= width-2*(width >> level)
		adda.w	d6,a3		; dst -= width-2*(width >> level)

		subq.w	#1,d4
		bne.s	.copy_y

		rts


******************************************************
*  void d_lz78(a0.l * LZ78Stream, a1.l * outputStream)
*
* Variable length LZ78 decoder. Modifies d0-d7/a0-a5.
******************************************************

CODE_BITS	=	12		; Bitwidth of a input stream codeword
MAX_VALUE	=	(1<<CODE_BITS)-1; Termination value
MAX_CODE	=	MAX_VALUE-1	; Maximum code value
STACK_LEN	=	4000		; Length of the decoding stack

d_lz78: 	lea.l	decodeStack,a2
		lea.l	prefixCode,a3
		lea.l	appendChar,a4

		move.w	#256,d5		; Next available code to define

		bsr.s	inputCode	; Read in the first code and initialize
		move.w	d0,d6		; oldCode
		move.b	d0,d7		; char
		move.b	d7,(a1)+

.decodeLoop:	bsr.s	inputCode	; inputCode() == MAX_VALUE?
		cmpi.w	#MAX_VALUE,d0
		beq.s	.return


; Handle special case with string+character+string+character+string

		cmp.w	d5,d0		; newCode >= nextCode?
		blo.s	.normal
		move.b	d7,(a2)+	; *decodeStack++ = char
		move.w	d6,d4	 	; decodeString(decodeStack,oldCode)
		bra.s	.decodeString


; Do a straight decode otherwise

.normal:	move.w	d0,d4		; decodeString(decodeStack,newCode)
.decodeString:	bsr.s	decodeString


; Output string in reverse order

		move.b	(a2)+,d7	; char = *stack
		lea.l	decodeStack,a5

.output:	move.b	-(a2),(a1)+
		cmpa.l	a5,a2
		bhi.s	.output


; Add a new record to the string table if possible

		cmpi.w	#MAX_CODE,d5	; nextCode <= MAX_CODE?
		bhi.s	.next		; yes, go and add new code

		move.w	d5,d4
		add.w	d4,d4
		move.w	d6,(a3,d4.w)	; prefixCode[nextCode] = oldCode
		move.b	d7,(a4,d5.w)	; appendChar[nextCode] = char
		addq.w	#1,d5		; nextCode++

.next:		move.w	d0,d6		; oldCode = newCode
		bra.s	.decodeLoop

.return:	rts


******************************************************
*  a2.l * decodeString(a2.l * stack, d4.w code,
*		       a4.l appendCharTable[],
*		       a3.l prefixCodeTable[])
*
* Return the decoded string to a given code value.
******************************************************

decodeString:	cmpi.w	#255,d4
		bls.s	.break

		move.b	(a4,d4.w),(a2)+	; *stack++ = appendChar[code]
		add.w	d4,d4
		move.w	(a3,d4.w),d4	; code = prefixCode[code]
		bra.s	decodeString

.break: 	move.b	d4,(a2)		; *stack = code
		rts


******************************************************
*  d0.w inputCode(a0.l * inputStream)
*
* Read a variable length bitfield from the packed input
* stream.
******************************************************

inputCode:	lea.l	.bitcount(pc),a5
		move.w	(a5)+,d0	; Load current shift value

		moveq.l #7,d1		; bitcount % 8
		and.w	d0,d1

		lsr.w	#3,d0		; bitcount / 8 (# bytes to read)
		moveq.l #0,d2

.readByte:	lsl.l	#8,d2
		move.b	(a0)+,d2
		subq.w	#1,d0
		bne.s	.readByte

		lsl.l	d1,d2		; Shift input into position and
		or.l	(a5)+,d2	; merge bitfields

		moveq.l #CODE_BITS,d3	; return(bitbuffer >> (32-CODE_BITS))
		rol.l	d3,d2		; Sloooow... (use swap.w + rol.l instead
		move.w	#MAX_VALUE,d0	; for speed)
		and.w	d2,d0

		eor.w	d0,d2		; bitbuffer <<= CODE_BITS
		move.l	d2,-(a5)
		add.w	d3,d1		; bitcount += CODE_BITS
		move.w	d1,-(a5)
		rts

.bitcount:	dc.w 32
.bitbuffer:	dc.l 0


		section bss
prefixCode:	ds.w	1<<CODE_BITS	; Prefix codes
appendChar:	ds.b	1<<CODE_BITS	; Chars appended during the decode
decodeStack:	ds.b	STACK_LEN	; String decode buffer
		even
