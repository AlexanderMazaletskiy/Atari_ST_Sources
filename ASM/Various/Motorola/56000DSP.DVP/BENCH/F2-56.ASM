        page    132,66,2,2
        opt     nomd,nomex,nocex,loc,mu
;*******************************************
;Motorola Austin DSP Operation  June 30,1988
;*******************************************
;DSP56000/1
;Port to Memory FFT - 1024 point
;File name: F2-56.asm
;**************************************************************************
;    Maximum sample rate:  3.332 ms at 20.5 MHZ/ 2.530 ms at 27.0 MHz
;    Memory Size: Prog:  151 words ; Data:  8194 words
;       Number of clock cycles: 68316 (34158 instruction cycles)
;    Clock Frequency:    20.5MHz/27.0MHz
;    Instruction cycle time:  97.5ns /  74.1ns
;**************************************************************************

fftr2fn   macro     data,coef,odata,ptr1,ptr2
fftr2fn   ident     1,0
;
; 1024 Point Complex Fast Fourier Transform Routine
;
; This routine performs a 1024 point complex FFT on external data
; using the Radix 2, Decimation in Time, Cooley-Tukey FFT algorithm.
;
;    Real input and complex output data
;        Real data in X memory
;        Imaginary data in Y memory
;    Normally ordered input data
;    Normally ordered output data
;    Coefficient lookup table
;        -Cosine values in X memory
;        -Sine values in Y memory
;
; Macro Call - fftr2fn  data,coef,odata,ptr1,ptr2
;
;    data       start of external data buffer
;    odata        start of external output data buffer
;    coef    start of sine/cosine table
;    ptr1    location of pointer pointing to data acquisition buffer
;    ptr2    location of pointer pointing to FFT buffer
;
; Radix 2, Decimation In Time Cooley-Tukey FFT algorithm
;             ___________
;            |           | 
; ar,ai ---->|  Radix 2  |----> ar',ai'
; br,bi ---->| Butterfly |----> br',bi'
;            |___________|
;                  ^
;                  |
;                wr,wi
;
;    ar' = ar + wr*br - wi*bi
;    ai' = ai + wi*br + wr*bi
;    br' = ar - wr*br + wi*bi = 2*ar - ar'
;    bi' = ai - wi*br - wr*bi = 2*ai - ai'
;
; Address pointers are organized as follows:
;
;    r0 = ar,ai input pointer n0 = group offset        m0 = modulo (points)
;    r1 = br,bi input pointer n1 = group offset        m1 = modulo (points)
;    r2 = ext. data base address   n2 = groups per pass          m2 = 256 point fft counter
;    r3 = coef. offset each pass   n3 = coefficient base address m3 = linear
;    r4 = ar',ai' output pointer   n4 = group offset        m4 = modulo (points)
;    r5 = br',bi' output pointer   n5 = group offset        m5 = modulo (points)
;    r6 = wr,wi input pointer n6 = coef. offset        m6 = bit reversed
;    r7 = not used (*)        n7 = output pointer storage   m7 = not used (*)
;
;    * - r7 and m7 are typically reserved for a user stack pointer.
;
; Alters Data ALU Registers
;    x1   x0   y1   y0
;    a2   a1   a0   a
;    b2   b1   b0   b
;
; Alters Address Registers
;    r0   n0   m0
;    r1   n1   m1
;    r2   n2   m2
;    r3   n3   m3
;    r4   n4   m4
;    r5   n5   m5
;    r6   n6   m6
;         n7
; Alters Program Control Registers
;    pc   sr
;
; Uses 8 locations on System Stack                                           
;
;
;
;Check r7 to see if input buffer is filled
;
strt move #points,b ;input buffer length
loop move r7,a      ;get input data pointer
     sub  a,b       ;subtract buffer length from current input location
     move x:ptr1,a  ;move input data base addres into a
     cmp  a,b       ;see if equal
     jne  loop      ;if not, go back
;
;    when ready, swap pointers of buffer to be loaded and buffer to be processed
;
     move x:ptr1,a
     move x:ptr2,b
     move b,x:ptr1
     move a,x:ptr2
;
;    main fft routine
;

_points   equ  1024      ;number of FFT points
_intdata  equ  0         ;address of internal data workspace
     move ptr2,r2        ;initialize input pointers
     move r2,r0
     move #_points/4,n0  ;initialize butterflies per group
     move n0,n4          ;initialize pointer offsets
     move n0,n6          ;initialize coefficient offset
     move #coef,n3       ;initialize coefficient base address
     move #_points-1,m0  ;initialize address modifiers
     move m0,m1          ;for modulo(points) addressing
     move m0,m4
     move m0,m5
     move #-1,m3         ;linear addressing for coefficient base offset
     move #0,m2          ;initialize 256 point fft counter
     move m2,m6          ;initialize coefficient address modifier
                         ;for reverse carry (bit reversed) addressing
;                           
; Do first and second Radix 2 FFT passes as four-point butterflies
;
     move           x:(r0)+n0,x0                  ;initialize butterfly
     tfr  x0,a      x:(r0)+n0,y1                  ;

     do   n0,_twopass                             
     tfr  y1,b      x:(r0)+n0,y0
     add  y0,a      x:(r0),x1                     ;ar+cr
     add  x1,b      r0,r4                         ;br+dr
     add  a,b       (r0)+n0                       ;ar'=(ar+cr)+(br+dr)
     subl b,a       b,x:(r0)+n0                   ;br'=(ar+cr)-(br+dr)
     tfr  x0,a      a,x0           y:(r0),b
     sub  y0,a                     y:(r4)+n4,y0   ;ar-cr
     sub  y0,b      x0,x:(r0)                     ;bi-di
     add  a,b                      y:(r0)+n0,x0   ;cr'=(ar-cr)+(bi-di)
     subl b,a       b,x:(r0)                      ;dr'=(ar-cr)-(bi-di)
     tfr  x0,a      a,x0           y:(r4),b
     add  y0,a                     y:(r0)+n0,y0   ;bi+di
     add  y0,b      x0,x:(r0)+n0                  ;ai+ci
     add  b,a                      y:(r0)+,x0     ;ai'=(ai+ci)+(bi+di)
     subl a,b                      a,y:(r4)+n4    ;bi'=(ai+ci)-(bi+di)
     tfr  x0,a                     b,y:(r4)+n4
     sub  y0,a      x1,b                          ;ai-ci
     sub  y1,b      x:(r0)+n0,x0                  ;dr-br
     add  a,b       x:(r0)+n0,y1                  ;ci'=(ai-ci)+(dr-br)
     subl b,a                      b,y:(r4)+n4    ;di'=(ai-ci)-(dr-br)
     tfr  x0,a                     a,y:(r4)+
_twopass
;                                                                   
; Do remaining 8 FFT passes as four 256 point Radix 2 FFT's using internal data
; and external coefficients.
;
; Each 256 point Radix 2 FFT consists of 8 passes.  The first pass uses external
; input data and internal output data to move the data on-chip.  Intermediate
; passes use internal input data and internal output data to keep the data
; on-chip.  The last pass uses internal input data and external output data
; to move the data off-chip.
;
     move #odata,r4      ;load output data address
     do   #4,_end_fft    ;do 256 point fft four times
     move r4,ssh         ;push output data address onto stack
     move r2,r0          ;get external data input address for first pass
     move m2,r3          ;update coefficient offset
     move #256/2,n1      ;initialize butterflies per group
     move #1,n2          ;initialize groups per pass

     do   #7,_end_pass   ;do first 7 passes out of 8
     move #_intdata,r4   ;initialize A output pointer

     move n1,r5
     move n1,n0          ;initialize pointer offsets
     lua  (r5)-,n7

     move n1,n4
     move n1,r6
     lua  (r0)+n0,r1     ;initialize B input pointer
     lua  (r4)+n4,r5     ;initialize B output pointer

     lua  (r6)+,n4
     move n4,n5
     lua  (r3)+n3,r6     ;initialize W input pointer
     move n4,n0
;
;    initialize butterfly
     move           x:(r1),x1      y:(r6),y0      ;lookup -sine value
     move                          y:(r0),b
     mac  x1,y0,b   x:(r6)+n6,x0   y:(r1)+,y1
     macr -x0,y1,b                 y:(r0),a       ;
                
     do   n2,_end_grp
                                                 
     do   n7,_end_bfy
     subl b,a       x:(r0),b       b,y:(r4)
     mac  -x1,x0,b  x:(r0)+,a      a,y:(r5)
     macr -y1,y0,b  x:(r1),x1
     subl b,a       b,x:(r4)+      y:(r0),b
     mac  x1,y0,b                  y:(r1)+,y1     ;Radix 2 DIT butterfly kernel
     macr -x0,y1,b  a,x:(r5)+      y:(r0),a       ;with constant twiddle factor
_end_bfy             
     move (r1)+n1
     subl b,a       x:(r0),b       b,y:(r4)
     mac  -x1,x0,b  x:(r0)+n0,a    a,y:(r5)
     macr -y1,y0,b  x:(r1),x1      y:(r6),y0      ;lookup -sine value
     subl b,a       b,x:(r4)+n4    y:(r0),b
     mac  x1,y0,b   x:(r6)+n6,x0   y:(r1)+,y1
     macr -x0,y1,b  a,x:(r5)+n5    y:(r0),a       ;

_end_grp            
     move n1,b1
     lsr  b    n2,a1               ;divide butterflies per group by two
     lsl  a    b1,n1               ;multiply groups per pass by two
     move      r3,b1     
     lsr  b    a1,n2               ;divide coefficient offset by two
     move      b1,r3
     move      #_intdata,r0        ;intermediate passes use internal input data
_end_pass
;        
; Do last FFT pass and move output data off-chip to external data memory.
;
     move n7,r1
     move ssh,r4
     move (r1)+

     move r1,n0
     move r1,n1          ;correct pointer offset for last pass
     move r1,n4
     move r1,n5

     move #_points/4,n4  ;offset for output pointer A 
     lua (r0)+,r1        ;initialize B input pointer        
     lua  (r4)+n4,r5     ;initialize B output pointer, first step
     move n4,n5          ;offset for output pointer B 
     lua  (r3)+n3,r6     ;initialize W input pointer
     move (r5)+n5        ;initialize B output pointer, second step
     move #0,m4          ;bit-reversed addressing for output pointer A
     move m4,m5          ;bit-reversed addressing for output pointer B
     move           x:(r1),x1      y:(r6),y0
     move (r5)-n5        ;predecrement output pointer A
     move           x:(r5),a       y:(r0),b

     do   n2,_lastpass
     mac  x1,y0,b   x:(r6)+n6,x0   y:(r1)+n1,y1   ;Radix 2 DIT butterfly kernel
     macr -x0,y1,b  a,x:(r5)+n5    y:(r0),a       ;with one butterfly per group
     subl b,a       x:(r0),b  b,y:(r4)            ;and changing twiddle factor
     mac  -x1,x0,b  x:(r0)+n0,a    a,y:(r5)
     macr -y1,y0,b  x:(r1),x1      y:(r6),y0
     subl b,a       b,x:(r4)+n4    y:(r0),b
_lastpass
     move           a,x:(r5)+n5    ;save last real result of these 256
     move      m0,m4               ;reinitialize pointers for modulo addr.
     move      m0,m5               ;    
     move m2,r6                    ;get fft counter
     move n6,n2                    ;get fft data input offset
     move m3,m2                    ;external data pointer uses linear arithmetic
     move (r6)+n6                  ;increment fft counter (bit reversed)
     move (r2)+n2                  ;point to next 256 point fft input data
     move r6,m2                    ;save fft counter
_end_fft
;    when fft is finished, jump back to see if data collection for next fft is completed
     jmp  strt           

     endm
;
;    interrupt routine
     org p:$8
     movep     y:$ffff,y:(r7)+          ;data collection upon interrupt
;
;main routine
     org p:$100
     move #256,a                        ;store pointer to data block 1
     move a,x:3328
     move #1280,a                       ;store pointer to data block 2
     move a,x:3329
     move #2047,m7                      ;set r7 for modulo addressing
;
;    call fft macro
     fftr2fn 1024,256,2304,3330,3328,3329
     
